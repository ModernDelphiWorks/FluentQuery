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

unit LQColligo.Core;

interface

uses
  Classes,
  SysUtils,
  Generics.Collections,
  Generics.Defaults;

type
  TLQColligoType = (ftNone, ftList, ftDictionary);
  TAction<T> = reference to procedure(const AArg: T);

  LQColligoNullable<T: record> = record
  private
    FValue: T;
    FHasValue: Boolean;
    function GetValue: T;
    procedure SetValue(const AValue: T);
  public
    constructor Create(const AValue: T); overload;
    class function CreateEmpty: LQColligoNullable<T>; static;
    class operator Equal(const A, B: LQColligoNullable<T>): Boolean;
    class operator NotEqual(const A, B: LQColligoNullable<T>): Boolean;
    class operator Implicit(const AValue: T): LQColligoNullable<T>;
    class operator Implicit(const AValue: LQColligoNullable<T>): T;
    class operator Explicit(const AValue: LQColligoNullable<T>): T;
    property HasValue: Boolean read FHasValue;
    property Value: T read GetValue write SetValue;
  end;

  NullableInt32 = LQColligoNullable<Int32>;
  NullableInt64 = LQColligoNullable<Int64>;
  NullableSingle = LQColligoNullable<Single>;
  NullableCurrency = LQColligoNullable<Currency>;
  NullableDouble = LQColligoNullable<Double>;

const
  ABSTRACT_METHOD_ERROR = 'Abstract method "%s" called in %s. ' +
                          'Derived classes must override this method to provide a concrete implementation.';

implementation

{ LQColligoNullable<T> }

constructor LQColligoNullable<T>.Create(const AValue: T);
begin
  FValue := AValue;
  FHasValue := True;
end;

class function LQColligoNullable<T>.CreateEmpty: LQColligoNullable<T>;
begin
  // A real null: no value. (Previously delegated to Create(Default(T)), which
  // set HasValue := True and thus was NOT empty.)
  Result.FValue := Default(T);
  Result.FHasValue := False;
end;

function LQColligoNullable<T>.GetValue: T;
begin
  if not FHasValue then
    raise EInvalidOperation.Create('Nullable não tem valor');
  Result := FValue;
end;

procedure LQColligoNullable<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
  FHasValue := True;
end;

class operator LQColligoNullable<T>.Equal(const A, B: LQColligoNullable<T>): Boolean;
begin
  if A.FHasValue and B.FHasValue then
    Result := TEqualityComparer<T>.Default.Equals(A.FValue, B.FValue)
  else
    Result := A.FHasValue = B.FHasValue;
end;

class operator LQColligoNullable<T>.NotEqual(const A, B: LQColligoNullable<T>): Boolean;
begin
  Result := not (A = B);
end;

class operator LQColligoNullable<T>.Implicit(const AValue: T): LQColligoNullable<T>;
begin
  Result := LQColligoNullable<T>.Create(AValue);
end;

class operator LQColligoNullable<T>.Implicit(const AValue: LQColligoNullable<T>): T;
begin
  Result := AValue.Value;
end;

class operator LQColligoNullable<T>.Explicit(const AValue: LQColligoNullable<T>): T;
begin
  Result := AValue.Value;
end;

end.



