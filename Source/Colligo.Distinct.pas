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

unit Colligo.Distinct;

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
  TColligoDistinctEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoDistinctEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FSet: TDictionary<T, Byte>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    function Contains(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IColligoEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TColligoDistinctQueryable<T> = class(TColligoQueryableBase<T>)
  private
    FSource: IColligoQueryableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IColligoQueryableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IColligoEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TColligoDistinctQueryableEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FSet: TDictionary<T, Byte>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    function Contains(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IColligoEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TColligoDistinctEnumerable<T> }

constructor TColligoDistinctEnumerable<T>.Create(
  const ASource: IColligoEnumerableBase<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  if AComparer = nil then
    FComparer := TEqualityComparer<T>.Default
  else
    FComparer := AComparer;
end;

function TColligoDistinctEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoDistinctEnumerator<T>.Create(FSource.GetEnumerator, FComparer);
end;

{ TColligoDistinctEnumerator<T> }

constructor TColligoDistinctEnumerator<T>.Create(
  const ASource: IColligoEnumerator<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSet := TDictionary<T, Byte>.Create(FComparer);
end;

destructor TColligoDistinctEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TColligoDistinctEnumerator<T>.Contains(const AValue: T): Boolean;
begin
  // O(1) hash lookup instead of an O(n) linear scan.
  Result := FSet.ContainsKey(AValue);
end;

function TColligoDistinctEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoDistinctEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoDistinctEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSet.Clear;
end;

{$IFDEF QUERYABLE}
{ TColligoDistinctQueryable<T> }

constructor TColligoDistinctQueryable<T>.Create(
  const ASource: IColligoQueryableBase<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  if AComparer = nil then
    FComparer := TEqualityComparer<T>.Default
  else
    FComparer := AComparer;
end;

function TColligoDistinctQueryable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoDistinctQueryableEnumerator<T>.Create(FSource.GetEnumerator, FComparer);
end;

function TColligoDistinctQueryable<T>.BuildQuery: string;
begin
  Result := 'SELECT DISTINCT * FROM (' + FSource.BuildQuery + ') AS Temp';
end;

{ TColligoDistinctQueryableEnumerator<T> }

constructor TColligoDistinctQueryableEnumerator<T>.Create(
  const ASource: IColligoEnumerator<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSet := TDictionary<T, Byte>.Create(FComparer);
end;

destructor TColligoDistinctQueryableEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TColligoDistinctQueryableEnumerator<T>.Contains(const AValue: T): Boolean;
begin
  // O(1) hash lookup instead of an O(n) linear scan.
  Result := FSet.ContainsKey(AValue);
end;

function TColligoDistinctQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoDistinctQueryableEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoDistinctQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSet.Clear;
end;
{$ENDIF}

end.



