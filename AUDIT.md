# FluentQuery — Relatório de Auditoria Técnica

**Data:** 2026-07-04
**Escopo:** `Source/` (~15.177 LOC, 40 units de operadores), `Test Delphi/` (~311 métodos DUnitX), manifestos, CI e dependências irmãs (`FluentSQL`/`cquery4d`, `DataEngine`, `ModernSyntax`/`evolution4d`).
**Método:** auditoria orquestrada com 5 subagentes especializados (arquitetura/memória, cobertura/semântica LINQ, testes, qualidade/bugs/performance, dependências/provider DB). Todos os achados citam `arquivo:linha` verificável.

> Este documento é a fotografia do estado atual e o plano de evolução. Não altera código — serve de base para as etapas subsequentes (cada etapa = 1 branch + 1 PR).

---

## 1. Sumário executivo

O **padrão record-como-interface** — a decisão de arquitetura central do projeto — é **sólido e elegante**. Ele resolve genuinamente a limitação do Delphi (interfaces não podem declarar métodos com tipo genérico próprio diferente do da interface) usando um `record` fachada que carrega uma interface ARC-managed num campo, obtendo simultaneamente: (a) assinaturas genéricas livres (`Select<TResult>`, `GroupBy<TKey,TResult>`, `Zip<TSecond,TResult>`) e (b) liberação automática em cascata via ARC, **sem double-free por construção**. A avaliação é **lazy, pull-based, com short-circuit** — LINQ idiomático de verdade. O núcleo in-memory é **standalone** (só RTL); as dependências de DB estão isoladas em 4 units sob `{$DEFINE QUERYABLE}`.

A fundação está correta. O que precisa de evolução:

- **3 bugs críticos** de correção (um deles causa perda silenciosa de dados).
- **Vazamento/posse de memória** em caminhos de fábrica e materialização.
- **Paridade semântica incompleta** com o LINQ do C# (nullable, distinção, estabilidade de ordenação, execução diferida, overloads de comparador).
- **Performance** O(n²) em operadores que já pagaram o custo de um dicionário.
- **Rede de segurança ausente**: não há CI que compile/rode a suíte; testes de DB irreprodutíveis.
- **Higiene**: conflito de licença, código morto, providers JSON/XML vazios, build não reprodutível.

---

## 2. Arquitetura & modelo de memória

### 2.1 O padrão record-como-interface (como está)

```
Fonte (TList<T> / TArray<T> / string / TDictionary)
     │  From() / AsEnumerable()   (Collections.pas / Adapters.pas)
     ▼
IFluentEnumerableBase<T>   ← interface ARC, 1 método GetEnumerator   (FluentQuery.pas:47-50)
     │  embrulhada em
     ▼
IFluentEnumerable<T>  == RECORD fachada ==  { FEnumerator: IFluentEnumerableBase<T> (ARC) }  (FluentQuery.pas:57-242)
     │  .Where(p) → TFluentWhereEnumerable(FEnumerator, p)
     ▼  .Select<R> → TFluentSelectEnumerable(FEnumerator, sel)
IFluentEnumerable<R>  { FEnumerator = nó Select → nó Where → adapter → TList }
     │  TERMINAL (ToList/Count/First/Sum...) chama GetEnumerator → dispara a cadeia pull-based
```

- Interface real ARC minimalista: `IFluentEnumerableBase<T>` (`FluentQuery.pas:47-50`); base abstrata `TFluentEnumerableBase<T>` (`:52-55`).
- Record fachada `IFluentEnumerable<T> = record` (`:57-242`) com campos gerenciados `FEnumerator`/`FComparer` (interfaces) → **managed record clássico** (sem `Initialize/Finalize` explícitos; a finalização vem dos campos-interface).
- Cada operador retorna **um novo record por valor**, embrulhando o nó anterior (`Where` `:452-459`, `Take` `:461-468`, `Select` `:559-566`). Cópia de record faz `_AddRef`; refcount correto.
- Lado DB: `IFluentQueryable<T> = record` (`Queryable.pas:212-217`) segue o mesmo padrão.

