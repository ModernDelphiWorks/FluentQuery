{
  ------------------------------------------------------------------------------
  LQColligo
  Lazy Data Manipulation and LINQ-like collection querying library for Delphi and Lazarus.

  SPDX-License-Identifier: MIT
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the MIT License.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ./LQColligo.inc}

unit LQColligo.GroupBy;

interface

uses
  Rtti,
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  LQColligo.Provider,
  LQColligo.Expression,
  {$ENDIF}
  Classes,
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  LQColligo.Core,
  LQColligo;

type
  TLQColligoGroupByEnumerable<TKey, T> = class(TLQColligoEnumerableBase<IGrouping<TKey, T>>, IGroupByEnumerable<TKey, T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FKeySelector: TFunc<T, TKey>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>;
      const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: ILQColligoEnumerator<IGrouping<TKey, T>>; override;
    function AsEnumerable: ILQColligoEnumerable<IGrouping<TKey, T>>;
  end;

  TLQColligoGroupByEnumerable<TKey, TElement, TSource> = class(TLQColligoEnumerableBase<IGrouping<TKey, TElement>>, IGroupByEnumerable<TKey, TElement>)
  private
    FSource: ILQColligoEnumerableBase<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FElementSelector: TFunc<TSource, TElement>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AElementSelector: TFunc<TSource, TElement>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: ILQColligoEnumerator<IGrouping<TKey, TElement>>; override;
    function AsEnumerable: ILQColligoEnumerable<IGrouping<TKey, TElement>>;
  end;

  TLQColligoGroupByResultEnumerable<TKey, TSource, TResult> = class(TLQColligoEnumerableBase<TResult>, ILQColligoEnumerableBase<TResult>)
  private
    FSource: ILQColligoEnumerableBase<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FResultSelector: TFunc<TKey, ILQColligoEnumerableAdapter<TSource>, TResult>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AResultSelector: TFunc<TKey, ILQColligoEnumerableAdapter<TSource>, TResult>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: ILQColligoEnumerator<TResult>; override;
  end;

  TLQColligoGroupByEnumerator<TKey, T> = class(TInterfacedObject, ILQColligoEnumerator<IGrouping<TKey, T>>)
  private
    FSourceEnum: ILQColligoEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FGroups: TDictionary<TKey, TList<T>>;
    FKeys: TList<TKey>;
    FIndex: Integer;
    FCurrent: IGrouping<TKey, T>;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>;
      const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: IGrouping<TKey, T>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: IGrouping<TKey, T> read GetCurrent;
  end;

  TLQColligoGroupByEnumerator<TKey, TElement, TSource> = class(TInterfacedObject, ILQColligoEnumerator<IGrouping<TKey, TElement>>)
  private
    FSourceEnum: ILQColligoEnumerator<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FElementSelector: TFunc<TSource, TElement>;
    FGroups: TDictionary<TKey, TList<TElement>>;
    FKeys: TList<TKey>;
    FIndex: Integer;
    FCurrent: IGrouping<TKey, TElement>;
  public
    constructor Create(const ASource: ILQColligoEnumerator<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AElementSelector: TFunc<TSource, TElement>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: IGrouping<TKey, TElement>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: IGrouping<TKey, TElement> read GetCurrent;
  end;

  TLQColligoGroupByResultEnumerator<TKey, TSource, TResult> = class(TInterfacedObject, ILQColligoEnumerator<TResult>)
  private
    FSourceEnum: ILQColligoEnumerator<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FResultSelector: TFunc<TKey, ILQColligoEnumerableAdapter<TSource>, TResult>;
    FGroups: TDictionary<TKey, TList<TSource>>;
    FKeys: TList<TKey>;
    FIndex: Integer;
    FCurrent: TResult;
  public
    constructor Create(const ASource: ILQColligoEnumerator<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AResultSelector: TFunc<TKey, ILQColligoEnumerableAdapter<TSource>, TResult>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TLQColligoGroupByQueryable<TKey, T> = class(TLQColligoQueryableBase<IGrouping<TKey, T>>, IGroupByQueryable<TKey, T>)
  private
    FSource: ILQColligoQueryableBase<T>;
    FProvider: ILQColligoQueryProvider<T>;
    FKeySelector: ILQColligoQueryExpression;
  public
    constructor Create(const ASource: ILQColligoQueryableBase<T>; const AKeySelector: ILQColligoQueryExpression;
      const AProvider: ILQColligoQueryProvider<T>);
    function GetEnumerator: ILQColligoEnumerator<IGrouping<TKey, T>>; override;
    function BuildQuery: string; override;
    function AsEnumerable: ILQColligoEnumerable<IGrouping<TKey, T>>;
    function ToList: ILQColligoList<IGrouping<TKey, T>>;
  end;

  TLQColligoGroupByQueryableEnumerator<TKey, T> = class(TInterfacedObject, ILQColligoEnumerator<IGrouping<TKey, T>>)
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
  LQColligo.Adapters,
  LQColligo.Collections;

{ TLQColligoGroupByEnumerable<TKey, T> }

constructor TLQColligoGroupByEnumerable<TKey, T>.Create(
  const ASource: ILQColligoEnumerableBase<T>;
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FComparer := AComparer;
end;

function TLQColligoGroupByEnumerable<TKey, T>.GetEnumerator: ILQColligoEnumerator<IGrouping<TKey, T>>;
begin
  Result := TLQColligoGroupByEnumerator<TKey, T>.Create(FSource.GetEnumerator, FKeySelector, FComparer);
end;

function TLQColligoGroupByEnumerable<TKey, T>.AsEnumerable: ILQColligoEnumerable<IGrouping<TKey, T>>;
begin
  Result := ILQColligoEnumerable<IGrouping<TKey, T>>.Create(Self);
end;

{ TLQColligoGroupByEnumerable<TKey, TElement, TSource> }

constructor TLQColligoGroupByEnumerable<TKey, TElement, TSource>.Create(
  const ASource: ILQColligoEnumerableBase<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AElementSelector: TFunc<TSource, TElement>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FElementSelector := AElementSelector;
  FComparer := AComparer;
end;

function TLQColligoGroupByEnumerable<TKey, TElement, TSource>.GetEnumerator: ILQColligoEnumerator<IGrouping<TKey, TElement>>;
begin
  Result := TLQColligoGroupByEnumerator<TKey, TElement, TSource>.Create(
    FSource.GetEnumerator, FKeySelector, FElementSelector, FComparer);
end;

function TLQColligoGroupByEnumerable<TKey, TElement, TSource>.AsEnumerable: ILQColligoEnumerable<IGrouping<TKey, TElement>>;
begin
  Result := ILQColligoEnumerable<IGrouping<TKey, TElement>>.Create(Self);
end;

{ TLQColligoGroupByResultEnumerable<TKey, TSource, TResult> }

constructor TLQColligoGroupByResultEnumerable<TKey, TSource, TResult>.Create(
  const ASource: ILQColligoEnumerableBase<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AResultSelector: TFunc<TKey, ILQColligoEnumerableAdapter<TSource>, TResult>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FResultSelector := AResultSelector;
  FComparer := AComparer;
end;

function TLQColligoGroupByResultEnumerable<TKey, TSource, TResult>.GetEnumerator: ILQColligoEnumerator<TResult>;
begin
  Result := TLQColligoGroupByResultEnumerator<TKey, TSource, TResult>.Create(
    FSource.GetEnumerator, FKeySelector, FResultSelector, FComparer);
end;

{ TLQColligoGroupByEnumerator<TKey, T> }

constructor TLQColligoGroupByEnumerator<TKey, T>.Create(
  const ASource: ILQColligoEnumerator<T>;
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

destructor TLQColligoGroupByEnumerator<TKey, T>.Destroy;
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

function TLQColligoGroupByEnumerator<TKey, T>.GetCurrent: IGrouping<TKey, T>;
begin
  Result := FCurrent;
end;

function TLQColligoGroupByEnumerator<TKey, T>.MoveNext: Boolean;
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
    FCurrent := TLQColligoGrouping<TKey, T>.Create(
      LKey,
      ILQColligoEnumerable<T>.Create(
        TListAdapter<T>.Create(TList<T>.Create(FGroups[LKey]), True),
        ftNone,
        TEqualityComparer<T>.Default
      )
    );
  end;
end;

procedure TLQColligoGroupByEnumerator<TKey, T>.Reset;
begin
  FIndex := -1;
  FCurrent := nil;
end;

{ TLQColligoGroupByEnumerator<TKey, TElement, TSource> }

constructor TLQColligoGroupByEnumerator<TKey, TElement, TSource>.Create(
  const ASource: ILQColligoEnumerator<TSource>;
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

destructor TLQColligoGroupByEnumerator<TKey, TElement, TSource>.Destroy;
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

function TLQColligoGroupByEnumerator<TKey, TElement, TSource>.GetCurrent: IGrouping<TKey, TElement>;
begin
  Result := FCurrent;
end;

function TLQColligoGroupByEnumerator<TKey, TElement, TSource>.MoveNext: Boolean;
var
  LKey: TKey;
begin
  Inc(FIndex);
  Result := FIndex < FKeys.Count;
  if Result then
  begin
    LKey := FKeys[FIndex];
    // Grouping owns an independent copy (see single-key MoveNext note).
    FCurrent := TLQColligoGrouping<TKey, TElement>.Create(
      LKey,
      ILQColligoEnumerable<TElement>.Create(
        TListAdapter<TElement>.Create(TList<TElement>.Create(FGroups[LKey]), True),
        ftNone,
        TEqualityComparer<TElement>.Default));
  end;
end;

procedure TLQColligoGroupByEnumerator<TKey, TElement, TSource>.Reset;
begin
  FIndex := -1;
  FCurrent := nil;
end;

{ TLQColligoGroupByResultEnumerator<TKey, TSource, TResult> }

constructor TLQColligoGroupByResultEnumerator<TKey, TSource, TResult>.Create(
  const ASource: ILQColligoEnumerator<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AResultSelector: TFunc<TKey, ILQColligoEnumerableAdapter<TSource>, TResult>;
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

destructor TLQColligoGroupByResultEnumerator<TKey, TSource, TResult>.Destroy;
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

function TLQColligoGroupByResultEnumerator<TKey, TSource, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TLQColligoGroupByResultEnumerator<TKey, TSource, TResult>.MoveNext: Boolean;
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
        ILQColligoEnumerable<TSource>.Create(
          TListAdapter<TSource>.Create(TList<TSource>.Create(FGroups[LKey]), True),
          ftNone,
          TEqualityComparer<TSource>.Default), nil));
  end;
end;

procedure TLQColligoGroupByResultEnumerator<TKey, TSource, TResult>.Reset;
begin
  FIndex := -1;
  FCurrent := Default(TResult);
end;

{$IFDEF QUERYABLE}
{ TLQColligoGroupByQueryable<TKey, T> }

constructor TLQColligoGroupByQueryable<TKey, T>.Create(const ASource: ILQColligoQueryableBase<T>;
  const AKeySelector: ILQColligoQueryExpression; const AProvider: ILQColligoQueryProvider<T>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FProvider := AProvider;
end;

function TLQColligoGroupByQueryable<TKey, T>.BuildQuery: string;
begin
  if Assigned(FProvider) then
    Result := FProvider.AsString
  else
    raise EInvalidOperation.Create('Provider not assigned');
end;

function TLQColligoGroupByQueryable<TKey, T>.GetEnumerator: ILQColligoEnumerator<IGrouping<TKey, T>>;
var
  LSQL: string;
  LDataSet: IDBDataSet;
begin
  LSQL := BuildQuery;
  LDataSet := FProvider.Connection.CreateDataSet(LSQL);
  Result := TLQColligoGroupByQueryableEnumerator<TKey, T>.Create(LDataSet, FKeySelector.Serialize);
end;

function TLQColligoGroupByQueryable<TKey, T>.ToList: ILQColligoList<IGrouping<TKey, T>>;
var
  LEnumerator: ILQColligoEnumerator<IGrouping<TKey, T>>;
begin
  Result := TLQColligoList<IGrouping<TKey, T>>.Create;
  LEnumerator := GetEnumerator;
  while LEnumerator.MoveNext do
    Result.Add(LEnumerator.Current);
end;

function TLQColligoGroupByQueryable<TKey, T>.AsEnumerable: ILQColligoEnumerable<IGrouping<TKey, T>>;
begin
  Result := ILQColligoEnumerable<IGrouping<TKey, T>>.Create(
    TQueryableToEnumerableAdapter<IGrouping<TKey, T>>.Create(Self)
  );
end;

{ TLQColligoGroupByQueryableEnumerator<TKey, T> }

constructor TLQColligoGroupByQueryableEnumerator<TKey, T>.Create(const ADataSet: IDBDataSet; const AKeyColumn: string);
begin
  inherited Create;
  FDataSet := ADataSet;
  FKeyColumn := AKeyColumn;
  FHasNext := True;
  FDataSet.Open;
  FEnumerator := TDataSetEnumerator<T>.Create(FDataSet);
end;

destructor TLQColligoGroupByQueryableEnumerator<TKey, T>.Destroy;
begin
  FEnumerator.Free;
  FDataSet.Close;
  inherited;
end;

procedure TLQColligoGroupByQueryableEnumerator<TKey, T>.Reset;
begin
  FDataSet.First;
  FHasNext := True;
  FEnumerator.Reset;
end;

function TLQColligoGroupByQueryableEnumerator<TKey, T>.MoveNext: Boolean;
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

function TLQColligoGroupByQueryableEnumerator<TKey, T>.GetCurrent: IGrouping<TKey, T>;
begin
  Result := FCurrentGroup;
end;

function TLQColligoGroupByQueryableEnumerator<TKey, T>._ParseGroup: IGrouping<TKey, T>;
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

    Result := TLQColligoGrouping<TKey, T>.Create(
      LKey,
      ILQColligoEnumerable<T>.Create(TListAdapter<T>.Create(LItems, True))
    );
  except
    LItems.Free;
    raise;
  end;
end;
{$ENDIF}

end.



