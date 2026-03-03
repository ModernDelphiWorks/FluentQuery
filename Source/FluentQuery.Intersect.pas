{
  ------------------------------------------------------------------------------
  FluentQuery
  LINQ-inspired fluent query API for Delphi.

  SPDX-License-Identifier: Apache-2.0
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ./FluentQuery.inc}

unit FluentQuery.Intersect;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  FluentQuery;

type
  TFluentIntersectEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FSecond: IFluentEnumerableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const ASecond: IFluentEnumerableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentIntersectEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FSecond: TDictionary<T, Boolean>;
    FCurrent: T;
    FComparer: IEqualityComparer<T>;
    function ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASecond: IFluentEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TFluentIntersectQueryable<T> = class(TFluentQueryableBase<T>)
  private
    FSource: IFluentQueryableBase<T>;
    FSecond: IFluentQueryableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IFluentQueryableBase<T>; const ASecond: IFluentQueryableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TFluentIntersectQueryableEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FSecond: TDictionary<T, Boolean>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    function _ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASecond: IFluentEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TFluentIntersectEnumerable<T> }

constructor TFluentIntersectEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>;
  const ASecond: IFluentEnumerableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TFluentIntersectEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentIntersectEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

{ TFluentIntersectEnumerator<T> }

constructor TFluentIntersectEnumerator<T>.Create(const ASource: IFluentEnumerator<T>;
  const ASecond: IFluentEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSecond := TDictionary<T, Boolean>.Create(FComparer);
  while ASecond.MoveNext do
    FSecond.Add(ASecond.Current, True);
end;

destructor TFluentIntersectEnumerator<T>.Destroy;
begin
  FSecond.Free;
  inherited;
end;

function TFluentIntersectEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentIntersectEnumerator<T>.ContainsValue(const AValue: T): Boolean;
var
  LKey: T;
begin
  for LKey in FSecond.Keys do
    if FComparer.Equals(LKey, AValue) then
      Exit(True);
  Result := False;
end;

function TFluentIntersectEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if ContainsValue(FCurrent) then
    begin
      FSecond.Remove(FCurrent);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TFluentIntersectEnumerator<T>.Reset;
begin
  FSource.Reset;
end;

{$IFDEF QUERYABLE}
{ TFluentIntersectQueryable<T> }

constructor TFluentIntersectQueryable<T>.Create(const ASource: IFluentQueryableBase<T>;
  const ASecond: IFluentQueryableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TFluentIntersectQueryable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentIntersectQueryableEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

function TFluentIntersectQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Intersect pra SQL (ex.: INTERSECT)
  Result := FSource.BuildQuery + ' INTERSECT ' + FSecond.BuildQuery;
  // Exemplo fictício: 'SELECT * FROM Table1 INTERSECT SELECT * FROM Table2'
end;

{ TFluentIntersectQueryableEnumerator<T> }

constructor TFluentIntersectQueryableEnumerator<T>.Create(const ASource: IFluentEnumerator<T>;
  const ASecond: IFluentEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSecond := TDictionary<T, Boolean>.Create(FComparer);
  while ASecond.MoveNext do
    FSecond.Add(ASecond.Current, True);
end;

destructor TFluentIntersectQueryableEnumerator<T>.Destroy;
begin
  FSecond.Free;
  inherited;
end;

function TFluentIntersectQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentIntersectQueryableEnumerator<T>._ContainsValue(const AValue: T): Boolean;
var
  LKey: T;
begin
  for LKey in FSecond.Keys do
    if FComparer.Equals(LKey, AValue) then
      Exit(True);
  Result := False;
end;

function TFluentIntersectQueryableEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if _ContainsValue(FCurrent) then
    begin
      FSecond.Remove(FCurrent);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TFluentIntersectQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
end;
{$ENDIF}

end.