**Pontos fortes:** núcleo pequeno e uniforme; composição trivial; sem `try/finally` no código do usuário; sem double-free.

### 2.2 Achados de memória

| Sev | Achado | Local |
|-----|--------|-------|
| 🟠 Alto | **Leak nos `From()`**: `TFluentList/TFluentArray.From` fazem `TFluentInterfacedObject.Create(...).GetEnumerable` sem capturar a interface → refcount 0, objeto órfão vaza a cada chamada. `AsEnumerable` não vaza (o dono é retido pelo chamador). Testes usam `AsEnumerable`, por isso não pegam. | `Collections.pas:264-277,752-760` |
| 🟠 Alto | **`ToArray`/`ToList` destrutivos**: `FList.Clear` após copiar esvazia a fonte; 2ª chamada retorna vazio. Em LINQ é não-destrutivo. | `Collections.pas:724-731` |
| 🟡 Médio | **Dangling latente**: `AsEnumerable` cria `TListAdapter.Create(FList, owns=False)` guardando ponteiro cru; se o `IFluentList` morrer antes do enumerable derivado → AV. Contrato de posse não documentado nem forçado pelo tipo. | `Collections.pas:738-745`; `Adapters.pas:46-56` |
| 🟡 Médio | **`IsNotAssigned`** compara o record inteiro via `TEqualityComparer` binário (compara ponteiros de interface); frágil e caro. Havendo `FIsValid`, bastaria `Result := FIsValid`. | `FluentQuery.pas:2394-2397` |
| 🟢 Baixo | **`TArrayAdapter`** duplica o payload (guarda `FArray` **e** cria um `TList` cópia). | `Adapters.pas:249-253,311-319` |
| 🟢 Baixo | **`Reset` inconsistente**: uns lançam, outros são no-op, outros reiniciam. Contrato não confiável. | `Adapters.pas:194-197,242-245`; `Queryable.pas:1395-1398` |

### 2.3 Múltipla enumeração (provider DB)

`TFluentQueryable<T>.GetEnumerator` **reexecuta a query inteira** a cada enumeração (`Queryable.pas:1291-1299`): `.Any` seguido de `.ToList` = 2 round-trips SQL, sem cache nem garantia de consistência. `Reset` do cursor é no-op.

---

## 3. Bugs de correção

### 🔴 Críticos

| # | Achado | Local | Correção |
|---|--------|-------|----------|
| C1 | **`OrderBy` descarta silenciosamente elementos = `Default(T)`** (`0`, `''`, `nil`). `[3,0,1,0,2].OrderBy` → `[1,2,3]`. A versão correta está comentada logo acima (`:71-86`). Afeta `OrderBy`, `Order`, `OrderDescending`. | `OrderBy.pas:93-97` | Remover o filtro `if not ...Default(T)`; adicionar sempre. |
| C2 | **`ThenBy` reordena só pela chave secundária** com `TList.Sort` (instável), descartando a ordem primária do `OrderBy`. `OrderBy(A).ThenBy(B)` ≈ `OrderBy(B)`. | `ThenBy.pas:108-114` | Comparador composto que usa a ordem anterior como tie-breaker; ordenação estável (índice decorado). |
| C3 | **`WriteLn` de debug em produção** no GroupBy e Parse → em app VCL/FMX/serviço sem console, dispara `EInOutError` (I/O 105). Também força boxing `TValue.From<TKey>` por item. | `GroupBy.pas:248,276`; `Parse.pas:269,285` | Remover os `WriteLn` e o boxing associado. |

### 🟠 Altos

| # | Achado | Local |
|---|--------|-------|
| A1 | **`Intersect` quebra após `Reset`/re-enumeração**: `FSecond.Remove(FCurrent)` drena o dicionário; `Reset` não o reconstrói. 2ª enumeração vem vazia. | `Intersect.pas:147,155-158` |
| A2 | **`GroupBy` muta o `TDictionary` durante a própria enumeração** (`FGroups.Remove` enquanto itera o enumerador do dict) → comportamento indefinido no RTL; inutiliza `Reset`. A variante `<TKey,TElement,TSource>` não faz isso (inconsistência). | `GroupBy.pas:250,285` |

