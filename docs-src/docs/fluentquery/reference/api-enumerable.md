---
title: IFluentEnumerable API
sidebar_position: 1
---

# IFluentEnumerable&lt;T&gt; API reference

`IFluentEnumerable<T>` is the core record type in `FluentQuery.pas`. All intermediate operators return a new `IFluentEnumerable<T>`. Terminal operators materialise the results.

## Construction

| Factory | Description |
|---|---|
| `TFluentArray<T>.From(AArray: TArray<T>)` | Wrap a typed dynamic array |
| `TFluentArray.From<T>(AArray: array of T)` | Wrap an open array |
| `TFluentList<T>.From(AList: TList<T>)` | Wrap a TList |
| `TFluentList<T>.From(AArray: TArray<T>)` | Wrap a TArray via list |
| `IFluentEnumerable<T>.Create(AEnumerator, ...)` | Wrap any `IFluentEnumerableBase<T>` |

## Filtering operators

| Method | Signature | Description |
|---|---|---|
| `Where` | `(APredicate: TFunc<T, Boolean>): IFluentEnumerable<T>` | Keep matching elements |
| `Distinct` | `(): IFluentEnumerable<T>` | Remove duplicates (default comparer) |
| `Distinct` | `(AComparer: IEqualityComparer<T>): IFluentEnumerable<T>` | Remove duplicates (custom comparer) |
| `DistinctBy<TKey>` | `(AKeySelector: TFunc<T, TKey>): IFluentEnumerable<T>` | Deduplicate by key |
| `OfType<TResult>` | `(AIsType, AConverter): IFluentEnumerable<TResult>` | Filter by type and convert |
| `Cast<TResult>` | `(): IFluentEnumerable<TResult>` | Re-interpret element type |
| `Exclude` | `(ASecond: IFluentEnumerable<T>): IFluentEnumerable<T>` | Set difference |
| `ExcludeBy<TKey>` | `(ASecond, AKeySelector): IFluentEnumerable<T>` | Set difference by key |
| `Intersect` | `(ASecond: IFluentEnumerable<T>): IFluentEnumerable<T>` | Set intersection |
| `IntersectBy<TKey>` | `(ASecond, AKeySelector): IFluentEnumerable<T>` | Intersection by key |

## Projection operators

| Method | Signature | Description |
|---|---|---|
| `Select<TResult>` | `(ASelector: TFunc<T, TResult>): IFluentEnumerable<TResult>` | Map each element |
| `Select<TResult>` | `(ASelector: TFunc<T, Integer, TResult>)` | Map with index |
| `SelectMany<TResult>` | `(ASelector: TFunc<T, TArray<TResult>>): IFluentEnumerable<TResult>` | Flatten |
| `SelectMany<TCollection, TResult>` | `(ACollectionSelector, AResultSelector)` | Flatten + project |
| `Append` | `(AElement: T): IFluentEnumerable<T>` | Append single element |
| `Prepend` | `(AElement: T): IFluentEnumerable<T>` | Prepend single element |
| `Reverse` | `(): IFluentEnumerable<T>` | Reverse order |
| `DefaultIfEmpty` | `(): IFluentEnumerable<T>` | Default element if empty |
| `DefaultIfEmpty` | `(ADefaultValue: T): IFluentEnumerable<T>` | Custom default |

## Partitioning operators

| Method | Signature | Description |
|---|---|---|
| `Take` | `(ACount: Integer): IFluentEnumerable<T>` | First N elements |
| `TakeWhile` | `(APredicate: TFunc<T, Boolean>)` | Take while predicate holds |
| `TakeWhile` | `(APredicate: TFunc<T, Integer, Boolean>)` | Take while (with index) |
| `TakeLast` | `(ACount: Integer): IFluentEnumerable<T>` | Last N elements |
| `Skip` | `(ACount: Integer): IFluentEnumerable<T>` | Skip first N |
| `SkipWhile` | `(APredicate: TFunc<T, Boolean>)` | Skip while predicate holds |
| `SkipWhile` | `(APredicate: TFunc<T, Integer, Boolean>)` | Skip while (with index) |
| `SkipLast` | `(ACount: Integer): IFluentEnumerable<T>` | Skip last N |
| `ElementAt` | `(AIndex: Integer): T` | Element at index |
| `ElementAtOrDefault` | `(AIndex: Integer): T` | Element at index or default |

## Ordering operators

| Method | Signature | Description |
|---|---|---|
| `OrderBy` | `(AComparer: TFunc<T, T, Integer>)` | Sort ascending |
| `OrderBy<TKey>` | `(AKeySelector, AComparer)` | Sort ascending by key |
| `OrderByDesc` | `(AComparer: TFunc<T, T, Integer>)` | Sort descending |
| `Order` | `(): IFluentEnumerable<T>` | Sort by default comparer |
| `Order` | `(AComparer: IComparer<T>)` | Sort by custom comparer |
| `OrderDescending` | `(): IFluentEnumerable<T>` | Sort desc by default |
| `OrderDescending` | `(AComparer: IComparer<T>)` | Sort desc by custom |
| `ThenBy<TKey>` | `(AKeySelector: TFunc<T, TKey>)` | Secondary sort ascending |
| `ThenByDescending<TKey>` | `(AKeySelector: TFunc<T, TKey>)` | Secondary sort descending |

