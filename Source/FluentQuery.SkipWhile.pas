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

unit FluentQuery.SkipWhile;

interface

uses
  SysUtils,
  FluentQuery;

type
  TFluentSkipWhileEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentSkipWhileEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FPredicate: TFunc<T, Boolean>;
    FSkipped: Boolean;
    FCurrent: T;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const APredicate: TFunc<T, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentSkipWhileEnumerable<T> }

constructor TFluentSkipWhileEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>;
  const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TFluentSkipWhileEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentSkipWhileEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TFluentSkipWhileEnumerator<T> }

constructor TFluentSkipWhileEnumerator<T>.Create(const ASource: IFluentEnumerator<T>;
  const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FSkipped := False;
end;

function TFluentSkipWhileEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentSkipWhileEnumerator<T>.MoveNext: Boolean;
begin
  if not FSkipped then
  begin
    while FSource.MoveNext do
    begin
      if not FPredicate(FSource.Current) then
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
    FCurrent := FSource.Current;
end;

procedure TFluentSkipWhileEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := False;
end;


end.



