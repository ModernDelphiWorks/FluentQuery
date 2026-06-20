---
title: Architecture overview
sidebar_position: 1
---

# Architecture overview

## Layer diagram

```
┌─────────────────────────────────────────────────────────┐
│                   Consumer code (uses)                   │
└──────────────┬──────────────────────┬───────────────────┘
               │                      │
     ┌─────────▼──────────┐  ┌────────▼──────────────┐
     │ IFluentEnumerable<T│  │ IFluentQueryable<T>   │
     │ (FluentQuery.pas)  │  │ (FluentQuery.Queryable)│
     └─────────┬──────────┘  └────────┬───────────────┘
               │                      │
     ┌─────────▼──────────┐  ┌────────▼───────────────┐
     │ Operator units     │  │ IFluentQueryProvider<T> │
     │ FluentQuery.Where  │  │ + FluentSQL AST         │
     │ FluentQuery.Select │  │ + DataEngine connection  │
     │ FluentQuery.Take   │  └────────────────────────-┘
     │ FluentQuery.Skip   │
     │ FluentQuery.OrderBy│
     │ ... (one unit each)│
     └─────────┬──────────┘
               │
     ┌─────────▼──────────┐
     │ FluentQuery.Core   │
     │ TFluentType        │
     │ FluentNullable<T>  │
     └────────────────────┘
```

## Key types

### FluentQuery.Core

- `TFluentType` — enum `(ftNone, ftList, ftDictionary)` used internally to tag the source kind.
- `FluentNullable<T: record>` — generic nullable value record.
- `TAction<T>` — `reference to procedure(const AArg: T)`.

### FluentQuery.pas — the public API

- **`IFluentEnumerable<T>`** — value record. Holds an `IFluentEnumerableBase<T>` (the current operator node) plus a comparer. Every method returns a new `IFluentEnumerable<T>` wrapping a new operator node around the previous one.
- **`IFluentEnumerator<T>`** — iterator interface (`GetCurrent`, `MoveNext`, `Reset`).
- **`IFluentEnumerableBase<T>`** — single method `GetEnumerator: IFluentEnumerator<T>`. Each operator unit implements a concrete class.
- **`IGroupByEnumerable<TKey, T>`** — result of `GroupBy`; iterable as `IGrouping<TKey, T>`.
- **`IGrouping<TKey, T>`** — `Key` + `Items: IFluentEnumerable<T>`.
- **`IFluentArray<T>`** — interface over `TArray<T>`; returned by `ToArray`.
- **`IFluentList<T>`** — interface over `TList<T>` with full mutation API.
- **`IFluentDictionary<K,V>`** — interface over `TDictionary<K,V>`.

### FluentQuery.Collections

Concrete implementations: `TFluentArray<T>`, `TFluentList<T>`, `TFluentDictionary<K,V>`. These can be used as replacement collections that integrate directly with the pipeline.

### Operator units

Each operator is isolated in its own unit:

| Unit | Operator(s) |
|---|---|
| `FluentQuery.Where` | `Where` |
| `FluentQuery.Select` | `Select`, `SelectIndexed` |
| `FluentQuery.Take` | `Take` |
| `FluentQuery.TakeWhile` / `TakeWhileIndexed` | `TakeWhile` |
| `FluentQuery.Skip` | `Skip` |
| `FluentQuery.SkipWhile` / `SkipWhileIndexed` | `SkipWhile` |
| `FluentQuery.OrderBy` | `OrderBy`, `OrderByDesc` |
| `FluentQuery.Order` | `Order`, `OrderDescending` |
| `FluentQuery.ThenBy` | `ThenBy`, `ThenByDescending` |
| `FluentQuery.Distinct` | `Distinct` |
| `FluentQuery.GroupBy` | `GroupBy` |
| `FluentQuery.Join` | `Join` |
| `FluentQuery.GroupJoin` | `GroupJoin` |
| `FluentQuery.Zip` | `Zip` |
| `FluentQuery.SelectMany` / variants | `SelectMany` |
| `FluentQuery.OfType` | `OfType` |
| `FluentQuery.Cast` | `Cast` |
| `FluentQuery.Exclude` | `Exclude` |
| `FluentQuery.Union` | `Union` |
| `FluentQuery.Intersect` | `Intersect` |
| `FluentQuery.Concat` | `Concat` |

### FluentQuery.Queryable

`IFluentQueryable<T>` — value record that wraps `IFluentQueryProvider<T>` (a FluentSQL-based SQL builder + DataEngine connection). Terminal operators build the SQL string, execute it via `IDBConnection.CreateDataSet`, and parse rows through `TDataSetEnumerator<T>` and `TFluentParseScalarDataSet<T>` / `TFluentParseObjectDataSet<T>`.

### Format providers (stubs)

`FluentQuery.Json` and `FluentQuery.Xml` declare `IFluentJsonProvider<T>` and `IFluentXmlProvider<T>` interfaces but contain no implementation yet.
