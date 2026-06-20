---
title: Grouping
sidebar_position: 8
---

# Grouping

`GroupBy` partitions a sequence into groups sharing the same key.

## GroupBy with key selector

```delphi
// function GroupBy<TKey>(
//   const AKeySelector: TFunc<T, TKey>): IGroupByEnumerable<TKey, T>;
```

The result implements `IGroupByEnumerable<TKey, T>`, which is iterable via `for … in`. Each element is an `IGrouping<TKey, T>`:

- `Key` — the group's key value.
- `Items` — an `IFluentEnumerable<T>` of the group's elements.

```delphi
type TProduct = record Category: string; Name: string; Price: Double; end;

var LProducts: TArray<TProduct>;
// Assume LProducts is populated...

var LGroups := TFluentArray<TProduct>.From(LProducts)
  .GroupBy<string>(
    function(const P: TProduct): string
    begin
      Result := P.Category;
    end);

var LGroup: IGrouping<string, TProduct>;
for LGroup in LGroups do
begin
  Writeln('Category: ', LGroup.Key);
  var LItem: TProduct;
  for LItem in LGroup.Items do
    Writeln('  ', LItem.Name, ' $', LItem.Price:0:2);
end;
```

## GroupBy with element selector

Projects each element before grouping:

```delphi
// function GroupBy<TKey, TElement>(
//   const AKeySelector: TFunc<T, TKey>;
//   const AElementSelector: TFunc<T, TElement>): IGroupByEnumerable<TKey, TElement>;
```

## GroupBy with result selector

Projects each group to a result value:

```delphi
// function GroupBy<TKey, TResult>(
//   const AKeySelector: TFunc<T, TKey>;
//   const AResultSelector: TFunc<TKey, IFluentEnumerableAdapter<T>, TResult>)
//     : IFluentEnumerable<TResult>;
```

<!-- TODO: confirm — add concrete GroupBy with result selector example -->

## Converting GroupBy output

`IGroupByEnumerable<TKey, T>` can be converted to a plain enumerable via `AsEnumerable`:

```delphi
var LEnumerable := TFluentArray<TProduct>.From(LProducts)
  .GroupBy<string>(function(const P: TProduct): string begin Result := P.Category end)
  .AsEnumerable;
// IFluentEnumerable<IGrouping<string, TProduct>>
```
