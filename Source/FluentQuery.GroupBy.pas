{
                          Apache License
                      Version 2.0, January 2004
                   http://www.apache.org/licenses/

       Licensed under the Apache License, Version 2.0 (the "License");
       you may not use this file except in compliance with the License.
       You may obtain a copy of the License at

             http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing, software
       distributed under the License is distributed on an "AS IS" BASIS,
       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
       See the License for the specific language governing permissions and
       limitations under the License.
}

{
  @abstract(Fluent4D: Fluent Data Processing Framework for Delphi)
  @description(A powerful and intuitive framework for fluent-style data manipulation in Delphi)
  @created(03 Abr 2025)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @Discord(https://discord.gg/T2zJC8zX)
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
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const AKeySelector: TFunc<T, TKey>);
    function GetEnumerator: IFluentEnumerator<IGrouping<TKey, T>>; override;
    function AsEnumerable: IFluentEnumerable<IGrouping<TKey, T>>;
  end;

  TFluentGroupByEnumerable<TKey, TElement, TSource> = class(TFluentEnumerableBase<IGrouping<TKey, TElement>>, IGroupByEnumerable<TKey, TElement>)
  private
    FSource: IFluentEnumerableBase<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FElementSelector: TFunc<TSource, TElement>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AElementSelector: TFunc<TSource, TElement>);
    function GetEnumerator: IFluentEnumerator<IGrouping<TKey, TElement>>; override;
    function AsEnumerable: IFluentEnumerable<IGrouping<TKey, TElement>>;
  end;

  TFluentGroupByResultEnumerable<TKey, TSource, TResult> = class(TFluentEnumerableBase<TResult>, IFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FResultSelector: TFunc<TKey, IFluentEnumerableAdapter<TSource>, TResult>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AResultSelector: TFunc<TKey, IFluentEnumerableAdapter<TSource>, TResult>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentGroupByEnumerator<TKey, T> = class(TInterfacedObject, IFluentEnumerator<IGrouping<TKey, T>>)
  private
    FSourceEnum: IFluentEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FGroups: TDictionary<TKey, TList<T>>;
    FEnumerator: TEnumerator<TPair<TKey, TList<T>>>;
    FCurrent: IGrouping<TKey, T>;
  public
    constructor Create(const ASource: IFluentEnumerator<T>;
      const AKeySelector: TFunc<T, TKey>);
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
    FEnumerator: TEnumerator<TPair<TKey, TList<TElement>>>;
    FCurrent: IGrouping<TKey, TElement>;
  public
    constructor Create(const ASource: IFluentEnumerator<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AElementSelector: TFunc<TSource, TElement>);
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
    FEnumerator: TEnumerator<TPair<TKey, TList<TSource>>>;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IFluentEnumerator<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      const AResultSelector: TFunc<TKey, IFluentEnumerableAdapter<TSource>, TResult>);
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
  const AKeySelector: TFunc<T, TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
end;

function TFluentGroupByEnumerable<TKey, T>.GetEnumerator: IFluentEnumerator<IGrouping<TKey, T>>;
begin
  Result := TFluentGroupByEnumerator<TKey, T>.Create(FSource.GetEnumerator, FKeySelector);
end;

function TFluentGroupByEnumerable<TKey, T>.AsEnumerable: IFluentEnumerable<IGrouping<TKey, T>>;
begin
  Result := IFluentEnumerable<IGrouping<TKey, T>>.Create(Self);
end;

{ TFluentGroupByEnumerable<TKey, TElement, TSource> }

