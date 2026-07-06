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

unit FluentQuery.UnionBy;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  FluentQuery;

type
  // LINQ UnionBy: deferred/streaming — yields the first element for each distinct
  // key across the first sequence then the second, in read order. The seen-keys
  // set grows as items are pulled; nothing runs until enumeration. Key equality
  // uses AComparer (nil => default).
  TFluentUnionByEnumerable<T, TKey> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FSecond: IFluentEnumerableBase<T>;
    FKeySelector: TFunc<T, TKey>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const ASecond: IFluentEnumerableBase<T>;
      const AKeySelector: TFunc<T, TKey>; const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentUnionByEnumerator<T, TKey> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FSecond: IFluentEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FSeen: TDictionary<TKey, Byte>;
    FCurrent: T;
    FOnSecond: Boolean;
    function TryNext(const AEnum: IFluentEnumerator<T>): Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASecond: IFluentEnumerator<T>;
      const AKeySelector: TFunc<T, TKey>; const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentUnionByEnumerable<T, TKey> }

constructor TFluentUnionByEnumerable<T, TKey>.Create(const ASource: IFluentEnumerableBase<T>;
  const ASecond: IFluentEnumerableBase<T>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FKeySelector := AKeySelector;
  FComparer := AComparer;
end;

function TFluentUnionByEnumerable<T, TKey>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentUnionByEnumerator<T, TKey>.Create(FSource.GetEnumerator, FSecond.GetEnumerator,
    FKeySelector, FComparer);
end;

{ TFluentUnionByEnumerator<T, TKey> }

constructor TFluentUnionByEnumerator<T, TKey>.Create(const ASource: IFluentEnumerator<T>;
  const ASecond: IFluentEnumerator<T>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FKeySelector := AKeySelector;
  FSeen := TDictionary<TKey, Byte>.Create(AComparer);
  FOnSecond := False;
end;

destructor TFluentUnionByEnumerator<T, TKey>.Destroy;
begin
  FSeen.Free;
  inherited;
end;

function TFluentUnionByEnumerator<T, TKey>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentUnionByEnumerator<T, TKey>.TryNext(const AEnum: IFluentEnumerator<T>): Boolean;
var
  LItem: T;
  LKey: TKey;
begin
  while AEnum.MoveNext do
  begin
    LItem := AEnum.Current;
    LKey := FKeySelector(LItem);
    if not FSeen.ContainsKey(LKey) then
    begin
      FSeen.Add(LKey, 0);
      FCurrent := LItem;
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function TFluentUnionByEnumerator<T, TKey>.MoveNext: Boolean;
begin
  if not FOnSecond then
  begin
    if TryNext(FSource) then
    begin
      Result := True;
      Exit;
    end;
    FOnSecond := True;
  end;
  Result := TryNext(FSecond);
end;

procedure TFluentUnionByEnumerator<T, TKey>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FSeen.Clear;
  FOnSecond := False;
end;

end.
