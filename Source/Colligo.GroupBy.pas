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

unit Colligo.GroupBy;

interface

uses
  Rtti,
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  Colligo.Provider,
  Colligo.Expression,
  {$ENDIF}
  Classes,
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  Colligo.Core,
  Colligo;

type
  TColligoGroupByEnumerable<TKey, T> = class(TColligoEnumerableBase<IGrouping<TKey, T>>, IGroupByEnumerable<TKey, T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FKeySelector: TFunc<T, TKey>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>;
      const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: IColligoEnumerator<IGrouping<TKey, T>>; override;
    function AsEnumerable: IColligoEnumerable<IGrouping<TKey, T>>;
  end;

  TColligoGroupByEnumerable<TKey, TElement, TSource> = class(TColligoEnumerableBase<IGrouping<TKey, TElement>>, IGroupByEnumerable<TKey, TElement>)
  private
    FSource: IColligoEnumerableBase<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FElementSelector: TFunc<TSource, TElement>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AElementSelector: TFunc<TSource, TElement>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: IColligoEnumerator<IGrouping<TKey, TElement>>; override;
    function AsEnumerable: IColligoEnumerable<IGrouping<TKey, TElement>>;
  end;

  TColligoGroupByResultEnumerable<TKey, TSource, TResult> = class(TColligoEnumerableBase<TResult>, IColligoEnumerableBase<TResult>)
  private
    FSource: IColligoEnumerableBase<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FResultSelector: TFunc<TKey, IColligoEnumerableAdapter<TSource>, TResult>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AResultSelector: TFunc<TKey, IColligoEnumerableAdapter<TSource>, TResult>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: IColligoEnumerator<TResult>; override;
  end;

  TColligoGroupByEnumerator<TKey, T> = class(TInterfacedObject, IColligoEnumerator<IGrouping<TKey, T>>)
  private
    FSourceEnum: IColligoEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FGroups: TDictionary<TKey, TList<T>>;
    FKeys: TList<TKey>;
    FIndex: Integer;
    FCurrent: IGrouping<TKey, T>;
  public
    constructor Create(const ASource: IColligoEnumerator<T>;
      const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: IGrouping<TKey, T>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: IGrouping<TKey, T> read GetCurrent;
  end;

  TColligoGroupByEnumerator<TKey, TElement, TSource> = class(TInterfacedObject, IColligoEnumerator<IGrouping<TKey, TElement>>)
  private
    FSourceEnum: IColligoEnumerator<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FElementSelector: TFunc<TSource, TElement>;
    FGroups: TDictionary<TKey, TList<TElement>>;
    FKeys: TList<TKey>;
    FIndex: Integer;
    FCurrent: IGrouping<TKey, TElement>;
  public
    constructor Create(const ASource: IColligoEnumerator<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AElementSelector: TFunc<TSource, TElement>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: IGrouping<TKey, TElement>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: IGrouping<TKey, TElement> read GetCurrent;
  end;

  TColligoGroupByResultEnumerator<TKey, TSource, TResult> = class(TInterfacedObject, IColligoEnumerator<TResult>)
  private
    FSourceEnum: IColligoEnumerator<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FResultSelector: TFunc<TKey, IColligoEnumerableAdapter<TSource>, TResult>;
    FGroups: TDictionary<TKey, TList<TSource>>;
    FKeys: TList<TKey>;
    FIndex: Integer;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IColligoEnumerator<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AResultSelector: TFunc<TKey, IColligoEnumerableAdapter<TSource>, TResult>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TColligoGroupByQueryable<TKey, T> = class(TColligoQueryableBase<IGrouping<TKey, T>>, IGroupByQueryable<TKey, T>)
  private
    FSource: IColligoQueryableBase<T>;
    FProvider: IColligoQueryProvider<T>;
    FKeySelector: IColligoQueryExpression;
  public
    constructor Create(const ASource: IColligoQueryableBase<T>; const AKeySelector: IColligoQueryExpression;
      const AProvider: IColligoQueryProvider<T>);
    function GetEnumerator: IColligoEnumerator<IGrouping<TKey, T>>; override;
    function BuildQuery: string; override;
    function AsEnumerable: IColligoEnumerable<IGrouping<TKey, T>>;
    function ToList: IColligoList<IGrouping<TKey, T>>;
  end;

  TColligoGroupByQueryableEnumerator<TKey, T> = class(TInterfacedObject, IColligoEnumerator<IGrouping<TKey, T>>)
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
  Colligo.Adapters,
  Colligo.Collections;

{ TColligoGroupByEnumerable<TKey, T> }

constructor TColligoGroupByEnumerable<TKey, T>.Create(
  const ASource: IColligoEnumerableBase<T>;
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FComparer := AComparer;
end;

function TColligoGroupByEnumerable<TKey, T>.GetEnumerator: IColligoEnumerator<IGrouping<TKey, T>>;
begin
  Result := TColligoGroupByEnumerator<TKey, T>.Create(FSource.GetEnumerator, FKeySelector, FComparer);
end;

function TColligoGroupByEnumerable<TKey, T>.AsEnumerable: IColligoEnumerable<IGrouping<TKey, T>>;
begin
  Result := IColligoEnumerable<IGrouping<TKey, T>>.Create(Self);
end;

{ TColligoGroupByEnumerable<TKey, TElement, TSource> }

constructor TColligoGroupByEnumerable<TKey, TElement, TSource>.Create(
  const ASource: IColligoEnumerableBase<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AElementSelector: TFunc<TSource, TElement>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FElementSelector := AElementSelector;
  FComparer := AComparer;
end;

function TColligoGroupByEnumerable<TKey, TElement, TSource>.GetEnumerator: IColligoEnumerator<IGrouping<TKey, TElement>>;
begin
  Result := TColligoGroupByEnumerator<TKey, TElement, TSource>.Create(
    FSource.GetEnumerator, FKeySelector, FElementSelector, FComparer);
end;

function TColligoGroupByEnumerable<TKey, TElement, TSource>.AsEnumerable: IColligoEnumerable<IGrouping<TKey, TElement>>;
begin
  Result := IColligoEnumerable<IGrouping<TKey, TElement>>.Create(Self);
end;

{ TColligoGroupByResultEnumerable<TKey, TSource, TResult> }

constructor TColligoGroupByResultEnumerable<TKey, TSource, TResult>.Create(
  const ASource: IColligoEnumerableBase<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AResultSelector: TFunc<TKey, IColligoEnumerableAdapter<TSource>, TResult>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FResultSelector := AResultSelector;
  FComparer := AComparer;
end;

function TColligoGroupByResultEnumerable<TKey, TSource, TResult>.GetEnumerator: IColligoEnumerator<TResult>;
begin
  Result := TColligoGroupByResultEnumerator<TKey, TSource, TResult>.Create(
    FSource.GetEnumerator, FKeySelector, FResultSelector, FComparer);
end;

{ TColligoGroupByEnumerator<TKey, T> }

constructor TColligoGroupByEnumerator<TKey, T>.Create(
  const ASource: IColligoEnumerator<T>;
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

destructor TColligoGroupByEnumerator<TKey, T>.Destroy;
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

function TColligoGroupByEnumerator<TKey, T>.GetCurrent: IGrouping<TKey, T>;
begin
  Result := FCurrent;
end;

function TColligoGroupByEnumerator<TKey, T>.MoveNext: Boolean;
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
    FCurrent := TColligoGrouping<TKey, T>.Create(
      LKey,
      IColligoEnumerable<T>.Create(
        TListAdapter<T>.Create(TList<T>.Create(FGroups[LKey]), True),
        ftNone,
        TEqualityComparer<T>.Default
      )
    );
  end;
end;

procedure TColligoGroupByEnumerator<TKey, T>.Reset;
begin
  FIndex := -1;
  FCurrent := nil;
end;

{ TColligoGroupByEnumerator<TKey, TElement, TSource> }

constructor TColligoGroupByEnumerator<TKey, TElement, TSource>.Create(
  const ASource: IColligoEnumerator<TSource>;
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

destructor TColligoGroupByEnumerator<TKey, TElement, TSource>.Destroy;
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

function TColligoGroupByEnumerator<TKey, TElement, TSource>.GetCurrent: IGrouping<TKey, TElement>;
begin
  Result := FCurrent;
end;

function TColligoGroupByEnumerator<TKey, TElement, TSource>.MoveNext: Boolean;
var
  LKey: TKey;
begin
  Inc(FIndex);
  Result := FIndex < FKeys.Count;
  if Result then
  begin
    LKey := FKeys[FIndex];
    // Grouping owns an independent copy (see single-key MoveNext note).
    FCurrent := TColligoGrouping<TKey, TElement>.Create(
      LKey,
      IColligoEnumerable<TElement>.Create(
        TListAdapter<TElement>.Create(TList<TElement>.Create(FGroups[LKey]), True),
        ftNone,
        TEqualityComparer<TElement>.Default));
  end;
end;

procedure TColligoGroupByEnumerator<TKey, TElement, TSource>.Reset;
begin
  FIndex := -1;
  FCurrent := nil;
end;

{ TColligoGroupByResultEnumerator<TKey, TSource, TResult> }

constructor TColligoGroupByResultEnumerator<TKey, TSource, TResult>.Create(
  const ASource: IColligoEnumerator<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AResultSelector: TFunc<TKey, IColligoEnumerableAdapter<TSource>, TResult>;
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

destructor TColligoGroupByResultEnumerator<TKey, TSource, TResult>.Destroy;
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

function TColligoGroupByResultEnumerator<TKey, TSource, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TColligoGroupByResultEnumerator<TKey, TSource, TResult>.MoveNext: Boolean;
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
        IColligoEnumerable<TSource>.Create(
          TListAdapter<TSource>.Create(TList<TSource>.Create(FGroups[LKey]), True),
          ftNone,
          TEqualityComparer<TSource>.Default), nil));
  end;
end;

procedure TColligoGroupByResultEnumerator<TKey, TSource, TResult>.Reset;
begin
  FIndex := -1;
  FCurrent := Default(TResult);
end;

{$IFDEF QUERYABLE}
{ TColligoGroupByQueryable<TKey, T> }

constructor TColligoGroupByQueryable<TKey, T>.Create(const ASource: IColligoQueryableBase<T>;
  const AKeySelector: IColligoQueryExpression; const AProvider: IColligoQueryProvider<T>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FProvider := AProvider;
end;

function TColligoGroupByQueryable<TKey, T>.BuildQuery: string;
begin
  if Assigned(FProvider) then
    Result := FProvider.AsString
  else
    raise EInvalidOperation.Create('Provider not assigned');
end;

function TColligoGroupByQueryable<TKey, T>.GetEnumerator: IColligoEnumerator<IGrouping<TKey, T>>;
var
  LSQL: string;
  LDataSet: IDBDataSet;
begin
  LSQL := BuildQuery;
  LDataSet := FProvider.Connection.CreateDataSet(LSQL);
  Result := TColligoGroupByQueryableEnumerator<TKey, T>.Create(LDataSet, FKeySelector.Serialize);
end;

function TColligoGroupByQueryable<TKey, T>.ToList: IColligoList<IGrouping<TKey, T>>;
var
  LEnumerator: IColligoEnumerator<IGrouping<TKey, T>>;
begin
  Result := TColligoList<IGrouping<TKey, T>>.Create;
  LEnumerator := GetEnumerator;
  while LEnumerator.MoveNext do
    Result.Add(LEnumerator.Current);
end;

function TColligoGroupByQueryable<TKey, T>.AsEnumerable: IColligoEnumerable<IGrouping<TKey, T>>;
begin
  Result := IColligoEnumerable<IGrouping<TKey, T>>.Create(
    TQueryableToEnumerableAdapter<IGrouping<TKey, T>>.Create(Self)
  );
end;

{ TColligoGroupByQueryableEnumerator<TKey, T> }

constructor TColligoGroupByQueryableEnumerator<TKey, T>.Create(const ADataSet: IDBDataSet; const AKeyColumn: string);
begin
  inherited Create;
  FDataSet := ADataSet;
  FKeyColumn := AKeyColumn;
  FHasNext := True;
  FDataSet.Open;
  FEnumerator := TDataSetEnumerator<T>.Create(FDataSet);
end;

destructor TColligoGroupByQueryableEnumerator<TKey, T>.Destroy;
begin
  FEnumerator.Free;
  FDataSet.Close;
  inherited;
end;

procedure TColligoGroupByQueryableEnumerator<TKey, T>.Reset;
begin
  FDataSet.First;
  FHasNext := True;
  FEnumerator.Reset;
end;

function TColligoGroupByQueryableEnumerator<TKey, T>.MoveNext: Boolean;
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

function TColligoGroupByQueryableEnumerator<TKey, T>.GetCurrent: IGrouping<TKey, T>;
begin
  Result := FCurrentGroup;
end;

function TColligoGroupByQueryableEnumerator<TKey, T>._ParseGroup: IGrouping<TKey, T>;
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

    Result := TColligoGrouping<TKey, T>.Create(
      LKey,
      IColligoEnumerable<T>.Create(TListAdapter<T>.Create(LItems, True))
    );
  except
    LItems.Free;
    raise;
  end;
end;
{$ENDIF}

end.



