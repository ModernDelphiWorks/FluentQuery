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

unit Colligo.IntersectBy;

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
  // LINQ IntersectBy: deferred — yields the DISTINCT first-sequence elements
  // whose key is among the second sequence of keys, in first-appearance order.
  // The second (keys) is buffered when enumeration starts (in the enumerator
  // constructor, i.e. at GetEnumerator); the source is streamed. Key equality
  // uses AComparer (nil => default).
  TColligoIntersectByEnumerable<T, TKey> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FSecondKeys: IColligoEnumerableBase<TKey>;
    FKeySelector: TFunc<T, TKey>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>;
      const ASecondKeys: IColligoEnumerableBase<TKey>; const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoIntersectByEnumerator<T, TKey> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FKeys: TDictionary<TKey, Byte>;
    FEmitted: TDictionary<TKey, Byte>;
    FCurrent: T;
  public
    constructor Create(const ASource: IColligoEnumerator<T>;
      const ASecondKeys: IColligoEnumerator<TKey>; const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoIntersectByEnumerable<T, TKey> }

constructor TColligoIntersectByEnumerable<T, TKey>.Create(const ASource: IColligoEnumerableBase<T>;
  const ASecondKeys: IColligoEnumerableBase<TKey>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FSecondKeys := ASecondKeys;
  FKeySelector := AKeySelector;
  FComparer := AComparer;
end;

function TColligoIntersectByEnumerable<T, TKey>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoIntersectByEnumerator<T, TKey>.Create(
    FSource.GetEnumerator, FSecondKeys.GetEnumerator, FKeySelector, FComparer);
end;

{ TColligoIntersectByEnumerator<T, TKey> }

constructor TColligoIntersectByEnumerator<T, TKey>.Create(const ASource: IColligoEnumerator<T>;
  const ASecondKeys: IColligoEnumerator<TKey>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FKeys := TDictionary<TKey, Byte>.Create(AComparer);
  FEmitted := TDictionary<TKey, Byte>.Create(AComparer);
  while ASecondKeys.MoveNext do
    FKeys.AddOrSetValue(ASecondKeys.Current, 0);
end;

destructor TColligoIntersectByEnumerator<T, TKey>.Destroy;
begin
  FKeys.Free;
  FEmitted.Free;
  inherited;
end;

function TColligoIntersectByEnumerator<T, TKey>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoIntersectByEnumerator<T, TKey>.MoveNext: Boolean;
var
  LItem: T;
  LKey: TKey;
begin
  while FSource.MoveNext do
  begin
    LItem := FSource.Current;
    LKey := FKeySelector(LItem);
    // Distinct set intersection: emit only keys present in the second set and
    // not already emitted.
    if FKeys.ContainsKey(LKey) and (not FEmitted.ContainsKey(LKey)) then
    begin
      FEmitted.Add(LKey, 0);
      FCurrent := LItem;
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TColligoIntersectByEnumerator<T, TKey>.Reset;
begin
  FSource.Reset;
  FEmitted.Clear; // FKeys persists (the second keys were already buffered)
end;

end.
