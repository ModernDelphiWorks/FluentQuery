---
title: IColligoQueryable API
sidebar_position: 2
---

# IColligoQueryable&lt;T&gt; API reference

`IColligoQueryable<T>` is a value record in `Colligo.Queryable` that builds and executes SQL queries through a FluentSQL AST and a DataEngine connection.

:::note
Method bodies are compiled only when `{$DEFINE QUERYABLE}` is active.
:::

## Constructors

| Constructor | Description |
|---|---|
| `Create(AQueryable: IColligoQueryableBase<T>)` | Wrap an existing queryable |
| `CreateForDatabase(AInitializer: TConnectionInitializer)` | Lambda-style init |
| `CreateForDatabase(ADatabase, AConnection [, ACQL])` | Explicit parameters |

## Query building operators (intermediate)

| Method | SQL clause | Notes |
|---|---|---|
| `From(ATableName)` | `FROM` | |
| `From(ATableName, AAlias)` | `FROM … AS` | |
| `Select(AColumns)` | `SELECT` | Defaults to `*` |
| `Select(AExpressions)` | `SELECT` | Array of `IColligoQueryExpression` |
| `Where(AExpression: string)` | `WHERE` | Raw SQL fragment |
| `Where(AExpression: array of const)` | `WHERE` | Variadic |
| `Where(AExpression: IColligoQueryExpression)` | `WHERE` | Type-safe expression |
| `AndOpe(…)` | `AND` | String, variadic, or expression |
| `OrOpe(…)` | `OR` | String, variadic, or expression |
| `InnerJoin(ATableName [, AAlias])` | `INNER JOIN` | |
| `OnCond(AExpression)` | `ON` | String or variadic |
| `Alias(AAlias)` | Sets alias for current table | |
| `GroupBy(AColumnName)` | `GROUP BY` | |
| `GroupBy<TKey>(AExpression)` | `GROUP BY` | Returns `IGroupByQueryable<TKey, T>` |
| `OrderBy(AColumnName)` | `ORDER BY` | |
| `OrderBy(AExpression)` | `ORDER BY` | Expression |
| `OrderByDesc(AExpression)` | `ORDER BY … DESC` | |
| `ThenBy(AExpression)` | Secondary `ORDER BY` | Ascending |
| `ThenByDescending(AExpression)` | Secondary `ORDER BY` | Descending |
| `Take(ACount)` | `FIRST N` / `LIMIT N` | Dialect-dependent |
| `Skip(ACount)` | `SKIP N` / `OFFSET N` | Dialect-dependent |
| `Distinct` | `SELECT DISTINCT` | |
| `Union(ASecond)` | `UNION` | |
| `Intersect(ASecond)` | `INTERSECT` | |
| `Exclude(ASecond)` | `EXCEPT` / `MINUS` | Dialect-dependent |
| `Join<TInner, TResult>(AInner, AOuterKey, AInnerKey, AResultColumns)` | `INNER JOIN` | Returns `IColligoQueryable<TResult>` |

## Expression factory

```delphi
function QE: IColligoQueryExpression;
```

Returns a typed expression builder scoped to the current database dialect.

```delphi
var LQ: IColligoQueryable<TProduct>;
// ...
var LExpr := LQ.QE.Field('PRICE').GreaterThan(50.0);
LQ := LQ.Where(LExpr);
```

## Terminal operators

