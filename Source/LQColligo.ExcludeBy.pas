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

unit LQColligo.ExcludeBy;

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
  // LINQ ExceptBy: deferred — yields the DISTINCT first-sequence elements whose
  // key is not among the second sequence of keys, in first-appearance order.
  // The second (keys) is buffered when enumeration starts (in the enumerator
  // constructor, i.e. at GetEnumerator); the source is streamed. Key equality
  // uses AComparer (nil => default).
  TFluentExcludeByEnumerable<T, TKey> = class(TFluentEnumerableBase<T>)
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

  TFluentExcludeByEnumerator<T, TKey> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FKeySelector: TFunc<T, TKey>;
    FExcluded: TDictionary<TKey, Byte>;
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

{ TFluentExcludeByEnumerable<T, TKey> }

constructor TFluentExcludeByEnumerable<T, TKey>.Create(const ASource: IFluentEnumerableBase<T>;
  const ASecondKeys: IFluentEnumerableBase<TKey>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FSecondKeys := ASecondKeys;
  FKeySelector := AKeySelector;
  FComparer := AComparer;
end;

function TFluentExcludeByEnumerable<T, TKey>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentExcludeByEnumerator<T, TKey>.Create(
    FSource.GetEnumerator, FSecondKeys.GetEnumerator, FKeySelector, FComparer);
end;

{ TFluentExcludeByEnumerator<T, TKey> }

constructor TFluentExcludeByEnumerator<T, TKey>.Create(const ASource: IFluentEnumerator<T>;
  const ASecondKeys: IFluentEnumerator<TKey>; const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FExcluded := TDictionary<TKey, Byte>.Create(AComparer);
  FEmitted := TDictionary<TKey, Byte>.Create(AComparer);
  while ASecondKeys.MoveNext do
    FExcluded.AddOrSetValue(ASecondKeys.Current, 0);
end;

destructor TFluentExcludeByEnumerator<T, TKey>.Destroy;
begin
  FExcluded.Free;
  FEmitted.Free;
  inherited;
end;

function TFluentExcludeByEnumerator<T, TKey>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentExcludeByEnumerator<T, TKey>.MoveNext: Boolean;
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

procedure TFluentExcludeByEnumerator<T, TKey>.Reset;
begin
  FSource.Reset;
  FEmitted.Clear; // FExcluded persists (the second keys were already buffered)
end;

end.
