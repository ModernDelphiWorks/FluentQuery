---
title: Introduction
sidebar_position: 1
---

# Introduction

FluentQuery is a LINQ-style library that brings functional collection processing to Delphi and Lazarus. It is built on two record-based, interface-backed types that compose into lazy data pipelines, executing only when a **terminal operator** is called.

## Design principles

### Lazy evaluation

Operators like `Where`, `Select`, `Take`, and `Skip` are *intermediate* — they do not iterate the source. Only terminal operators (`ToArray`, `ToList`, `First`, `Count`, `Sum`, …) pull data through the pipeline.

```delphi
// Nothing executes here:
var LPipeline := TFluentArray<Integer>.From([1,2,3,4,5])
  .Where(function(const X: Integer): Boolean begin Result := X > 2 end)
  .Select<string>(function(const X: Integer): string begin Result := IntToStr(X) end);

// Execution happens here:
var LResult := LPipeline.ToArray;
```

### Zero intermediate allocation core

`IFluentEnumerable<T>` is a **record** wrapping an `IFluentEnumerableBase<T>` interface. Each chained operator returns a new record that wraps the previous enumerator — no heap-allocated temporary arrays are created between steps.

### Generics-first

All operators are generic. Type parameters flow from the source element type through projections and aggregations without boxing.

## Two primary abstractions

| Abstraction | Source | Terminal | Use case |
|---|---|---|---|
| `IFluentEnumerable<T>` | `TArray<T>`, `TList<T>`, any `IFluentEnumerableBase<T>` | `ToArray`, `ToList`, `First`, `Count`, … | In-memory collections |
| `IFluentQueryable<T>` | Database via FluentSQL + DataEngine | `ToArray`, `ToList`, `First`, `Count`, … | SQL database queries |

## Compatibility

| Environment | Platform | Lazy evaluation | Zero-allocation record core |
|---|---|---|---|
| Delphi XE or superior | VCL, FMX, Console (ARC & Non-ARC) | Yes | Yes |
| Lazarus / FreePascal | LCL, Console (cross-platform) | Yes | Yes |

**Cross-platform build status (2026-06-20):** Win32, Win64, and Linux64 (`dcclinux64`) all compile. macOS/iOS/Android follow from the Delphi RTL but are not build-verified yet.

:::note Linux64 build note
`TFluentString` case operations (`ToLower`/`ToUpper`) had a broken Linux fallback. The fix uses `System.SysUtils.LowerCase`/`UpperCase` as the fallback. Windows behaviour is unchanged.
:::
