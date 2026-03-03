{
  ------------------------------------------------------------------------------
  FluentQuery
  LINQ-inspired fluent query API for Delphi.

  SPDX-License-Identifier: Apache-2.0
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ./FluentQuery.inc}

unit FluentQuery.Core;

interface

uses
  Classes,
  SysUtils,
  Generics.Collections,
  Generics.Defaults;

type
  TFluentType = (ftNone, ftList, ftDictionary);
  TAction<T> = reference to procedure(const AArg: T);

  FluentNullable<T: record> = record
  private
    FValue: T;
    FHasValue: Boolean;
    function GetValue: T;
    procedure SetValue(const AValue: T);
  public
    constructor Create(const AValue: T); overload;
    class function CreateEmpty: FluentNullable<T>; static;
    class operator Equal(const A, B: FluentNullable<T>): Boolean;
    class operator NotEqual(const A, B: FluentNullable<T>): Boolean;
    class operator Implicit(const AValue: T): FluentNullable<T>;
    class operator Implicit(const AValue: FluentNullable<T>): T;
    class operator Explicit(const AValue: FluentNullable<T>): T;
    property HasValue: Boolean read FHasValue;
    property Value: T read GetValue write SetValue;
  end;

  NullableInt32 = FluentNullable<Int32>;
  NullableInt64 = FluentNullable<Int64>;
  NullableSingle = FluentNullable<Single>;
  NullableCurrency = FluentNullable<Currency>;
  NullableDouble = FluentNullable<Double>;

const
  ABSTRACT_METHOD_ERROR = 'Abstract method "%s" called in %s. ' +
                          'Derived classes must override this method to provide a concrete implementation.';

implementation

{ FluentNullable<T> }

constructor FluentNullable<T>.Create(const AValue: T);
begin
  FValue := AValue;
  FHasValue := True;
end;

class function FluentNullable<T>.CreateEmpty: FluentNullable<T>;
begin
  Result := FluentNullable<T>.Create(Default(T));
end;

function FluentNullable<T>.GetValue: T;
begin
  if not FHasValue then
    raise EInvalidOperation.Create('Nullable não tem valor');
  Result := FValue;
end;

procedure FluentNullable<T>.SetValue(const AValue: T);
begin
  FValue := AValue;
  FHasValue := True;
end;

class operator FluentNullable<T>.Equal(const A, B: FluentNullable<T>): Boolean;
begin
  if A.FHasValue and B.FHasValue then
    Result := TEqualityComparer<T>.Default.Equals(A.FValue, B.FValue)
  else
    Result := A.FHasValue = B.FHasValue;
end;

class operator FluentNullable<T>.NotEqual(const A, B: FluentNullable<T>): Boolean;
begin
  Result := not (A = B);
end;

class operator FluentNullable<T>.Implicit(const AValue: T): FluentNullable<T>;
begin
  Result := FluentNullable<T>.Create(AValue);
end;

class operator FluentNullable<T>.Implicit(const AValue: FluentNullable<T>): T;
begin
  Result := AValue.Value;
end;

class operator FluentNullable<T>.Explicit(const AValue: FluentNullable<T>): T;
begin
  Result := AValue.Value;
end;

end.



