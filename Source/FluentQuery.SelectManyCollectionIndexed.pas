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

unit FluentQuery.SelectManyCollectionIndexed;

interface

uses
  SysUtils,
  FluentQuery;

type
TFluentSelectManyCollectionIndexedEnumerable<T, TCollection, TResult> = class(TFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<T>;
    FCollectionSelector: TFunc<T, Integer, TArray<TCollection>>;
    FResultSelector: TFunc<T, TCollection, TResult>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const ACollectionSelector: TFunc<T, Integer, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentSelectManyCollectionIndexedEnumerator<T, TCollection, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSource: IFluentEnumerator<T>;
    FCollectionSelector: TFunc<T, Integer, TArray<TCollection>>;
    FResultSelector: TFunc<T, TCollection, TResult>;
    FCurrentArray: TArray<TCollection>;
    FIndex: Integer;
    FSourceIndex: Integer;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IFluentEnumerator<T>;
      const ACollectionSelector: TFunc<T, Integer, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TFluentSelectManyCollectionIndexedEnumerable<T, TCollection, TResult> }

constructor TFluentSelectManyCollectionIndexedEnumerable<T, TCollection, TResult>.Create(
  const ASource: IFluentEnumerableBase<T>;
  const ACollectionSelector: TFunc<T, Integer, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>);
begin
  FSource := ASource;
  FCollectionSelector := ACollectionSelector;
  FResultSelector := AResultSelector;
end;

function TFluentSelectManyCollectionIndexedEnumerable<T, TCollection, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentSelectManyCollectionIndexedEnumerator<T, TCollection, TResult>.Create(
    FSource.GetEnumerator, FCollectionSelector, FResultSelector);
end;

{ TFluentSelectManyCollectionIndexedEnumerator<T, TCollection, TResult> }

constructor TFluentSelectManyCollectionIndexedEnumerator<T, TCollection, TResult>.Create(
  const ASource: IFluentEnumerator<T>;
  const ACollectionSelector: TFunc<T, Integer, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>);
begin
  FSource := ASource;
  FCollectionSelector := ACollectionSelector;
  FResultSelector := AResultSelector;
  FIndex := -1;
  FSourceIndex := -1;
end;

function TFluentSelectManyCollectionIndexedEnumerator<T, TCollection, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentSelectManyCollectionIndexedEnumerator<T, TCollection, TResult>.MoveNext: Boolean;
var
  LSourceItem: T;
begin
  LSourceItem := Default(T);
  while True do
  begin
    if (FIndex >= 0) and (FIndex < Length(FCurrentArray) - 1) then
    begin
      Inc(FIndex);
      FCurrent := FResultSelector(LSourceItem, FCurrentArray[FIndex]);
      Result := True;
      Exit;
    end;
    if not FSource.MoveNext then
    begin
      Result := False;
      Exit;
    end;
    Inc(FSourceIndex);
    LSourceItem := FSource.Current;
    FCurrentArray := FCollectionSelector(LSourceItem, FSourceIndex);
    FIndex := 0;
    if Length(FCurrentArray) > 0 then
    begin
      FCurrent := FResultSelector(LSourceItem, FCurrentArray[FIndex]);
      Result := True;
      Exit;
    end;
  end;
end;

procedure TFluentSelectManyCollectionIndexedEnumerator<T, TCollection, TResult>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
  FSourceIndex := -1;
  FCurrentArray := nil;
end;

end.



