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

unit Colligo.UnionBy;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  Colligo;

type
  // LINQ UnionBy: deferred/streaming — yields the first element for each distinct
  // key across the first sequence then the second, in read order. The seen-keys
  // set grows as items are pulled; nothing runs until enumeration. Key equality
  // uses AComparer (nil => default).
  TColligoUnionByEnumerable<T, TKey> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FSecond: IColligoEnumerableBase<T>;
    FKeySelector: TFunc<T, TKey>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const ASecond: IColligoEnumerableBase<T>;
      const AKeySelector: TFunc<T, TKey>; const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoUnionByEnumerator<T, TKey> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FSecond: IColligoEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FSeen: TDictionary<TKey, Byte>;
    FCurrent: T;
    FOnSecond: Boolean;
    function TryNext(const AEnum: IColligoEnumerator<T>): Boolean;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ASecond: IColligoEnumerator<T>;
      const AKeySelector: TFunc<T, TKey>; const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoUnionByEnumerable<T, TKey> }

constructor TColligoUnionByEnumerable<T, TKey>.Create(const ASource: IColligoEnumerableBase<T>;
  const ASecond: IColligoEnumerableBase<T>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FKeySelector := AKeySelector;
  FComparer := AComparer;
end;

function TColligoUnionByEnumerable<T, TKey>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoUnionByEnumerator<T, TKey>.Create(FSource.GetEnumerator, FSecond.GetEnumerator,
    FKeySelector, FComparer);
end;

{ TColligoUnionByEnumerator<T, TKey> }

constructor TColligoUnionByEnumerator<T, TKey>.Create(const ASource: IColligoEnumerator<T>;
  const ASecond: IColligoEnumerator<T>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FKeySelector := AKeySelector;
  FSeen := TDictionary<TKey, Byte>.Create(AComparer);
  FOnSecond := False;
end;

destructor TColligoUnionByEnumerator<T, TKey>.Destroy;
begin
  FSeen.Free;
  inherited;
end;

function TColligoUnionByEnumerator<T, TKey>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoUnionByEnumerator<T, TKey>.TryNext(const AEnum: IColligoEnumerator<T>): Boolean;
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

function TColligoUnionByEnumerator<T, TKey>.MoveNext: Boolean;
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

procedure TColligoUnionByEnumerator<T, TKey>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FSeen.Clear;
  FOnSecond := False;
end;

end.
