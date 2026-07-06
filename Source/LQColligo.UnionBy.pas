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

unit LQColligo.UnionBy;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  LQColligo;

type
  // LINQ UnionBy: deferred/streaming — yields the first element for each distinct
  // key across the first sequence then the second, in read order. The seen-keys
  // set grows as items are pulled; nothing runs until enumeration. Key equality
  // uses AComparer (nil => default).
  TLQColligoUnionByEnumerable<T, TKey> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FSecond: ILQColligoEnumerableBase<T>;
    FKeySelector: TFunc<T, TKey>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const ASecond: ILQColligoEnumerableBase<T>;
      const AKeySelector: TFunc<T, TKey>; const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoUnionByEnumerator<T, TKey> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSecond: ILQColligoEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FSeen: TDictionary<TKey, Byte>;
    FCurrent: T;
    FOnSecond: Boolean;
    function TryNext(const AEnum: ILQColligoEnumerator<T>): Boolean;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ASecond: ILQColligoEnumerator<T>;
      const AKeySelector: TFunc<T, TKey>; const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TLQColligoUnionByEnumerable<T, TKey> }

constructor TLQColligoUnionByEnumerable<T, TKey>.Create(const ASource: ILQColligoEnumerableBase<T>;
  const ASecond: ILQColligoEnumerableBase<T>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FKeySelector := AKeySelector;
  FComparer := AComparer;
end;

function TLQColligoUnionByEnumerable<T, TKey>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoUnionByEnumerator<T, TKey>.Create(FSource.GetEnumerator, FSecond.GetEnumerator,
    FKeySelector, FComparer);
end;

{ TLQColligoUnionByEnumerator<T, TKey> }

constructor TLQColligoUnionByEnumerator<T, TKey>.Create(const ASource: ILQColligoEnumerator<T>;
  const ASecond: ILQColligoEnumerator<T>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FKeySelector := AKeySelector;
  FSeen := TDictionary<TKey, Byte>.Create(AComparer);
  FOnSecond := False;
end;

destructor TLQColligoUnionByEnumerator<T, TKey>.Destroy;
begin
  FSeen.Free;
  inherited;
end;

function TLQColligoUnionByEnumerator<T, TKey>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoUnionByEnumerator<T, TKey>.TryNext(const AEnum: ILQColligoEnumerator<T>): Boolean;
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

function TLQColligoUnionByEnumerator<T, TKey>.MoveNext: Boolean;
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

procedure TLQColligoUnionByEnumerator<T, TKey>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FSeen.Clear;
  FOnSecond := False;
end;

end.
