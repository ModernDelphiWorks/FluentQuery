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

unit Colligo.Take;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Colligo;

type
  TColligoTakeEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const ACount: Integer);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoTakeEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FCount: Integer;
    FCurrentIndex: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ACount: Integer);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TColligoTakeQueryable<T> = class(TColligoQueryableBase<T>)
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

  TColligoTakeQueryableEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FCount: Integer;
    FCurrentIndex: Integer;
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

{ TColligoTakeEnumerable<T> }

constructor TColligoTakeEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

function TColligoTakeEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoTakeEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TColligoTakeEnumerator<T> }

constructor TColligoTakeEnumerator<T>.Create(const ASource: IColligoEnumerator<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FCurrentIndex := 0;
end;

function TColligoTakeEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoTakeEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoTakeEnumerator<T>.Reset;
begin
  FSource.Reset;
  FCurrentIndex := 0;
end;

{$IFDEF QUERYABLE}
{ TColligoTakeQueryable<T> }

constructor TColligoTakeQueryable<T>.Create(const ASource: IColligoQueryableBase<T>;
  const ACount: Integer; const AProvider: IColligoQueryProvider<T>);
begin
  FSource := ASource;
  FCount := ACount;
  FProvider := AProvider;
end;

function TColligoTakeQueryable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoTakeQueryableEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

function TColligoTakeQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Take pra SQL (ex.: LIMIT ou TOP)
  Result := FSource.BuildQuery + ' LIMIT ' + IntToStr(FCount);
  // Exemplo fictício: 'SELECT * FROM Table LIMIT 10'
  // Nota: Dependendo do banco (ex.: SQL Server usa TOP), tu pode precisar ajustar via FProvider
end;

{ TColligoTakeQueryableEnumerator<T> }

constructor TColligoTakeQueryableEnumerator<T>.Create(const ASource: IColligoEnumerator<T>;
  const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FCurrentIndex := 0;
end;

function TColligoTakeQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoTakeQueryableEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoTakeQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FCurrentIndex := 0;
end;
{$ENDIF}

end.



