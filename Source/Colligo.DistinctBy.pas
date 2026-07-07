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

unit Colligo.DistinctBy;

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
  // LINQ DistinctBy: deferred/streaming — yields the first element for each
  // distinct key, in source order. The seen-keys set grows as items are pulled;
  // nothing runs until enumeration. Key equality uses AComparer (nil => default).
  TColligoDistinctByEnumerable<T, TKey> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FKeySelector: TFunc<T, TKey>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoDistinctByEnumerator<T, TKey> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FSeen: TDictionary<TKey, Byte>;
    FCurrent: T;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoDistinctByEnumerable<T, TKey> }

constructor TColligoDistinctByEnumerable<T, TKey>.Create(const ASource: IColligoEnumerableBase<T>;
  const AKeySelector: TFunc<T, TKey>; const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FComparer := AComparer;
end;

function TColligoDistinctByEnumerable<T, TKey>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoDistinctByEnumerator<T, TKey>.Create(FSource.GetEnumerator, FKeySelector, FComparer);
end;

{ TColligoDistinctByEnumerator<T, TKey> }

constructor TColligoDistinctByEnumerator<T, TKey>.Create(const ASource: IColligoEnumerator<T>;
  const AKeySelector: TFunc<T, TKey>; const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FSeen := TDictionary<TKey, Byte>.Create(AComparer);
end;

destructor TColligoDistinctByEnumerator<T, TKey>.Destroy;
begin
  FSeen.Free;
  inherited;
end;

function TColligoDistinctByEnumerator<T, TKey>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoDistinctByEnumerator<T, TKey>.MoveNext: Boolean;
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

procedure TColligoDistinctByEnumerator<T, TKey>.Reset;
begin
  FSource.Reset;
  FSeen.Clear;
end;

end.