### 🟡 Médios

| # | Achado | Local |
|---|--------|-------|
| M1 | **`Sum(Integer)` overflow silencioso**: acumulador 32-bit, `.inc` não liga `{$Q+}`. `Average(Int32)` acumula em Int64 (inconsistente). | `FluentQuery.pas:698-710,726-738` |
| M2 | **Comparador nil não protegido** em Union/Intersect/Exclude (Distinct protege). `ContainsValue` chamaria `FComparer.Equals(nil)` → AV. Latente. | `Union.pas:103`; `Intersect.pas:99`; `Exclude.pas:99` |
| M3 | **`GetCurrent` sem bound-check** antes do 1º `MoveNext` no OrderBy (SelectMany protege). | `OrderBy.pas:107-110` |
| M4 | **`Where` não valida predicate nil** (outros operadores validam). | `FluentQuery.pas:452` |

---

## 4. Cobertura & correção semântica vs LINQ do C#

### 4.1 Desvios semânticos

| Sev | Desvio | Comportamento C# | Local |
|-----|--------|------------------|-------|
| 🔴 | OrderBy/ThenBy — ver C1/C2 | preserva todos os elementos; ordenação estável e subordinada | `OrderBy.pas:95`; `ThenBy.pas:108` |
| 🟠 | **Ordenações não-estáveis** (`TArray.Sort`/`TList.Sort` = introsort) | `OrderBy`/`ThenBy` garantem estabilidade | `OrderBy.pas:99`; `ThenBy.pas:108` |
| 🟡 | **`Except`(Exclude) não deduplica** | retorna elementos **distintos** | `Exclude.pas:140-152` |
| 🟡 | **`Sum`/`Average` sobre `Nullable` lançam em vazio/tudo-nulo** | `Sum`→0, `Average`→`null`; nunca lançam | `FluentQuery.pas:787-788,978-1005` |
| 🟡 | **Execução imediata onde C# é deferred**: Reverse, Append, Prepend, DefaultIfEmpty, Cast, DistinctBy, UnionBy, IntersectBy, ExcludeBy, TakeLast, SkipLast | deferred (lazy) | `FluentQuery.pas:2190-2481` |
| 🟡 | **GroupBy**: ordem dos grupos = ordem de hash (não 1ª aparição); sem overload de comparer | ordem de primeira aparição; `EqualityComparer<TKey>.Default` | `GroupBy.pas:250,318,382` |
| 🟡 | **`OfType<TResult>` com assinatura não-padrão** (exige `AIsType`+`AConverter`) | sem argumentos; filtra por tipo em runtime | `FluentQuery.pas:1516` |
| 🟡 | **`Cast` eager + `TValue.AsType`** (unit `Cast.pas` está 100% comentada) | deferred; `InvalidCastException` por elemento | `FluentQuery.pas:2253` |
| 🟢 | **`ToLookup` não é `ILookup`** (retorna `TDictionary<TKey,TList>`; posse manual) | `ILookup`; chave ausente → sequência vazia | `FluentQuery.pas:2115` |

### 4.2 Lacunas de operadores / overloads

- **P1 (funcionalidade ausente):** `Chunk` (declarado e desabilitado — "trava o compilador", `FluentQuery.pas:180-181`); geradores `Range`/`Repeat`/`Empty`; `OrderByDescending<TKey>(keySelector[, IComparer])` (só existe `OrderByDesc(TFunc<T,T,Integer>)`).
- **P2 (overloads de igualdade/comparação):** `GroupBy`/`Join`/`GroupJoin`/`Union`/`Intersect`/`Except`/`UnionBy`/`IntersectBy`/`ExceptBy`/`DistinctBy`/`MinBy`/`MaxBy`/`SequenceEqual` **sem overload de `IEqualityComparer`/`IComparer`** — grande buraco vs C#.
- **P3 (menores):** `Where` indexado; `ElementAt(System.Index)`; `Take(Range)`; `Zip` tuple e 3-sequências; `Index()` (.NET 9).

