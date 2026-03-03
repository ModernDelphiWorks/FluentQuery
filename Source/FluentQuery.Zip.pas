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

unit FluentQuery.Zip;

interface

uses
  SysUtils,
  FluentQuery;

type
  TFluentZipEnumerable<T, TSecond, TResult> = class(TFluentEnumerableBase<TResult>)
  private
    FSource1: IFluentEnumerableBase<T>;
    FSource2: IFluentEnumerableBase<TSecond>;
    FSelector: TFunc<T, TSecond, TResult>;
  public
    constructor Create(const ASource1: IFluentEnumerableBase<T>; const ASource2: IFluentEnumerableBase<TSecond>;
      const ASelector: TFunc<T, TSecond, TResult>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentZipEnumerator<T, TSecond, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSource1: IFluentEnumerator<T>;
    FSource2: IFluentEnumerator<TSecond>;
    FSelector: TFunc<T, TSecond, TResult>;
    FCurrent: TResult;
  public
    constructor Create(const ASource1: IFluentEnumerator<T>; const ASource2: IFluentEnumerator<TSecond>;
      const ASelector: TFunc<T, TSecond, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TFluentZipEnumerable<T, TSecond, TResult> }

constructor TFluentZipEnumerable<T, TSecond, TResult>.Create(const ASource1: IFluentEnumerableBase<T>;
  const ASource2: IFluentEnumerableBase<TSecond>; const ASelector: TFunc<T, TSecond, TResult>);
begin
  FSource1 := ASource1;
  FSource2 := ASource2;
  FSelector := ASelector;
end;

function TFluentZipEnumerable<T, TSecond, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentZipEnumerator<T, TSecond, TResult>.Create(FSource1.GetEnumerator, FSource2.GetEnumerator, FSelector);
end;

{ TFluentZipEnumerator<T, TSecond, TResult> }

constructor TFluentZipEnumerator<T, TSecond, TResult>.Create(const ASource1: IFluentEnumerator<T>;
  const ASource2: IFluentEnumerator<TSecond>; const ASelector: TFunc<T, TSecond, TResult>);
begin
  FSource1 := ASource1;
  FSource2 := ASource2;
  FSelector := ASelector;
end;

function TFluentZipEnumerator<T, TSecond, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentZipEnumerator<T, TSecond, TResult>.MoveNext: Boolean;
begin
  if FSource1.MoveNext and FSource2.MoveNext then
  begin
    FCurrent := FSelector(FSource1.Current, FSource2.Current);
    Result := True;
  end
  else
    Result := False;
end;

procedure TFluentZipEnumerator<T, TSecond, TResult>.Reset;
begin
  FSource1.Reset;
  FSource2.Reset;
end;

end.



