# FluentQuery Framework for Delphi & Lazarus

[![Delphi XE+](https://img.shields.io/badge/Delphi-XE%20or%20superior-blue.svg)]()
[![Lazarus Compatible](https://img.shields.io/badge/Lazarus-Compatible-orange.svg)]()
[![License](https://img.shields.io/badge/License-LGPL--3.0-blue.svg)](LICENSE)

*   [🇬🇧 English](#-english)
*   [🇧🇷 Português](#-português)

---

## 🇬🇧 English

**FluentQuery** is a high-performance functional programming and collection manipulation library for Delphi and Lazarus, heavily inspired by **C# LINQ** and stream processing APIs found in Java, Kotlin, and Rust. It introduces powerful record-based structures (`IFluentEnumerable<T>` and `IFluentQueryable<T>`) designed to query, filter, map, order, and aggregate in-memory collections and datasets. By employing **Lazy Evaluation** (deferred execution), FluentQuery avoids intermediate object allocations, ensuring exceptional CPU speed and minimal memory footprint.

### 🚀 Key Features

*   **Fluent & Chainable API:** Write highly expressive, readable queries using method chaining (e.g., `Filter().Take().Select().ToArray()`).
*   **Lazy Evaluation:** Data pipelines are executed only when a terminal operator (like `ToArray`, `ToList`, or `First`) is triggered, avoiding unnecessary intermediate array allocations.
*   **Zero-Allocation Core:** Leverages lightweight Delphi record interfaces, avoiding the typical object allocation overhead.
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

### ⚙️ Installation

To install using the package manager [**Boss**](https://github.com/HashLoad/boss):

```sh
boss install Fluent4D
```

> [!NOTE]
> For historical registry reasons on Boss, the package name is declared as **Fluent4D** in its manifest, but the official framework name is **FluentQuery**.

---

### ⚡️ Quick Start

#### 1. Basic Filtering and Projection (LINQ Style)
```delphi
uses
  System.SysUtils,
  FluentQuery;

var
  LNumbers: TArray<Integer>;
  LResult: TArray<string>;
begin
  LNumbers := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // Fluid chain - no intermediate arrays are created during execution!
  LResult := TFluentEnumerable<Integer>.Create(LNumbers)
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
    .ToArray;

  // LResult = ['Number 2', 'Number 4', 'Number 6']
end;
```

#### 2. Advanced Ordering and Pagination (Skip/Take)
```delphi
var
  LResult: TArray<string>;
begin
  LResult := Queryable(MyCollection)
    .OrderBy(
      function(const A, B: TUser): Integer
      begin
        Result := CompareText(A.Name, B.Name);
      end)
    .Skip(10) // Skip first 10 items (pagination)
    .Take(5)  // Take next 5 items
    .Select<string>(
      function(const U: TUser): string
      begin
        Result := U.Email;
      end)
    .ToArray;
end;
```

---

## 🇧🇷 Português

**FluentQuery** é uma biblioteca de alta performance para programação funcional e manipulação de coleções em Delphi e Lazarus, fortemente inspirada no **LINQ do C#** e nas APIs de processamento de streams do Java, Kotlin e Rust. Ela introduz estruturas otimizadas baseadas em records (`IFluentEnumerable<T>` e `IFluentQueryable<T>`) projetadas para consultar, filtrar, mapear, ordenar e agregar coleções na memória e datasets. Ao adotar **Avaliação Preguiçosa** (lazy evaluation), o FluentQuery posterga o processamento até o último instante, eliminando alocações desnecessárias e maximizando a performance de CPU e memória.

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
*   **Provedores de Formato Estensíveis:** Integração nativa com coleções padrão do Delphi (`TList<T>`, `TArray<T>`), datasets JSON e documentos XML.

### 🏛 Matriz de Compatibilidade

| Ambiente / IDE | Plataforma / Compilador | Avaliação Preguiçosa | Zero Alocação de Objetos |
| :--- | :--- | :---: | :---: |
| **Delphi XE ou superior** | VCL, FMX, Console (ARC e Não-ARC) | ✅ Sim | ✅ Sim |
| **Lazarus / FreePascal** | LCL, Console (Multiplataforma) | ✅ Sim | ✅ Sim |

### ⚙️ Instalação

Para instalar usando o gerenciador de pacotes [**Boss**](https://github.com/HashLoad/boss):

```sh
boss install Fluent4D
```

> [!NOTE]
> Por motivos históricos de registro no Boss, o pacote é declarado como **Fluent4D** no manifesto, embora o nome oficial do projeto seja **FluentQuery**.

---

### ⚡️ Início Rápido

#### 1. Filtragem Básica e Projeção (Estilo LINQ)
```delphi
uses
  System.SysUtils,
  FluentQuery;

var
  LNumbers: TArray<Integer>;
  LResult: TArray<string>;
begin
  LNumbers := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // Pipeline fluido - nenhum array intermediário é alocado durante a execução!
  LResult := TFluentEnumerable<Integer>.Create(LNumbers)
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
    .ToArray;

  // LResult = ['Number 2', 'Number 4', 'Number 6']
end;
```

#### 2. Ordenação Avançada e Paginação (Skip/Take)
```delphi
var
  LResult: TArray<string>;
begin
  LResult := Queryable(MyCollection)
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
    .ToArray;
end;
```

---
*Copyright © 2025-2026 Isaque Pinheiro. Licensed under LGPL-3.0 License.*
