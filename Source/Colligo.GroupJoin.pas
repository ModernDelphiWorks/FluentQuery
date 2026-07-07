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

unit Colligo.GroupJoin;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  Colligo,
  Colligo.Adapters;

type
  TColligoGroupJoinEnumerable<T, TInner, TKey, TResult> = class(TColligoEnumerableBase<TResult>)
  private
    FSource: IColligoEnumerableBase<T>;
    FInner: IColligoEnumerableBase<TInner>;
    FOuterKeySelector: TFunc<T, TKey>;
    FInnerKeySelector: TFunc<TInner, TKey>;
    FResultSelector: TFunc<T, IColligoEnumerableAdapter<TInner>, TResult>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const AInner: IColligoEnumerableBase<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, IColligoEnumerableAdapter<TInner>, TResult>);
    function GetEnumerator: IColligoEnumerator<TResult>; override;
  end;

  TColligoGroupJoinEnumerator<T, TInner, TKey, TResult> = class(TInterfacedObject, IColligoEnumerator<TResult>)
  private
    FSource: IColligoEnumerator<T>;
    FInner: TList<TInner>;
    FOuterKeySelector: TFunc<T, TKey>;
    FInnerKeySelector: TFunc<TInner, TKey>;
    FResultSelector: TFunc<T, IColligoEnumerableAdapter<TInner>, TResult>;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const AInner: IColligoEnumerator<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, IColligoEnumerableAdapter<TInner>, TResult>);
    destructor Destroy; override;
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TColligoGroupJoinEnumerable<T, TInner, TKey, TResult> }

constructor TColligoGroupJoinEnumerable<T, TInner, TKey, TResult>.Create(const ASource: IColligoEnumerableBase<T>;
  const AInner: IColligoEnumerableBase<TInner>; const AOuterKeySelector: TFunc<T, TKey>;
  const AInnerKeySelector: TFunc<TInner, TKey>; const AResultSelector: TFunc<T, IColligoEnumerableAdapter<TInner>, TResult>);
begin
  FSource := ASource;
  FInner := AInner;
  FOuterKeySelector := AOuterKeySelector;
  FInnerKeySelector := AInnerKeySelector;
  FResultSelector := AResultSelector;
end;

function TColligoGroupJoinEnumerable<T, TInner, TKey, TResult>.GetEnumerator: IColligoEnumerator<TResult>;
begin
  Result := TColligoGroupJoinEnumerator<T, TInner, TKey, TResult>.Create(FSource.GetEnumerator, FInner.GetEnumerator,
    FOuterKeySelector, FInnerKeySelector, FResultSelector);
end;

{ TColligoGroupJoinEnumerator<T, TInner, TKey, TResult> }

constructor TColligoGroupJoinEnumerator<T, TInner, TKey, TResult>.Create(const ASource: IColligoEnumerator<T>;
  const AInner: IColligoEnumerator<TInner>; const AOuterKeySelector: TFunc<T, TKey>;
  const AInnerKeySelector: TFunc<TInner, TKey>; const AResultSelector: TFunc<T, IColligoEnumerableAdapter<TInner>, TResult>);
begin
  FSource := ASource;
  FInner := TList<TInner>.Create;
  FOuterKeySelector := AOuterKeySelector;
  FInnerKeySelector := AInnerKeySelector;
  FResultSelector := AResultSelector;
  while AInner.MoveNext do
    FInner.Add(AInner.Current);
end;

destructor TColligoGroupJoinEnumerator<T, TInner, TKey, TResult>.Destroy;
begin
  FInner.Free;
  inherited;
end;

function TColligoGroupJoinEnumerator<T, TInner, TKey, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TColligoGroupJoinEnumerator<T, TInner, TKey, TResult>.MoveNext: Boolean;
var
  LOuterKey: TKey;
  LMatches: IColligoEnumerable<TInner>;
  LWrapper: IColligoEnumerableAdapter<TInner>;
begin
  if FSource.MoveNext then
  begin
    LOuterKey := FOuterKeySelector(FSource.Current);
    LMatches := IColligoEnumerable<TInner>.Create(TListAdapter<TInner>.Create(FInner)).Where(
      function(Item: TInner): Boolean
      begin
        Result := TComparer<TKey>.Default.Compare(LOuterKey, FInnerKeySelector(Item)) = 0;
      end);
    LWrapper := TEnumerableAdapter<TInner>.Create(LMatches, nil);
    FCurrent := FResultSelector(FSource.Current, LWrapper);
    Result := True;
  end
  else
    Result := False;
end;

procedure TColligoGroupJoinEnumerator<T, TInner, TKey, TResult>.Reset;
begin
  FSource.Reset;
end;

end.



