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

unit FluentQuery.Skip;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  {$ENDIF}
  SysUtils,
  FluentQuery;

type
  TFluentSkipEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; ACount: Integer);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentSkipEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FCount: Integer;
    FSkipped: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; ACount: Integer);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TFluentSkipQueryable<T> = class(TFluentQueryableBase<T>)
  private
    FSource: IFluentQueryableBase<T>;
    FCount: Integer;
    FProvider: IFluentQueryProvider<T>;
  public
    constructor Create(const ASource: IFluentQueryableBase<T>; const ACount: Integer;
      const AProvider: IFluentQueryProvider<T> = nil);
    function GetEnumerator: IFluentEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TFluentSkipQueryableEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FCount: Integer;
    FSkipped: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ACount: Integer);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TFluentSkipEnumerable<T> }

constructor TFluentSkipEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

function TFluentSkipEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentSkipEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TFluentSkipEnumerator<T> }

constructor TFluentSkipEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FSkipped := 0;
end;

function TFluentSkipEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentSkipEnumerator<T>.MoveNext: Boolean;
begin
  while FSkipped < FCount do
  begin
    if FSource.MoveNext then
      Inc(FSkipped)
    else
      Exit(False);
  end;
  Result := FSource.MoveNext;
  if Result then
    FCurrent := FSource.Current;
end;

procedure TFluentSkipEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := 0;
end;

{$IFDEF QUERYABLE}
{ TFluentSkipQueryable<T> }

constructor TFluentSkipQueryable<T>.Create(const ASource: IFluentQueryableBase<T>;
  const ACount: Integer; const AProvider: IFluentQueryProvider<T>);
begin
  FSource := ASource;
  FCount := ACount;
  FProvider := AProvider;
end;

function TFluentSkipQueryable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentSkipQueryableEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

function TFluentSkipQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Skip pra SQL (ex.: OFFSET)
  Result := FSource.BuildQuery + ' OFFSET ' + IntToStr(FCount) + ' ROWS';
  // Exemplo fictício: 'SELECT * FROM Table OFFSET 10 ROWS'
  // Nota: Alguns bancos (ex.: SQL Server < 2012) não suportam OFFSET nativo, pode precisar de ajustes via FProvider
end;

{ TFluentSkipQueryableEnumerator<T> }

constructor TFluentSkipQueryableEnumerator<T>.Create(const ASource: IFluentEnumerator<T>;
  const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FSkipped := 0;
end;

function TFluentSkipQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentSkipQueryableEnumerator<T>.MoveNext: Boolean;
begin
  while FSkipped < FCount do
  begin
    if FSource.MoveNext then
      Inc(FSkipped)
    else
      Exit(False);
  end;
  Result := FSource.MoveNext;
  if Result then
    FCurrent := FSource.Current;
end;

procedure TFluentSkipQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := 0;
end;
{$ENDIF}

end.



