---
title: Set operations — Union, Intersect, Concat, Exclude
sidebar_position: 5
---

# Set operations

Colligo supports all four classic set operations on two sequences.

## Union

`Union` returns distinct elements from both sequences (like SQL UNION):

```delphi
var LA := TColligoArray<Integer>.From([1, 2, 3]);
var LB := TColligoArray<Integer>.From([3, 4, 5]);

var LResult := LA.Union(LB).ToArray;
// Result: [1, 2, 3, 4, 5]
```

### UnionBy

Deduplicate by key when merging:

```delphi
// function UnionBy<TKey>(
//   const ASecond: IColligoEnumerable<T>;
//   const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>;
```

## Intersect

`Intersect` returns elements that appear in both sequences:

```delphi
var LA := TColligoArray<Integer>.From([1, 2, 3, 4]);
var LB := TColligoArray<Integer>.From([2, 4, 6]);

var LResult := LA.Intersect(LB).ToArray;
// Result: [2, 4]
```

### IntersectBy

```delphi
// function IntersectBy<TKey>(
//   const ASecond: IColligoEnumerable<TKey>;
//   const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>;
```

## Concat

`Concat` appends all elements of the second sequence to the first (no deduplication):

```delphi
var LA := TColligoArray<Integer>.From([1, 2]);
var LB := TColligoArray<Integer>.From([3, 4]);

var LResult := LA.Concat(LB).ToArray;
// Result: [1, 2, 3, 4]
```

## Exclude (set difference)

`Exclude` returns elements from the first sequence that do not appear in the second:

```delphi
var LA := TColligoArray<Integer>.From([1, 2, 3, 4, 5]);
var LB := TColligoArray<Integer>.From([2, 4]);

var LResult := LA.Exclude(LB).ToArray;
// Result: [1, 3, 5]
```

## SequenceEqual

`SequenceEqual` returns `True` if both sequences contain the same elements in the same order:

```delphi
var LA := TColligoArray<Integer>.From([1, 2, 3]);
var LB := TColligoArray<Integer>.From([1, 2, 3]);

var LSame := LA.SequenceEqual(LB); // True
```
