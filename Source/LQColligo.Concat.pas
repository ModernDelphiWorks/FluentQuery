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

unit LQColligo.Concat;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  LQColligo;

type
  TLQColligoConcatEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FSecond: ILQColligoEnumerableBase<T>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const ASecond: ILQColligoEnumerableBase<T>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoConcatEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSecond: ILQColligoEnumerator<T>;
    FCurrent: T;
    FOnSecond: Boolean;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ASecond: ILQColligoEnumerator<T>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TLQColligoConcatQueryable<T> = class(TLQColligoQueryableBase<T>)
  private
    FSource: ILQColligoQueryableBase<T>;
    FSecond: ILQColligoQueryableBase<T>;
  public
    constructor Create(const ASource: ILQColligoQueryableBase<T>; const ASecond: ILQColligoQueryableBase<T>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TLQColligoConcatQueryableEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSecond: ILQColligoEnumerator<T>;
    FCurrent: T;
    FOnSecond: Boolean;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ASecond: ILQColligoEnumerator<T>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TLQColligoConcatEnumerable<T> }

constructor TLQColligoConcatEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>;
  const ASecond: ILQColligoEnumerableBase<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
end;

function TLQColligoConcatEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoConcatEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator);
end;

{ TLQColligoConcatEnumerator<T> }

constructor TLQColligoConcatEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>; const ASecond: ILQColligoEnumerator<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FOnSecond := False;
end;

function TLQColligoConcatEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoConcatEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoConcatEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FOnSecond := False;
end;

{$IFDEF QUERYABLE}
{ TLQColligoConcatQueryable<T> }

constructor TLQColligoConcatQueryable<T>.Create(const ASource: ILQColligoQueryableBase<T>;
  const ASecond: ILQColligoQueryableBase<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
end;

function TLQColligoConcatQueryable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoConcatQueryableEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator);
end;

function TLQColligoConcatQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Concat pra SQL (ex.: UNION ALL)
  Result := FSource.BuildQuery + ' UNION ALL ' + FSecond.BuildQuery;
  // Exemplo fictício: 'SELECT * FROM Table1 UNION ALL SELECT * FROM Table2'
end;

{ TLQColligoConcatQueryableEnumerator<T> }

constructor TLQColligoConcatQueryableEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>;
  const ASecond: ILQColligoEnumerator<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FOnSecond := False;
end;

function TLQColligoConcatQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoConcatQueryableEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoConcatQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FOnSecond := False;
end;
{$ENDIF}

end.



