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

unit FluentQuery.Concat;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  {$ENDIF}
  SysUtils,
  FluentQuery;

type
  TFluentConcatEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FSecond: IFluentEnumerableBase<T>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const ASecond: IFluentEnumerableBase<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentConcatEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FSecond: IFluentEnumerator<T>;
    FCurrent: T;
    FOnSecond: Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASecond: IFluentEnumerator<T>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TFluentConcatQueryable<T> = class(TFluentQueryableBase<T>)
  private
    FSource: IFluentQueryableBase<T>;
    FSecond: IFluentQueryableBase<T>;
  public
    constructor Create(const ASource: IFluentQueryableBase<T>; const ASecond: IFluentQueryableBase<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TFluentConcatQueryableEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FSecond: IFluentEnumerator<T>;
    FCurrent: T;
    FOnSecond: Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASecond: IFluentEnumerator<T>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TFluentConcatEnumerable<T> }

constructor TFluentConcatEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>;
  const ASecond: IFluentEnumerableBase<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
end;

function TFluentConcatEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentConcatEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator);
end;

{ TFluentConcatEnumerator<T> }

constructor TFluentConcatEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; const ASecond: IFluentEnumerator<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FOnSecond := False;
end;

function TFluentConcatEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentConcatEnumerator<T>.MoveNext: Boolean;
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

procedure TFluentConcatEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FOnSecond := False;
end;

{$IFDEF QUERYABLE}
{ TFluentConcatQueryable<T> }

constructor TFluentConcatQueryable<T>.Create(const ASource: IFluentQueryableBase<T>;
  const ASecond: IFluentQueryableBase<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
end;

function TFluentConcatQueryable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentConcatQueryableEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator);
end;

function TFluentConcatQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Concat pra SQL (ex.: UNION ALL)
  Result := FSource.BuildQuery + ' UNION ALL ' + FSecond.BuildQuery;
  // Exemplo fictício: 'SELECT * FROM Table1 UNION ALL SELECT * FROM Table2'
end;

{ TFluentConcatQueryableEnumerator<T> }

constructor TFluentConcatQueryableEnumerator<T>.Create(const ASource: IFluentEnumerator<T>;
  const ASecond: IFluentEnumerator<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FOnSecond := False;
end;

function TFluentConcatQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentConcatQueryableEnumerator<T>.MoveNext: Boolean;
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

procedure TFluentConcatQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FOnSecond := False;
end;
{$ENDIF}

end.