## Set operators

| Method | Description |
|---|---|
| `Union(ASecond)` | Distinct elements from both |
| `UnionBy<TKey>(ASecond, AKeySelector)` | Union by key |
| `Intersect(ASecond)` | Elements in both |
| `Concat(ASecond)` | Concatenate (no dedup) |
| `Exclude(ASecond)` | Elements not in second |
| `SequenceEqual(ASecond)` | True if identical sequences |

## Join operators

| Method | Description |
|---|---|
| `Join<TInner, TKey, TResult>(AInner, AOuterKey, AInnerKey, AResultSelector)` | Inner join |
| `GroupJoin<TInner, TKey, TResult>(AInner, AOuterKey, AInnerKey, AResultSelector)` | Left outer join |
| `Zip<TSecond, TResult>(ASecond, AResultSelector)` | Element-by-element combine |

## Aggregation operators (terminal)

| Method | Returns | Description |
|---|---|---|
| `Count` | `Integer` | Total elements |
| `Count(APredicate)` | `Integer` | Matching elements |
| `LongCount` | `Int64` | Total elements (long) |
| `LongCount(APredicate)` | `Int64` | Matching (long) |
| `Sum(ASelector)` | numeric | Sum of projected values |
| `SumCurrency(ASelector)` | `Currency` | Sum as Currency |
| `SumInt32(ASelector)` | `Int32` | Sum as Int32 |
| `Average(ASelector)` | numeric | Average of projected values |
| `Min` | `T` | Minimum element |
| `Min(ASelector)` | numeric | Minimum of projected values |
| `MinBy<TKey>(AKeySelector, AComparer)` | `T` | Element with min key |
| `Max` | `T` | Maximum element |
| `Max(ASelector)` | numeric | Maximum of projected values |
| `MaxBy<TKey>(AKeySelector, AComparer)` | `T` | Element with max key |
| `Any` | `Boolean` | Non-empty |
| `Any(APredicate)` | `Boolean` | Any match |
| `All(APredicate)` | `Boolean` | All match |
| `Contains(AValue)` | `Boolean` | Contains value |
| `Contains(AValue, AComparer)` | `Boolean` | Contains (custom comparer) |
| `First` | `T` | First element (raises if empty) |
| `First(APredicate)` | `T` | First matching (raises if none) |
| `FirstOrDefault` | `T` | First or Default(T) |
| `FirstOrDefault(APredicate)` | `T` | First matching or Default(T) |
| `Last` | `T` | Last element |
| `Last(APredicate)` | `T` | Last matching |
| `LastOrDefault` | `T` | Last or Default(T) |
| `LastOrDefault(APredicate)` | `T` | Last matching or Default(T) |
| `Single` | `T` | Exactly one element |
| `Single(APredicate)` | `T` | Exactly one matching |
| `SingleOrDefault` | `T` | Zero or one element |
| `SingleOrDefault(APredicate)` | `T` | Zero or one matching |
| `Aggregate(AReducer)` | `T` | Fold without seed |
| `Aggregate<TAcc>(ASeed, AAccumulator)` | `TAcc` | Fold with seed |
| `Aggregate<TAcc, TResult>(...)` | `TResult` | Fold + result selector |
| `AggregateBy<TKey, TAcc>(...)` | `TDictionary<TKey, TAcc>` | Per-group fold |
| `CountBy<TKey>(AKeySelector)` | `TDictionary<TKey, Integer>` | Count per group |

## Materialisation (terminal)

| Method | Returns | Description |
|---|---|---|
| `ToArray` | `IFluentArray<T>` | Execute pipeline, return array |
| `ToList` | `IFluentList<T>` | Execute pipeline, return list |
| `ToHashSet` | `THashSet<T>` | Execute pipeline, return hash set |
| `ToDictionary<TKey, TValue>(...)` | `TDictionary<TKey, TValue>` | Execute, return dictionary |
| `ToLookup<TKey, TElement>(...)` | `TDictionary<TKey, TList<TElement>>` | Execute, return lookup |
| `TryGetNonEnumeratedCount(out ACount)` | `Boolean` | Count without iterating (if source supports it) |

## Iteration

```delphi
var LEnum: IFluentEnumerator<T>;
LEnum := MyEnumerable.GetEnumerator;
while LEnum.MoveNext do
  Process(LEnum.Current);
```

Or use `for … in` directly on `IFluentEnumerable<T>`.
