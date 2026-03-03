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

unit FluentQuery.Take;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  {$ENDIF}
  SysUtils,
  FluentQuery;

type
  TFluentTakeEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const ACount: Integer);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentTakeEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FCount: Integer;
    FCurrentIndex: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ACount: Integer);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TFluentTakeQueryable<T> = class(TFluentQueryableBase<T>)
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

  TFluentTakeQueryableEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FCount: Integer;
    FCurrentIndex: Integer;
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

{ TFluentTakeEnumerable<T> }

constructor TFluentTakeEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

function TFluentTakeEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentTakeEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TFluentTakeEnumerator<T> }

constructor TFluentTakeEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FCurrentIndex := 0;
end;

function TFluentTakeEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentTakeEnumerator<T>.MoveNext: Boolean;
begin
  if FCurrentIndex < FCount then
  begin
    if FSource.MoveNext then
    begin
      FCurrent := FSource.Current;
      Inc(FCurrentIndex);
      Result := True;
    end
    else
      Result := False;
  end
  else
    Result := False;
end;

procedure TFluentTakeEnumerator<T>.Reset;
begin
  FSource.Reset;
  FCurrentIndex := 0;
end;

{$IFDEF QUERYABLE}
{ TFluentTakeQueryable<T> }

constructor TFluentTakeQueryable<T>.Create(const ASource: IFluentQueryableBase<T>;
  const ACount: Integer; const AProvider: IFluentQueryProvider<T>);
begin
  FSource := ASource;
  FCount := ACount;
  FProvider := AProvider;
end;

function TFluentTakeQueryable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentTakeQueryableEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

function TFluentTakeQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Take pra SQL (ex.: LIMIT ou TOP)
  Result := FSource.BuildQuery + ' LIMIT ' + IntToStr(FCount);
  // Exemplo fictício: 'SELECT * FROM Table LIMIT 10'
  // Nota: Dependendo do banco (ex.: SQL Server usa TOP), tu pode precisar ajustar via FProvider
end;

{ TFluentTakeQueryableEnumerator<T> }

constructor TFluentTakeQueryableEnumerator<T>.Create(const ASource: IFluentEnumerator<T>;
  const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FCurrentIndex := 0;
end;

function TFluentTakeQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentTakeQueryableEnumerator<T>.MoveNext: Boolean;
begin
  if FCurrentIndex < FCount then
  begin
    if FSource.MoveNext then
    begin
      FCurrent := FSource.Current;
      Inc(FCurrentIndex);
      Result := True;
    end
    else
      Result := False;
  end
  else
    Result := False;
end;

procedure TFluentTakeQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FCurrentIndex := 0;
end;
{$ENDIF}

end.



