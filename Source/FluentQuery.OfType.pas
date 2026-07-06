{
  ------------------------------------------------------------------------------
  FluentQuery
  Lazy Data Manipulation and LINQ-like collection querying library for Delphi and Lazarus.

  SPDX-License-Identifier: MIT
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the MIT License.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ./FluentQuery.inc}

unit FluentQuery.OfType;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  {$ENDIF}
  SysUtils,
  Rtti,
  FluentQuery;

type
  // LINQ OfType<TResult>(): no arguments. Deferred/streaming filter by runtime
  // type; elements not convertible to TResult are silently discarded. Never
  // raises on a type mismatch (contrast with Cast).
  TFluentOfTypeEnumerable<T, TResult> = class(TFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<T>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentOfTypeEnumerator<T, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSource: IFluentEnumerator<T>;
    FCurrent: TResult;
    class function TryConvert(const AItem: T; out AResult: TResult): Boolean; static;
  public
    constructor Create(const ASource: IFluentEnumerator<T>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

//  {$IFDEF QUERYABLE}
//  TFluentOfTypeQueryable<T, TResult> = class(TFluentQueryableBase<TResult>, IFluentQueryableBase<TResult>)
//  private
//    FSource: IFluentQueryableBase<T>;
//    FIsType: TFunc<T, Boolean>;
//    FConverter: TFunc<T, TResult>;
//  public
//    constructor Create(const ASource: IFluentQueryableBase<T>;
//      const AIsType: TFunc<T, Boolean>;
//      const AConverter: TFunc<T, TResult>);
//    function GetEnumerator: IFluentEnumerator<TResult>; override;
//    function BuildQuery: string; override;
//  end;
//
//  TFluentOfTypeQueryableEnumerator<T, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
//  private
//    FSourceEnum: IFluentEnumerator<T>;
//    FIsType: TFunc<T, Boolean>;
//    FConverter: TFunc<T, TResult>;
//    FCurrent: TResult;
//  public
//    constructor Create(const ASource: IFluentEnumerator<T>;
//      const AIsType: TFunc<T, Boolean>;
//      const AConverter: TFunc<T, TResult>);
//    destructor Destroy; override;
//    function GetCurrent: TResult;
//    function MoveNext: Boolean;
//    procedure Reset;
//    property Current: TResult read GetCurrent;
//  end;
//  {$ENDIF}

implementation

{ TFluentOfTypeEnumerable<T, TResult> }

constructor TFluentOfTypeEnumerable<T, TResult>.Create(const ASource: IFluentEnumerableBase<T>);
begin
  FSource := ASource;
end;

function TFluentOfTypeEnumerable<T, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentOfTypeEnumerator<T, TResult>.Create(FSource.GetEnumerator);
end;

{ TFluentOfTypeEnumerator<T, TResult> }

constructor TFluentOfTypeEnumerator<T, TResult>.Create(const ASource: IFluentEnumerator<T>);
begin
  FSource := ASource;
end;

class function TFluentOfTypeEnumerator<T, TResult>.TryConvert(const AItem: T;
  out AResult: TResult): Boolean;
var
  LValue: TValue;
begin
  LValue := TValue.From<T>(AItem);
  // Unwrap a variant to its underlying runtime type so a heterogeneous
  // Variant collection is filtered by the actual element type.
  if LValue.Kind = tkVariant then
    LValue := TValue.FromVariant(LValue.AsVariant);
  try
    Result := LValue.TryAsType<TResult>(AResult);
  except
    // A conversion that raises (e.g. an incompatible variant coercion) counts
    // as "not of this type" — OfType filters it out silently.
    Result := False;
  end;
end;

function TFluentOfTypeEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentOfTypeEnumerator<T, TResult>.MoveNext: Boolean;
var
  LConverted: TResult;
begin
  while FSource.MoveNext do
  begin
    if TryConvert(FSource.Current, LConverted) then
    begin
      FCurrent := LConverted;
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TFluentOfTypeEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
  FCurrent := Default(TResult);
end;

//{$IFDEF QUERYABLE}
//{ TFluentOfTypeQueryable<T, TResult> }
//
//constructor TFluentOfTypeQueryable<T, TResult>.Create(
//  const ASource: IFluentQueryableBase<T>;
//  const AIsType: TFunc<T, Boolean>;
//  const AConverter: TFunc<T, TResult>);
//begin
//  FSource := ASource;
//  FIsType := AIsType;
//  FConverter := AConverter;
//end;
//
//function TFluentOfTypeQueryable<T, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
//begin
//  Result := TFluentOfTypeQueryableEnumerator<T, TResult>.Create(
//    FSource.GetEnumerator, FIsType, FConverter);
//end;
//
//function TFluentOfTypeQueryable<T, TResult>.BuildQuery: string;
//begin
//  // Placeholder: Traduzir para SQL, ex.: WHERE tipo = <TResult>
//  Result := FSource.BuildQuery + ' /* OfType<TResult> */';
//end;
//
//{ TFluentOfTypeQueryableEnumerator<T, TResult> }
//
//constructor TFluentOfTypeQueryableEnumerator<T, TResult>.Create(
//  const ASource: IFluentEnumerator<T>;
//  const AIsType: TFunc<T, Boolean>;
//  const AConverter: TFunc<T, TResult>);
//begin
//  FSourceEnum := ASource;
//  FIsType := AIsType;
//  FConverter := AConverter;
//end;
//
//destructor TFluentOfTypeQueryableEnumerator<T, TResult>.Destroy;
//begin
//  FSourceEnum := nil;
//  inherited;
//end;
//
//function TFluentOfTypeQueryableEnumerator<T, TResult>.GetCurrent: TResult;
//begin
//  Result := FCurrent;
//end;
//
//function TFluentOfTypeQueryableEnumerator<T, TResult>.MoveNext: Boolean;
//var
//  LItem: T;
//begin
//  while FSourceEnum.MoveNext do
//  begin
//    LItem := FSourceEnum.Current;
//    if FIsType(LItem) then
//    begin
//      FCurrent := FConverter(LItem);
//      Result := True;
//      Exit;
//    end;
//  end;
//  Result := False;
//end;
//
//procedure TFluentOfTypeQueryableEnumerator<T, TResult>.Reset;
//begin
//  FSourceEnum.Reset;
//  FCurrent := Default(TResult);
//end;
//{$ENDIF}

end.



