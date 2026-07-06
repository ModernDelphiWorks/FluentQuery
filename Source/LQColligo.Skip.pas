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

unit LQColligo.Skip;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  LQColligo;

type
  TLQColligoSkipEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; ACount: Integer);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoSkipEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FCount: Integer;
    FSkipped: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; ACount: Integer);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TLQColligoSkipQueryable<T> = class(TLQColligoQueryableBase<T>)
  private
    FSource: ILQColligoQueryableBase<T>;
    FCount: Integer;
    FProvider: ILQColligoQueryProvider<T>;
  public
    constructor Create(const ASource: ILQColligoQueryableBase<T>; const ACount: Integer;
      const AProvider: ILQColligoQueryProvider<T> = nil);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TLQColligoSkipQueryableEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FCount: Integer;
    FSkipped: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ACount: Integer);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TLQColligoSkipEnumerable<T> }

constructor TLQColligoSkipEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>; ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

function TLQColligoSkipEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoSkipEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TLQColligoSkipEnumerator<T> }

constructor TLQColligoSkipEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>; ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FSkipped := 0;
end;

function TLQColligoSkipEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoSkipEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoSkipEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := 0;
end;

{$IFDEF QUERYABLE}
{ TLQColligoSkipQueryable<T> }

constructor TLQColligoSkipQueryable<T>.Create(const ASource: ILQColligoQueryableBase<T>;
  const ACount: Integer; const AProvider: ILQColligoQueryProvider<T>);
begin
  FSource := ASource;
  FCount := ACount;
  FProvider := AProvider;
end;

function TLQColligoSkipQueryable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoSkipQueryableEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

function TLQColligoSkipQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Skip pra SQL (ex.: OFFSET)
  Result := FSource.BuildQuery + ' OFFSET ' + IntToStr(FCount) + ' ROWS';
  // Exemplo fictício: 'SELECT * FROM Table OFFSET 10 ROWS'
  // Nota: Alguns bancos (ex.: SQL Server < 2012) não suportam OFFSET nativo, pode precisar de ajustes via FProvider
end;

{ TLQColligoSkipQueryableEnumerator<T> }

constructor TLQColligoSkipQueryableEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>;
  const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FSkipped := 0;
end;

function TLQColligoSkipQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoSkipQueryableEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoSkipQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := 0;
end;
{$ENDIF}

end.



