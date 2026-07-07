{
  ------------------------------------------------------------------------------
  Colligo
  Lazy Data Manipulation and LINQ-like collection querying library for Delphi and Lazarus.

  SPDX-License-Identifier: MIT
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the MIT License.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ./Colligo.inc}

unit Colligo.OfType;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Rtti,
  Colligo;

type
  // LINQ OfType<TResult>(): no arguments. Deferred/streaming filter by runtime
  // type; elements not convertible to TResult are silently discarded. Never
  // raises on a type mismatch (contrast with Cast).
  TColligoOfTypeEnumerable<T, TResult> = class(TColligoEnumerableBase<TResult>)
  private
    FSource: IColligoEnumerableBase<T>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>);
    function GetEnumerator: IColligoEnumerator<TResult>; override;
  end;

  TColligoOfTypeEnumerator<T, TResult> = class(TInterfacedObject, IColligoEnumerator<TResult>)
  private
    FSource: IColligoEnumerator<T>;
    FCurrent: TResult;
    class function TryConvert(const AItem: T; out AResult: TResult): Boolean; static;
  public
    constructor Create(const ASource: IColligoEnumerator<T>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

//  {$IFDEF QUERYABLE}
//  TColligoOfTypeQueryable<T, TResult> = class(TColligoQueryableBase<TResult>, IColligoQueryableBase<TResult>)
//  private
//    FSource: IColligoQueryableBase<T>;
//    FIsType: TFunc<T, Boolean>;
//    FConverter: TFunc<T, TResult>;
//  public
//    constructor Create(const ASource: IColligoQueryableBase<T>;
//      const AIsType: TFunc<T, Boolean>;
//      const AConverter: TFunc<T, TResult>);
//    function GetEnumerator: IColligoEnumerator<TResult>; override;
//    function BuildQuery: string; override;
//  end;
//
//  TColligoOfTypeQueryableEnumerator<T, TResult> = class(TInterfacedObject, IColligoEnumerator<TResult>)
//  private
//    FSourceEnum: IColligoEnumerator<T>;
//    FIsType: TFunc<T, Boolean>;
//    FConverter: TFunc<T, TResult>;
//    FCurrent: TResult;
//  public
//    constructor Create(const ASource: IColligoEnumerator<T>;
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

{ TColligoOfTypeEnumerable<T, TResult> }

constructor TColligoOfTypeEnumerable<T, TResult>.Create(const ASource: IColligoEnumerableBase<T>);
begin
  FSource := ASource;
end;

function TColligoOfTypeEnumerable<T, TResult>.GetEnumerator: IColligoEnumerator<TResult>;
begin
  Result := TColligoOfTypeEnumerator<T, TResult>.Create(FSource.GetEnumerator);
end;

{ TColligoOfTypeEnumerator<T, TResult> }

constructor TColligoOfTypeEnumerator<T, TResult>.Create(const ASource: IColligoEnumerator<T>);
begin
  FSource := ASource;
end;

class function TColligoOfTypeEnumerator<T, TResult>.TryConvert(const AItem: T;
  out AResult: TResult): Boolean;
var
  LValue: TValue;
begin
  LValue := TValue.From<T>(AItem);
  // Unwrap a variant to its underlying runtime type so a heterogeneous Variant
  // collection is filtered by the actual element type. Conversion uses TValue's
  // rules: for classes/interfaces this is an is-a test; for value types it
  // accepts numeric-compatible values (a Variant integer is treated as Integer).
  // That coercion is the pragmatic Delphi/Variant reading of "of type", which
  // is looser than C# boxing for cross-numeric cases (documented deviation).
  if LValue.Kind = tkVariant then
    LValue := TValue.FromVariant(LValue.AsVariant);
  try
    Result := LValue.TryAsType<TResult>(AResult);
  except
    // A conversion that raises (e.g. an incompatible variant coercion) counts
    // as "not of this type" — OfType filters it out silently, never raising.
    Result := False;
  end;
end;

function TColligoOfTypeEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TColligoOfTypeEnumerator<T, TResult>.MoveNext: Boolean;
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

procedure TColligoOfTypeEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
  FCurrent := Default(TResult);
end;

//{$IFDEF QUERYABLE}
//{ TColligoOfTypeQueryable<T, TResult> }
//
//constructor TColligoOfTypeQueryable<T, TResult>.Create(
//  const ASource: IColligoQueryableBase<T>;
//  const AIsType: TFunc<T, Boolean>;
//  const AConverter: TFunc<T, TResult>);
//begin
//  FSource := ASource;
//  FIsType := AIsType;
//  FConverter := AConverter;
//end;
//
//function TColligoOfTypeQueryable<T, TResult>.GetEnumerator: IColligoEnumerator<TResult>;
//begin
//  Result := TColligoOfTypeQueryableEnumerator<T, TResult>.Create(
//    FSource.GetEnumerator, FIsType, FConverter);
//end;
//
//function TColligoOfTypeQueryable<T, TResult>.BuildQuery: string;
//begin
//  // Placeholder: Traduzir para SQL, ex.: WHERE tipo = <TResult>
//  Result := FSource.BuildQuery + ' /* OfType<TResult> */';
//end;
//
//{ TColligoOfTypeQueryableEnumerator<T, TResult> }
//
//constructor TColligoOfTypeQueryableEnumerator<T, TResult>.Create(
//  const ASource: IColligoEnumerator<T>;
//  const AIsType: TFunc<T, Boolean>;
//  const AConverter: TFunc<T, TResult>);
//begin
//  FSourceEnum := ASource;
//  FIsType := AIsType;
//  FConverter := AConverter;
//end;
//
//destructor TColligoOfTypeQueryableEnumerator<T, TResult>.Destroy;
//begin
//  FSourceEnum := nil;
//  inherited;
//end;
//
//function TColligoOfTypeQueryableEnumerator<T, TResult>.GetCurrent: TResult;
//begin
//  Result := FCurrent;
//end;
//
//function TColligoOfTypeQueryableEnumerator<T, TResult>.MoveNext: Boolean;
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
//procedure TColligoOfTypeQueryableEnumerator<T, TResult>.Reset;
//begin
//  FSourceEnum.Reset;
//  FCurrent := Default(TResult);
//end;
//{$ENDIF}

end.



