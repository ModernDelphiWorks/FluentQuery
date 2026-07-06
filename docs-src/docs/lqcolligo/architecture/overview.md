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
     │ ILQColligoEnumerable<T│  │ ILQColligoQueryable<T>   │
     │ (LQColligo.pas)  │  │ (LQColligo.Queryable)│
     └─────────┬──────────┘  └────────┬───────────────┘
               │                      │
     ┌─────────▼──────────┐  ┌────────▼───────────────┐
     │ Operator units     │  │ ILQColligoQueryProvider<T> │
     │ LQColligo.Where  │  │ + FluentSQL AST         │
     │ LQColligo.Select │  │ + DataEngine connection  │
     │ LQColligo.Take   │  └────────────────────────-┘
     │ LQColligo.Skip   │
     │ LQColligo.OrderBy│
     │ ... (one unit each)│
     └─────────┬──────────┘
               │
     ┌─────────▼──────────┐
     │ LQColligo.Core   │
     │ TFluentType        │
     │ LQColligoNullable<T>  │
     └────────────────────┘
```

## Key types

### LQColligo.Core

- `TFluentType` — enum `(ftNone, ftList, ftDictionary)` used internally to tag the source kind.
- `LQColligoNullable<T: record>` — generic nullable value record.
- `TAction<T>` — `reference to procedure(const AArg: T)`.

### LQColligo.pas — the public API

- **`ILQColligoEnumerable<T>`** — value record. Holds an `ILQColligoEnumerableBase<T>` (the current operator node) plus a comparer. Every method returns a new `ILQColligoEnumerable<T>` wrapping a new operator node around the previous one.
- **`IFluentEnumerator<T>`** — iterator interface (`GetCurrent`, `MoveNext`, `Reset`).
- **`ILQColligoEnumerableBase<T>`** — single method `GetEnumerator: IFluentEnumerator<T>`. Each operator unit implements a concrete class.
- **`IGroupByEnumerable<TKey, T>`** — result of `GroupBy`; iterable as `IGrouping<TKey, T>`.
- **`IGrouping<TKey, T>`** — `Key` + `Items: ILQColligoEnumerable<T>`.
- **`IFluentArray<T>`** — interface over `TArray<T>`; returned by `ToArray`.
- **`IFluentList<T>`** — interface over `TList<T>` with full mutation API.
- **`IFluentDictionary<K,V>`** — interface over `TDictionary<K,V>`.

### LQColligo.Collections

Concrete implementations: `TLQColligoArray<T>`, `TLQColligoList<T>`, `TFluentDictionary<K,V>`. These can be used as replacement collections that integrate directly with the pipeline.

### Operator units

Each operator is isolated in its own unit:

| Unit | Operator(s) |
|---|---|
| `LQColligo.Where` | `Where` |
| `LQColligo.Select` | `Select`, `SelectIndexed` |
| `LQColligo.Take` | `Take` |
| `LQColligo.TakeWhile` / `TakeWhileIndexed` | `TakeWhile` |
| `LQColligo.Skip` | `Skip` |
| `LQColligo.SkipWhile` / `SkipWhileIndexed` | `SkipWhile` |
| `LQColligo.OrderBy` | `OrderBy`, `OrderByDesc` |
| `LQColligo.Order` | `Order`, `OrderDescending` |
| `LQColligo.ThenBy` | `ThenBy`, `ThenByDescending` |
| `LQColligo.Distinct` | `Distinct` |
| `LQColligo.GroupBy` | `GroupBy` |
| `LQColligo.Join` | `Join` |
| `LQColligo.GroupJoin` | `GroupJoin` |
| `LQColligo.Zip` | `Zip` |
| `LQColligo.SelectMany` / variants | `SelectMany` |
| `LQColligo.OfType` | `OfType` |
| `LQColligo.Cast` | `Cast` |
| `LQColligo.Exclude` | `Exclude` |
| `LQColligo.Union` | `Union` |
| `LQColligo.Intersect` | `Intersect` |
| `LQColligo.Concat` | `Concat` |

### LQColligo.Queryable

`ILQColligoQueryable<T>` — value record that wraps `ILQColligoQueryProvider<T>` (a FluentSQL-based SQL builder + DataEngine connection). Terminal operators build the SQL string, execute it via `IDBConnection.CreateDataSet`, and parse rows through `TDataSetEnumerator<T>` and `TLQColligoParseScalarDataSet<T>` / `TLQColligoParseObjectDataSet<T>`.

### Format providers (stubs)

`LQColligo.Json` and `LQColligo.Xml` declare `ILQColligoJsonProvider<T>` and `ILQColligoXmlProvider<T>` interfaces but contain no implementation yet.
