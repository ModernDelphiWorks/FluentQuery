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

unit Colligo.Concat;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Colligo;

type
  TColligoConcatEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FSecond: IColligoEnumerableBase<T>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const ASecond: IColligoEnumerableBase<T>);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoConcatEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FSecond: IColligoEnumerator<T>;
    FCurrent: T;
    FOnSecond: Boolean;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ASecond: IColligoEnumerator<T>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TColligoConcatQueryable<T> = class(TColligoQueryableBase<T>)
  private
    FSource: IColligoQueryableBase<T>;
    FSecond: IColligoQueryableBase<T>;
  public
    constructor Create(const ASource: IColligoQueryableBase<T>; const ASecond: IColligoQueryableBase<T>);
    function GetEnumerator: IColligoEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TColligoConcatQueryableEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FSecond: IColligoEnumerator<T>;
    FCurrent: T;
    FOnSecond: Boolean;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ASecond: IColligoEnumerator<T>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TColligoConcatEnumerable<T> }

constructor TColligoConcatEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>;
  const ASecond: IColligoEnumerableBase<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
end;

function TColligoConcatEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoConcatEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator);
end;

{ TColligoConcatEnumerator<T> }

constructor TColligoConcatEnumerator<T>.Create(const ASource: IColligoEnumerator<T>; const ASecond: IColligoEnumerator<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FOnSecond := False;
end;

function TColligoConcatEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoConcatEnumerator<T>.MoveNext: Boolean;
begin
  if not FOnSecond then
  begin
    if FSource.MoveNext then
    begin
      FCurrent := FSource.Current;
      Result := True;
      Exit;
    end
    else
      FOnSecond := True;
  end;
  if FSecond.MoveNext then
  begin
    FCurrent := FSecond.Current;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure TColligoConcatEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FOnSecond := False;
end;

{$IFDEF QUERYABLE}
{ TColligoConcatQueryable<T> }

constructor TColligoConcatQueryable<T>.Create(const ASource: IColligoQueryableBase<T>;
  const ASecond: IColligoQueryableBase<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
end;

function TColligoConcatQueryable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoConcatQueryableEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator);
end;

function TColligoConcatQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Concat pra SQL (ex.: UNION ALL)
  Result := FSource.BuildQuery + ' UNION ALL ' + FSecond.BuildQuery;
  // Exemplo fictício: 'SELECT * FROM Table1 UNION ALL SELECT * FROM Table2'
end;

{ TColligoConcatQueryableEnumerator<T> }

constructor TColligoConcatQueryableEnumerator<T>.Create(const ASource: IColligoEnumerator<T>;
  const ASecond: IColligoEnumerator<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FOnSecond := False;
end;

function TColligoConcatQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoConcatQueryableEnumerator<T>.MoveNext: Boolean;
begin
  if not FOnSecond then
  begin
    if FSource.MoveNext then
    begin
      FCurrent := FSource.Current;
      Result := True;
      Exit;
    end
    else
      FOnSecond := True;
  end;
  if FSecond.MoveNext then
  begin
    FCurrent := FSecond.Current;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure TColligoConcatQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FOnSecond := False;
end;
{$ENDIF}

end.



