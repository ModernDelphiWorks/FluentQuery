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

unit LQColligo.Distinct;

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
  TLQColligoDistinctEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoDistinctEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSet: TDictionary<T, Byte>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    function Contains(const AValue: T): Boolean;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TLQColligoDistinctQueryable<T> = class(TLQColligoQueryableBase<T>)
  private
    FSource: ILQColligoQueryableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: ILQColligoQueryableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TLQColligoDistinctQueryableEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSet: TDictionary<T, Byte>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    function Contains(const AValue: T): Boolean;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TLQColligoDistinctEnumerable<T> }

constructor TLQColligoDistinctEnumerable<T>.Create(
  const ASource: ILQColligoEnumerableBase<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  if AComparer = nil then
    FComparer := TEqualityComparer<T>.Default
  else
    FComparer := AComparer;
end;

function TLQColligoDistinctEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoDistinctEnumerator<T>.Create(FSource.GetEnumerator, FComparer);
end;

{ TLQColligoDistinctEnumerator<T> }

constructor TLQColligoDistinctEnumerator<T>.Create(
  const ASource: ILQColligoEnumerator<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSet := TDictionary<T, Byte>.Create(FComparer);
end;

destructor TLQColligoDistinctEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TLQColligoDistinctEnumerator<T>.Contains(const AValue: T): Boolean;
begin
  // O(1) hash lookup instead of an O(n) linear scan.
  Result := FSet.ContainsKey(AValue);
end;

function TLQColligoDistinctEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoDistinctEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if not Contains(FCurrent) then
    begin
      FSet.Add(FCurrent, 0);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TLQColligoDistinctEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSet.Clear;
end;

{$IFDEF QUERYABLE}
{ TLQColligoDistinctQueryable<T> }

constructor TLQColligoDistinctQueryable<T>.Create(
  const ASource: ILQColligoQueryableBase<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  if AComparer = nil then
    FComparer := TEqualityComparer<T>.Default
  else
    FComparer := AComparer;
end;

function TLQColligoDistinctQueryable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoDistinctQueryableEnumerator<T>.Create(FSource.GetEnumerator, FComparer);
end;

function TLQColligoDistinctQueryable<T>.BuildQuery: string;
begin
  Result := 'SELECT DISTINCT * FROM (' + FSource.BuildQuery + ') AS Temp';
end;

{ TLQColligoDistinctQueryableEnumerator<T> }

constructor TLQColligoDistinctQueryableEnumerator<T>.Create(
  const ASource: ILQColligoEnumerator<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSet := TDictionary<T, Byte>.Create(FComparer);
end;

destructor TLQColligoDistinctQueryableEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TLQColligoDistinctQueryableEnumerator<T>.Contains(const AValue: T): Boolean;
begin
  // O(1) hash lookup instead of an O(n) linear scan.
  Result := FSet.ContainsKey(AValue);
end;

function TLQColligoDistinctQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoDistinctQueryableEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if not Contains(FCurrent) then
    begin
      FSet.Add(FCurrent, 0);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TLQColligoDistinctQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSet.Clear;
end;
{$ENDIF}

end.



