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

unit FluentQuery.Where;

interface

uses
  SysUtils,
  FluentQuery;

type
  TFluentWhereEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentWhereEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FPredicate: TFunc<T, Boolean>;
    FCurrent: T;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const APredicate: TFunc<T, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentFilterEnumerable<T> }

constructor TFluentWhereEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TFluentWhereEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentWhereEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TFluentFilterEnumerator<T> }

constructor TFluentWhereEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TFluentWhereEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentWhereEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if FPredicate(FCurrent) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TFluentWhereEnumerator<T>.Reset;
begin
  FSource.Reset;
end;


end.



