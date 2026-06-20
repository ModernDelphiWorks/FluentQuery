---
title: Nullable types
sidebar_position: 10
---

# Nullable types — FluentNullable

FluentQuery defines `FluentNullable<T>` in `FluentQuery.Core` — a generic record that wraps any value type with a `HasValue` flag, similar to C# `Nullable<T>`.

## Type aliases

```delphi
type
  NullableInt32    = FluentNullable<Int32>;
  NullableInt64    = FluentNullable<Int64>;
  NullableSingle   = FluentNullable<Single>;
  NullableCurrency = FluentNullable<Currency>;
  NullableDouble   = FluentNullable<Double>;
```

## Creating nullable values

```delphi
uses FluentQuery.Core;

var LValue: NullableInt32;

// With a value:
LValue := NullableInt32.Create(42);
Writeln(LValue.HasValue); // True
Writeln(LValue.Value);    // 42

// Empty:
LValue := NullableInt32.CreateEmpty;
Writeln(LValue.HasValue); // False
// LValue.Value → raises EInvalidOperation
```

## Implicit conversion

```delphi
var LValue: NullableInt32 := 100; // implicit from Int32
var LRaw: Int32 := LValue;        // implicit to Int32 (raises if HasValue = False)
```

## Equality

```delphi
var LA: NullableInt32 := 5;
var LB: NullableInt32 := 5;
if LA = LB then ...  // True — both have value 5
```

## Use with aggregation operators

Several `Sum`, `Average`, `Min`, `Max` overloads on `IFluentEnumerable<T>` accept nullable selectors. They skip elements where `HasValue = False`:

```delphi
type TItem = record Price: NullableDouble; end;

var LTotal := TFluentArray<TItem>.From(LItems)
  .Sum(function(const I: TItem): NullableDouble begin Result := I.Price end);
// Skips items where Price.HasValue = False
// Raises EInvalidOperation if all items have HasValue = False
```

:::warning Empty sequence behaviour
Nullable aggregations raise `EInvalidOperation` when no element has a value. Use a `Where` filter before aggregating if the empty case is possible.
:::
