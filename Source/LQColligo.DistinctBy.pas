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

unit LQColligo.DistinctBy;

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
  // LINQ DistinctBy: deferred/streaming — yields the first element for each
  // distinct key, in source order. The seen-keys set grows as items are pulled;
  // nothing runs until enumeration. Key equality uses AComparer (nil => default).
  TLQColligoDistinctByEnumerable<T, TKey> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FKeySelector: TFunc<T, TKey>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoDistinctByEnumerator<T, TKey> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FSeen: TDictionary<TKey, Byte>;
    FCurrent: T;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TLQColligoDistinctByEnumerable<T, TKey> }

constructor TLQColligoDistinctByEnumerable<T, TKey>.Create(const ASource: ILQColligoEnumerableBase<T>;
  const AKeySelector: TFunc<T, TKey>; const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FComparer := AComparer;
end;

function TLQColligoDistinctByEnumerable<T, TKey>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoDistinctByEnumerator<T, TKey>.Create(FSource.GetEnumerator, FKeySelector, FComparer);
end;

{ TLQColligoDistinctByEnumerator<T, TKey> }

constructor TLQColligoDistinctByEnumerator<T, TKey>.Create(const ASource: ILQColligoEnumerator<T>;
  const AKeySelector: TFunc<T, TKey>; const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FSeen := TDictionary<TKey, Byte>.Create(AComparer);
end;

destructor TLQColligoDistinctByEnumerator<T, TKey>.Destroy;
begin
  FSeen.Free;
  inherited;
end;

function TLQColligoDistinctByEnumerator<T, TKey>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoDistinctByEnumerator<T, TKey>.MoveNext: Boolean;
var
  LItem: T;
  LKey: TKey;
begin
  while FSource.MoveNext do
  begin
    LItem := FSource.Current;
    LKey := FKeySelector(LItem); // computed once per item
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

procedure TLQColligoDistinctByEnumerator<T, TKey>.Reset;
begin
  FSource.Reset;
  FSeen.Clear;
end;

end.
