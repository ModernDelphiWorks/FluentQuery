# LQ-Colligo — LINQ-style fluent collections & DB query library for Delphi

[![Delphi XE+](https://img.shields.io/badge/Delphi-XE%20or%20superior-blue.svg)]()
[![Lazarus Compatible](https://img.shields.io/badge/Lazarus-Compatible-orange.svg)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CRA-ready](https://img.shields.io/badge/CRA--ready-SBOM%20%2B%20Security%20policy-success)](https://www.pubpascal.dev/packages/lq-colligo)

> 🔒 **Supply-chain transparency (CRA-ready):** a machine-readable **SBOM** (CycloneDX) is published on the package portal — [pubpascal.dev/packages/lq-colligo](https://www.pubpascal.dev/packages/lq-colligo) · security disclosure policy in **[SECURITY.md](SECURITY.md)**.

> 💡 **Inspired by LINQ.** LQ-Colligo is a Delphi/Lazarus re-imagining of **C# LINQ to Objects** (`System.Linq`). Its operator set, deferred/immediate execution semantics, and edge-case behaviour deliberately mirror LINQ so that experience transfers directly.

📚 **[Documentation](https://moderndelphiworks.github.io/LQ-Colligo/)** · ⬇️ **[Download](../../releases)** · 🐛 **[Issues](../../issues)**

*   [🇬🇧 English](#-english)
*   [🇧🇷 Português](#-português)

---

## 🇬🇧 English

**LQ-Colligo** is a high-performance functional-programming and collection-manipulation library for Delphi and Lazarus, heavily inspired by **C# LINQ** and the stream-processing APIs found in Java, Kotlin, and Rust. It introduces powerful record-based structures (`ILQColligoEnumerable<T>` and `ILQColligoQueryable<T>`) designed to query, filter, map, order, and aggregate in-memory collections and datasets. By employing **Lazy Evaluation** (deferred execution), LQ-Colligo avoids intermediate object allocations, ensuring exceptional CPU speed and a minimal memory footprint.

### 🚀 Key Features

*   **Fluent & Chainable API:** Write highly expressive, readable queries using method chaining (e.g., `Filter().Take().Select().ToArray()`).
*   **Lazy Evaluation:** Data pipelines execute only when a terminal operator (such as `ToArray`, `ToList`, or `First`) is triggered, avoiding unnecessary intermediate array allocations.
*   **Zero-Allocation Core:** Leverages lightweight Delphi record interfaces, eliminating the typical heap-allocation overhead.
*   **Comprehensive LINQ-Like Operators:**
    *   *Filtering:* `Where`, `OfType`, `Cast`, `Distinct`, `Exclude`
    *   *Projections:* `Select`, `SelectIndexed`, `SelectMany`
    *   *Partitioning:* `Take`, `TakeWhile`, `Skip`, `SkipWhile`, `Chunk`
    *   *Ordering:* `OrderBy`, `ThenBy` (Ascending and Descending)
    *   *Set Operations:* `Union`, `Intersect`, `Concat`
    *   *Joins & Zipping:* `Join`, `GroupJoin`, `Zip`
    *   *Aggregations:* `First`, `FirstOrDefault`, `Last`, `Any`, `All`, `Count`, `Sum`, `Average`
*   **Extensible Format Providers:** Native integration with standard Delphi collections (`TList<T>`, `TArray<T>`), JSON datasets, and XML documents.

### 🏛 Compatibility Matrix

| Environment / IDE | Platform / Compiler | Lazy Evaluation | Zero-Allocation Record Core |
| :--- | :--- | :---: | :---: |
| **Delphi XE or superior** | VCL, FMX, Console (ARC & Non-ARC) | ✅ Yes | ✅ Yes |
| **Lazarus / FreePascal** | LCL, Console (Cross-platform) | ✅ Yes | ✅ Yes |

### 🐧 Cross-Platform Build — Win32 / Win64 / Linux64 (verified)

> **✅ Verified 2026-06-20** in a real production backend: LQ-Colligo compiles as a dependency on **Win32, Win64 and Linux64** (`dcclinux64`). macOS/iOS/Android follow from the Delphi RTL but are **not build-verified** here yet.

The `TLQColligoString` case operations (`ToLower`/`ToUpper` and their invariants) had a broken Linux fallback calling the undeclared `UCS4LowerCase`/`UCS4UpperCase`. Locale-aware lowering still uses the `USE_LIBICU` path; the fallback now uses the RTL `System.SysUtils.LowerCase`/`UpperCase`. Windows behaviour is unchanged.

**Building a consumer app for Linux64:** install the Linux 64-bit platform (RAD Studio GetIt / `GetItCmd -if=delphi_linux -ae`), provide a Linux SDK (RAD Studio SDK Manager + PAServer, **or** a sysroot assembled from a WSL/Linux toolchain passed to `dcclinux64` via `--syslibroot` / `--libpath`), then compile with `dcclinux64`.

### ⚙️ Installation

Install using the [**Boss**](https://github.com/HashLoad/boss) package manager:

```sh
boss install LQ-Colligo
```

Or register the package via [**pubpascal.dev**](https://www.pubpascal.dev/packages/lq-colligo) and follow the on-screen instructions.

---

### ⚡️ Quick Start

#### 1. Basic Filtering and Projection (LINQ Style)

```delphi
uses
  System.SysUtils,
  LQColligo,
  LQColligo.Collections;

var
  LNumbers: TArray<Integer>;
  LResult: TArray<string>;
begin
  LNumbers := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // Fluid chain — no intermediate arrays are allocated during execution!
  LResult := TLQColligoArray.From<Integer>(LNumbers)
    .Where(
      function(const X: Integer): Boolean
      begin
        Result := (X mod 2 = 0); // Keep even numbers
      end)
    .Take(3) // Limit to the first 3 matching items
    .Select<string>(
      function(const X: Integer): string
      begin
        Result := 'Number ' + IntToStr(X); // Map to string
      end)
    .ToArray
    .ArrayData;

  // LResult = ['Number 2', 'Number 4', 'Number 6']
end;
```

#### 2. Advanced Ordering and Pagination (Skip/Take)

```delphi
var
  LResult: TArray<string>;
begin
  LResult := TLQColligoList<TUser>.From(MyCollection)
    .OrderBy(
      function(const A, B: TUser): Integer
      begin
        Result := CompareText(A.Name, B.Name);
      end)
    .Skip(10) // Skip the first 10 items (pagination)
    .Take(5)  // Take the next 5 items
    .Select<string>(
      function(const U: TUser): string
      begin
        Result := U.Email;
      end)
    .ToArray
    .ArrayData;
end;
```

---

## 🇧🇷 Português

**LQ-Colligo** é uma biblioteca de alta performance para programação funcional e manipulação de coleções em Delphi e Lazarus, fortemente inspirada no **LINQ do C#** e nas APIs de processamento de streams do Java, Kotlin e Rust. Ela introduz estruturas otimizadas baseadas em records (`ILQColligoEnumerable<T>` e `ILQColligoQueryable<T>`) projetadas para consultar, filtrar, mapear, ordenar e agregar coleções na memória e datasets. Ao adotar **Avaliação Preguiçosa** (lazy evaluation), o LQ-Colligo posterga o processamento até o último instante, eliminando alocações desnecessárias e maximizando a performance de CPU e memória.

> 💡 **Inspirado no LINQ.** O LQ-Colligo é uma releitura em Delphi/Lazarus do **C# LINQ to Objects** (`System.Linq`). Seu conjunto de operadores, a semântica de execução (deferred/immediate) e o comportamento em casos de borda espelham deliberadamente o LINQ, para que a experiência seja transferida diretamente.

### 🚀 Recursos Principais

*   **API Fluente e Encadeável:** Escreva consultas expressivas e legíveis através de chamadas consecutivas de métodos (ex: `Filter().Take().Select().ToArray()`).
*   **Avaliação Preguiçosa (Lazy Evaluation):** Os pipelines de dados só são executados ao acionar um operador terminal (como `ToArray`, `ToList` ou `First`), poupando ciclos de CPU.
*   **Core Livre de Alocação de Objetos:** Utiliza records leves em Object Pascal, evitando o overhead de alocação de objetos em heap.
*   **Operadores Completos Estilo LINQ:**
    *   *Filtragem:* `Where`, `OfType`, `Cast`, `Distinct`, `Exclude`
    *   *Projeção:* `Select`, `SelectIndexed`, `SelectMany`
    *   *Particionamento:* `Take`, `TakeWhile`, `Skip`, `SkipWhile`, `Chunk`
    *   *Ordenação:* `OrderBy`, `ThenBy` (Ascendente e Decrescente)
    *   *Operações de Conjunto:* `Union`, `Intersect`, `Concat`
    *   *Junções e Zipping:* `Join`, `GroupJoin`, `Zip`
    *   *Agregações:* `First`, `FirstOrDefault`, `Last`, `Any`, `All`, `Count`, `Sum`, `Average`
*   **Provedores de Formato Extensíveis:** Integração nativa com coleções padrão do Delphi (`TList<T>`, `TArray<T>`), datasets JSON e documentos XML.

### 🏛 Matriz de Compatibilidade

| Ambiente / IDE | Plataforma / Compilador | Avaliação Preguiçosa | Zero Alocação de Objetos |
| :--- | :--- | :---: | :---: |
| **Delphi XE ou superior** | VCL, FMX, Console (ARC e Não-ARC) | ✅ Sim | ✅ Sim |
| **Lazarus / FreePascal** | LCL, Console (Multiplataforma) | ✅ Sim | ✅ Sim |

### 🐧 Build Multiplataforma — Win32 / Win64 / Linux64 (verificado)

> **✅ Verificado em 2026-06-20** num backend real em produção: o LQ-Colligo compila como dependência em **Win32, Win64 e Linux64** (`dcclinux64`). macOS/iOS/Android seguem da RTL Delphi, mas **ainda não foram verificados** em build aqui.

As operações de caixa do `TLQColligoString` (`ToLower`/`ToUpper` e invariantes) tinham um fallback Linux quebrado chamando `UCS4LowerCase`/`UCS4UpperCase` (inexistente). O lowering com locale continua usando o caminho `USE_LIBICU`; o fallback agora usa o RTL `System.SysUtils.LowerCase`/`UpperCase`. O comportamento no Windows não muda.

**Para buildar um app consumidor no Linux64:** instale a plataforma Linux 64-bit (RAD Studio GetIt / `GetItCmd -if=delphi_linux -ae`), forneça um SDK Linux (SDK Manager do RAD Studio + PAServer, **ou** um sysroot montado de um toolchain WSL/Linux passado ao `dcclinux64` via `--syslibroot` / `--libpath`), e compile com `dcclinux64`.

### ⚙️ Instalação

Instale usando o gerenciador de pacotes [**Boss**](https://github.com/HashLoad/boss):

```sh
boss install LQ-Colligo
```

Ou registre o pacote via [**pubpascal.dev**](https://www.pubpascal.dev/packages/lq-colligo) e siga as instruções na tela.

---

### ⚡️ Início Rápido

#### 1. Filtragem Básica e Projeção (Estilo LINQ)

```delphi
uses
  System.SysUtils,
  LQColligo,
  LQColligo.Collections;

var
  LNumbers: TArray<Integer>;
  LResult: TArray<string>;
begin
  LNumbers := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // Pipeline fluido — nenhum array intermediário é alocado durante a execução!
  LResult := TLQColligoArray.From<Integer>(LNumbers)
    .Where(
      function(const X: Integer): Boolean
      begin
        Result := (X mod 2 = 0); // Filtra números pares
      end)
    .Take(3) // Limita aos primeiros 3 correspondentes
    .Select<string>(
      function(const X: Integer): string
      begin
        Result := 'Number ' + IntToStr(X); // Mapeia para string
      end)
    .ToArray
    .ArrayData;

  // LResult = ['Number 2', 'Number 4', 'Number 6']
end;
```

#### 2. Ordenação Avançada e Paginação (Skip/Take)

```delphi
var
  LResult: TArray<string>;
begin
  LResult := TLQColligoList<TUser>.From(MyCollection)
    .OrderBy(
      function(const A, B: TUser): Integer
      begin
        Result := CompareText(A.Name, B.Name);
      end)
    .Skip(10) // Pula os 10 primeiros (paginação)
    .Take(5)  // Pega os 5 próximos
    .Select<string>(
      function(const U: TUser): string
      begin
        Result := U.Email;
      end)
    .ToArray
    .ArrayData;
end;
```

---

## ⛏️ Contributing / Contribuição

Contributions are welcome — bug reports, fixes, new operators, or documentation improvements.
Contribuições são bem-vindas — relatórios de bugs, correções, novos operadores ou melhorias na documentação.

[![Issues](https://img.shields.io/badge/Issues-channel-orange)](../../issues)

**Steps / Passos:**

1. Fork the repository / Faça um fork do repositório.
2. Create a feature branch / Crie uma branch de feature: `git checkout -b feat/my-feature`.
3. Commit your changes / Commite suas alterações: `git commit -m "feat: description"`.
4. Push to the branch / Envie para a branch: `git push origin feat/my-feature`.
5. Open a Pull Request targeting `main` / Abra um Pull Request apontando para `main`.

---

## 📬 Contact / Contato

[![Email](https://img.shields.io/badge/Email-isaquesp%40gmail.com-D14836?logo=gmail&logoColor=white)](mailto:isaquesp@gmail.com)

---

## 💲 Donation / Doação

If LQ-Colligo saves you time, consider supporting its development.
Se o LQ-Colligo economiza seu tempo, considere apoiar o desenvolvimento.

[![Doação](https://img.shields.io/badge/PagSeguro-contribua-green)](https://pag.ae/bglQrWD)

---

## 📄 License / Licença

Distributed under the **MIT License**. See [LICENSE](LICENSE) for details.
Distribuído sob a **Licença MIT**. Consulte [LICENSE](LICENSE) para detalhes.

*Copyright © 2025-2026 Isaque Pinheiro.*
