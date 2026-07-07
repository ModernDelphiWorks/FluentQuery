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

unit Colligo.Core;

interface

uses
  Classes,
  SysUtils,
  Generics.Collections,
  Generics.Defaults;

type
  TColligoType = (ftNone, ftList, ftDictionary);
  TAction<T> = reference to procedure(const AArg: T);

  ColligoNullable<T: record> = record
  private
    FValue: T;
    FHasValue: Boolean;
    function GetValue: T;
    procedure SetValue(const AValue: T);
  public
    constructor Create(const AValue: T); overload;
    class function CreateEmpty: ColligoNullable<T>; static;
    class operator Equal(const A, B: ColligoNullable<T>): Boolean;
    class operator NotEqual(const A, B: ColligoNullable<T>): Boolean;
    class operator Implicit(const AValue: T): ColligoNullable<T>;
    class operator Implicit(const AValue: ColligoNullable<T>): T;
    class operator Explicit(const AValue: ColligoNullable<T>): T;
    property HasValue: Boolean read FHasValue;
    property Value: T read GetValue write SetValue;
  end;

  NullableInt32 = ColligoNullable<Int32>;
  NullableInt64 = ColligoNullable<Int64>;
  NullableSingle = ColligoNullable<Single>;
  NullableCurrency = ColligoNullable<Currency>;
  NullableDouble = ColligoNullable<Double>;

const
  ABSTRACT_METHOD_ERROR = 'Abstract method "%s" called in %s. ' +
                          'Derived classes must override this method to provide a concrete implementation.';

implementation

{ ColligoNullable<T> }

constructor ColligoNullable<T>.Create(const AValue: T);
begin
  FValue := AValue;
  FHasValue := True;
end;

class function ColligoNullable<T>.CreateEmpty: ColligoNullable<T>;
begin
  // A real null: no value. (Previously delegated to Create(Default(T)), which
  // set HasValue := True and thus was NOT empty.)
  Result.FValue := Default(T);
  Result.FHasValue := False;
end;

function ColligoNullable<T>.GetValue: T;
begin
  if not FHasValue then
    raise EInvalidOperation.Create('Nullable não tem valor');
  Result := FValue;
end;

procedure ColligoNullable<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
  FHasValue := True;
end;

class operator ColligoNullable<T>.Equal(const A, B: ColligoNullable<T>): Boolean;
begin
  if A.FHasValue and B.FHasValue then
    Result := TEqualityComparer<T>.Default.Equals(A.FValue, B.FValue)
  else
    Result := A.FHasValue = B.FHasValue;
end;

class operator ColligoNullable<T>.NotEqual(const A, B: ColligoNullable<T>): Boolean;
begin
  Result := not (A = B);
end;

class operator ColligoNullable<T>.Implicit(const AValue: T): ColligoNullable<T>;
begin
  Result := ColligoNullable<T>.Create(AValue);
end;

class operator ColligoNullable<T>.Implicit(const AValue: ColligoNullable<T>): T;
begin
  Result := AValue.Value;
end;

class operator ColligoNullable<T>.Explicit(const AValue: ColligoNullable<T>): T;
begin
  Result := AValue.Value;
end;

end.



