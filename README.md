# FluentQuery / Fluent4D: Lazy Data Manipulation Library for Delphi

[![Delphi XE+](https://img.shields.io/badge/Delphi-XE%20or%20superior-blue.svg)]()
[![Lazarus Compatible](https://img.shields.io/badge/Lazarus-Compatible-orange.svg)]()
[![License](https://img.shields.io/badge/License-LGPL--3.0-blue.svg)](LICENSE)

*   [🇬🇧 English](#-english)
*   [🇧🇷 Português](#-português)

---

## 🇬🇧 English

**FluentQuery** (internally declared as **Fluent4D**) is a state-of-the-art, high-performance functional programming and fluent collection manipulation library for Delphi, inspired by **C# LINQ** and modern functional streams from **Java/Kotlin/Rust**. 

It enables developers to query, filter, transform, and aggregate data structures fluidly using **Lazy Evaluation** (deferred execution), ensuring maximum speed and minimized memory overhead.

### 🏛 Supported Platforms
*   **Delphi XE or superior** (VCL, FMX, Console, ARC & Non-ARC)
*   **Lazarus / FreePascal** (Compatible Core)

### ⚙️ Installation
To install using [`boss`]:
```sh
boss install "https://github.com/ModernDelphiWorks/FluentQuery"
```

---

### 🚀 Key Features

*   **Fluent API:** Elegant, chainable method syntax for complex query construction (e.g., `Filter().Take().Select().ToArray()`).
*   **Lazy Evaluation:** Operations are deferred and only executed when a terminal method (like `ToArray`, `ToList`, or `First`) is invoked. It completely avoids allocating intermediate arrays, optimizing memory.
*   **Zero-Allocation Record Core:** Core structures are based on lightweight records (`IFluentEnumerable<T>` and `IFluentQueryable<T>`), completely avoiding typical object allocation overhead.
*   **Comprehensive LINQ Operators:**
    *   **Filtering:** `Where`, `OfType`, `Cast`, `Distinct`, `Exclude`
    *   **Projections:** `Select`, `SelectIndexed`, `SelectMany`
    *   **Partitioning:** `Take`, `TakeWhile`, `Skip`, `SkipWhile`, `Chunk`
    *   **Ordering:** `OrderBy`, `ThenBy` (Ascending and Descending)
    *   **Set Operations:** `Union`, `Intersect`, `Concat`
    *   **Joining & Zipping:** `Join`, `GroupJoin`, `Zip`
    *   **Aggregation:** `First`, `FirstOrDefault`, `Last`, `Any`, `All`, `Count`
*   **Format Providers:** Extensible architecture supporting native Delphi collections (`TList<T>`, `TArray<T>`), JSON elements, and XML documents.

---

### ⚡️ Quick Start

#### Basic Filtering and Projection (Lazy LINQ style)
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

#### Complex Ordering and Skipping
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

### ⛏️ Contributing
We love contributions! Feel free to open issues or submit pull requests.

1.  Fork the project.
2.  Create your feature branch (`git checkout -b feature/AmazingFeature`).
3.  Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4.  Push to the branch (`git push origin feature/AmazingFeature`).
5.  Open a Pull Request.

### 📬 Contact & Support
*   **Telegram**: [HashLoad Channel](https://t.me/hashload)
*   **Website**: [isaquepinheiro.com.br](https://www.isaquepinheiro.com.br)

### 💲 Donation
[![Doação](https://img.shields.io/badge/PagSeguro-contribua-green)](https://pag.ae/bglQrWD)

---

## 🇧🇷 Português

**FluentQuery** (declarado internamente como **Fluent4D**) é uma biblioteca moderna e de alta performance de programação funcional e manipulação fluida de coleções para Delphi, fortemente inspirada no **C# LINQ** e em streams funcionais de linguagens como **Java/Kotlin/Rust**.

Ela permite consultar, filtrar, transformar e agrupar estruturas de dados de forma intuitiva utilizando **Lazy Evaluation** (avaliação adiada/lazy), garantindo máxima velocidade e baixíssimo consumo de memória.

### 🏛 Plataformas Suportadas
*   **Delphi XE ou superior** (VCL, FMX, Console, ARC & Non-ARC)
*   **Lazarus / FreePascal** (Core Compatível)

### ⚙️ Instalação
Para instalar usando o [`boss`]:
```sh
boss install "https://github.com/ModernDelphiWorks/FluentQuery"
```

---

### 🚀 Recursos Principais

*   **API Fluente:** Sintaxe de encadeamento de métodos elegante para a construção de queries complexas (ex.: `Filter().Take().Select().ToArray()`).
*   **Lazy Evaluation:** As operações são adiadas e executadas *apenas* quando um método terminal (como `ToArray`, `ToList` ou `First`) é invocado. Isso evita alocações desnecessárias de arrays intermediários em memória.
*   **Core em Records de Alocação Zero:** A arquitetura do framework é baseada em registros leves (`IFluentEnumerable<T>` e `IFluentQueryable<T>`), evitando overhead de alocação de objetos.
*   **Conjunto Completo de Operadores LINQ:**
    *   **Filtros:** `Where`, `OfType`, `Cast`, `Distinct`, `Exclude`
    *   **Projeções:** `Select`, `SelectIndexed`, `SelectMany`
    *   **Particionamento:** `Take`, `TakeWhile`, `Skip`, `SkipWhile`, `Chunk`
    *   **Ordenações:** `OrderBy`, `ThenBy` (Crescente e Decrescente)
    *   **Operações de Conjunto:** `Union`, `Intersect`, `Concat`
    *   **Cruzamentos & Associações:** `Join`, `GroupJoin`, `Zip`
    *   **Agregadores:** `First`, `FirstOrDefault`, `Last`, `Any`, `All`, `Count`
*   **Provedores de Formato:** Arquitetura extensível com suporte a coleções nativas do Delphi (`TList<T>`, `TArray<T>`), além de elementos JSON e XML.

---

### ⚡️ Início Rápido

#### Filtro e Projeção Básica (Estilo LINQ Lazy)
```delphi
uses
  System.SysUtils,
  FluentQuery;

var
  LNumbers: TArray<Integer>;
  LResult: TArray<string>;
begin
  LNumbers := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // Cadeia fluida - nenhum array intermediário é gerado em memória durante a execução!
  LResult := TFluentEnumerable<Integer>.Create(LNumbers)
    .Where(
      function(const X: Integer): Boolean
      begin
        Result := (X mod 2 = 0); // Mantém números pares
      end)
    .Take(3) // Limita aos 3 primeiros correspondentes
    .Select<string>(
      function(const X: Integer): string
      begin
        Result := 'Number ' + IntToStr(X); // Mapeia para string
      end)
    .ToArray;

  // LResult = ['Number 2', 'Number 4', 'Number 6']
end;
```

#### Paginação e Ordenação Complexa
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
    .Skip(10) // Pula os primeiros 10 itens (paginação)
    .Take(5)  // Pega os 5 itens seguintes
    .Select<string>(
      function(const U: TUser): string
      begin
        Result := U.Email;
      end)
    .ToArray;
end;
```

---

### ⛏️ Contribuição
Adoramos contribuições! Sinta-se à vontade para abrir issues ou enviar pull requests.

1.  Faça um Fork do projeto.
2.  Crie sua branch de recurso (`git checkout -b feature/MinhaNovaFeature`).
3.  Faça o commit de suas alterações (`git commit -m 'Adiciona MinhaNovaFeature'`).
4.  Faça o push para a branch (`git push origin feature/MinhaNovaFeature`).
5.  Abra um Pull Request.

### 📬 Contato & Suporte
*   **Telegram**: [Canal HashLoad](https://t.me/hashload)
*   **Website**: [isaquepinheiro.com.br](https://www.isaquepinheiro.com.br)

### 💲 Doação
[![Doação](https://img.shields.io/badge/PagSeguro-contribua-green)](https://pag.ae/bglQrWD)

---
*Copyright © 2025-2026 Isaque Pinheiro. Licensed under Apache-2.0.*