| Method | Returns | Description |
|---|---|---|
| `ToArray` | `IFluentArray<T>` | Execute and return all rows |
| `ToList` | `IFluentList<T>` | Execute and return list |
| `First` | `T` | `FIRST 1`, raises if empty |
| `First(AExpression)` | `T` | With WHERE, raises if empty |
| `FirstOrDefault` | `T` | `FIRST 1`, returns Default(T) if empty |
| `FirstOrDefault(AExpression)` | `T` | With WHERE |
| `Last` | `T` | `ORDER BY … DESC FIRST 1` |
| `Last(AExpression)` | `T` | With WHERE |
| `LastOrDefault` | `T` | As Last but safe |
| `LastOrDefault(AExpression)` | `T` | With WHERE |
| `Single` | `T` | Exactly one row; raises otherwise |
| `Single(AExpression)` | `T` | With WHERE |
| `SingleOrDefault` | `T` | Zero or one row |
| `SingleOrDefault(AExpression)` | `T` | With WHERE |
| `ElementAt(AIndex)` | `T` | `Skip(N).Take(1)` |
| `ElementAtOrDefault(AIndex)` | `T` | Safe version |
| `Any` | `Boolean` | COUNT(*) > 0 |
| `Any(AExpression)` | `Boolean` | With WHERE |
| `All(AExpression)` | `Boolean` | COUNT with negated WHERE = 0 |
| `Contains(AValue, AComparer)` | `Boolean` | In-memory check on fetched data |
| `Count` | `Integer` | `SELECT COUNT(*)` |
| `Count(AExpression)` | `Integer` | With WHERE |
| `LongCount` | `Int64` | `SELECT COUNT(*)` as Int64 |
| `LongCount(AExpression)` | `Int64` | With WHERE |
| `Min` | `T` | `SELECT MIN(*)` |
| `Min(AComparer)` | `T` | In-memory min |
| `Min<TResult>(AFieldName [, AAlias])` | `TResult` | `SELECT MIN(field)` |
| `MinBy(AFieldName)` | `T` | `ORDER BY field ASC FIRST 1` |
| `Max` | `T` | `SELECT MAX(*)` |
| `Max(AComparer)` | `T` | In-memory max |
| `Max<TResult>(AFieldName [, AAlias])` | `TResult` | `SELECT MAX(field)` |
| `MaxBy(AFieldName)` | `T` | `ORDER BY field DESC FIRST 1` |
| `Sum<TResult>(AFieldName [, AAlias])` | `TResult` | `SELECT SUM(field)` |
| `Average<TResult>(AFieldName [, AAlias])` | `TResult` | `SELECT AVG(field)` |
| `AsString` | `string` | Return generated SQL without executing |
| `AsEnumerable` | `IColligoEnumerable<T>` | Convert to in-memory pipeline |

## IColligoQueryExpression operators

`IColligoQueryExpression` (unit `Colligo.Expression`) constructs typed SQL predicates:

| Method | SQL fragment |
|---|---|
| `Field(AFieldName)` | Column reference |
| `Equal(AValue)` | `field = value` |
| `NotEqual(AValue)` | `field <> value` |
| `GreaterThan(AValue)` | `field > value` |
| `GreaterThanOrEqual(AValue)` | `field >= value` |
| `LessThan(AValue)` | `field < value` |
| `LessThanOrEqual(AValue)` | `field <= value` |
| `IsNull` | `field IS NULL` |
| `IsNotNull` | `field IS NOT NULL` |
| `Like(AValue)` | `field LIKE value` |
| `NotLike(AValue)` | `field NOT LIKE value` |
| `Contains(AValue)` | `field LIKE '%value%'` |
| `StartsWith(AValue)` | `field LIKE 'value%'` |
| `EndsWith(AValue)` | `field LIKE '%value'` |
| `InValues(AValues)` | `field IN (...)` |
| `NotInValues(AValues)` | `field NOT IN (...)` |
| `Exists(AValue)` | `EXISTS (...)` |
| `NotExists(AValue)` | `NOT EXISTS (...)` |
| `AndWith(AFieldName)` | `AND field` |
| `OrWith(AFieldName)` | `OR field` |
| `Negate` | `NOT (...)` |
| `SubExpression(AFieldName)` | Nested predicate |
| `EqualIgnoreCase(AValue)` | Case-insensitive equal (dialect-dependent) |

Values are overloaded for `Integer`, `Extended`, `string`, `TDate`, `TDateTime`, `TGUID`.
