---
title: Partitioning — Take / Skip
sidebar_position: 4
---

# Partitioning — Take / Skip

Partitioning operators slice a sequence without creating intermediate arrays.

## Take

`Take(N)` returns the first N elements:

```delphi
var LResult := TFluentArray<Integer>.From([1, 2, 3, 4, 5])
  .Take(3)
  .ToArray;
// Result: [1, 2, 3]
```

### TakeWhile

`TakeWhile` keeps elements as long as the predicate holds, then stops:

```delphi
var LResult := TFluentArray<Integer>.From([1, 2, 3, 4, 5])
  .TakeWhile(function(const X: Integer): Boolean begin Result := X < 4 end)
  .ToArray;
// Result: [1, 2, 3]
```

Indexed variant passes the element index:

```delphi
// function TakeWhile(const APredicate: TFunc<T, Integer, Boolean>): IFluentEnumerable<T>;
```

### TakeLast

`TakeLast(N)` returns the last N elements (buffers the full sequence):

```delphi
var LResult := TFluentArray<Integer>.From([1, 2, 3, 4, 5])
  .TakeLast(2)
  .ToArray;
// Result: [4, 5]
```

## Skip

`Skip(N)` discards the first N elements:

```delphi
var LResult := TFluentArray<Integer>.From([1, 2, 3, 4, 5])
  .Skip(2)
  .ToArray;
// Result: [3, 4, 5]
```

### SkipWhile

`SkipWhile` discards elements as long as the predicate holds, then returns the rest:

```delphi
var LResult := TFluentArray<Integer>.From([1, 2, 3, 4, 5])
  .SkipWhile(function(const X: Integer): Boolean begin Result := X < 3 end)
  .ToArray;
// Result: [3, 4, 5]
```

Indexed variant:

```delphi
// function SkipWhile(const APredicate: TFunc<T, Integer, Boolean>): IFluentEnumerable<T>;
```

### SkipLast

`SkipLast(N)` returns all elements except the last N:

```delphi
var LResult := TFluentArray<Integer>.From([1, 2, 3, 4, 5])
  .SkipLast(2)
  .ToArray;
// Result: [1, 2, 3]
```

## ElementAt / ElementAtOrDefault

Access an element by index (zero-based):

```delphi
var LValue := TFluentArray<string>.From(['a', 'b', 'c']).ElementAt(1);
// LValue = 'b'

var LSafe := TFluentArray<string>.From(['a', 'b']).ElementAtOrDefault(5);
// LSafe = '' (default string)
```

## Pagination pattern

Combine `Skip` and `Take` for pagination:

```delphi
const PageSize = 10;

procedure LoadPage(const APage: Integer; const AAll: TArray<TRecord>);
var
  LPage: IFluentArray<TRecord>;
begin
  LPage := TFluentArray<TRecord>.From(AAll)
    .Skip(APage * PageSize)
    .Take(PageSize)
    .ToArray;
end;
```
