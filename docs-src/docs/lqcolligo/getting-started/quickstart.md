---
title: Quickstart
sidebar_position: 2
---

# Quickstart

This page shows the most common LQ-Colligo patterns so you can be productive in minutes.

## 1. Basic filtering and projection

```delphi
uses
  System.SysUtils,
  LQColligo;

var
  LNumbers: TArray<Integer>;
  LResult: IFluentArray<string>;
begin
  LNumbers := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];

  // Fluent chain — no intermediate arrays are created during execution.
  LResult := TLQColligoArray<Integer>.From(LNumbers)
    .Where(
      function(const X: Integer): Boolean
      begin
        Result := (X mod 2 = 0); // Keep even numbers
      end)
    .Take(3)
    .Select<string>(
      function(const X: Integer): string
      begin
        Result := 'Number ' + IntToStr(X);
      end)
    .ToArray;

  // LResult contains: ['Number 2', 'Number 4', 'Number 6']
end;
```

## 2. Ordering and pagination

```delphi
uses
  LQColligo;

type
  TUser = record
    Name: string;
    Email: string;
  end;

var
  LUsers: TArray<TUser>;
  LResult: IFluentArray<string>;
begin
  // Assume LUsers is populated...

  LResult := TLQColligoArray<TUser>.From(LUsers)
    .OrderBy(
      function(const A, B: TUser): Integer
      begin
        Result := CompareText(A.Name, B.Name);
      end)
    .Skip(10)   // Pagination: skip first 10
    .Take(5)    // Take next 5
    .Select<string>(
      function(const U: TUser): string
      begin
        Result := U.Email;
      end)
    .ToArray;
end;
```

## 3. Aggregation — count, sum, average

```delphi
uses
  LQColligo;

var
  LPrices: TArray<Double>;
  LTotal: Double;
  LCount: Integer;
begin
  LPrices := [10.0, 20.5, 30.0, 5.5];

  LTotal := TLQColligoArray<Double>.From(LPrices)
    .Sum(function(const X: Double): Double begin Result := X end);
  // LTotal = 66.0

  LCount := TLQColligoArray<Double>.From(LPrices)
    .Count(function(const X: Double): Boolean begin Result := X > 10.0 end);
  // LCount = 2
end;
```

## 4. Working with TLQColligoList

`TLQColligoList<T>` is LQ-Colligo's interface-backed replacement for `TList<T>`. It converts directly to an enumerable pipeline.

```delphi
uses
  LQColligo,
  LQColligo.Collections;

var
  LList: IFluentList<Integer>;
  LResult: IFluentArray<Integer>;
begin
  LList := TLQColligoList<Integer>.Create;
  LList.Add(3);
  LList.Add(1);
  LList.Add(4);
  LList.Add(1);
  LList.Add(5);

  LResult := LList.AsEnumerable
    .Distinct
    .OrderBy(function(const A, B: Integer): Integer begin Result := A - B end)
    .ToArray;

  // LResult: [1, 3, 4, 5]
end;
```

## 5. GroupBy

```delphi
uses
  LQColligo;

type
  TProduct = record
    Category: string;
    Price: Double;
  end;

var
  LProducts: TArray<TProduct>;
  LGroup: IGrouping<string, TProduct>;
begin
  // Assume LProducts is populated...

  var LGroups := TLQColligoArray<TProduct>.From(LProducts)
    .GroupBy<string>(
      function(const P: TProduct): string
      begin
        Result := P.Category;
      end);

  for LGroup in LGroups do
  begin
    Writeln('Category: ', LGroup.Key);
    // LGroup.Items is ILQColligoEnumerable<TProduct>
  end;
end;
```

## Next steps

- [Filtering collections](../guides/filtering-collections.md) — all filter operators
- [Aggregations](../guides/aggregations.md) — Sum, Average, Min, Max, Count
- [Querying the database](../guides/querying-database.md) — `ILQColligoQueryable<T>`
