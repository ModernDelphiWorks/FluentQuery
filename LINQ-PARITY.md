# Referência de Semântica LINQ (C#) para paridade no FluentQuery

**Fonte da verdade:** `System.Linq.Enumerable` (LINQ to Objects), confirmado contra `learn.microsoft.com` e o *reference source*. Este documento guia as correções de paridade (Etapa 4 do plano em `AUDIT.md`). Cada seção traz: **(A)** regra exata do C#, **(B)** por que importa, **(C)** recomendação Delphi + meio-termo aceitável.

Convenções: `Default(T)` = 0/`nil`/`''`/record zerado. Igualdade padrão C# = `EqualityComparer<T>.Default` ≈ `TEqualityComparer<T>.Default` (`System.Generics.Defaults`). Ordenação padrão = `Comparer<T>.Default` ≈ `TComparer<T>.Default`.

---

## 1. OrderBy / OrderByDescending — estabilidade

**(A)** Ordenação **ESTÁVEL**: chaves iguais preservam a ordem original relativa (*"if the keys of two elements are equal, the order of the elements is preserved"*). **Deferred não-streaming** (materializa tudo no 1º `MoveNext`; nada roda até enumerar). Chave via `Comparer<TKey>.Default` ou o `IComparer` fornecido. Vazio → vazio (não lança). `null` como chave = "menor que qualquer valor".

**(B)** Estabilidade é contrato observável (ordenações multi-nível em passadas separadas, UI determinística). O RTL do Delphi (`TArray.Sort`/`TList.Sort`) é **introsort — NÃO estável** → tradução ingênua embaralha empates e diverge silenciosamente.

**(C)** **Decore cada elemento com seu índice original** e use-o como desempate final:
```
Result := KeyCompare(a, b);
if Result = 0 then Result := a.Index - b.Index;  // estabilidade emulada
```
Custo O(1) por comparação, mesmo O(n log n). Não trocar por merge sort. Esse array decorado é a base natural do `ThenBy` (§2).

---

## 2. ThenBy / ThenByDescending — ordenação subordinada

**(A)** Só existe sobre `IOrderedEnumerable<T>` (retorno de `OrderBy`). **Subordina**: nova chave desempata **apenas** elementos cujas chaves anteriores são todas iguais. Estável, deferred não-streaming. `OrderBy(k1).ThenBy(k2).ThenBy(k3)` = ordenação lexicográfica por `(k1,k2,k3)` e, por fim, pela posição original. **`OrderBy(k1).ThenBy(k2)` ≠ `OrderBy(k1)` seguido de `OrderBy(k2)`** (este descartaria k1).

**(B)** Implementar `ThenBy` como "reordena pela 2ª chave" **destrói** a ordem primária — bug clássico (é exatamente o bug C2 do `AUDIT.md`).

**(C)** Modele a **cadeia de critérios** `(KeySelector, Comparer, Descending)` e ordene UMA vez com o comparador composto:
```
for crit in Criterios do begin
  c := crit.Comparer.Compare(crit.Key(a), crit.Key(b));
  if crit.Descending then c := -c;
  if c <> 0 then Exit(c);
end;
Exit(a.OriginalIndex - b.OriginalIndex);  // estabilidade da cadeia toda
```
`OrderBy`/`ThenBy` retornam objeto novo (imutável/copy-on-write) que anexa um critério. Paridade 1:1 barata.

---

## 3. Except / Intersect / Union / Distinct — distinção, igualdade, ordem

**(A)** Todos retornam elementos **distintos**, usam `EqualityComparer<T>.Default` (overload aceita `IEqualityComparer<T>`), são **deferred** e usam **hashset → O(n+m)**, não O(n²).

| Operador | Produz | Ordem de emissão | Streaming |
|---|---|---|---|
| `Distinct()` | distintos de source | 1ª aparição | streaming |
| `Union(a,b)` | distintos de a, depois de b não vistos | 1ª aparição | streaming |
| `Intersect(a,b)` | distintos em ambos | ordem de **a** | a streaming, **b bufferizado** |
| `Except(a,b)` | distintos de a que não estão em b | ordem de a | a streaming, **b bufferizado** |

`Intersect`/`Except` carregam **b inteiro num set ANTES** de emitir; `a` em streaming. `null` é elemento válido (entra no set uma vez).

**(B)** Riscos: perder "primeira aparição" (ordem previsível); implementar com busca linear → **O(n²)** (armadilha nº1 em ports de LINQ — é o achado de performance do `AUDIT.md`).

