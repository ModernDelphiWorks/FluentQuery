---
title: Joins and Zip
sidebar_position: 6
---

# Joins and Zip

FluentQuery provides in-memory `Join`, `GroupJoin`, and `Zip` for combining two sequences.

## Join (inner join)

`Join` correlates elements from two sequences by matching keys:

```delphi
// function Join<TInner, TKey, TResult>(
//   const AInner: IFluentEnumerable<TInner>;
//   const AOuterKeySelector: TFunc<T, TKey>;
//   const AInnerKeySelector: TFunc<TInner, TKey>;
//   const AResultSelector: TFunc<T, TInner, TResult>): IFluentEnumerable<TResult>;
```

```delphi
type
  TOrder  = record Id: Integer; CustomerId: Integer; end;
  TCustomer = record Id: Integer; Name: string; end;
  TOrderDetail = record OrderId: Integer; CustomerName: string; end;

var
  LOrders: TArray<TOrder>;
  LCustomers: TArray<TCustomer>;
  LResult: IFluentArray<TOrderDetail>;
begin
  // Assume LOrders and LCustomers are populated...

  LResult := TFluentArray<TOrder>.From(LOrders)
    .Join<TCustomer, Integer, TOrderDetail>(
      TFluentArray<TCustomer>.From(LCustomers),
      function(const O: TOrder): Integer begin Result := O.CustomerId end,
      function(const C: TCustomer): Integer begin Result := C.Id end,
      function(const O: TOrder; const C: TCustomer): TOrderDetail
      begin
        Result.OrderId := O.Id;
        Result.CustomerName := C.Name;
      end)
    .ToArray;
end;
```

## GroupJoin (left outer join / one-to-many)

`GroupJoin` correlates an outer element with a group of matching inner elements. Every outer element appears in the result even when there are no matching inner elements (left-outer semantics). The `AResultSelector` receives the outer element and an `IFluentEnumerableAdapter<TInner>` containing the matched inner elements (call `.AsEnumerable` to iterate them):

```delphi
// function GroupJoin<TInner, TKey, TResult>(
//   const AInner: IFluentEnumerable<TInner>;
//   const AOuterKeySelector: TFunc<T, TKey>;
//   const AInnerKeySelector: TFunc<TInner, TKey>;
//   const AResultSelector: TFunc<T, IFluentEnumerableAdapter<TInner>, TResult>)
//     : IFluentEnumerable<TResult>;
```

```delphi
type
  TDepartment = record Id: Integer; Name: string; end;
  TEmployee   = record DeptId: Integer; FullName: string; end;
  TDeptSummary = record DeptName: string; EmployeeCount: Integer; end;

var
  LDepts: TArray<TDepartment>;
  LEmps:  TArray<TEmployee>;
  LResult: IFluentArray<TDeptSummary>;
begin
  // Assume LDepts and LEmps are populated...

  LResult := TFluentArray<TDepartment>.From(LDepts)
    .GroupJoin<TEmployee, Integer, TDeptSummary>(
      TFluentArray<TEmployee>.From(LEmps),
      function(const D: TDepartment): Integer begin Result := D.Id end,
      function(const E: TEmployee):   Integer begin Result := E.DeptId end,
      function(const D: TDepartment; const Group: IFluentEnumerableAdapter<TEmployee>): TDeptSummary
      var
        LCount: Integer;
        LEmp: TEmployee;
      begin
        LCount := 0;
        for LEmp in Group.AsEnumerable do
          Inc(LCount);
        Result.DeptName      := D.Name;
        Result.EmployeeCount := LCount;
      end)
    .ToArray;
  // Every department appears once; EmployeeCount is 0 when there are no matches
end;
```

## Zip

`Zip` combines two sequences element-by-element using a result selector. The output length equals the shorter sequence.

```delphi
// function Zip<TSecond, TResult>(
//   const ASecond: IFluentEnumerable<TSecond>;
//   const AResultSelector: TFunc<T, TSecond, TResult>): IFluentEnumerable<TResult>;
```

```delphi
var LNames := TFluentArray<string>.From(['Alice', 'Bob', 'Carol']);
var LScores := TFluentArray<Integer>.From([95, 87, 92]);

var LResult := LNames
  .Zip<Integer, string>(LScores,
    function(const Name: string; const Score: Integer): string
    begin
      Result := Name + ': ' + IntToStr(Score);
    end)
  .ToArray;
// Result: ['Alice: 95', 'Bob: 87', 'Carol: 92']
```
