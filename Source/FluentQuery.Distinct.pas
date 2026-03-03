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

unit FluentQuery.Distinct;

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
  TFluentDistinctEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentDistinctEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FSet: TList<T>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    function Contains(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TFluentDistinctQueryable<T> = class(TFluentQueryableBase<T>)
  private
    FSource: IFluentQueryableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IFluentQueryableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TFluentDistinctQueryableEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FSet: TList<T>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    function Contains(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TFluentDistinctEnumerable<T> }

constructor TFluentDistinctEnumerable<T>.Create(
  const ASource: IFluentEnumerableBase<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  if AComparer = nil then
    FComparer := TEqualityComparer<T>.Default
  else
    FComparer := AComparer;
end;

function TFluentDistinctEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentDistinctEnumerator<T>.Create(FSource.GetEnumerator, FComparer);
end;

{ TFluentDistinctEnumerator<T> }

constructor TFluentDistinctEnumerator<T>.Create(
  const ASource: IFluentEnumerator<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSet := TList<T>.Create;
end;

destructor TFluentDistinctEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TFluentDistinctEnumerator<T>.Contains(const AValue: T): Boolean;
var
  LItem: T;
begin
  for LItem in FSet do
    if FComparer.Equals(LItem, AValue) then
      Exit(True);
  Result := False;
end;

function TFluentDistinctEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentDistinctEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if not Contains(FCurrent) then
    begin
      FSet.Add(FCurrent);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TFluentDistinctEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSet.Clear;
end;

{$IFDEF QUERYABLE}
{ TFluentDistinctQueryable<T> }

constructor TFluentDistinctQueryable<T>.Create(
  const ASource: IFluentQueryableBase<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  if AComparer = nil then
    FComparer := TEqualityComparer<T>.Default
  else
    FComparer := AComparer;
end;

function TFluentDistinctQueryable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentDistinctQueryableEnumerator<T>.Create(FSource.GetEnumerator, FComparer);
end;

function TFluentDistinctQueryable<T>.BuildQuery: string;
begin
  Result := 'SELECT DISTINCT * FROM (' + FSource.BuildQuery + ') AS Temp';
end;

{ TFluentDistinctQueryableEnumerator<T> }

constructor TFluentDistinctQueryableEnumerator<T>.Create(
  const ASource: IFluentEnumerator<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSet := TList<T>.Create;
end;

destructor TFluentDistinctQueryableEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TFluentDistinctQueryableEnumerator<T>.Contains(const AValue: T): Boolean;
var
  LItem: T;
begin
  for LItem in FSet do
    if FComparer.Equals(LItem, AValue) then
      Exit(True);
  Result := False;
end;

function TFluentDistinctQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentDistinctQueryableEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if not Contains(FCurrent) then
    begin
      FSet.Add(FCurrent);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TFluentDistinctQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSet.Clear;
end;
{$ENDIF}

end.



