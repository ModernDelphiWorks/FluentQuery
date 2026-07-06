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

unit FluentQuery.GroupBy;

interface

uses
  Rtti,
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  FluentQuery.Provider,
  FluentQuery.Expression,
  {$ENDIF}
  Classes,
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  FluentQuery.Core,
  FluentQuery;

type
  TFluentGroupByEnumerable<TKey, T> = class(TFluentEnumerableBase<IGrouping<TKey, T>>, IGroupByEnumerable<TKey, T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FKeySelector: TFunc<T, TKey>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: IFluentEnumerator<IGrouping<TKey, T>>; override;
    function AsEnumerable: IFluentEnumerable<IGrouping<TKey, T>>;
  end;

  TFluentGroupByEnumerable<TKey, TElement, TSource> = class(TFluentEnumerableBase<IGrouping<TKey, TElement>>, IGroupByEnumerable<TKey, TElement>)
  private
    FSource: IFluentEnumerableBase<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FElementSelector: TFunc<TSource, TElement>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AElementSelector: TFunc<TSource, TElement>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: IFluentEnumerator<IGrouping<TKey, TElement>>; override;
    function AsEnumerable: IFluentEnumerable<IGrouping<TKey, TElement>>;
  end;

  TFluentGroupByResultEnumerable<TKey, TSource, TResult> = class(TFluentEnumerableBase<TResult>, IFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FResultSelector: TFunc<TKey, IFluentEnumerableAdapter<TSource>, TResult>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AResultSelector: TFunc<TKey, IFluentEnumerableAdapter<TSource>, TResult>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentGroupByEnumerator<TKey, T> = class(TInterfacedObject, IFluentEnumerator<IGrouping<TKey, T>>)
  private
    FSourceEnum: IFluentEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FGroups: TDictionary<TKey, TList<T>>;
    FKeys: TList<TKey>;
    FIndex: Integer;
    FCurrent: IGrouping<TKey, T>;
  public
    constructor Create(const ASource: IFluentEnumerator<T>;
      const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: IGrouping<TKey, T>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: IGrouping<TKey, T> read GetCurrent;
  end;

  TFluentGroupByEnumerator<TKey, TElement, TSource> = class(TInterfacedObject, IFluentEnumerator<IGrouping<TKey, TElement>>)
  private
    FSourceEnum: IFluentEnumerator<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FElementSelector: TFunc<TSource, TElement>;
    FGroups: TDictionary<TKey, TList<TElement>>;
    FKeys: TList<TKey>;
    FIndex: Integer;
    FCurrent: IGrouping<TKey, TElement>;
  public
    constructor Create(const ASource: IFluentEnumerator<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AElementSelector: TFunc<TSource, TElement>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: IGrouping<TKey, TElement>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: IGrouping<TKey, TElement> read GetCurrent;
  end;

  TFluentGroupByResultEnumerator<TKey, TSource, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSourceEnum: IFluentEnumerator<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FResultSelector: TFunc<TKey, IFluentEnumerableAdapter<TSource>, TResult>;
    FGroups: TDictionary<TKey, TList<TSource>>;
    FKeys: TList<TKey>;
    FIndex: Integer;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IFluentEnumerator<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AResultSelector: TFunc<TKey, IFluentEnumerableAdapter<TSource>, TResult>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TFluentGroupByQueryable<TKey, T> = class(TFluentQueryableBase<IGrouping<TKey, T>>, IGroupByQueryable<TKey, T>)
  private
    FSource: IFluentQueryableBase<T>;
    FProvider: IFluentQueryProvider<T>;
    FKeySelector: IFluentQueryExpression;
  public
    constructor Create(const ASource: IFluentQueryableBase<T>; const AKeySelector: IFluentQueryExpression;
      const AProvider: IFluentQueryProvider<T>);
    function GetEnumerator: IFluentEnumerator<IGrouping<TKey, T>>; override;
    function BuildQuery: string; override;
    function AsEnumerable: IFluentEnumerable<IGrouping<TKey, T>>;
    function ToList: IFluentList<IGrouping<TKey, T>>;
  end;

  TFluentGroupByQueryableEnumerator<TKey, T> = class(TInterfacedObject, IFluentEnumerator<IGrouping<TKey, T>>)
  private
    FDataSet: IDBDataSet;
    FKeyColumn: string;
    FCurrentKey: TKey;
    FCurrentGroup: IGrouping<TKey, T>;
    FHasNext: Boolean;
    FEnumerator: TDataSetEnumerator<T>;
    function _ParseGroup: IGrouping<TKey, T>;
  public
    constructor Create(const ADataSet: IDBDataSet; const AKeyColumn: string);
    destructor Destroy; override;
    procedure Reset;
    function MoveNext: Boolean;
    function GetCurrent: IGrouping<TKey, T>;
    property Current: IGrouping<TKey, T> read GetCurrent;
  end;
  {$ENDIF}

implementation

uses
  FluentQuery.Adapters,
  FluentQuery.Collections;

{ TFluentGroupByEnumerable<TKey, T> }

constructor TFluentGroupByEnumerable<TKey, T>.Create(
  const ASource: IFluentEnumerableBase<T>;
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FComparer := AComparer;
end;

function TFluentGroupByEnumerable<TKey, T>.GetEnumerator: IFluentEnumerator<IGrouping<TKey, T>>;
begin
  Result := TFluentGroupByEnumerator<TKey, T>.Create(FSource.GetEnumerator, FKeySelector, FComparer);
end;

function TFluentGroupByEnumerable<TKey, T>.AsEnumerable: IFluentEnumerable<IGrouping<TKey, T>>;
begin
  Result := IFluentEnumerable<IGrouping<TKey, T>>.Create(Self);
end;

{ TFluentGroupByEnumerable<TKey, TElement, TSource> }

constructor TFluentGroupByEnumerable<TKey, TElement, TSource>.Create(
  const ASource: IFluentEnumerableBase<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AElementSelector: TFunc<TSource, TElement>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FElementSelector := AElementSelector;
  FComparer := AComparer;
end;

function TFluentGroupByEnumerable<TKey, TElement, TSource>.GetEnumerator: IFluentEnumerator<IGrouping<TKey, TElement>>;
begin
  Result := TFluentGroupByEnumerator<TKey, TElement, TSource>.Create(
    FSource.GetEnumerator, FKeySelector, FElementSelector, FComparer);
end;

function TFluentGroupByEnumerable<TKey, TElement, TSource>.AsEnumerable: IFluentEnumerable<IGrouping<TKey, TElement>>;
begin
  Result := IFluentEnumerable<IGrouping<TKey, TElement>>.Create(Self);
end;

{ TFluentGroupByResultEnumerable<TKey, TSource, TResult> }

constructor TFluentGroupByResultEnumerable<TKey, TSource, TResult>.Create(
  const ASource: IFluentEnumerableBase<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AResultSelector: TFunc<TKey, IFluentEnumerableAdapter<TSource>, TResult>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FResultSelector := AResultSelector;
  FComparer := AComparer;
end;

function TFluentGroupByResultEnumerable<TKey, TSource, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentGroupByResultEnumerator<TKey, TSource, TResult>.Create(
    FSource.GetEnumerator, FKeySelector, FResultSelector, FComparer);
end;

{ TFluentGroupByEnumerator<TKey, T> }

constructor TFluentGroupByEnumerator<TKey, T>.Create(
  const ASource: IFluentEnumerator<T>;
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
var
  LItem: T;
  LKey: TKey;
  LList: TList<T>;
begin
  FSourceEnum := ASource;
  FKeySelector := AKeySelector;
  FGroups := TDictionary<TKey, TList<T>>.Create(AComparer);
  FKeys := TList<TKey>.Create;
  FIndex := -1;
  while FSourceEnum.MoveNext do
  begin
    LItem := FSourceEnum.Current;
    LKey := FKeySelector(LItem);
    if not FGroups.TryGetValue(LKey, LList) then
    begin
      LList := TList<T>.Create;
      FGroups.Add(LKey, LList);
      FKeys.Add(LKey);
    end;
    LList.Add(LItem);
  end;
end;

destructor TFluentGroupByEnumerator<TKey, T>.Destroy;
var
  LList: TList<T>;
begin
  if Assigned(FGroups) then
    for LList in FGroups.Values do
      LList.Free;
  FGroups.Free;
  FKeys.Free;
  inherited;
end;

function TFluentGroupByEnumerator<TKey, T>.GetCurrent: IGrouping<TKey, T>;
begin
  Result := FCurrent;
end;

function TFluentGroupByEnumerator<TKey, T>.MoveNext: Boolean;
var
  LKey: TKey;
begin
  Inc(FIndex);
  Result := FIndex < FKeys.Count;
  if Result then
  begin
    LKey := FKeys[FIndex];
    // The grouping owns an independent COPY of its elements, so it stays
    // valid if retained past this enumerator (e.g. GroupBy(...).ToList).
    // The master list in FGroups is kept for the enumerator's lifetime,
    // which keeps Reset re-enumerable and avoids any double-free.
    FCurrent := TFluentGrouping<TKey, T>.Create(
      LKey,
      IFluentEnumerable<T>.Create(
        TListAdapter<T>.Create(TList<T>.Create(FGroups[LKey]), True),
        ftNone,
        TEqualityComparer<T>.Default
      )
    );
  end;
end;

procedure TFluentGroupByEnumerator<TKey, T>.Reset;
begin
  FIndex := -1;
  FCurrent := nil;
end;

{ TFluentGroupByEnumerator<TKey, TElement, TSource> }

constructor TFluentGroupByEnumerator<TKey, TElement, TSource>.Create(
  const ASource: IFluentEnumerator<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AElementSelector: TFunc<TSource, TElement>;
  const AComparer: IEqualityComparer<TKey>);
var
  LItem: TSource;
  LKey: TKey;
  LList: TList<TElement>;
begin
  FSourceEnum := ASource;
  FKeySelector := AKeySelector;
  FElementSelector := AElementSelector;
  FGroups := TDictionary<TKey, TList<TElement>>.Create(AComparer);
  FKeys := TList<TKey>.Create;
  FIndex := -1;
  while FSourceEnum.MoveNext do
  begin
    LItem := FSourceEnum.Current;
    LKey := FKeySelector(LItem);
    if not FGroups.TryGetValue(LKey, LList) then
    begin
      LList := TList<TElement>.Create;
      FGroups.Add(LKey, LList);
      FKeys.Add(LKey);
    end;
    LList.Add(FElementSelector(LItem));
  end;
end;

destructor TFluentGroupByEnumerator<TKey, TElement, TSource>.Destroy;
var
  LList: TList<TElement>;
begin
  if Assigned(FGroups) then
    for LList in FGroups.Values do
      LList.Free;
  FGroups.Free;
  FKeys.Free;
  inherited;
end;

function TFluentGroupByEnumerator<TKey, TElement, TSource>.GetCurrent: IGrouping<TKey, TElement>;
begin
  Result := FCurrent;
end;

function TFluentGroupByEnumerator<TKey, TElement, TSource>.MoveNext: Boolean;
var
  LKey: TKey;
begin
  Inc(FIndex);
  Result := FIndex < FKeys.Count;
  if Result then
  begin
    LKey := FKeys[FIndex];
    // Grouping owns an independent copy (see single-key MoveNext note).
    FCurrent := TFluentGrouping<TKey, TElement>.Create(
      LKey,
      IFluentEnumerable<TElement>.Create(
        TListAdapter<TElement>.Create(TList<TElement>.Create(FGroups[LKey]), True),
        ftNone,
        TEqualityComparer<TElement>.Default));
  end;
end;

procedure TFluentGroupByEnumerator<TKey, TElement, TSource>.Reset;
begin
  FIndex := -1;
  FCurrent := nil;
end;

{ TFluentGroupByResultEnumerator<TKey, TSource, TResult> }

constructor TFluentGroupByResultEnumerator<TKey, TSource, TResult>.Create(
  const ASource: IFluentEnumerator<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AResultSelector: TFunc<TKey, IFluentEnumerableAdapter<TSource>, TResult>;
  const AComparer: IEqualityComparer<TKey>);
var
  LItem: TSource;
  LKey: TKey;
  LList: TList<TSource>;
begin
  FSourceEnum := ASource;
  FKeySelector := AKeySelector;
  FResultSelector := AResultSelector;
  FGroups := TDictionary<TKey, TList<TSource>>.Create(AComparer);
  FKeys := TList<TKey>.Create;
  FIndex := -1;
  while FSourceEnum.MoveNext do
  begin
    LItem := FSourceEnum.Current;
    LKey := FKeySelector(LItem);
    if not FGroups.TryGetValue(LKey, LList) then
    begin
      LList := TList<TSource>.Create;
      FGroups.Add(LKey, LList);
      FKeys.Add(LKey);
    end;
    LList.Add(LItem);
  end;
end;

destructor TFluentGroupByResultEnumerator<TKey, TSource, TResult>.Destroy;
var
  LList: TList<TSource>;
begin
  if Assigned(FGroups) then
    for LList in FGroups.Values do
      LList.Free;
  FGroups.Free;
  FKeys.Free;
  inherited;
end;

function TFluentGroupByResultEnumerator<TKey, TSource, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentGroupByResultEnumerator<TKey, TSource, TResult>.MoveNext: Boolean;
var
  LKey: TKey;
begin
  Inc(FIndex);
  Result := FIndex < FKeys.Count;
  if Result then
  begin
    LKey := FKeys[FIndex];
    // Grouping adapter owns an independent copy (see single-key MoveNext note).
    FCurrent := FResultSelector(
      LKey,
      TEnumerableAdapter<TSource>.Create(
        IFluentEnumerable<TSource>.Create(
          TListAdapter<TSource>.Create(TList<TSource>.Create(FGroups[LKey]), True),
          ftNone,
          TEqualityComparer<TSource>.Default), nil));
  end;
end;

procedure TFluentGroupByResultEnumerator<TKey, TSource, TResult>.Reset;
begin
  FIndex := -1;
  FCurrent := Default(TResult);
end;

{$IFDEF QUERYABLE}
{ TFluentGroupByQueryable<TKey, T> }

constructor TFluentGroupByQueryable<TKey, T>.Create(const ASource: IFluentQueryableBase<T>;
  const AKeySelector: IFluentQueryExpression; const AProvider: IFluentQueryProvider<T>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FProvider := AProvider;
end;

function TFluentGroupByQueryable<TKey, T>.BuildQuery: string;
begin
  if Assigned(FProvider) then
    Result := FProvider.AsString
  else
    raise EInvalidOperation.Create('Provider not assigned');
end;

function TFluentGroupByQueryable<TKey, T>.GetEnumerator: IFluentEnumerator<IGrouping<TKey, T>>;
var
  LSQL: string;
  LDataSet: IDBDataSet;
begin
  LSQL := BuildQuery;
  LDataSet := FProvider.Connection.CreateDataSet(LSQL);
  Result := TFluentGroupByQueryableEnumerator<TKey, T>.Create(LDataSet, FKeySelector.Serialize);
end;

function TFluentGroupByQueryable<TKey, T>.ToList: IFluentList<IGrouping<TKey, T>>;
var
  LEnumerator: IFluentEnumerator<IGrouping<TKey, T>>;
begin
  Result := TFluentList<IGrouping<TKey, T>>.Create;
  LEnumerator := GetEnumerator;
  while LEnumerator.MoveNext do
    Result.Add(LEnumerator.Current);
end;

function TFluentGroupByQueryable<TKey, T>.AsEnumerable: IFluentEnumerable<IGrouping<TKey, T>>;
begin
  Result := IFluentEnumerable<IGrouping<TKey, T>>.Create(
    TQueryableToEnumerableAdapter<IGrouping<TKey, T>>.Create(Self)
  );
end;

{ TFluentGroupByQueryableEnumerator<TKey, T> }

constructor TFluentGroupByQueryableEnumerator<TKey, T>.Create(const ADataSet: IDBDataSet; const AKeyColumn: string);
begin
  inherited Create;
  FDataSet := ADataSet;
  FKeyColumn := AKeyColumn;
  FHasNext := True;
  FDataSet.Open;
  FEnumerator := TDataSetEnumerator<T>.Create(FDataSet);
end;

destructor TFluentGroupByQueryableEnumerator<TKey, T>.Destroy;
begin
  FEnumerator.Free;
  FDataSet.Close;
  inherited;
end;

procedure TFluentGroupByQueryableEnumerator<TKey, T>.Reset;
begin
  FDataSet.First;
  FHasNext := True;
  FEnumerator.Reset;
end;

function TFluentGroupByQueryableEnumerator<TKey, T>.MoveNext: Boolean;
begin
  if FHasNext and not FDataSet.Eof then
  begin
    FCurrentGroup := _ParseGroup;
    Result := True;
  end
  else
  begin
    FHasNext := False;
    Result := False;
  end;
end;

function TFluentGroupByQueryableEnumerator<TKey, T>.GetCurrent: IGrouping<TKey, T>;
begin
  Result := FCurrentGroup;
end;

function TFluentGroupByQueryableEnumerator<TKey, T>._ParseGroup: IGrouping<TKey, T>;
var
  LItems: TList<T>;
  LKey: TKey;
  LKeyValue: TValue;
  LItem: T;
  LNextKeyValue: TValue;
begin
  LItems := TList<T>.Create;
  try
    LKeyValue := TValue.FromVariant(FDataSet.FieldByName(FKeyColumn).AsVariant);
    LKey := LKeyValue.AsType<TKey>;

    // Adiciona o item atual
    LItem := FEnumerator.Current;
    LItems.Add(LItem);

    // Itera enquanto houver itens com a mesma chave
    while FEnumerator.MoveNext do
    begin
      LNextKeyValue := TValue.FromVariant(FDataSet.FieldByName(FKeyColumn).AsVariant);
      if LNextKeyValue.AsVariant <> LKeyValue.AsVariant then
        Break; // Nova chave, parar o grupo
      LItem := FEnumerator.Current;
      LItems.Add(LItem);
    end;

    Result := TFluentGrouping<TKey, T>.Create(
      LKey,
      IFluentEnumerable<T>.Create(TListAdapter<T>.Create(LItems, True))
    );
  except
    LItems.Free;
    raise;
  end;
end;
{$ENDIF}

end.



