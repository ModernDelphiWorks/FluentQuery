---
displayed_sidebar: lqcolligoSidebar
title: LQ-Colligo
sidebar_position: 0
---

**LQ-Colligo** is a high-performance functional programming and collection manipulation library for Delphi and Lazarus, heavily inspired by **C# LINQ** and stream-processing APIs from Java, Kotlin, and Rust.

It provides two primary abstractions:

- **`ILQColligoEnumerable<T>`** — lazy pipeline for in-memory collections (arrays, lists).
- **`ILQColligoQueryable<T>`** — SQL-backed pipeline for database queries (requires FluentSQL + a DataEngine connection).

## Where to start

- [Introduction](introduction.md)
- [Installation](getting-started/installation.md)
- [Quickstart](getting-started/quickstart.md)
- [Troubleshooting](troubleshooting/common-errors.md)

### Guides

- [Filtering collections](guides/filtering-collections.md)
- [Projections — Select / SelectMany](guides/projections-select.md)
- [Ordering collections](guides/ordering-collections.md)
- [Partitioning — Take / Skip](guides/partitioning-take-skip.md)
- [Set operations — Union, Intersect, Concat, Exclude](guides/set-operations.md)
- [Joins and Zip](guides/joins-zip.md)
- [Aggregations](guides/aggregations.md)
- [Grouping](guides/grouping.md)
- [Querying the database (ILQColligoQueryable)](guides/querying-database.md)
- [Nullable types](guides/nullable-types.md)

### Reference

- [ILQColligoEnumerable API](reference/api-enumerable.md)
- [ILQColligoQueryable API](reference/api-queryable.md)
- [Collections API (TLQColligoList, TLQColligoArray, TFluentDictionary)](reference/api-collections.md)

### Architecture

- [Architecture overview](architecture/overview.md)

## Scope

- **Covers:** lazy in-memory collection pipelines; SQL-backed DB pipelines via `ILQColligoQueryable<T>`; fluent collections (`TLQColligoList<T>`, `TLQColligoArray<T>`, `TFluentDictionary<K,V>`); nullable value helpers (`LQColligoNullable<T>`).
- **Does not cover:** JSON/XML providers (`LQColligo.Json`, `LQColligo.Xml`) — these units are stubs not yet implemented.
