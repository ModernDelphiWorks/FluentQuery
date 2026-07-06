{
  ------------------------------------------------------------------------------
  FluentQuery
  Lazy Data Manipulation and LINQ-like collection querying library for Delphi and Lazarus.

  SPDX-License-Identifier: MIT
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the MIT License.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ./FluentQuery.inc}

unit FluentQuery.Join;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  FluentQuery.Expression,
  {$ENDIF}
  SysUtils,
  Classes,
  Generics.Collections,
  Generics.Defaults,
  FluentQuery,
  FluentQuery.Collections,
  FluentQuery.Adapters;

type
  TFluentJoinEnumerable<T, TInner, TKey, TResult> = class(TFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<T>;
    FInner: IFluentEnumerableBase<TInner>;
    FOuterKeySelector: TFunc<T, TKey>;
    FInnerKeySelector: TFunc<TInner, TKey>;
    FResultSelector: TFunc<T, TInner, TResult>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const AInner: IFluentEnumerableBase<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, TInner, TResult>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentJoinEnumerator<T, TInner, TKey, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSource: IFluentEnumerator<T>;
    FLookup: TDictionary<TKey, TList<TInner>>;
    FOuterKeySelector: TFunc<T, TKey>;
    FResultSelector: TFunc<T, TInner, TResult>;
    FCurrent: TResult;
    FCurrentOuter: T;
    FMatches: TList<TInner>;
    FMatchIndex: Integer;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const AInner: IFluentEnumerator<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, TInner, TResult>);
    destructor Destroy; override;
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TFluentJoinQueryable<TInner, TResult, T> = class(TFluentQueryableBase<TResult>, IFluentQueryableBase<TResult>)
  private
    FProvider: IFluentQueryProvider<TResult>;
  public
    constructor Create(const AProvider: IFluentQueryProvider<TResult>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
    function BuildQuery: string; override;
    function AsEnumerable: IFluentEnumerable<TResult>;
    function ToList: TFluentList<TResult>;
    function AsQueryable: IFluentQueryable<TResult>;
  end;
  {$ENDIF}

implementation

{ TFluentJoinEnumerable<T, TInner, TKey, TResult> }

constructor TFluentJoinEnumerable<T, TInner, TKey, TResult>.Create(const ASource: IFluentEnumerableBase<T>;
  const AInner: IFluentEnumerableBase<TInner>; const AOuterKeySelector: TFunc<T, TKey>;
  const AInnerKeySelector: TFunc<TInner, TKey>; const AResultSelector: TFunc<T, TInner, TResult>);
begin
  FSource := ASource;
  FInner := AInner;
  FOuterKeySelector := AOuterKeySelector;
  FInnerKeySelector := AInnerKeySelector;
  FResultSelector := AResultSelector;
end;

function TFluentJoinEnumerable<T, TInner, TKey, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentJoinEnumerator<T, TInner, TKey, TResult>.Create(FSource.GetEnumerator, FInner.GetEnumerator,
    FOuterKeySelector, FInnerKeySelector, FResultSelector);
end;

{ TFluentJoinEnumerator<T, TInner, TKey, TResult> }

constructor TFluentJoinEnumerator<T, TInner, TKey, TResult>.Create(const ASource: IFluentEnumerator<T>;
  const AInner: IFluentEnumerator<TInner>; const AOuterKeySelector: TFunc<T, TKey>;
  const AInnerKeySelector: TFunc<TInner, TKey>; const AResultSelector: TFunc<T, TInner, TResult>);
var
  LItem: TInner;
  LKey: TKey;
  LList: TList<TInner>;
begin
  FSource := ASource;
  FOuterKeySelector := AOuterKeySelector;
  FResultSelector := AResultSelector;
  FMatches := nil;
  FMatchIndex := -1;
  // Build a lookup of the inner sequence keyed by the inner key selector:
  // one pass over inner (O(m)); each outer element then finds its matches in
  // O(1) average instead of re-scanning all of inner (was O(n*m)). Items are
  // appended per key in inner-enumeration order, so match order is preserved.
  FLookup := TDictionary<TKey, TList<TInner>>.Create;
  while AInner.MoveNext do
  begin
    LItem := AInner.Current;
    LKey := AInnerKeySelector(LItem);
    if not FLookup.TryGetValue(LKey, LList) then
    begin
      LList := TList<TInner>.Create;
      FLookup.Add(LKey, LList);
    end;
    LList.Add(LItem);
  end;
end;

destructor TFluentJoinEnumerator<T, TInner, TKey, TResult>.Destroy;
var
  LList: TList<TInner>;
begin
  if Assigned(FLookup) then
    for LList in FLookup.Values do
      LList.Free;
  FLookup.Free;
  inherited;
end;

function TFluentJoinEnumerator<T, TInner, TKey, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentJoinEnumerator<T, TInner, TKey, TResult>.MoveNext: Boolean;
var
  LKey: TKey;
begin
  while True do
  begin
    if FMatches <> nil then
    begin
      Inc(FMatchIndex);
      if FMatchIndex < FMatches.Count then
      begin
        FCurrent := FResultSelector(FCurrentOuter, FMatches[FMatchIndex]);
        Result := True;
        Exit;
      end;
      FMatches := nil;
    end;
    if not FSource.MoveNext then
    begin
      Result := False;
      Exit;
    end;
    FCurrentOuter := FSource.Current;
    LKey := FOuterKeySelector(FCurrentOuter);
    if FLookup.TryGetValue(LKey, FMatches) then
      FMatchIndex := -1
    else
      FMatches := nil;
  end;
end;

procedure TFluentJoinEnumerator<T, TInner, TKey, TResult>.Reset;
begin
  FSource.Reset;
  FMatches := nil;
  FMatchIndex := -1;
end;

{$IFDEF QUERYABLE}
{ TFluentJoinQueryable<T, TInner, TKey, TResult> }

constructor TFluentJoinQueryable<TInner, TResult, T>.Create(const AProvider: IFluentQueryProvider<TResult>);
begin
  FProvider := AProvider;
end;

function TFluentJoinQueryable<TInner, TResult, T>.BuildQuery: string;
begin
  if Assigned(FProvider) then
    Result := FProvider.AsString
  else
    raise EInvalidOperation.Create('Provider not assigned');
end;

function TFluentJoinQueryable<TInner, TResult, T>.GetEnumerator: IFluentEnumerator<TResult>;
var
  LSQL: string;
  LDataSet: IDBDataSet;
begin
  LSQL := BuildQuery;
  LDataSet := FProvider.Connection.CreateDataSet(LSQL);
  Result := TDataSetEnumerator<TResult>.Create(LDataSet);
end;

function TFluentJoinQueryable<TInner, TResult, T>.ToList: TFluentList<TResult>;
var
  LEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentList<TResult>.Create;
  try
    LEnumerator := GetEnumerator;
    while LEnumerator.MoveNext do
      Result.Add(LEnumerator.Current);
  except
    Result.Free;
    raise;
  end;
end;

function TFluentJoinQueryable<TInner, TResult, T>.AsEnumerable: IFluentEnumerable<TResult>;
begin
  Result := IFluentEnumerable<TResult>.Create(
    TQueryableToEnumerableAdapter<TResult>.Create(Self)
  );
end;

function TFluentJoinQueryable<TInner, TResult, T>.AsQueryable: IFluentQueryable<TResult>;
begin
  Result := IFluentQueryable<TResult>.CreateForDatabase(FProvider.Database,
                                                        FProvider.Connection,
                                                        FProvider.FluentSQL);
end;
{$ENDIF}

end.



