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

unit Colligo.Join;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  Colligo.Expression,
  {$ENDIF}
  SysUtils,
  Classes,
  Generics.Collections,
  Generics.Defaults,
  Colligo,
  Colligo.Collections,
  Colligo.Adapters;

type
  TColligoJoinEnumerable<T, TInner, TKey, TResult> = class(TColligoEnumerableBase<TResult>)
  private
    FSource: IColligoEnumerableBase<T>;
    FInner: IColligoEnumerableBase<TInner>;
    FOuterKeySelector: TFunc<T, TKey>;
    FInnerKeySelector: TFunc<TInner, TKey>;
    FResultSelector: TFunc<T, TInner, TResult>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const AInner: IColligoEnumerableBase<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, TInner, TResult>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: IColligoEnumerator<TResult>; override;
  end;

  TColligoJoinEnumerator<T, TInner, TKey, TResult> = class(TInterfacedObject, IColligoEnumerator<TResult>)
  private
    FSource: IColligoEnumerator<T>;
    FLookup: TDictionary<TKey, TList<TInner>>;
    FOuterKeySelector: TFunc<T, TKey>;
    FResultSelector: TFunc<T, TInner, TResult>;
    FCurrent: TResult;
    FCurrentOuter: T;
    FMatches: TList<TInner>;
    FMatchIndex: Integer;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const AInner: IColligoEnumerator<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, TInner, TResult>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TColligoJoinQueryable<TInner, TResult, T> = class(TColligoQueryableBase<TResult>, IColligoQueryableBase<TResult>)
  private
    FProvider: IColligoQueryProvider<TResult>;
  public
    constructor Create(const AProvider: IColligoQueryProvider<TResult>);
    function GetEnumerator: IColligoEnumerator<TResult>; override;
    function BuildQuery: string; override;
    function AsEnumerable: IColligoEnumerable<TResult>;
    function ToList: TColligoList<TResult>;
    function AsQueryable: IColligoQueryable<TResult>;
  end;
  {$ENDIF}

implementation

{ TColligoJoinEnumerable<T, TInner, TKey, TResult> }

constructor TColligoJoinEnumerable<T, TInner, TKey, TResult>.Create(const ASource: IColligoEnumerableBase<T>;
  const AInner: IColligoEnumerableBase<TInner>; const AOuterKeySelector: TFunc<T, TKey>;
  const AInnerKeySelector: TFunc<TInner, TKey>; const AResultSelector: TFunc<T, TInner, TResult>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FInner := AInner;
  FOuterKeySelector := AOuterKeySelector;
  FInnerKeySelector := AInnerKeySelector;
  FResultSelector := AResultSelector;
  FComparer := AComparer;
end;

function TColligoJoinEnumerable<T, TInner, TKey, TResult>.GetEnumerator: IColligoEnumerator<TResult>;
begin
  Result := TColligoJoinEnumerator<T, TInner, TKey, TResult>.Create(FSource.GetEnumerator, FInner.GetEnumerator,
    FOuterKeySelector, FInnerKeySelector, FResultSelector, FComparer);
end;

{ TColligoJoinEnumerator<T, TInner, TKey, TResult> }

constructor TColligoJoinEnumerator<T, TInner, TKey, TResult>.Create(const ASource: IColligoEnumerator<T>;
  const AInner: IColligoEnumerator<TInner>; const AOuterKeySelector: TFunc<T, TKey>;
  const AInnerKeySelector: TFunc<TInner, TKey>; const AResultSelector: TFunc<T, TInner, TResult>;
  const AComparer: IEqualityComparer<TKey>);
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
  // Key equality uses AComparer (nil => TEqualityComparer<TKey>.Default).
  FLookup := TDictionary<TKey, TList<TInner>>.Create(AComparer);
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

destructor TColligoJoinEnumerator<T, TInner, TKey, TResult>.Destroy;
var
  LList: TList<TInner>;
begin
  if Assigned(FLookup) then
    for LList in FLookup.Values do
      LList.Free;
  FLookup.Free;
  inherited;
end;

function TColligoJoinEnumerator<T, TInner, TKey, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TColligoJoinEnumerator<T, TInner, TKey, TResult>.MoveNext: Boolean;
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

procedure TColligoJoinEnumerator<T, TInner, TKey, TResult>.Reset;
begin
  FSource.Reset;
  FMatches := nil;
  FMatchIndex := -1;
end;

{$IFDEF QUERYABLE}
{ TColligoJoinQueryable<T, TInner, TKey, TResult> }

constructor TColligoJoinQueryable<TInner, TResult, T>.Create(const AProvider: IColligoQueryProvider<TResult>);
begin
  FProvider := AProvider;
end;

function TColligoJoinQueryable<TInner, TResult, T>.BuildQuery: string;
begin
  if Assigned(FProvider) then
    Result := FProvider.AsString
  else
    raise EInvalidOperation.Create('Provider not assigned');
end;

function TColligoJoinQueryable<TInner, TResult, T>.GetEnumerator: IColligoEnumerator<TResult>;
var
  LSQL: string;
  LDataSet: IDBDataSet;
begin
  LSQL := BuildQuery;
  LDataSet := FProvider.Connection.CreateDataSet(LSQL);
  Result := TDataSetEnumerator<TResult>.Create(LDataSet);
end;

function TColligoJoinQueryable<TInner, TResult, T>.ToList: TColligoList<TResult>;
var
  LEnumerator: IColligoEnumerator<TResult>;
begin
  Result := TColligoList<TResult>.Create;
  try
    LEnumerator := GetEnumerator;
    while LEnumerator.MoveNext do
      Result.Add(LEnumerator.Current);
  except
    Result.Free;
    raise;
  end;
end;

function TColligoJoinQueryable<TInner, TResult, T>.AsEnumerable: IColligoEnumerable<TResult>;
begin
  Result := IColligoEnumerable<TResult>.Create(
    TQueryableToEnumerableAdapter<TResult>.Create(Self)
  );
end;

function TColligoJoinQueryable<TInner, TResult, T>.AsQueryable: IColligoQueryable<TResult>;
begin
  Result := IColligoQueryable<TResult>.CreateForDatabase(FProvider.Database,
                                                        FProvider.Connection,
                                                        FProvider.FluentSQL);
end;
{$ENDIF}

end.



