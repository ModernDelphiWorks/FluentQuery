---
title: Filtering collections
sidebar_position: 1
---

# Filtering collections

LQ-Colligo provides several operators to filter elements from a sequence.

## Where

`Where` keeps only elements matching a predicate.

```delphi
var LResult := TLQColligoArray<Integer>.From([1, 2, 3, 4, 5])
  .Where(function(const X: Integer): Boolean
  begin
    Result := X > 2;
  end)
  .ToArray;
// Result: [3, 4, 5]
```

## Distinct

`Distinct` removes duplicate elements using the default equality comparer.

```delphi
var LResult := TLQColligoArray<Integer>.From([1, 2, 2, 3, 1])
  .Distinct
  .ToArray;
// Result: [1, 2, 3]
```

Pass a custom `IEqualityComparer<T>` for non-default equality:

```delphi
var LResult := TLQColligoArray<string>.From(['a', 'A', 'b'])
  .Distinct(TStringComparer.OrdinalIgnoreCase)
  .ToArray;
// Result: ['a', 'b']
```

### DistinctBy

Deduplicate by a key selector:

```delphi
type TUser = record Name: string; Age: Integer; end;

var LResult := TLQColligoArray<TUser>.From(LUsers)
  .DistinctBy<string>(function(const U: TUser): string begin Result := U.Name end)
  .ToArray;
```

## OfType

`OfType<TResult>` filters elements that pass a type-check and converts them.

```delphi
// Signature:
// function OfType<TResult>(
//   const AIsType: TFunc<T, Boolean>;
//   const AConverter: TFunc<T, TResult>): ILQColligoEnumerable<TResult>;
```

## Cast

`Cast<TResult>` re-interprets every element as `TResult` (no type guard — use when you know the types are compatible).

## Exclude (set subtraction)

`Exclude` removes elements that appear in a second sequence.

```delphi
var LA := TLQColligoArray<Integer>.From([1, 2, 3, 4]);
var LB := TLQColligoArray<Integer>.From([2, 4]);

var LResult := LA.Exclude(LB).ToArray;
// Result: [1, 3]
```

### ExcludeBy

Exclude elements whose key matches any key in a second sequence:

```delphi
// function ExcludeBy<TKey>(
//   const ASecond: ILQColligoEnumerable<TKey>;
//   const AKeySelector: TFunc<T, TKey>): ILQColligoEnumerable<T>;
```

```delphi
type TProduct = record Id: Integer; Name: string; end;

var LBlocked := TLQColligoArray<Integer>.From([2, 5]);
var LProducts: TArray<TProduct>;
// Assume LProducts is populated...

var LResult := TLQColligoArray<TProduct>.From(LProducts)
  .ExcludeBy<Integer>(
    LBlocked,
    function(const P: TProduct): Integer
    begin
      Result := P.Id;
    end)
  .ToArray;
// Yields every product whose Id is NOT in LBlocked
```

## Contains

`Contains` returns `True` if the sequence contains a value (uses default or custom comparer):

```delphi
var LFound := TLQColligoArray<Integer>.From([1, 2, 3]).Contains(2); // True
```

## Any / All

`Any` returns `True` if at least one element satisfies the predicate (or if the sequence is non-empty when called without arguments).

`All` returns `True` if every element satisfies the predicate.

```delphi
var LHasEven := TLQColligoArray<Integer>.From([1, 3, 5, 6])
  .Any(function(const X: Integer): Boolean begin Result := X mod 2 = 0 end);
// True

var LAllPositive := TLQColligoArray<Integer>.From([1, 2, 3])
  .All(function(const X: Integer): Boolean begin Result := X > 0 end);
// True
```
