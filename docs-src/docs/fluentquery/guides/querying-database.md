---
title: Querying the database
sidebar_position: 9
---

# Querying the database — IFluentQueryable

`IFluentQueryable<T>` translates a fluent operator chain into SQL executed against a live database connection. It requires **FluentSQL** for SQL generation and a **DataEngine** connection.

:::note Compile-time gate
`IFluentQueryable<T>` implementation is gated behind the `{$DEFINE QUERYABLE}` compiler directive in `FluentQuery.Queryable.pas`. The type declarations are always available; the method bodies compile only when `QUERYABLE` is defined.
:::

## Setup

```delphi
uses
  FluentQuery,
  FluentQuery.Queryable;
```

### Creating a queryable from a connection

```delphi
var LQuery: IFluentQueryable<TCustomer>;
LQuery := IFluentQueryable<TCustomer>.CreateForDatabase(
  procedure(var ADatabase: TDBEngineDriver; var AConnection: IDBConnection)
  begin
    ADatabase  := dnFirebird;      // from DataEngine.FactoryInterfaces
    AConnection := MyDBConnection; // your IDBConnection implementation
  end);
```

Or with explicit parameters:

```delphi
LQuery := IFluentQueryable<TCustomer>.CreateForDatabase(
  dnFirebird,
  MyDBConnection
  {, optional pre-built IFluentSQLAST }
);
```

## Basic SELECT

```delphi
var LCustomers := LQuery
  .From('CUSTOMERS')
  .Where('ACTIVE = 1')
  .Select('ID, NAME, EMAIL')
  .ToList;
// Executes: SELECT ID, NAME, EMAIL FROM CUSTOMERS WHERE ACTIVE = 1
```

## WHERE with typed expressions

Use `QE` (query expression factory) for typed WHERE conditions:

```delphi
var LResult := LQuery
  .From('ORDERS')
  .Where(LQuery.QE.Field('TOTAL').GreaterThan(100.0))
  .ToArray;
```

### IFluentQueryExpression operators

`IFluentQueryExpression` (from `FluentQuery.Expression`) supports:

- `Field(name)` — selects a field
- `Equal`, `NotEqual`, `GreaterThan`, `LessThan`, `GreaterThanOrEqual`, `LessThanOrEqual`
- `IsNull`, `IsNotNull`
- `Like`, `NotLike`, `Contains`, `StartsWith`, `EndsWith`
- `InValues`, `NotInValues`
- `Exists`, `NotExists`
- `AndWith`, `OrWith`

## Joins

```delphi
var LResult := LQuery
  .From('ORDERS', 'O')
  .InnerJoin('CUSTOMERS', 'C')
  .OnCond('O.CUSTOMER_ID = C.ID')
  .Select('O.ID, C.NAME, O.TOTAL')
  .Where('O.TOTAL > 500')
  .ToList;
```

## OrderBy / ThenBy

```delphi
var LResult := LQuery
  .From('PRODUCTS')
  .OrderBy('CATEGORY')
  .ThenBy(LQuery.QE.Field('PRICE'))
  .ToList;
```

## Take / Skip (pagination)

```delphi
var LPage := LQuery
  .From('ORDERS')
  .OrderBy('ID')
  .Skip(20)
  .Take(10)
  .ToList;
// Page 3 of 10 records per page
```

## Aggregations on DB

```delphi
var LTotal := LQuery
  .From('ORDERS')
  .Where('CUSTOMER_ID = 42')
  .Sum<Double>('TOTAL');

var LCount := LQuery
  .From('ORDERS')
  .Count;
```

## AsString — inspect generated SQL

```delphi
var LSQL := LQuery
  .From('PRODUCTS')
  .Where('ACTIVE = 1')
  .Select('ID, NAME')
  .AsString;
Writeln(LSQL);
// SELECT ID, NAME FROM PRODUCTS WHERE ACTIVE = 1
```

## Supported databases

`IFluentQueryable<T>` delegates SQL generation to FluentSQL, which supports:

`MSSQL`, `MySQL`, `Firebird`, `SQLite`, `Interbase`, `DB2`, `Oracle`, `Informix`, `PostgreSQL`, `ADS`, `ASA`, `AbsoluteDB`, `MongoDB`, `ElevateDB`, `NexusDB`.

<!-- TODO: confirm — document DataEngine.FactoryInterfaces connection contract -->
