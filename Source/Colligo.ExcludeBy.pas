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

unit Colligo.ExcludeBy;

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
  // LINQ ExceptBy: deferred — yields the DISTINCT first-sequence elements whose
  // key is not among the second sequence of keys, in first-appearance order.
  // The second (keys) is buffered when enumeration starts (in the enumerator
  // constructor, i.e. at GetEnumerator); the source is streamed. Key equality
  // uses AComparer (nil => default).
  TColligoExcludeByEnumerable<T, TKey> = class(TColligoEnumerableBase<T>)
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

  TColligoExcludeByEnumerator<T, TKey> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FExcluded: TDictionary<TKey, Byte>;
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

{ TColligoExcludeByEnumerable<T, TKey> }

constructor TColligoExcludeByEnumerable<T, TKey>.Create(const ASource: IColligoEnumerableBase<T>;
  const ASecondKeys: IColligoEnumerableBase<TKey>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FSecondKeys := ASecondKeys;
  FKeySelector := AKeySelector;
  FComparer := AComparer;
end;

function TColligoExcludeByEnumerable<T, TKey>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoExcludeByEnumerator<T, TKey>.Create(
    FSource.GetEnumerator, FSecondKeys.GetEnumerator, FKeySelector, FComparer);
end;

{ TColligoExcludeByEnumerator<T, TKey> }

constructor TColligoExcludeByEnumerator<T, TKey>.Create(const ASource: IColligoEnumerator<T>;
  const ASecondKeys: IColligoEnumerator<TKey>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FExcluded := TDictionary<TKey, Byte>.Create(AComparer);
  FEmitted := TDictionary<TKey, Byte>.Create(AComparer);
  while ASecondKeys.MoveNext do
    FExcluded.AddOrSetValue(ASecondKeys.Current, 0);
end;

destructor TColligoExcludeByEnumerator<T, TKey>.Destroy;
begin
  FExcluded.Free;
  FEmitted.Free;
  inherited;
end;

function TColligoExcludeByEnumerator<T, TKey>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoExcludeByEnumerator<T, TKey>.MoveNext: Boolean;
var
  LItem: T;
  LKey: TKey;
begin
  while FSource.MoveNext do
  begin
    LItem := FSource.Current;
    LKey := FKeySelector(LItem);
    // Distinct set difference: skip excluded keys and any key already emitted.
    if (not FExcluded.ContainsKey(LKey)) and (not FEmitted.ContainsKey(LKey)) then
    begin
      FEmitted.Add(LKey, 0);
      FCurrent := LItem;
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TColligoExcludeByEnumerator<T, TKey>.Reset;
begin
  FSource.Reset;
  FEmitted.Clear; // FExcluded persists (the second keys were already buffered)
end;

end.
