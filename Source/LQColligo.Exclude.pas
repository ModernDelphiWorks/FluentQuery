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

unit LQColligo.Exclude;

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
  TLQColligoExcludeEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FSecond: ILQColligoEnumerableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>;
      const ASecond: ILQColligoEnumerableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoExcludeEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSecond: TDictionary<T, Boolean>;
    FEmitted: TDictionary<T, Boolean>;
    FCurrent: T;
    FComparer: IEqualityComparer<T>;
    function ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ASecond: ILQColligoEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TLQColligoExcludeQueryable<T> = class(TLQColligoQueryableBase<T>)
  private
    FSource: ILQColligoQueryableBase<T>;
    FSecond: ILQColligoQueryableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: ILQColligoQueryableBase<T>; const ASecond: ILQColligoQueryableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TLQColligoExcludeQueryableEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSecond: TDictionary<T, Boolean>;
    FEmitted: TDictionary<T, Boolean>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    function _ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ASecond: ILQColligoEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TLQColligoExcludeEnumerable<T> }

constructor TLQColligoExcludeEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>;
  const ASecond: ILQColligoEnumerableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TLQColligoExcludeEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoExcludeEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

{ TLQColligoExcludeEnumerator<T> }

constructor TLQColligoExcludeEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>;
  const ASecond: ILQColligoEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSecond := TDictionary<T, Boolean>.Create(FComparer);
  FEmitted := TDictionary<T, Boolean>.Create(FComparer);
  while ASecond.MoveNext do
    // AddOrSetValue (not Add) so a second sequence containing duplicates does
    // not raise EListError — the dictionary is a set, duplicates are a no-op.
    FSecond.AddOrSetValue(ASecond.Current, True);
end;

destructor TLQColligoExcludeEnumerator<T>.Destroy;
begin
  FSecond.Free;
  FEmitted.Free;
  inherited;
end;

function TLQColligoExcludeEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoExcludeEnumerator<T>.ContainsValue(const AValue: T): Boolean;
begin
  // O(1) hash lookup — the dictionary was already built with FComparer.
  Result := FSecond.ContainsKey(AValue);
end;

function TLQColligoExcludeEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    // Except yields DISTINCT elements: skip items in the second set AND any
    // already emitted, so duplicates in the source appear at most once
    // (first-appearance order preserved).
    if not ContainsValue(FCurrent) and not FEmitted.ContainsKey(FCurrent) then
    begin
      FEmitted.AddOrSetValue(FCurrent, True);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TLQColligoExcludeEnumerator<T>.Reset;
begin
  FSource.Reset;
  FEmitted.Clear;
end;

{$IFDEF QUERYABLE}
{ TLQColligoExcludeQueryable<T> }

constructor TLQColligoExcludeQueryable<T>.Create(const ASource: ILQColligoQueryableBase<T>;
  const ASecond: ILQColligoQueryableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TLQColligoExcludeQueryable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoExcludeQueryableEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

function TLQColligoExcludeQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Exclude pra SQL (ex.: LEFT JOIN com WHERE NULL)
  Result := FSource.BuildQuery + ' EXCEPT ' + FSecond.BuildQuery;
  // Exemplo fictício: 'SELECT * FROM Table1 EXCEPT SELECT * FROM Table2'
end;

{ TLQColligoExcludeQueryableEnumerator<T> }

constructor TLQColligoExcludeQueryableEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>;
  const ASecond: ILQColligoEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSecond := TDictionary<T, Boolean>.Create(FComparer);
  FEmitted := TDictionary<T, Boolean>.Create(FComparer);
  while ASecond.MoveNext do
    // AddOrSetValue (not Add) so a second sequence containing duplicates does
    // not raise EListError — the dictionary is a set, duplicates are a no-op.
    FSecond.AddOrSetValue(ASecond.Current, True);
end;

destructor TLQColligoExcludeQueryableEnumerator<T>.Destroy;
begin
  FSecond.Free;
  FEmitted.Free;
  inherited;
end;

function TLQColligoExcludeQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoExcludeQueryableEnumerator<T>._ContainsValue(const AValue: T): Boolean;
begin
  // O(1) hash lookup — the dictionary was already built with FComparer.
  Result := FSecond.ContainsKey(AValue);
end;

function TLQColligoExcludeQueryableEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    // Except yields DISTINCT elements: skip the second set AND already emitted.
    if not _ContainsValue(FCurrent) and not FEmitted.ContainsKey(FCurrent) then
    begin
      FEmitted.AddOrSetValue(FCurrent, True);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TLQColligoExcludeQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FEmitted.Clear;
end;
{$ENDIF}

end.



