---
title: Troubleshooting
sidebar_position: 1
---

# Troubleshooting

## EInvalidOperation: "Sequence contains no elements"

`First`, `Last`, `Single`, `Min`, `Max`, and `Aggregate` (without seed) raise this when the sequence is empty.

**Fix:** use the `OrDefault` variant or add `Any` check first:

```delphi
if LQuery.Any then
  var LFirst := LQuery.First
else
  var LFirst := Default(TMyType);

// Or simply:
var LFirst := LQuery.FirstOrDefault;
```

## EInvalidOperation: "Scalar query returned no results"

Thrown by `ILQColligoQueryable<T>` terminal operators when the database query returns no rows.

**Fix:** use `FirstOrDefault` / `LastOrDefault` / `SingleOrDefault` instead of their non-defaulting variants.

## EArgumentNilException: "Predicate cannot be nil"

`Where`, `TakeWhile`, `SkipWhile`, and `All` raise this when the predicate parameter is not assigned.

**Fix:** always assign a valid anonymous function before calling.

## Pipeline returns wrong results after reuse

`ILQColligoEnumerable<T>` is a **value record**. If you assign it to a local variable and then modify it (chain more operators), the original variable is unchanged because records are copied by value.

```delphi
var LBase := TLQColligoArray<Integer>.From([1, 2, 3, 4, 5]);

// LBase is not modified — LFiltered is a new record:
var LFiltered := LBase.Where(function(const X: Integer): Boolean begin Result := X > 2 end);
```

## Linux64: "Undeclared identifier UCS4LowerCase"

`TLQColligoString.ToLower`/`ToUpper` previously referenced `UCS4LowerCase`/`UCS4UpperCase` which do not exist on Linux. This is fixed in current source — the fallback uses `System.SysUtils.LowerCase`/`UpperCase`. Ensure you are on the latest `main` branch.

## ILQColligoQueryable: "Provider not assigned for query building"

`TLQColligoQueryable<T>.BuildQuery` raises this when the internal provider is nil. This can happen if you call `Create(nil)` directly.

**Fix:** always use `CreateForDatabase(...)` or provide a non-nil `ILQColligoQueryableBase<T>`.

## ILQColligoQueryable: "Generated SQL is empty"

`_ExecuteScalar` raises this when the FluentSQL AST generates an empty string. This usually means `From(...)` was not called.

**Fix:** ensure `From('TABLE_NAME')` is the first call in the chain.

## ILQColligoQueryable methods not compiling

`ILQColligoQueryable<T>` method bodies require `{$DEFINE QUERYABLE}`. Operator declarations always compile; method bodies do not without the define.

**Fix:** add `{$DEFINE QUERYABLE}` to your project's conditional defines or to a `.inc` file included before `LQColligo.Queryable`.

## `TLQColligoList<T>` with AOwnerships deletes objects on removal

When `AOwnerships = True` and `T` is a class, `TLQColligoList<T>` calls `.Free` on each removed object. If another reference to the same object exists elsewhere, this causes a dangling pointer.

**Fix:** use `AOwnerships = False` (the default) unless you want the list to own the objects exclusively.
