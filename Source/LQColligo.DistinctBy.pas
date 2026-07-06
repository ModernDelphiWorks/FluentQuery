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
  TFluentDistinctByEnumerable<T, TKey> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FKeySelector: TFunc<T, TKey>;
    FComparer: IEqualityComparer<TKey>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey> = nil);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentDistinctByEnumerator<T, TKey> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FSeen: TDictionary<TKey, Byte>;
    FCurrent: T;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentDistinctByEnumerable<T, TKey> }

constructor TFluentDistinctByEnumerable<T, TKey>.Create(const ASource: IFluentEnumerableBase<T>;
  const AKeySelector: TFunc<T, TKey>; const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FComparer := AComparer;
end;

function TFluentDistinctByEnumerable<T, TKey>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentDistinctByEnumerator<T, TKey>.Create(FSource.GetEnumerator, FKeySelector, FComparer);
end;

{ TFluentDistinctByEnumerator<T, TKey> }

constructor TFluentDistinctByEnumerator<T, TKey>.Create(const ASource: IFluentEnumerator<T>;
  const AKeySelector: TFunc<T, TKey>; const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FSeen := TDictionary<TKey, Byte>.Create(AComparer);
end;

destructor TFluentDistinctByEnumerator<T, TKey>.Destroy;
begin
  FSeen.Free;
  inherited;
end;

function TFluentDistinctByEnumerator<T, TKey>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentDistinctByEnumerator<T, TKey>.MoveNext: Boolean;
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

procedure TFluentDistinctByEnumerator<T, TKey>.Reset;
begin
  FSource.Reset;
  FSeen.Clear;
end;

end.
