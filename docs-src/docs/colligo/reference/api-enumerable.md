---
title: IColligoEnumerable API
sidebar_position: 1
---

# IColligoEnumerable&lt;T&gt; API reference

`IColligoEnumerable<T>` is the core record type in `Colligo.pas`. All intermediate operators return a new `IColligoEnumerable<T>`. Terminal operators materialise the results.

## Construction

| Factory | Description |
|---|---|
| `TColligoArray<T>.From(AArray: TArray<T>)` | Wrap a typed dynamic array |
| `TColligoArray.From<T>(AArray: array of T)` | Wrap an open array |
| `TColligoList<T>.From(AList: TList<T>)` | Wrap a TList |
| `TColligoList<T>.From(AArray: TArray<T>)` | Wrap a TArray via list |
| `IColligoEnumerable<T>.Create(AEnumerator, ...)` | Wrap any `IColligoEnumerableBase<T>` |

## Filtering operators

| Method | Signature | Description |
|---|---|---|
| `Where` | `(APredicate: TFunc<T, Boolean>): IColligoEnumerable<T>` | Keep matching elements |
| `Distinct` | `(): IColligoEnumerable<T>` | Remove duplicates (default comparer) |
| `Distinct` | `(AComparer: IEqualityComparer<T>): IColligoEnumerable<T>` | Remove duplicates (custom comparer) |
| `DistinctBy<TKey>` | `(AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>` | Deduplicate by key |
| `OfType<TResult>` | `(AIsType, AConverter): IColligoEnumerable<TResult>` | Filter by type and convert |
| `Cast<TResult>` | `(): IColligoEnumerable<TResult>` | Re-interpret element type |
| `Exclude` | `(ASecond: IColligoEnumerable<T>): IColligoEnumerable<T>` | Set difference |
| `ExcludeBy<TKey>` | `(ASecond, AKeySelector): IColligoEnumerable<T>` | Set difference by key |
| `Intersect` | `(ASecond: IColligoEnumerable<T>): IColligoEnumerable<T>` | Set intersection |
| `IntersectBy<TKey>` | `(ASecond, AKeySelector): IColligoEnumerable<T>` | Intersection by key |

## Projection operators

| Method | Signature | Description |
|---|---|---|
| `Select<TResult>` | `(ASelector: TFunc<T, TResult>): IColligoEnumerable<TResult>` | Map each element |
| `Select<TResult>` | `(ASelector: TFunc<T, Integer, TResult>)` | Map with index |
| `SelectMany<TResult>` | `(ASelector: TFunc<T, TArray<TResult>>): IColligoEnumerable<TResult>` | Flatten |
| `SelectMany<TCollection, TResult>` | `(ACollectionSelector, AResultSelector)` | Flatten + project |
| `Append` | `(AElement: T): IColligoEnumerable<T>` | Append single element |
| `Prepend` | `(AElement: T): IColligoEnumerable<T>` | Prepend single element |
| `Reverse` | `(): IColligoEnumerable<T>` | Reverse order |
| `DefaultIfEmpty` | `(): IColligoEnumerable<T>` | Default element if empty |
| `DefaultIfEmpty` | `(ADefaultValue: T): IColligoEnumerable<T>` | Custom default |

## Partitioning operators

| Method | Signature | Description |
|---|---|---|
| `Take` | `(ACount: Integer): IColligoEnumerable<T>` | First N elements |
| `TakeWhile` | `(APredicate: TFunc<T, Boolean>)` | Take while predicate holds |
| `TakeWhile` | `(APredicate: TFunc<T, Integer, Boolean>)` | Take while (with index) |
| `TakeLast` | `(ACount: Integer): IColligoEnumerable<T>` | Last N elements |
| `Skip` | `(ACount: Integer): IColligoEnumerable<T>` | Skip first N |
| `SkipWhile` | `(APredicate: TFunc<T, Boolean>)` | Skip while predicate holds |
| `SkipWhile` | `(APredicate: TFunc<T, Integer, Boolean>)` | Skip while (with index) |
| `SkipLast` | `(ACount: Integer): IColligoEnumerable<T>` | Skip last N |
| `ElementAt` | `(AIndex: Integer): T` | Element at index |
| `ElementAtOrDefault` | `(AIndex: Integer): T` | Element at index or default |

## Ordering operators

| Method | Signature | Description |
|---|---|---|
| `OrderBy` | `(AComparer: TFunc<T, T, Integer>)` | Sort ascending |
| `OrderBy<TKey>` | `(AKeySelector, AComparer)` | Sort ascending by key |
| `OrderByDesc` | `(AComparer: TFunc<T, T, Integer>)` | Sort descending |
| `Order` | `(): IColligoEnumerable<T>` | Sort by default comparer |
| `Order` | `(AComparer: IComparer<T>)` | Sort by custom comparer |
| `OrderDescending` | `(): IColligoEnumerable<T>` | Sort desc by default |
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

Or use `for … in` directly on `IColligoEnumerable<T>`.