**(C)** `TDictionary<T,Byte>` como hashset com `TEqualityComparer<T>.Default` (ou fornecido):
- `Distinct`: `if seen.TryAdd(item,0) then yield item`.
- `Union`: set compartilhado entre a e b, emite na ordem de leitura.
- `Intersect`: carregue b num set; percorra a, emitindo se está em b **e** ainda não emitido (2º set de emitidos).
- `Except`: carregue b num set; percorra a, emitindo se **não** está em b e ainda não emitido.
- Sempre passe o comparer ao `TDictionary` (respeita `GetHashCode`/`Equals` custom).

Meio-termo: para tipos sem bom `GetHashCode` default (records complexos), exija comparer explícito nesses casos em vez de degradar para O(n²) silenciosamente.

---

## 4. Sum / Average — matriz nullable vs não-nullable

**(A)** **Immediate**. Diferença crítica entre overloads:

| Operação | Vazia | Toda-`null` (nullable) | Nulls no meio |
|---|---|---|---|
| `Sum` (não-nullable) | **0** | — | — |
| `Sum` (int?/double?/…) | **0** (não `null`!) | **0** (não `null`!) | ignora nulls, soma o resto |
| `Average` (não-nullable) | **lança `InvalidOperationException`** | — | — |
| `Average` (nullable) | **retorna `null`** | **retorna `null`** | ignora nulls, média do resto |

- **`Sum` nunca retorna `null`**, mesmo nullable — vazio/tudo-null = **0**.
- **`Average` nullable = `null`** em vazio; **não-nullable LANÇA** em vazio.
- Tipo de retorno de `Average`: `int`/`long`→`double`; `int?`→`double?`; `decimal`→`decimal`. Média de inteiros é ponto flutuante.
- **Overflow**: `Sum` de inteiros é **checked** → `OverflowException`; `double` não estoura (`Infinity`/`NaN`).

**(B)** Desvio mais traiçoeiro: `Average` de lista vazia retornando 0 (em vez de lançar/`null`) corrompe cálculos financeiros sem erro visível; `Sum` nullable retornando `null` quebra `total := query.Sum(...)`.

**(C)** Dois conjuntos de sobrecargas (há `ModernSyntax.Nullable` disponível):
- `Sum`/`Average` sobre `T` numérico: `Sum` vazio=0; `Average` vazio = `raise EInvalidOpException.Create('Sequence contains no elements')`.
- `Sum`/`Average` sobre `Nullable<T>`: descartar sem-valor; `Sum` vazio/tudo-null = `Nullable<T>`(0); `Average` vazio/tudo-null = `Nullable` vazio.
- `Average` acumula em `Double` para inteiros.
- Overflow: acumular `Sum` de inteiros em **Int64** (evita a maioria dos estouros práticos); replicar `OverflowException` byte-a-byte não vale o custo salvo exigência.

Meio-termo: pode oferecer `AverageOrDefault`/overload que devolve `Nullable`, mas **não** mudar o `Average` canônico para "retornar 0".

---

## 5. First / Single / Last vs *OrDefault

**(A)** Todos **immediate**; exceção = `InvalidOperationException`.

| Método | Vazio | Sem match (pred) | Mais de um |
|---|---|---|---|
| `First()` / `First(pred)` | **lança** "no elements" | **lança** "no matching element" | ok |
| `FirstOrDefault(...)` | `Default(T)` | `Default(T)` | ok |
| `Last()` / `Last(pred)` | **lança** | **lança** | ok |
| `LastOrDefault(...)` | `Default(T)` | `Default(T)` | ok |
| `Single()` | **lança** "no elements" | — | **lança** "more than one element" |
| `Single(pred)` | lança | **lança** "no matching" | **lança** "more than one matching" |
| `SingleOrDefault()` | `Default(T)` | — | **ainda LANÇA** "more than one" |
| `SingleOrDefault(pred)` | `Default(T)` | `Default(T)` | **ainda LANÇA** |

**Ponto crítico:** `OrDefault` só neutraliza **vazio/sem-match**. **NÃO** neutraliza o "mais de um" do `Single` — `SingleOrDefault` continua lançando com 2+ elementos.

**(B)** `Single` é **asserção de unicidade**. `SingleOrDefault` que retorna o 1º quando há vários mascara violação de invariante ("deveria haver exatamente um").

**(C)** Duas famílias com as **mesmas mensagens**. `Single` lê **no máximo 2 elementos** (curto-circuito). `Last` varre até o fim (otimizável se a fonte for indexável). Nenhum meio-termo — a semântica de lançamento é o próprio contrato.

---

## 6. GroupBy

**(A)** **Deferred não-streaming** (lê tudo para formar grupos). Retorna `IEnumerable<IGrouping<TKey,TElement>>`. Usa `EqualityComparer<TKey>.Default` (overload de comparer). **Ordem dos grupos = 1ª aparição da chave**; **ordem interna = original (estável)**. Overloads: `keySelector`; `+elementSelector`; `+resultSelector(key, elementos)`; combinação. Chave `null` = um grupo. Vazio → zero grupos.

