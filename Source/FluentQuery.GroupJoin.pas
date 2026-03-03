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

unit FluentQuery.GroupJoin;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  FluentQuery,
  FluentQuery.Adapters;

type
  TFluentGroupJoinEnumerable<T, TInner, TKey, TResult> = class(TFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<T>;
    FInner: IFluentEnumerableBase<TInner>;
    FOuterKeySelector: TFunc<T, TKey>;
    FInnerKeySelector: TFunc<TInner, TKey>;
    FResultSelector: TFunc<T, IFluentEnumerableAdapter<TInner>, TResult>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const AInner: IFluentEnumerableBase<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, IFluentEnumerableAdapter<TInner>, TResult>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentGroupJoinEnumerator<T, TInner, TKey, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSource: IFluentEnumerator<T>;
    FInner: TList<TInner>;
    FOuterKeySelector: TFunc<T, TKey>;
    FInnerKeySelector: TFunc<TInner, TKey>;
    FResultSelector: TFunc<T, IFluentEnumerableAdapter<TInner>, TResult>;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const AInner: IFluentEnumerator<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, IFluentEnumerableAdapter<TInner>, TResult>);
    destructor Destroy; override;
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TFluentGroupJoinEnumerable<T, TInner, TKey, TResult> }

constructor TFluentGroupJoinEnumerable<T, TInner, TKey, TResult>.Create(const ASource: IFluentEnumerableBase<T>;
  const AInner: IFluentEnumerableBase<TInner>; const AOuterKeySelector: TFunc<T, TKey>;
  const AInnerKeySelector: TFunc<TInner, TKey>; const AResultSelector: TFunc<T, IFluentEnumerableAdapter<TInner>, TResult>);
begin
  FSource := ASource;
  FInner := AInner;
  FOuterKeySelector := AOuterKeySelector;
  FInnerKeySelector := AInnerKeySelector;
  FResultSelector := AResultSelector;
end;

function TFluentGroupJoinEnumerable<T, TInner, TKey, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentGroupJoinEnumerator<T, TInner, TKey, TResult>.Create(FSource.GetEnumerator, FInner.GetEnumerator,
    FOuterKeySelector, FInnerKeySelector, FResultSelector);
end;

{ TFluentGroupJoinEnumerator<T, TInner, TKey, TResult> }

constructor TFluentGroupJoinEnumerator<T, TInner, TKey, TResult>.Create(const ASource: IFluentEnumerator<T>;
  const AInner: IFluentEnumerator<TInner>; const AOuterKeySelector: TFunc<T, TKey>;
  const AInnerKeySelector: TFunc<TInner, TKey>; const AResultSelector: TFunc<T, IFluentEnumerableAdapter<TInner>, TResult>);
begin
  FSource := ASource;
  FInner := TList<TInner>.Create;
  FOuterKeySelector := AOuterKeySelector;
  FInnerKeySelector := AInnerKeySelector;
  FResultSelector := AResultSelector;
  while AInner.MoveNext do
    FInner.Add(AInner.Current);
end;

destructor TFluentGroupJoinEnumerator<T, TInner, TKey, TResult>.Destroy;
begin
  FInner.Free;
  inherited;
end;

function TFluentGroupJoinEnumerator<T, TInner, TKey, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentGroupJoinEnumerator<T, TInner, TKey, TResult>.MoveNext: Boolean;
var
  LOuterKey: TKey;
  LMatches: IFluentEnumerable<TInner>;
  LWrapper: IFluentEnumerableAdapter<TInner>;
begin
  if FSource.MoveNext then
  begin
    LOuterKey := FOuterKeySelector(FSource.Current);
    LMatches := IFluentEnumerable<TInner>.Create(TListAdapter<TInner>.Create(FInner)).Where(
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

procedure TFluentGroupJoinEnumerator<T, TInner, TKey, TResult>.Reset;
begin
  FSource.Reset;
end;

end.
