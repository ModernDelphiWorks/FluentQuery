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

unit LQColligo.Take;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  LQColligo;

type
  TLQColligoTakeEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const ACount: Integer);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoTakeEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FCount: Integer;
    FCurrentIndex: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ACount: Integer);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TLQColligoTakeQueryable<T> = class(TLQColligoQueryableBase<T>)
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

  TLQColligoTakeQueryableEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FCount: Integer;
    FCurrentIndex: Integer;
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

{ TLQColligoTakeEnumerable<T> }

constructor TLQColligoTakeEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

function TLQColligoTakeEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoTakeEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TLQColligoTakeEnumerator<T> }

constructor TLQColligoTakeEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FCurrentIndex := 0;
end;

function TLQColligoTakeEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoTakeEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoTakeEnumerator<T>.Reset;
begin
  FSource.Reset;
  FCurrentIndex := 0;
end;

{$IFDEF QUERYABLE}
{ TLQColligoTakeQueryable<T> }

constructor TLQColligoTakeQueryable<T>.Create(const ASource: ILQColligoQueryableBase<T>;
  const ACount: Integer; const AProvider: ILQColligoQueryProvider<T>);
begin
  FSource := ASource;
  FCount := ACount;
  FProvider := AProvider;
end;

function TLQColligoTakeQueryable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoTakeQueryableEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

function TLQColligoTakeQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Take pra SQL (ex.: LIMIT ou TOP)
  Result := FSource.BuildQuery + ' LIMIT ' + IntToStr(FCount);
  // Exemplo fictício: 'SELECT * FROM Table LIMIT 10'
  // Nota: Dependendo do banco (ex.: SQL Server usa TOP), tu pode precisar ajustar via FProvider
end;

{ TLQColligoTakeQueryableEnumerator<T> }

constructor TLQColligoTakeQueryableEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>;
  const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FCurrentIndex := 0;
end;

function TLQColligoTakeQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoTakeQueryableEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoTakeQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FCurrentIndex := 0;
end;
{$ENDIF}

end.