> **Nota de nomenclatura:** aqui `Except` chama-se `Exclude`/`ExcludeBy`; `OrderByDescending` só existe como `OrderByDesc`. Confirmado no código.

---

## 5. Performance

| Sev | Achado | Local |
|-----|--------|-------|
| 🟠 Alta | **O(n²) inútil**: `Union`/`Intersect`/`Exclude` **criam** `TDictionary` com o comparador mas fazem varredura linear em `.Keys` em vez de `ContainsKey` (O(1) pago e jogado fora). `Distinct` usa `TList.Contains` linear. Trocar por `ContainsKey`/`ContainsValue` → O(n). | `Union.pas:134-142`; `Intersect.pas:130-138`; `Exclude.pas:130-138`; `Distinct.pas:124-132` |
| 🟠 Alta | **`Join` O(n·m)** sem hash: re-enumera o inner por item externo. Construir `TDictionary<TKey,TList<TInner>>` uma vez → O(n+m). | `Join.pas:130-158` |
| 🟡 Média | **`GroupBy` chama o KeySelector 3–4× por item** (`ContainsKey`, `[]`, `Add`). Computar `LKey` uma vez. | `GroupBy.pas:241-246,314-316` |
| 🟢 Baixa | `TComparer.Construct` novo por `GetEnumerator` (Order/OrderBy); `Chunk` aloca `TList` por bloco. | `Order.pas:51-58`; `OrderBy.pas:99-103`; `Chunk.pas:123` |

---

## 6. Dependências & provider de banco

- **Mapeamento repo↔units:** `cquery4d` → `FluentSQL.*` (AST `IFluentSQLAST`/`TFluentSQLAST`); `DataEngine` → `DataEngine.FactoryInterfaces` (`IDBConnection`/`TDriverName`); `evolution4d` → `ModernSyntax.*` (`Tuple`).
- **Acoplamento cirúrgico:** só **4 units** tocam as deps (Provider, Queryable, Expression, Parse), todas sob `{$DEFINE QUERYABLE}`. Fachada + 36 operadores usam só RTL + `FluentQuery.Core`. **Desligando `QUERYABLE`, o núcleo compila com zero deps de terceiros.** → recomenda-se declarar as deps como **opcionais**.
- **Dois mundos:** `IFluentEnumerable` (in-memory, lambdas reais) × `IFluentQueryable` (100% SQL). **Não há tradução lambda→SQL**: o `Where` do queryable recebe string / `array of const` / `IFluentQueryExpression` (builder explícito `.Field('idade').GreaterThan(18)`). Operadores "de coleção" (SelectMany, Zip, GroupJoin, Concat, *Indexed, TakeWhile/SkipWhile por predicado) **não** têm tradução SQL — só existem in-memory.
- **Segurança (médio):** valores string interpolados no SQL via `QuotedStr` (`Expression.pas:261,297`) — mitiga aspas simples, mas **não é parametrização** (sem bind params). Superfície de SQL-injection para entrada não confiável.
- **JSON/XML providers = stubs vazios (0%)**: `FluentQuery.Json*.pas`/`Xml*.pas` só declaram interfaces vazias; o XML **repete o mesmo GUID** do JSON (`{6ED58176-...}`). Não implementados.

---

## 7. Testes & CI

