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
    FInner: TList<TInner>;
    FOuterKeySelector: TFunc<T, TKey>;
    FInnerKeySelector: TFunc<TInner, TKey>;
    FResultSelector: TFunc<T, TInner, TResult>;
    FCurrent: TResult;
    FInnerEnum: IFluentEnumerator<TInner>;
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
begin
  FSource := ASource;
  FInner := TList<TInner>.Create;
  FOuterKeySelector := AOuterKeySelector;
  FInnerKeySelector := AInnerKeySelector;
  FResultSelector := AResultSelector;
  while AInner.MoveNext do
    FInner.Add(AInner.Current);
  FInnerEnum := nil;
end;

destructor TFluentJoinEnumerator<T, TInner, TKey, TResult>.Destroy;
begin
  FInner.Free;
  inherited;
end;

function TFluentJoinEnumerator<T, TInner, TKey, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentJoinEnumerator<T, TInner, TKey, TResult>.MoveNext: Boolean;
var
  LOuterKey: TKey;
  LInnerItem: TInner;
begin
  while True do
  begin
    if not Assigned(FInnerEnum) or not FInnerEnum.MoveNext then
    begin
      if not FSource.MoveNext then
      begin
        FInnerEnum := nil;
        Result := False;
        Exit;
      end;
      FInnerEnum := TListAdapterEnumerator<TInner>.Create(FInner.GetEnumerator);
      if not FInnerEnum.MoveNext then
        Continue;
    end;
    LOuterKey := FOuterKeySelector(FSource.Current);
    LInnerItem := FInnerEnum.Current;
    if TComparer<TKey>.Default.Compare(LOuterKey, FInnerKeySelector(LInnerItem)) = 0 then
    begin
      FCurrent := FResultSelector(FSource.Current, LInnerItem);
      Result := True;
      Exit;
    end;
  end;
end;

procedure TFluentJoinEnumerator<T, TInner, TKey, TResult>.Reset;
begin
  FSource.Reset;
  FInnerEnum := nil;
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
