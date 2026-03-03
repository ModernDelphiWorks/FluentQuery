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

unit FluentQuery.SkipWhileIndexed;

interface

uses
  SysUtils,
  FluentQuery;

type
  TFluentSkipWhileIndexedEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentSkipWhileIndexedEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
    FSkipped: Boolean;
    FIndex: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentSkipWhileIndexedEnumerable<T> }

constructor TFluentSkipWhileIndexedEnumerable<T>.Create(
  const ASource: IFluentEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TFluentSkipWhileIndexedEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentSkipWhileIndexedEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TFluentSkipWhileIndexedEnumerator<T> }

constructor TFluentSkipWhileIndexedEnumerator<T>.Create(
  const ASource: IFluentEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FSkipped := False;
  FIndex := -1;
end;

function TFluentSkipWhileIndexedEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentSkipWhileIndexedEnumerator<T>.MoveNext: Boolean;
begin
  if not FSkipped then
  begin
    while FSource.MoveNext do
    begin
      Inc(FIndex);
      if not FPredicate(FSource.Current, FIndex) then
      begin
        FCurrent := FSource.Current;
        FSkipped := True;
        Result := True;
        Exit;
      end;
    end;
    FSkipped := True;
  end;
  Result := FSource.MoveNext;
  if Result then
  begin
    Inc(FIndex);
    FCurrent := FSource.Current;
  end;
end;

procedure TFluentSkipWhileIndexedEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := False;
  FIndex := -1;
end;

end.



