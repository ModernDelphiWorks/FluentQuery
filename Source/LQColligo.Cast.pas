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
  TFluentCastEnumerable<T, TResult> = class(TFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<T>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentCastEnumerator<T, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSource: IFluentEnumerator<T>;
    FCurrent: TResult;
    function Convert(const AItem: T): TResult;
  public
    constructor Create(const ASource: IFluentEnumerator<T>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TFluentCastEnumerable<T, TResult> }

constructor TFluentCastEnumerable<T, TResult>.Create(const ASource: IFluentEnumerableBase<T>);
begin
  FSource := ASource;
end;

function TFluentCastEnumerable<T, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentCastEnumerator<T, TResult>.Create(FSource.GetEnumerator);
end;

{ TFluentCastEnumerator<T, TResult> }

constructor TFluentCastEnumerator<T, TResult>.Create(const ASource: IFluentEnumerator<T>);
begin
  FSource := ASource;
end;

function TFluentCastEnumerator<T, TResult>.Convert(const AItem: T): TResult;
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

function TFluentCastEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentCastEnumerator<T, TResult>.MoveNext: Boolean;
begin
  Result := FSource.MoveNext;
  if Result then
    FCurrent := Convert(FSource.Current);
end;

procedure TFluentCastEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
  FCurrent := Default(TResult);
end;

end.



