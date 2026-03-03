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

unit FluentQuery.SelectIndexed;

interface

uses
  SysUtils,
  FluentQuery;

type
  TFluentSelectIndexedEnumerable<T, TResult> = class(TFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<T>;
    FSelector: TFunc<T, Integer, TResult>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const ASelector: TFunc<T, Integer, TResult>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentSelectIndexedEnumerator<T, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSource: IFluentEnumerator<T>;
    FSelector: TFunc<T, Integer, TResult>;
    FIndex: Integer;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASelector: TFunc<T, Integer, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TFluentSelectIndexedEnumerable<T, TResult> }

constructor TFluentSelectIndexedEnumerable<T, TResult>.Create(
  const ASource: IFluentEnumerableBase<T>; const ASelector: TFunc<T, Integer, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TFluentSelectIndexedEnumerable<T, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentSelectIndexedEnumerator<T, TResult>.Create(FSource.GetEnumerator, FSelector);
end;

{ TFluentSelectIndexedEnumerator<T, TResult> }

constructor TFluentSelectIndexedEnumerator<T, TResult>.Create(
  const ASource: IFluentEnumerator<T>; const ASelector: TFunc<T, Integer, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
  FIndex := -1;
end;

function TFluentSelectIndexedEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentSelectIndexedEnumerator<T, TResult>.MoveNext: Boolean;
begin
  if FSource.MoveNext then
  begin
    Inc(FIndex);
    FCurrent := FSelector(FSource.Current, FIndex);
    Result := True;
  end
  else
    Result := False;
end;

procedure TFluentSelectIndexedEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
end;

end.



