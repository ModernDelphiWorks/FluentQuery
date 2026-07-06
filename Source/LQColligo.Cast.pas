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

unit LQColligo.Cast;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  Rtti,
  LQColligo;

type
  // LINQ Cast<TResult>(): deferred/streaming. Converts every element to
  // TResult and raises EInvalidCast (per element, during enumeration) when an
  // element is not of that type. Contrast with OfType, which filters silently.
  TLQColligoCastEnumerable<T, TResult> = class(TLQColligoEnumerableBase<TResult>)
  private
    FSource: ILQColligoEnumerableBase<T>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>);
    function GetEnumerator: ILQColligoEnumerator<TResult>; override;
  end;

  TLQColligoCastEnumerator<T, TResult> = class(TInterfacedObject, ILQColligoEnumerator<TResult>)
  private
    FSource: ILQColligoEnumerator<T>;
    FCurrent: TResult;
    function Convert(const AItem: T): TResult;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TLQColligoCastEnumerable<T, TResult> }

constructor TLQColligoCastEnumerable<T, TResult>.Create(const ASource: ILQColligoEnumerableBase<T>);
begin
  FSource := ASource;
end;

function TLQColligoCastEnumerable<T, TResult>.GetEnumerator: ILQColligoEnumerator<TResult>;
begin
  Result := TLQColligoCastEnumerator<T, TResult>.Create(FSource.GetEnumerator);
end;

{ TLQColligoCastEnumerator<T, TResult> }

constructor TLQColligoCastEnumerator<T, TResult>.Create(const ASource: ILQColligoEnumerator<T>);
begin
  FSource := ASource;
end;

function TLQColligoCastEnumerator<T, TResult>.Convert(const AItem: T): TResult;
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

function TLQColligoCastEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TLQColligoCastEnumerator<T, TResult>.MoveNext: Boolean;
begin
  Result := FSource.MoveNext;
  if Result then
    FCurrent := Convert(FSource.Current);
end;

procedure TLQColligoCastEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
  FCurrent := Default(TResult);
end;

end.



