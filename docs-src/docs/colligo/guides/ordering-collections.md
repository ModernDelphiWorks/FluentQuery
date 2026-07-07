---
title: Ordering collections
sidebar_position: 3
---

# Ordering collections

Colligo provides multiple ordering operators, all of which buffer the full sequence before returning the first element.

## OrderBy

`OrderBy` sorts ascending using a comparator function:

```delphi
var LResult := TColligoArray<string>.From(['banana', 'apple', 'cherry'])
  .OrderBy(function(const A, B: string): Integer
  begin
    Result := CompareText(A, B);
  end)
  .ToArray;
// Result: ['apple', 'banana', 'cherry']
```

### OrderBy with key selector and IComparer

```delphi
// function OrderBy<TKey>(
//   const AKeySelector: TFunc<T, TKey>;
//   const AComparer: IComparer<TKey>): IColligoEnumerable<T>;
```

## OrderByDesc

Sorts descending using a comparator function:

```delphi
var LResult := TColligoArray<Integer>.From([3, 1, 4, 1, 5])
  .OrderByDesc(function(const A, B: Integer): Integer begin Result := A - B end)
  .ToArray;
// Result: [5, 4, 3, 1, 1]
```

## Order / OrderDescending

Shorthand operators that rely on the default `IComparer<T>` for the element type:

```delphi
var LResult := TColligoArray<Integer>.From([3, 1, 2])
  .Order
  .ToArray;
// Result: [1, 2, 3]

var LDesc := TColligoArray<Integer>.From([3, 1, 2])
  .OrderDescending
  .ToArray;
// Result: [3, 2, 1]
```

Pass a custom `IComparer<T>` if needed:

```delphi
var LResult := TColligoArray<string>.From(['b', 'A', 'c'])
  .Order(TStringComparer.OrdinalIgnoreCase)
  .ToArray;
```

## ThenBy / ThenByDescending

Secondary sort keys applied after an `OrderBy`:

```delphi
// function ThenBy<TKey>(const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>;
// function ThenByDescending<TKey>(const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>;
```

```delphi
type TEmployee = record Dept: string; Name: string; end;

var LResult := TColligoArray<TEmployee>.From(LEmployees)
  .OrderBy(function(const A, B: TEmployee): Integer
    begin Result := CompareText(A.Dept, B.Dept) end)
  .ThenBy<string>(function(const E: TEmployee): string begin Result := E.Name end)
  .ToArray;
```

## MinBy / MaxBy

Return the element with the minimum or maximum key. Both take a key selector and a raw comparator function (`TFunc<TKey, TKey, Integer>`):

```delphi
// function MinBy<TKey>(
//   const AKeySelector: TFunc<T, TKey>;
//   const AComparer: TFunc<TKey, TKey, Integer>): T;
// function MaxBy<TKey>(
//   const AKeySelector: TFunc<T, TKey>;
//   const AComparer: TFunc<TKey, TKey, Integer>): T;
```

```delphi
type TProduct = record Name: string; Price: Double; end;

var LProducts: TArray<TProduct>;
// Assume LProducts is populated...

// Cheapest product
var LCheapest := TColligoArray<TProduct>.From(LProducts)
  .MinBy<Double>(
    function(const P: TProduct): Double begin Result := P.Price end,
    function(const A, B: Double): Integer begin Result := Sign(A - B) end);

// Most expensive product
var LMostExpensive := TColligoArray<TProduct>.From(LProducts)
  .MaxBy<Double>(
    function(const P: TProduct): Double begin Result := P.Price end,
    function(const A, B: Double): Integer begin Result := Sign(A - B) end);
```
