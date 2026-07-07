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

unit Colligo.Cast;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Rtti,
  Colligo;

type
  // LINQ Cast<TResult>(): deferred/streaming. Converts every element to
  // TResult and raises EInvalidCast (per element, during enumeration) when an
  // element is not of that type. Contrast with OfType, which filters silently.
  TColligoCastEnumerable<T, TResult> = class(TColligoEnumerableBase<TResult>)
  private
    FSource: IColligoEnumerableBase<T>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>);
    function GetEnumerator: IColligoEnumerator<TResult>; override;
  end;

  TColligoCastEnumerator<T, TResult> = class(TInterfacedObject, IColligoEnumerator<TResult>)
  private
    FSource: IColligoEnumerator<T>;
    FCurrent: TResult;
    function Convert(const AItem: T): TResult;
  public
    constructor Create(const ASource: IColligoEnumerator<T>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TColligoCastEnumerable<T, TResult> }

constructor TColligoCastEnumerable<T, TResult>.Create(const ASource: IColligoEnumerableBase<T>);
begin
  FSource := ASource;
end;

function TColligoCastEnumerable<T, TResult>.GetEnumerator: IColligoEnumerator<TResult>;
begin
  Result := TColligoCastEnumerator<T, TResult>.Create(FSource.GetEnumerator);
end;

{ TColligoCastEnumerator<T, TResult> }

constructor TColligoCastEnumerator<T, TResult>.Create(const ASource: IColligoEnumerator<T>);
begin
  FSource := ASource;
end;

function TColligoCastEnumerator<T, TResult>.Convert(const AItem: T): TResult;
var
  LValue: TValue;
begin
  LValue := TValue.From<T>(AItem);
  // Unwrap a variant to its underlying runtime type before the cast. Conversion
  // follows the same TValue rules as OfType (is-a for reference types; numeric-
  // compatible for value types), but a failure RAISES instead of skipping.
  if LValue.Kind = tkVariant then
    LValue := TValue.FromVariant(LValue.AsVariant);
  try
    if not LValue.TryAsType<TResult>(Result) then
      raise EInvalidCast.Create('Cannot cast element to the requested type');
  except
    on E: EInvalidCast do
      raise;
    on E: Exception do
      // Normalise any underlying conversion error into EInvalidCast, matching
      // C# Cast<TResult> which throws InvalidCastException per element.
      raise EInvalidCast.Create('Cannot cast element to the requested type: ' + E.Message);
  end;
end;

function TColligoCastEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TColligoCastEnumerator<T, TResult>.MoveNext: Boolean;
begin
  Result := FSource.MoveNext;
  if Result then
    FCurrent := Convert(FSource.Current);
end;

procedure TColligoCastEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
  FCurrent := Default(TResult);
end;

end.