**(B)** Ordem por 1ª aparição e ordem interna estável são observáveis (relatórios). Usar "ordem de hash" do dicionário diverge e vira não-determinismo (é o achado M do GroupBy no `AUDIT.md`).

**(C)** `TLookup` emulada: `TDictionary<TKey, TList<TElement>>` **+ lista auxiliar de chaves na ordem de inserção** (o `TDictionary` do Delphi não preserva ordem). Ao ler item: se chave nova, acrescente à lista-de-ordem; adicione elemento à `TList` do grupo. Na emissão, percorra a **lista-de-ordem**. Passe o comparer ao `TDictionary`. Mantenha o gatilho **deferred** (nada roda até a 1ª enumeração). **Compute a chave uma vez por item** (não 3-4×).

---

## 7. Deferred vs Immediate — classificação canônica

**DEFERRED — STREAMING:** `Select`, `SelectMany`, `Where`, `Take`, `TakeWhile`, `Skip`, `SkipWhile`, `Distinct`, `Union`, `Concat`, `Cast`, `OfType`, `DefaultIfEmpty`, `Range`, `Repeat`, `AsEnumerable`, `Append`, `Prepend`, `Zip`, `Select` indexado.

**DEFERRED — NÃO-STREAMING** (bufferizam TUDO no 1º `MoveNext`, mas nada roda antes de enumerar): **`OrderBy`, `OrderByDescending`, `ThenBy`, `ThenByDescending`, `Reverse`, `GroupBy`**; `TakeLast`/`SkipLast`/`Chunk` (buffer por natureza).

**DEFERRED com 2ª sequência bufferizada:** `Except`, `Intersect`, `Join`, `GroupJoin` — *"it is always the first sequence that is evaluated in a deferred, streaming manner"*.

**IMMEDIATE (terminais):** `ToList`, `ToArray`, `ToDictionary`, `ToLookup`, `Count`, `LongCount`, `Sum`, `Average`, `Min`, `Max`, `Aggregate`, `Any`, `All`, `Contains`, `First*`, `Last*`, `Single*`, `ElementAt*`, `SequenceEqual`.

**(B)** Deferred/immediate define **quando** selectors/predicados/efeitos rodam, quantas passadas na fonte, e se re-enumerar reflete mudanças. Materializar cedo demais muda semântica de re-enumeração e custo. É diferença comportamental, não só de performance. → é o achado "eager onde C# é deferred" do `AUDIT.md`.

**(C)** Sem `yield return`: **enumeradores manuais encadeados**. Cada operador deferred retorna `IFluentEnumerable<T>` cujo `GetEnumerator` encapsula o da fonte e transforma **em `MoveNext`** (nada de materializar no construtor). Não-streaming (`OrderBy`/`GroupBy`/`Reverse`): objeto deferred, mas **1º `MoveNext` materializa** a fonte e processa. Cada `GetEnumerator` reprocessa da fonte (não cachear resultado).

Meio-termo mínimo aceitável: terminais corretos + garantir que `OrderBy`/`GroupBy` não rodem antes da enumeração. O desvio mais grave a corrigir é qualquer **operador não-terminal que execute imediatamente**.

---

## 8. Cast vs OfType

**(A)** Ambos **deferred streaming**, partem de `IEnumerable` não-genérico → `IEnumerable<TResult>`.
- **`Cast<TResult>()`**: converte **cada** elemento; se não for do tipo, **lança `InvalidCastException`** por elemento, na enumeração. Se a fonte já é `IEnumerable<TResult>`, retorna-a direto. `null` passa para tipos de referência/nullable.
- **`OfType<TResult>()`**: **sem argumentos**; **filtra por tipo em runtime** (`x is TResult`), descartando silenciosamente incompatíveis e `null` (value-type). Nunca lança por tipo. Fonte incompatível → sequência vazia.

**(B)** Confundir inverte o contrato: `Cast` que filtra esconde dados malformados; `OfType` que lança quebra coleções mistas. Comportamento **por elemento** e **na enumeração** importa. → achados "OfType assinatura não-padrão" e "Cast eager/comentado" do `AUDIT.md`.

**(C)** Type erasure do Delphi: via `TValue`/RTTI (`System.Rtti`). `OfType`: testar `TypeInfo(TResult)` — classes: `item.IsObject and (item.AsObject is TResult)`; `TValue`: `item.TryAsType<TResult>(v)` — só emitir se passar. `Cast`: mesma travessia, mas `raise EInvalidCast` na falha. Ambos lazy.

