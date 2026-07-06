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

unit LQColligo.Intersect;

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
  TLQColligoIntersectEnumerable<T> = class(TLQColligoEnumerableBase<T>)
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

  TLQColligoIntersectEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
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
  TLQColligoIntersectQueryable<T> = class(TLQColligoQueryableBase<T>)
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

  TLQColligoIntersectQueryableEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
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

{ TLQColligoIntersectEnumerable<T> }

constructor TLQColligoIntersectEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>;
  const ASecond: ILQColligoEnumerableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TLQColligoIntersectEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoIntersectEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

{ TLQColligoIntersectEnumerator<T> }

constructor TLQColligoIntersectEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>;
  const ASecond: ILQColligoEnumerator<T>; const AComparer: IEqualityComparer<T>);
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

destructor TLQColligoIntersectEnumerator<T>.Destroy;
begin
  FSecond.Free;
  FEmitted.Free;
  inherited;
end;

function TLQColligoIntersectEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoIntersectEnumerator<T>.ContainsValue(const AValue: T): Boolean;
begin
  // O(1) hash lookup — the dictionary was already built with FComparer.
  Result := FSecond.ContainsKey(AValue);
end;

function TLQColligoIntersectEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoIntersectEnumerator<T>.Reset;
begin
  FSource.Reset;
  FEmitted.Clear;
end;

{$IFDEF QUERYABLE}
{ TLQColligoIntersectQueryable<T> }

constructor TLQColligoIntersectQueryable<T>.Create(const ASource: ILQColligoQueryableBase<T>;
  const ASecond: ILQColligoQueryableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TLQColligoIntersectQueryable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoIntersectQueryableEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

function TLQColligoIntersectQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Intersect pra SQL (ex.: INTERSECT)
  Result := FSource.BuildQuery + ' INTERSECT ' + FSecond.BuildQuery;
  // Exemplo fictício: 'SELECT * FROM Table1 INTERSECT SELECT * FROM Table2'
end;

{ TLQColligoIntersectQueryableEnumerator<T> }

constructor TLQColligoIntersectQueryableEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>;
  const ASecond: ILQColligoEnumerator<T>; const AComparer: IEqualityComparer<T>);
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

destructor TLQColligoIntersectQueryableEnumerator<T>.Destroy;
begin
  FSecond.Free;
  FEmitted.Free;
  inherited;
end;

function TLQColligoIntersectQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoIntersectQueryableEnumerator<T>._ContainsValue(const AValue: T): Boolean;
begin
  // O(1) hash lookup — the dictionary was already built with FComparer.
  Result := FSecond.ContainsKey(AValue);
end;

function TLQColligoIntersectQueryableEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoIntersectQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FEmitted.Clear;
end;
{$ENDIF}

end.



