---
title: Aggregations
sidebar_position: 7
---

# Aggregations

Aggregation operators are **terminal** — they consume the entire sequence and return a scalar value.

## Count / LongCount

```delphi
var LAll := TColligoArray<Integer>.From([1, 2, 3, 4, 5]).Count; // 5

var LEven := TColligoArray<Integer>.From([1, 2, 3, 4, 5])
  .Count(function(const X: Integer): Boolean begin Result := X mod 2 = 0 end);
// 2

// LongCount returns Int64:
var LLong := TColligoArray<Integer>.From([1, 2, 3]).LongCount;
```

## Sum

`Sum` accepts a typed selector. Overloads for `Double`, `Integer`, `Int64`, `Single`, `Currency`, and `ColligoNullable<*>` variants:

```delphi
var LTotal := TColligoArray<Double>.From([1.0, 2.0, 3.0])
  .Sum(function(const X: Double): Double begin Result := X end);
// LTotal = 6.0

var LIntSum := TColligoArray<Integer>.From([1, 2, 3])
  .Sum(function(const X: Integer): Integer begin Result := X end);
// LIntSum = 6
```

## Average

`Average` accepts typed selectors for `Double`, `Int32`, `Int64`, `Single`, `Currency`, and nullable variants. Always raises `EInvalidOperation` on an empty sequence.

```delphi
var LAvg := TColligoArray<Integer>.From([1, 2, 3, 4, 5])
  .Average(function(const X: Integer): Integer begin Result := X end);
// LAvg = 3.0 (Double)
```

## Min / Max

`Min` and `Max` use the default comparer when called without arguments:

```delphi
var LMin := TColligoArray<Integer>.From([3, 1, 4]).Min; // 1
var LMax := TColligoArray<Integer>.From([3, 1, 4]).Max; // 4
```

Typed-selector overloads return the extreme value of the extracted key:

```delphi
var LLowest := TColligoArray<Double>.From([2.5, 1.1, 3.3])
  .Min(function(const X: Double): Double begin Result := X end);
// 1.1
```

## First / Last / Single

Terminal operators that return a single element:

| Operator | Behaviour on empty / missing |
|---|---|
| `First` | Raises `EInvalidOperation` |
| `FirstOrDefault` | Returns `Default(T)` |
| `Last` | Raises `EInvalidOperation` |
| `LastOrDefault` | Returns `Default(T)` |
| `Single` | Raises if not exactly one match |
| `SingleOrDefault` | Returns `Default(T)` if zero; raises if more than one |

```delphi
var LFirst := TColligoArray<Integer>.From([5, 3, 1]).First; // 5

var LMatch := TColligoArray<Integer>.From([1, 2, 3, 4])
  .First(function(const X: Integer): Boolean begin Result := X > 2 end);
// 3
```

## Aggregate

`Aggregate` applies a reducer function across the sequence.

**Without seed** (uses first element as seed, raises on empty):

```delphi
var LProduct := TColligoArray<Integer>.From([1, 2, 3, 4])
  .Aggregate(function(const Acc, X: Integer): Integer begin Result := Acc * X end);
// 24
```

**With seed:**

```delphi
var LSum := TColligoArray<Integer>.From([1, 2, 3])
  .Aggregate<Integer>(0,
    function(const Acc, X: Integer): Integer begin Result := Acc + X end);
// 6
```

**With seed and result selector:**

```delphi
var LResult := TColligoArray<string>.From(['a', 'b', 'c'])
  .Aggregate<string, string>('',
    function(const Acc, X: string): string begin Result := Acc + X end,
    function(const S: string): string begin Result := '[' + S + ']' end);
// '[abc]'
```

## AggregateBy

Groups elements and aggregates per group in one pass:

```delphi
// function AggregateBy<TKey, TAccumulate>(
//   const AKeySelector: TFunc<T, TKey>;
//   const ASeed: TAccumulate;
//   const AAccumulator: TFunc<TAccumulate, T, TAccumulate>;
//   const AComparer: IEqualityComparer<TKey> = nil): TDictionary<TKey, TAccumulate>;
```

## CountBy

Counts elements per group key in one pass:

```delphi
// function CountBy<TKey>(
//   const AKeySelector: TFunc<T, TKey>;
//   const AComparer: IEqualityComparer<TKey> = nil): TDictionary<TKey, Integer>;
```

## ToHashSet / ToLookup / ToDictionary

Terminal operators that materialise results into standard collections:

```delphi
var LSet := TColligoArray<Integer>.From([1, 2, 2, 3]).ToHashSet;
// THashSet<Integer> with {1, 2, 3}

var LDict := TColligoArray<TUser>.From(LUsers)
  .ToDictionary<Integer, string>(
    function(const U: TUser): Integer begin Result := U.Id end,
    function(const U: TUser): string begin Result := U.Name end);
// TDictionary<Integer, string>
```
