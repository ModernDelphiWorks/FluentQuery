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

unit Colligo.Exclude;

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
  TColligoExcludeEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FSecond: IColligoEnumerableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>;
      const ASecond: IColligoEnumerableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoExcludeEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FSecond: TDictionary<T, Boolean>;
    FEmitted: TDictionary<T, Boolean>;
    FCurrent: T;
    FComparer: IEqualityComparer<T>;
    function ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ASecond: IColligoEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TColligoExcludeQueryable<T> = class(TColligoQueryableBase<T>)
  private
    FSource: IColligoQueryableBase<T>;
    FSecond: IColligoQueryableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IColligoQueryableBase<T>; const ASecond: IColligoQueryableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IColligoEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TColligoExcludeQueryableEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FSecond: TDictionary<T, Boolean>;
    FEmitted: TDictionary<T, Boolean>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    function _ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ASecond: IColligoEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TColligoExcludeEnumerable<T> }

constructor TColligoExcludeEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>;
  const ASecond: IColligoEnumerableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TColligoExcludeEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoExcludeEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

{ TColligoExcludeEnumerator<T> }

constructor TColligoExcludeEnumerator<T>.Create(const ASource: IColligoEnumerator<T>;
  const ASecond: IColligoEnumerator<T>; const AComparer: IEqualityComparer<T>);
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

destructor TColligoExcludeEnumerator<T>.Destroy;
begin
  FSecond.Free;
  FEmitted.Free;
  inherited;
end;

function TColligoExcludeEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoExcludeEnumerator<T>.ContainsValue(const AValue: T): Boolean;
begin
  // O(1) hash lookup — the dictionary was already built with FComparer.
  Result := FSecond.ContainsKey(AValue);
end;

function TColligoExcludeEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoExcludeEnumerator<T>.Reset;
begin
  FSource.Reset;
  FEmitted.Clear;
end;

{$IFDEF QUERYABLE}
{ TColligoExcludeQueryable<T> }

constructor TColligoExcludeQueryable<T>.Create(const ASource: IColligoQueryableBase<T>;
  const ASecond: IColligoQueryableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TColligoExcludeQueryable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoExcludeQueryableEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

function TColligoExcludeQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Exclude pra SQL (ex.: LEFT JOIN com WHERE NULL)
  Result := FSource.BuildQuery + ' EXCEPT ' + FSecond.BuildQuery;
  // Exemplo fictício: 'SELECT * FROM Table1 EXCEPT SELECT * FROM Table2'
end;

{ TColligoExcludeQueryableEnumerator<T> }

constructor TColligoExcludeQueryableEnumerator<T>.Create(const ASource: IColligoEnumerator<T>;
  const ASecond: IColligoEnumerator<T>; const AComparer: IEqualityComparer<T>);
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

destructor TColligoExcludeQueryableEnumerator<T>.Destroy;
begin
  FSecond.Free;
  FEmitted.Free;
  inherited;
end;

function TColligoExcludeQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoExcludeQueryableEnumerator<T>._ContainsValue(const AValue: T): Boolean;
begin
  // O(1) hash lookup — the dictionary was already built with FComparer.
  Result := FSecond.ContainsKey(AValue);
end;

function TColligoExcludeQueryableEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoExcludeQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FEmitted.Clear;
end;
{$ENDIF}

end.



