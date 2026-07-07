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

unit Colligo.Intersect;

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
  TColligoIntersectEnumerable<T> = class(TColligoEnumerableBase<T>)
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

  TColligoIntersectEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
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
  TColligoIntersectQueryable<T> = class(TColligoQueryableBase<T>)
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

  TColligoIntersectQueryableEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
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

{ TColligoIntersectEnumerable<T> }

constructor TColligoIntersectEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>;
  const ASecond: IColligoEnumerableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TColligoIntersectEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoIntersectEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

{ TColligoIntersectEnumerator<T> }

constructor TColligoIntersectEnumerator<T>.Create(const ASource: IColligoEnumerator<T>;
  const ASecond: IColligoEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSecond := TDictionary<T, Boolean>.Create(FComparer);
  // Track already-emitted items so results stay distinct WITHOUT draining
  // FSecond (the old code removed matched keys from FSecond, which broke Reset).
  FEmitted := TDictionary<T, Boolean>.Create(FComparer);
  while ASecond.MoveNext do
    // AddOrSetValue (not Add) so a second sequence containing duplicates does
    // not raise EListError — the dictionary is a set, duplicates are a no-op.
    FSecond.AddOrSetValue(ASecond.Current, True);
end;

destructor TColligoIntersectEnumerator<T>.Destroy;
begin
  FSecond.Free;
  FEmitted.Free;
  inherited;
end;

function TColligoIntersectEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoIntersectEnumerator<T>.ContainsValue(const AValue: T): Boolean;
begin
  // O(1) hash lookup — the dictionary was already built with FComparer.
  Result := FSecond.ContainsKey(AValue);
end;

function TColligoIntersectEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if ContainsValue(FCurrent) and not FEmitted.ContainsKey(FCurrent) then
    begin
      FEmitted.Add(FCurrent, True);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TColligoIntersectEnumerator<T>.Reset;
begin
  FSource.Reset;
  FEmitted.Clear;
end;

{$IFDEF QUERYABLE}
{ TColligoIntersectQueryable<T> }

constructor TColligoIntersectQueryable<T>.Create(const ASource: IColligoQueryableBase<T>;
  const ASecond: IColligoQueryableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TColligoIntersectQueryable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoIntersectQueryableEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

function TColligoIntersectQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Intersect pra SQL (ex.: INTERSECT)
  Result := FSource.BuildQuery + ' INTERSECT ' + FSecond.BuildQuery;
  // Exemplo fictício: 'SELECT * FROM Table1 INTERSECT SELECT * FROM Table2'
end;

{ TColligoIntersectQueryableEnumerator<T> }

constructor TColligoIntersectQueryableEnumerator<T>.Create(const ASource: IColligoEnumerator<T>;
  const ASecond: IColligoEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSecond := TDictionary<T, Boolean>.Create(FComparer);
  // Track already-emitted items so results stay distinct WITHOUT draining
  // FSecond (the old code removed matched keys from FSecond, which broke Reset).
  FEmitted := TDictionary<T, Boolean>.Create(FComparer);
  while ASecond.MoveNext do
    // AddOrSetValue (not Add) so a second sequence containing duplicates does
    // not raise EListError — the dictionary is a set, duplicates are a no-op.
    FSecond.AddOrSetValue(ASecond.Current, True);
end;

destructor TColligoIntersectQueryableEnumerator<T>.Destroy;
begin
  FSecond.Free;
  FEmitted.Free;
  inherited;
end;

function TColligoIntersectQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoIntersectQueryableEnumerator<T>._ContainsValue(const AValue: T): Boolean;
begin
  // O(1) hash lookup — the dictionary was already built with FComparer.
  Result := FSecond.ContainsKey(AValue);
end;

function TColligoIntersectQueryableEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if _ContainsValue(FCurrent) and not FEmitted.ContainsKey(FCurrent) then
    begin
      FEmitted.Add(FCurrent, True);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TColligoIntersectQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FEmitted.Clear;
end;
{$ENDIF}

end.



