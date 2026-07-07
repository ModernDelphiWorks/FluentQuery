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
     │ IColligoEnumerable<T│  │ IColligoQueryable<T>   │
     │ (Colligo.pas)  │  │ (Colligo.Queryable)│
     └─────────┬──────────┘  └────────┬───────────────┘
               │                      │
     ┌─────────▼──────────┐  ┌────────▼───────────────┐
     │ Operator units     │  │ IColligoQueryProvider<T> │
     │ Colligo.Where  │  │ + FluentSQL AST         │
     │ Colligo.Select │  │ + DataEngine connection  │
     │ Colligo.Take   │  └────────────────────────-┘
     │ Colligo.Skip   │
     │ Colligo.OrderBy│
     │ ... (one unit each)│
     └─────────┬──────────┘
               │
     ┌─────────▼──────────┐
     │ Colligo.Core   │
     │ TFluentType        │
     │ ColligoNullable<T>  │
     └────────────────────┘
```

## Key types

### Colligo.Core

- `TFluentType` — enum `(ftNone, ftList, ftDictionary)` used internally to tag the source kind.
- `ColligoNullable<T: record>` — generic nullable value record.
- `TAction<T>` — `reference to procedure(const AArg: T)`.

### Colligo.pas — the public API

- **`IColligoEnumerable<T>`** — value record. Holds an `IColligoEnumerableBase<T>` (the current operator node) plus a comparer. Every method returns a new `IColligoEnumerable<T>` wrapping a new operator node around the previous one.
- **`IFluentEnumerator<T>`** — iterator interface (`GetCurrent`, `MoveNext`, `Reset`).
- **`IColligoEnumerableBase<T>`** — single method `GetEnumerator: IFluentEnumerator<T>`. Each operator unit implements a concrete class.
- **`IGroupByEnumerable<TKey, T>`** — result of `GroupBy`; iterable as `IGrouping<TKey, T>`.
- **`IGrouping<TKey, T>`** — `Key` + `Items: IColligoEnumerable<T>`.
- **`IFluentArray<T>`** — interface over `TArray<T>`; returned by `ToArray`.
- **`IFluentList<T>`** — interface over `TList<T>` with full mutation API.
- **`IFluentDictionary<K,V>`** — interface over `TDictionary<K,V>`.

### Colligo.Collections

Concrete implementations: `TColligoArray<T>`, `TColligoList<T>`, `TFluentDictionary<K,V>`. These can be used as replacement collections that integrate directly with the pipeline.

### Operator units

Each operator is isolated in its own unit:

| Unit | Operator(s) |
|---|---|
| `Colligo.Where` | `Where` |
| `Colligo.Select` | `Select`, `SelectIndexed` |
| `Colligo.Take` | `Take` |
| `Colligo.TakeWhile` / `TakeWhileIndexed` | `TakeWhile` |
| `Colligo.Skip` | `Skip` |
| `Colligo.SkipWhile` / `SkipWhileIndexed` | `SkipWhile` |
| `Colligo.OrderBy` | `OrderBy`, `OrderByDesc` |
| `Colligo.Order` | `Order`, `OrderDescending` |
| `Colligo.ThenBy` | `ThenBy`, `ThenByDescending` |
| `Colligo.Distinct` | `Distinct` |
| `Colligo.GroupBy` | `GroupBy` |
| `Colligo.Join` | `Join` |
| `Colligo.GroupJoin` | `GroupJoin` |
| `Colligo.Zip` | `Zip` |
| `Colligo.SelectMany` / variants | `SelectMany` |
| `Colligo.OfType` | `OfType` |
| `Colligo.Cast` | `Cast` |
| `Colligo.Exclude` | `Exclude` |
| `Colligo.Union` | `Union` |
| `Colligo.Intersect` | `Intersect` |
| `Colligo.Concat` | `Concat` |

### Colligo.Queryable

`IColligoQueryable<T>` — value record that wraps `IColligoQueryProvider<T>` (a FluentSQL-based SQL builder + DataEngine connection). Terminal operators build the SQL string, execute it via `IDBConnection.CreateDataSet`, and parse rows through `TDataSetEnumerator<T>` and `TColligoParseScalarDataSet<T>` / `TColligoParseObjectDataSet<T>`.

### Format providers (stubs)

`Colligo.Json` and `Colligo.Xml` declare `IColligoJsonProvider<T>` and `IColligoXmlProvider<T>` interfaces but contain no implementation yet.