- **Contagem real:** ~311 métodos `[Test]` (ArrayStatic 50, ArrayT 57, List 57, Dictionary 83, CQL 46, String 18). Zero `[TestCase]` (nada data-driven).
- **🔴 Sem CI de testes:** único workflow (`deploy-docs.yml`) só publica Docusaurus. Nenhum compila/roda DUnitX. `dunitx-results.xml` versionado é obsoleto/parcial (só 18 casos String, de outra máquina).
- **🔴 CQL irreprodutível:** `Setup` usa caminho absoluto hard-coded `D:\PROJETOS-4D\FLUENT4D\...\CLIENTES.FDB` (`CQL.pas:163`, nem é o `.FDB` do repo) + `FDConnection.Open` a Firebird vivo → 100% falham no `Setup` sem servidor, **inclusive** testes que só validam a string SQL.
- **Ponto forte:** detecção de leaks real (FastMM4 + `DUnitX.MemoryLeakMonitor.FastMM4` + `ReportMemoryLeaksOnShutdown`) — reprova teste que vazar. Asserts majoritariamente significativos (conteúdo posicional, não só não-nulo). Exceções esperadas cobertas em `Single`/`ElementAt`.
- **Ponto fraco:** testes "Lazy" **não testam laziness** (só `Writeln`, sem assert; com mojibake de encoding). **Empty-collection edge cases quase ausentes** (`First`/`Single`/`Aggregate`/`Min`/`Max`/`Average` sobre `[]`). Operadores sem teste: `Cast`, `Order`/`OrderDescending`, `ThenBy` em coleções (só SQL), `Append`/`Prepend`, `DefaultIfEmpty`, `SkipLast`/`TakeLast`, `UnionBy`/`IntersectBy`/`ExcludeBy`, `AggregateBy`/`CountBy`, `ToHashSet`/`ToLookup`, overloads Nullable/Currency/Int64 de Sum/Average/Min/Max.

---

## 8. Higiene & build

- **Conflito de licença:** headers `.pas` dizem **MIT** (ex. `Distinct.pas:6`), `FluentQuery.inc:4-18` diz **Apache 2.0**. Resolver para uma só.
- **Código morto:** `Cast.pas` 100% comentado (unit publicada vazia); `Chunk.pas:53-90` comentado; construtor antigo em `OrderBy.pas:71-86`.
- **`remove_extra_headers.py`** em `Source/` com caminho absoluto hard-coded (`d:\Ecossistema-Delphi\FluentQuery\Source`) que nem corresponde ao repo — script de manutenção destrutivo dentro da pasta distribuível. Mover para `tools/` ou remover.
- **Build não reprodutível:** `boss-lock.json` vazio (`installedModules: {}`) + versões `^0` (pré-1.0). Manifestos divergentes (`boss.json` × `pubpascal.json`: nomes e versões inconsistentes). Plataformas declaradas só `Win32/Win64` apesar do núcleo ser portável (há trabalho em Linux — commit `49d0a92`).

---

## 9. Plano de evolução (cada etapa = 1 branch + 1 PR)

1. **Correções críticas** — C1 (OrderBy), C2 (ThenBy), C3 (WriteLn) + testes que os provam. *Baixo risco, altíssimo valor.*
2. **Memória** — leak dos `From`, `ToArray/ToList` não-destrutivo, `Intersect.Reset` (A1), mutação do dict no GroupBy (A2).
3. **Performance** — set-ops O(n²)→O(n), `Join` com lookup por chave, `Sum` Int64.
4. **Paridade semântica** — nullable Sum/Average, Except distinct, estabilidade de ordenação, overloads de `IEqualityComparer`/`IComparer`, execução diferida, `OfType`/`Cast` idiomáticos. *(guiado pela referência de semântica LINQ do C#.)*
5. **Infra de testes** — workflow CI (Windows/DUnitX), desacoplar CQL do Firebird (SQL-string vs execução; caminho relativo; credenciais por env), edge cases de coleção vazia, testes de laziness reais.
6. **Operadores faltantes** — `Chunk`, geradores `Range`/`Repeat`/`Empty`.
7. **Higiene** — licença única, remover código morto, decisão sobre JSON/XML, deps opcionais no manifesto, popular `boss-lock`, ampliar plataformas.

Pós-plano: avaliação de **rebranding** do projeto (nome mais aderente ao propósito, sem risco legal).

---

## Anexo — Incertezas a confirmar empiricamente

- Leak dos `From`: confirmar com caso mínimo `TFluentList<Integer>.From(L)` + `ReportMemoryLeaksOnShutdown := True` (não há teste exercitando `From` direto).
- C1/C2: testes com `[3,0,1,0,2]` (zeros somem?) e `OrderBy(A).ThenBy(B)` com dataset onde a ordem por A difere de B.
- Semântica de `TEqualityComparer<record>.Default` em `IsNotAssigned` depende da versão do RTL.
