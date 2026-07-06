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

unit FluentQuery.IntersectBy;

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
  // LINQ IntersectBy: deferred — yields the DISTINCT first-sequence elements
  // whose key is among the second sequence of keys, in first-appearance order.
  // The second (keys) is buffered when enumeration starts (in the enumerator
  // constructor, i.e. at GetEnumerator); the source is streamed. Key equality
  // uses AComparer (nil => default).
  TFluentIntersectByEnumerable<T, TKey> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FSecondKeys: IFluentEnumerableBase<TKey>;
    FKeySelector: TFunc<T, TKey>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const ASecondKeys: IFluentEnumerableBase<TKey>; const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentIntersectByEnumerator<T, TKey> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FKeys: TDictionary<TKey, Byte>;
    FEmitted: TDictionary<TKey, Byte>;
    FCurrent: T;
  public
    constructor Create(const ASource: IFluentEnumerator<T>;
      const ASecondKeys: IFluentEnumerator<TKey>; const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentIntersectByEnumerable<T, TKey> }

constructor TFluentIntersectByEnumerable<T, TKey>.Create(const ASource: IFluentEnumerableBase<T>;
  const ASecondKeys: IFluentEnumerableBase<TKey>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FSecondKeys := ASecondKeys;
  FKeySelector := AKeySelector;
  FComparer := AComparer;
end;

function TFluentIntersectByEnumerable<T, TKey>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentIntersectByEnumerator<T, TKey>.Create(
    FSource.GetEnumerator, FSecondKeys.GetEnumerator, FKeySelector, FComparer);
end;

{ TFluentIntersectByEnumerator<T, TKey> }

constructor TFluentIntersectByEnumerator<T, TKey>.Create(const ASource: IFluentEnumerator<T>;
  const ASecondKeys: IFluentEnumerator<TKey>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FKeys := TDictionary<TKey, Byte>.Create(AComparer);
  FEmitted := TDictionary<TKey, Byte>.Create(AComparer);
  while ASecondKeys.MoveNext do
    FKeys.AddOrSetValue(ASecondKeys.Current, 0);
end;

destructor TFluentIntersectByEnumerator<T, TKey>.Destroy;
begin
  FKeys.Free;
  FEmitted.Free;
  inherited;
end;

function TFluentIntersectByEnumerator<T, TKey>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentIntersectByEnumerator<T, TKey>.MoveNext: Boolean;
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

procedure TFluentIntersectByEnumerator<T, TKey>.Reset;
begin
  FSource.Reset;
  FEmitted.Clear; // FKeys persists (the second keys were already buffered)
end;

end.