Meio-termo (paridade total é cara): quando a coleção é fortemente tipada (`TList<TBase>` de objetos — caso comum), o cenário realista é downcast de hierarquia → use `is`/`as` de objetos, barato. Reserve `TValue`/RTTI para coleções genuinamente heterogêneas. Documente que `OfType` para value-types exige RTTI (custo, caso de nicho).

---

## 9. Zip

**(A)** **Deferred streaming**. **Trunca no MENOR** (nunca lança por tamanhos diferentes). Overloads: (1) `Zip(first, second, resultSelector)`; (2) .NET 6+ `Zip(first, second)` → `IEnumerable<(T1,T2)>` (tuplas); (3) .NET 6+ `Zip(first, second, third)` → tripla, trunca no menor dos três. Enumera em paralelo, para no 1º `MoveNext` falso.

**(B)** "Trunca no menor" é o esperado; lançar por tamanho diferente ou preencher com `default` (padding) diverge. Streaming importa para fontes infinitas/custosas.

**(C)** Enumerador que segura os enumeradores e avança todos; se qualquer um falhar, encerra. Sem `ValueTuple` nativo: priorize o overload **com `resultSelector`** (`TFunc<T1,T2,TResult>`) como canônico; para "sem selector", retorne record `TZipPair<T1,T2>`/`TPair` (e `TZipTriple` para 3). Meio-termo: o mínimo é o overload com `resultSelector` (cobre 100% funcionalmente); tuplas são açúcar.

---

## 10. Geradores estáticos — Range / Repeat / Empty

**(A)**
- **`Range(start, count)`**: `count` inteiros consecutivos de `start` (`start..start+count-1`). Deferred streaming. `count=0`→vazio. **Lança `ArgumentOutOfRangeException`** se `count<0` ou `start+count-1 > int.MaxValue`. Só `int`. **`Range(1,5)` = `{1,2,3,4,5}`** (contagem, não intervalo!).
- **`Repeat(element, count)`**: mesmo elemento `count` vezes. Deferred streaming. `count=0`→vazio. Lança se `count<0`. `element` pode ser `null`.
- **`Empty<TResult>()`**: sequência vazia; .NET cacheia um array vazio singleton por tipo (otimização, não observável).

**(B)** Pontos de entrada de pipelines. Erros comuns: aceitar `count<0` silenciosamente; interpretar o 2º arg como fim em vez de contagem.

**(C)** Métodos de classe estáticos (`TFluentQuery.Range/.Repeat/.Empty<T>`):
- `Range`: validar `ACount>=0` e `AStart+ACount-1 <= High(Integer)`, senão `raise EArgumentOutOfRangeException`; gerar **lazy**.
- `Repeat<T>`: validar `ACount>=0`; enumerador lazy.
- `Empty<T>`: enumerável vazio (cache singleton opcional).
- Manter `Range` estritamente como **contagem**; se houver método de intervalo, nomear diferente (`RangeTo`) para não confundir.

---

## Prioridade dos desvios a corrigir

1. **OrderBy/ThenBy sem estabilidade** → decorar com índice original (§1, §2).
2. **SingleOrDefault que não lança em 2+** → deve continuar lançando (§5).
3. **Average vazio** → não-nullable lança; nullable `null`; nunca "0" (§4).
4. **Sum nullable retornando null** → deve retornar 0 (§4).
5. **Set ops O(n²)** → hashset com default comparer, preservando 1ª aparição (§3).
6. **Operadores não-terminais executando imediatamente** → deferred; OrderBy/GroupBy bufferizam só no 1º MoveNext (§7).
7. **Cast vs OfType trocados** → Cast lança por elemento; OfType filtra silenciosamente (§8).

---

## Fontes (Microsoft Learn)

- OrderBy (stable sort): https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.orderby
- ThenBy: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.thenby
- Classification by manner of execution (deferred streaming/non-streaming/immediate): https://learn.microsoft.com/en-us/dotnet/visual-basic/programming-guide/concepts/linq/classification-of-standard-query-operators-by-manner-of-execution
- Distinct: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.distinct
- Union: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.union
- Intersect: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.intersect
- Except: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.except
- Set operations (LINQ): https://learn.microsoft.com/en-us/dotnet/csharp/linq/standard-query-operators/set-operations
- Average: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.average
- Sum: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.sum
- Single/SingleOrDefault: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.singleordefault
- GroupBy: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.groupby
- Grouping data (LINQ): https://learn.microsoft.com/en-us/dotnet/csharp/linq/standard-query-operators/grouping-data
- Cast: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.cast
- OfType: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.oftype
- CA2021 (Cast/OfType incompatible types): https://learn.microsoft.com/en-us/dotnet/fundamentals/code-analysis/quality-rules/ca2021
- Zip: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.zip
- Range: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.range
- Repeat: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.repeat
- Empty: https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable.empty