constructor TFluentGroupByEnumerable<TKey, TElement, TSource>.Create(
  const ASource: IFluentEnumerableBase<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AElementSelector: TFunc<TSource, TElement>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FElementSelector := AElementSelector;
end;

function TFluentGroupByEnumerable<TKey, TElement, TSource>.GetEnumerator: IFluentEnumerator<IGrouping<TKey, TElement>>;
begin
  Result := TFluentGroupByEnumerator<TKey, TElement, TSource>.Create(
    FSource.GetEnumerator, FKeySelector, FElementSelector);
end;

function TFluentGroupByEnumerable<TKey, TElement, TSource>.AsEnumerable: IFluentEnumerable<IGrouping<TKey, TElement>>;
begin
  Result := IFluentEnumerable<IGrouping<TKey, TElement>>.Create(Self);
end;

{ TFluentGroupByResultEnumerable<TKey, TSource, TResult> }

constructor TFluentGroupByResultEnumerable<TKey, TSource, TResult>.Create(
  const ASource: IFluentEnumerableBase<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AResultSelector: TFunc<TKey, IFluentEnumerableAdapter<TSource>, TResult>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FResultSelector := AResultSelector;
end;

function TFluentGroupByResultEnumerable<TKey, TSource, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentGroupByResultEnumerator<TKey, TSource, TResult>.Create(
    FSource.GetEnumerator, FKeySelector, FResultSelector);
end;

{ TFluentGroupByEnumerator<TKey, T> }

constructor TFluentGroupByEnumerator<TKey, T>.Create(
  const ASource: IFluentEnumerator<T>;
  const AKeySelector: TFunc<T, TKey>);
var
  LItem: T;
begin
  FSourceEnum := ASource;
  FKeySelector := AKeySelector;
  FGroups := TDictionary<TKey, TList<T>>.Create;
  while FSourceEnum.MoveNext do
  begin
    LItem := FSourceEnum.Current;
    if FGroups.ContainsKey(FKeySelector(LItem)) then
      FGroups[FKeySelector(LItem)].Add(LItem)
    else
    begin
      FGroups.Add(FKeySelector(LItem), TList<T>.Create);
      FGroups[FKeySelector(LItem)].Add(LItem);
    end;
    WriteLn('Adicionado item ao grupo com Key: ' + TValue.From<TKey>(FKeySelector(LItem)).ToString);
  end;
  FEnumerator := FGroups.GetEnumerator;
end;

destructor TFluentGroupByEnumerator<TKey, T>.Destroy;
var
  LPair: TPair<TKey, TList<T>>;
begin
  for LPair in FGroups do
    LPair.Value.Free;
  FGroups.Free;
  FEnumerator.Free;
  inherited;
end;

function TFluentGroupByEnumerator<TKey, T>.GetCurrent: IGrouping<TKey, T>;
begin
  Result := FCurrent;
end;

function TFluentGroupByEnumerator<TKey, T>.MoveNext: Boolean;
var
  LPair: TPair<TKey, TList<T>>;
begin
  if FEnumerator.MoveNext then
  begin
    LPair := FEnumerator.Current;
    WriteLn('Grupo Key: ' + TValue.From<TKey>(LPair.Key).ToString + ', Item Count: ' + LPair.Value.Count.ToString);
    FCurrent := TFluentGrouping<TKey, T>.Create(
      LPair.Key,
      IFluentEnumerable<T>.Create(
        TListAdapter<T>.Create(LPair.Value, True),
        ftNone,
        TEqualityComparer<T>.Default
      )
    );
    FGroups.Remove(LPair.Key);
    Result := True;
  end
  else
    Result := False;
end;

procedure TFluentGroupByEnumerator<TKey, T>.Reset;
begin
  FEnumerator.Free;
  FEnumerator := FGroups.GetEnumerator;
end;

{ TFluentGroupByEnumerator<TKey, TElement, TSource> }

constructor TFluentGroupByEnumerator<TKey, TElement, TSource>.Create(
  const ASource: IFluentEnumerator<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AElementSelector: TFunc<TSource, TElement>);
var
  LItem: TSource;
begin
  FSourceEnum := ASource;
  FKeySelector := AKeySelector;
  FElementSelector := AElementSelector;
  FGroups := TDictionary<TKey, TList<TElement>>.Create;
  while FSourceEnum.MoveNext do
  begin
    LItem := FSourceEnum.Current;
    if not FGroups.ContainsKey(FKeySelector(LItem)) then
      FGroups.Add(FKeySelector(LItem), TList<TElement>.Create);
    FGroups[FKeySelector(LItem)].Add(FElementSelector(LItem));
  end;
  FEnumerator := FGroups.GetEnumerator;
end;

destructor TFluentGroupByEnumerator<TKey, TElement, TSource>.Destroy;
var
  LPair: TPair<TKey, TList<TElement>>;
begin
  for LPair in FGroups do
    LPair.Value.Free;
  FGroups.Free;
  FEnumerator.Free;
  inherited;
end;

function TFluentGroupByEnumerator<TKey, TElement, TSource>.GetCurrent: IGrouping<TKey, TElement>;
begin
  Result := FCurrent;
end;

function TFluentGroupByEnumerator<TKey, TElement, TSource>.MoveNext: Boolean;
var
  LPair: TPair<TKey, TList<TElement>>;
begin
  if FEnumerator.MoveNext then
  begin
    LPair := FEnumerator.Current;
    FCurrent := TFluentGrouping<TKey, TElement>.Create(
      LPair.Key,
      IFluentEnumerable<TElement>.Create(
        TListAdapter<TElement>.Create(LPair.Value, False),
        ftNone,
        TEqualityComparer<TElement>.Default));
    Result := True;
  end
  else
    Result := False;
end;

procedure TFluentGroupByEnumerator<TKey, TElement, TSource>.Reset;
begin
  FEnumerator.Free;
  FEnumerator := FGroups.GetEnumerator;
end;

{ TFluentGroupByResultEnumerator<TKey, TSource, TResult> }

constructor TFluentGroupByResultEnumerator<TKey, TSource, TResult>.Create(
  const ASource: IFluentEnumerator<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  const AResultSelector: TFunc<TKey, IFluentEnumerableAdapter<TSource>, TResult>);
var
  LItem: TSource;
begin
  FSourceEnum := ASource;
  FKeySelector := AKeySelector;
  FResultSelector := AResultSelector;
  FGroups := TDictionary<TKey, TList<TSource>>.Create;
  while FSourceEnum.MoveNext do
  begin
    LItem := FSourceEnum.Current;
    if not FGroups.ContainsKey(FKeySelector(LItem)) then
      FGroups.Add(FKeySelector(LItem), TList<TSource>.Create);
    FGroups[FKeySelector(LItem)].Add(LItem);
  end;
  FEnumerator := FGroups.GetEnumerator;
end;

destructor TFluentGroupByResultEnumerator<TKey, TSource, TResult>.Destroy;
var
  LPair: TPair<TKey, TList<TSource>>;
begin
  for LPair in FGroups do
    LPair.Value.Free;
  FGroups.Free;
  FEnumerator.Free;
  inherited;
end;

function TFluentGroupByResultEnumerator<TKey, TSource, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentGroupByResultEnumerator<TKey, TSource, TResult>.MoveNext: Boolean;
var
  LPair: TPair<TKey, TList<TSource>>;
begin
  if FEnumerator.MoveNext then
  begin
    LPair := FEnumerator.Current;
    FCurrent := FResultSelector(
      LPair.Key,
      TEnumerableAdapter<TSource>.Create(
        IFluentEnumerable<TSource>.Create(
          TListAdapter<TSource>.Create(LPair.Value, False),
          ftNone,
          TEqualityComparer<TSource>.Default), nil));
    Result := True;
  end
  else
    Result := False;
end;

procedure TFluentGroupByResultEnumerator<TKey, TSource, TResult>.Reset;
begin
  FEnumerator.Free;
  FEnumerator := FGroups.GetEnumerator;
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
