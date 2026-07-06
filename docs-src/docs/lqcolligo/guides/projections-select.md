---
title: Projections — Select / SelectMany
sidebar_position: 2
---

# Projections — Select / SelectMany

Projection operators transform elements from one type to another.

## Select

`Select<TResult>` maps each element to a new value.

```delphi
var LResult := TLQColligoArray<Integer>.From([1, 2, 3])
  .Select<string>(function(const X: Integer): string
  begin
    Result := 'Item ' + IntToStr(X);
  end)
  .ToArray;
// Result: ['Item 1', 'Item 2', 'Item 3']
```

### Select with index

An overload passes the element index as the second argument:

```delphi
// function Select<TResult>(
//   const ASelector: TFunc<T, Integer, TResult>): ILQColligoEnumerable<TResult>;

var LResult := TLQColligoArray<string>.From(['a', 'b', 'c'])
  .Select<string>(function(const S: string; const Index: Integer): string
  begin
    Result := IntToStr(Index) + ':' + S;
  end)
  .ToArray;
// Result: ['0:a', '1:b', '2:c']
```

## SelectMany

`SelectMany<TResult>` flattens a sequence of sequences (one-to-many projection).

```delphi
type TOrder = record Lines: TArray<string>; end;

var LResult := TLQColligoArray<TOrder>.From(LOrders)
  .SelectMany<string>(function(const O: TOrder): TArray<string>
  begin
    Result := O.Lines;
  end)
  .ToArray;
// Flat array of all order lines
```

### SelectMany with collection selector and result selector

The two-selector overload first expands each source element into a sub-array (`ACollectionSelector`) and then combines each source element with each sub-element (`AResultSelector`):

```delphi
// function SelectMany<TCollection, TResult>(
//   const ACollectionSelector: TFunc<T, TArray<TCollection>>;
//   const AResultSelector: TFunc<T, TCollection, TResult>): ILQColligoEnumerable<TResult>;
```

```delphi
type
  TOrder = record Id: Integer; Lines: TArray<string>; end;
  TLineDetail = record OrderId: Integer; Line: string; end;

var LOrders: TArray<TOrder>;
// Assume LOrders is populated...

var LResult := TLQColligoArray<TOrder>.From(LOrders)
  .SelectMany<string, TLineDetail>(
    // expand: one order → its lines
    function(const O: TOrder): TArray<string>
    begin
      Result := O.Lines;
    end,
    // combine: (order, line) → TLineDetail
    function(const O: TOrder; const Line: string): TLineDetail
    begin
      Result.OrderId := O.Id;
      Result.Line    := Line;
    end)
  .ToArray;
// Flat array of TLineDetail, one per order line
```

## Append / Prepend

Add a single element at the end or beginning of a sequence without modifying the original:

```delphi
var LResult := TLQColligoArray<Integer>.From([2, 3])
  .Prepend(1)
  .Append(4)
  .ToArray;
// Result: [1, 2, 3, 4]
```

## Reverse

`Reverse` reverses the order of elements:

```delphi
var LResult := TLQColligoArray<Integer>.From([1, 2, 3])
  .Reverse
  .ToArray;
// Result: [3, 2, 1]
```

## DefaultIfEmpty

`DefaultIfEmpty` returns the sequence unchanged if it is non-empty, or a single default element if empty:

```delphi
var LResult := TLQColligoArray<Integer>.From([])
  .DefaultIfEmpty(0)
  .ToArray;
// Result: [0]
```
