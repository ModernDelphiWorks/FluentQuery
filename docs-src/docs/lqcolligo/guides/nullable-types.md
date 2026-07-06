---
title: Nullable types
sidebar_position: 10
---

# Nullable types — LQColligoNullable

LQ-Colligo defines `LQColligoNullable<T>` in `LQColligo.Core` — a generic record that wraps any value type with a `HasValue` flag, similar to C# `Nullable<T>`.

## Type aliases

```delphi
type
  NullableInt32    = LQColligoNullable<Int32>;
  NullableInt64    = LQColligoNullable<Int64>;
  NullableSingle   = LQColligoNullable<Single>;
  NullableCurrency = LQColligoNullable<Currency>;
  NullableDouble   = LQColligoNullable<Double>;
```

## Creating nullable values

```delphi
uses LQColligo.Core;

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

Several `Sum`, `Average`, `Min`, `Max` overloads on `ILQColligoEnumerable<T>` accept nullable selectors. They skip elements where `HasValue = False`:

```delphi
type TItem = record Price: NullableDouble; end;

var LTotal := TLQColligoArray<TItem>.From(LItems)
  .Sum(function(const I: TItem): NullableDouble begin Result := I.Price end);
// Skips items where Price.HasValue = False
// Raises EInvalidOperation if all items have HasValue = False
```

:::warning Empty sequence behaviour
Nullable aggregations raise `EInvalidOperation` when no element has a value. Use a `Where` filter before aggregating if the empty case is possible.
:::
