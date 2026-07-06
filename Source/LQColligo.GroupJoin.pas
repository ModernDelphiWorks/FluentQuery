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

unit LQColligo.GroupJoin;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  LQColligo,
  LQColligo.Adapters;

type
  TLQColligoGroupJoinEnumerable<T, TInner, TKey, TResult> = class(TLQColligoEnumerableBase<TResult>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FInner: ILQColligoEnumerableBase<TInner>;
    FOuterKeySelector: TFunc<T, TKey>;
    FInnerKeySelector: TFunc<TInner, TKey>;
    FResultSelector: TFunc<T, ILQColligoEnumerableAdapter<TInner>, TResult>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const AInner: ILQColligoEnumerableBase<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, ILQColligoEnumerableAdapter<TInner>, TResult>);
    function GetEnumerator: ILQColligoEnumerator<TResult>; override;
  end;

  TLQColligoGroupJoinEnumerator<T, TInner, TKey, TResult> = class(TInterfacedObject, ILQColligoEnumerator<TResult>)
  private
    FSource: ILQColligoEnumerator<T>;
    FInner: TList<TInner>;
    FOuterKeySelector: TFunc<T, TKey>;
    FInnerKeySelector: TFunc<TInner, TKey>;
    FResultSelector: TFunc<T, ILQColligoEnumerableAdapter<TInner>, TResult>;
    FCurrent: TResult;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const AInner: ILQColligoEnumerator<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, ILQColligoEnumerableAdapter<TInner>, TResult>);
    destructor Destroy; override;
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TLQColligoGroupJoinEnumerable<T, TInner, TKey, TResult> }

constructor TLQColligoGroupJoinEnumerable<T, TInner, TKey, TResult>.Create(const ASource: ILQColligoEnumerableBase<T>;
  const AInner: ILQColligoEnumerableBase<TInner>; const AOuterKeySelector: TFunc<T, TKey>;
  const AInnerKeySelector: TFunc<TInner, TKey>; const AResultSelector: TFunc<T, ILQColligoEnumerableAdapter<TInner>, TResult>);
begin
  FSource := ASource;
  FInner := AInner;
  FOuterKeySelector := AOuterKeySelector;
  FInnerKeySelector := AInnerKeySelector;
  FResultSelector := AResultSelector;
end;

function TLQColligoGroupJoinEnumerable<T, TInner, TKey, TResult>.GetEnumerator: ILQColligoEnumerator<TResult>;
begin
  Result := TLQColligoGroupJoinEnumerator<T, TInner, TKey, TResult>.Create(FSource.GetEnumerator, FInner.GetEnumerator,
    FOuterKeySelector, FInnerKeySelector, FResultSelector);
end;

{ TLQColligoGroupJoinEnumerator<T, TInner, TKey, TResult> }

constructor TLQColligoGroupJoinEnumerator<T, TInner, TKey, TResult>.Create(const ASource: ILQColligoEnumerator<T>;
  const AInner: ILQColligoEnumerator<TInner>; const AOuterKeySelector: TFunc<T, TKey>;
  const AInnerKeySelector: TFunc<TInner, TKey>; const AResultSelector: TFunc<T, ILQColligoEnumerableAdapter<TInner>, TResult>);
begin
  FSource := ASource;
  FInner := TList<TInner>.Create;
  FOuterKeySelector := AOuterKeySelector;
  FInnerKeySelector := AInnerKeySelector;
  FResultSelector := AResultSelector;
  while AInner.MoveNext do
    FInner.Add(AInner.Current);
end;

destructor TLQColligoGroupJoinEnumerator<T, TInner, TKey, TResult>.Destroy;
begin
  FInner.Free;
  inherited;
end;

function TLQColligoGroupJoinEnumerator<T, TInner, TKey, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TLQColligoGroupJoinEnumerator<T, TInner, TKey, TResult>.MoveNext: Boolean;
var
  LOuterKey: TKey;
  LMatches: ILQColligoEnumerable<TInner>;
  LWrapper: ILQColligoEnumerableAdapter<TInner>;
begin
  if FSource.MoveNext then
  begin
    LOuterKey := FOuterKeySelector(FSource.Current);
    LMatches := ILQColligoEnumerable<TInner>.Create(TListAdapter<TInner>.Create(FInner)).Where(
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

procedure TLQColligoGroupJoinEnumerator<T, TInner, TKey, TResult>.Reset;
begin
  FSource.Reset;
end;

end.



