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

unit Colligo.Skip;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Colligo;

type
  TColligoSkipEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; ACount: Integer);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoSkipEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FCount: Integer;
    FSkipped: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; ACount: Integer);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TColligoSkipQueryable<T> = class(TColligoQueryableBase<T>)
  private
    FSource: IColligoQueryableBase<T>;
    FCount: Integer;
    FProvider: IColligoQueryProvider<T>;
  public
    constructor Create(const ASource: IColligoQueryableBase<T>; const ACount: Integer;
      const AProvider: IColligoQueryProvider<T> = nil);
    function GetEnumerator: IColligoEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TColligoSkipQueryableEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FCount: Integer;
    FSkipped: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ACount: Integer);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TColligoSkipEnumerable<T> }

constructor TColligoSkipEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>; ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

function TColligoSkipEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoSkipEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TColligoSkipEnumerator<T> }

constructor TColligoSkipEnumerator<T>.Create(const ASource: IColligoEnumerator<T>; ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FSkipped := 0;
end;

function TColligoSkipEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoSkipEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoSkipEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := 0;
end;

{$IFDEF QUERYABLE}
{ TColligoSkipQueryable<T> }

constructor TColligoSkipQueryable<T>.Create(const ASource: IColligoQueryableBase<T>;
  const ACount: Integer; const AProvider: IColligoQueryProvider<T>);
begin
  FSource := ASource;
  FCount := ACount;
  FProvider := AProvider;
end;

function TColligoSkipQueryable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoSkipQueryableEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

function TColligoSkipQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Skip pra SQL (ex.: OFFSET)
  Result := FSource.BuildQuery + ' OFFSET ' + IntToStr(FCount) + ' ROWS';
  // Exemplo fictício: 'SELECT * FROM Table OFFSET 10 ROWS'
  // Nota: Alguns bancos (ex.: SQL Server < 2012) não suportam OFFSET nativo, pode precisar de ajustes via FProvider
end;

{ TColligoSkipQueryableEnumerator<T> }

constructor TColligoSkipQueryableEnumerator<T>.Create(const ASource: IColligoEnumerator<T>;
  const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FSkipped := 0;
end;

function TColligoSkipQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoSkipQueryableEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoSkipQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := 0;
end;
{$ENDIF}

end.



