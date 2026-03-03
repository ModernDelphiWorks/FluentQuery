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

unit FluentQuery.TakeWhile;

interface

uses
  SysUtils,
  FluentQuery;

type
  TFluentTakeWhileEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentTakeWhileEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FPredicate: TFunc<T, Boolean>;
    FCurrent: T;
    FDone: Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const APredicate: TFunc<T, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentTakeWhileEnumerable<T> }

constructor TFluentTakeWhileEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TFluentTakeWhileEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentTakeWhileEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TFluentTakeWhileEnumerator<T> }

constructor TFluentTakeWhileEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FDone := False;
end;

function TFluentTakeWhileEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentTakeWhileEnumerator<T>.MoveNext: Boolean;
begin
  if FDone or not FSource.MoveNext then
    Exit(False);
  FCurrent := FSource.Current;
  if not FPredicate(FCurrent) then
  begin
    FDone := True;
    Exit(False);
  end;
  Result := True;
end;

procedure TFluentTakeWhileEnumerator<T>.Reset;
begin
  FSource.Reset;
  FDone := False;
end;

end.



