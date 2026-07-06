{
  ------------------------------------------------------------------------------
  LQColligo
  Lazy Data Manipulation and LINQ-like collection querying library for Delphi and Lazarus.

  SPDX-License-Identifier: MIT
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the MIT License.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ./LQColligo.inc}

unit LQColligo.OfType;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  Rtti,
  LQColligo;

type
  // LINQ OfType<TResult>(): no arguments. Deferred/streaming filter by runtime
  // type; elements not convertible to TResult are silently discarded. Never
  // raises on a type mismatch (contrast with Cast).
  TLQColligoOfTypeEnumerable<T, TResult> = class(TLQColligoEnumerableBase<TResult>)
  private
    FSource: ILQColligoEnumerableBase<T>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>);
    function GetEnumerator: ILQColligoEnumerator<TResult>; override;
  end;

  TLQColligoOfTypeEnumerator<T, TResult> = class(TInterfacedObject, ILQColligoEnumerator<TResult>)
  private
    FSource: ILQColligoEnumerator<T>;
    FCurrent: TResult;
    class function TryConvert(const AItem: T; out AResult: TResult): Boolean; static;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

//  {$IFDEF QUERYABLE}
//  TLQColligoOfTypeQueryable<T, TResult> = class(TLQColligoQueryableBase<TResult>, ILQColligoQueryableBase<TResult>)
//  private
//    FSource: ILQColligoQueryableBase<T>;
//    FIsType: TFunc<T, Boolean>;
//    FConverter: TFunc<T, TResult>;
//  public
//    constructor Create(const ASource: ILQColligoQueryableBase<T>;
//      const AIsType: TFunc<T, Boolean>;
//      const AConverter: TFunc<T, TResult>);
//    function GetEnumerator: ILQColligoEnumerator<TResult>; override;
//    function BuildQuery: string; override;
//  end;
//
//  TLQColligoOfTypeQueryableEnumerator<T, TResult> = class(TInterfacedObject, ILQColligoEnumerator<TResult>)
//  private
//    FSourceEnum: ILQColligoEnumerator<T>;
//    FIsType: TFunc<T, Boolean>;
//    FConverter: TFunc<T, TResult>;
//    FCurrent: TResult;
//  public
//    constructor Create(const ASource: ILQColligoEnumerator<T>;
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

{ TLQColligoOfTypeEnumerable<T, TResult> }

constructor TLQColligoOfTypeEnumerable<T, TResult>.Create(const ASource: ILQColligoEnumerableBase<T>);
begin
  FSource := ASource;
end;

function TLQColligoOfTypeEnumerable<T, TResult>.GetEnumerator: ILQColligoEnumerator<TResult>;
begin
  Result := TLQColligoOfTypeEnumerator<T, TResult>.Create(FSource.GetEnumerator);
end;

{ TLQColligoOfTypeEnumerator<T, TResult> }

constructor TLQColligoOfTypeEnumerator<T, TResult>.Create(const ASource: ILQColligoEnumerator<T>);
begin
  FSource := ASource;
end;

class function TLQColligoOfTypeEnumerator<T, TResult>.TryConvert(const AItem: T;
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

function TLQColligoOfTypeEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TLQColligoOfTypeEnumerator<T, TResult>.MoveNext: Boolean;
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

procedure TLQColligoOfTypeEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
  FCurrent := Default(TResult);
end;

//{$IFDEF QUERYABLE}
//{ TLQColligoOfTypeQueryable<T, TResult> }
//
//constructor TLQColligoOfTypeQueryable<T, TResult>.Create(
//  const ASource: ILQColligoQueryableBase<T>;
//  const AIsType: TFunc<T, Boolean>;
//  const AConverter: TFunc<T, TResult>);
//begin
//  FSource := ASource;
//  FIsType := AIsType;
//  FConverter := AConverter;
//end;
//
//function TLQColligoOfTypeQueryable<T, TResult>.GetEnumerator: ILQColligoEnumerator<TResult>;
//begin
//  Result := TLQColligoOfTypeQueryableEnumerator<T, TResult>.Create(
//    FSource.GetEnumerator, FIsType, FConverter);
//end;
//
//function TLQColligoOfTypeQueryable<T, TResult>.BuildQuery: string;
//begin
//  // Placeholder: Traduzir para SQL, ex.: WHERE tipo = <TResult>
//  Result := FSource.BuildQuery + ' /* OfType<TResult> */';
//end;
//
//{ TLQColligoOfTypeQueryableEnumerator<T, TResult> }
//
//constructor TLQColligoOfTypeQueryableEnumerator<T, TResult>.Create(
//  const ASource: ILQColligoEnumerator<T>;
//  const AIsType: TFunc<T, Boolean>;
//  const AConverter: TFunc<T, TResult>);
//begin
//  FSourceEnum := ASource;
//  FIsType := AIsType;
//  FConverter := AConverter;
//end;
//
//destructor TLQColligoOfTypeQueryableEnumerator<T, TResult>.Destroy;
//begin
//  FSourceEnum := nil;
//  inherited;
//end;
//
//function TLQColligoOfTypeQueryableEnumerator<T, TResult>.GetCurrent: TResult;
//begin
//  Result := FCurrent;
//end;
//
//function TLQColligoOfTypeQueryableEnumerator<T, TResult>.MoveNext: Boolean;
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
//procedure TLQColligoOfTypeQueryableEnumerator<T, TResult>.Reset;
//begin
//  FSourceEnum.Reset;
//  FCurrent := Default(TResult);
//end;
//{$ENDIF}

end.



