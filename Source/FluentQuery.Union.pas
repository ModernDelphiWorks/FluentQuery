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

unit FluentQuery.Union;

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
  TFluentUnionEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FSecond: IFluentEnumerableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const ASecond: IFluentEnumerableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentUnionEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FSecond: IFluentEnumerator<T>;
    FSet: TDictionary<T, Boolean>;
    FCurrent: T;
    FOnSecond: Boolean;
    FComparer: IEqualityComparer<T>;
    function ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASecond: IFluentEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TFluentUnionQueryable<T> = class(TFluentQueryableBase<T>)
  private
    FSource: IFluentQueryableBase<T>;
    FSecond: IFluentQueryableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IFluentQueryableBase<T>; const ASecond: IFluentQueryableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TFluentUnionQueryableEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FSecond: IFluentEnumerator<T>;
    FSet: TDictionary<T, Boolean>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    FOnSecond: Boolean;
    function _ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASecond: IFluentEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TFluentUnionEnumerable<T> }

constructor TFluentUnionEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>;
  const ASecond: IFluentEnumerableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TFluentUnionEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentUnionEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

{ TFluentUnionEnumerator<T> }

constructor TFluentUnionEnumerator<T>.Create(const ASource: IFluentEnumerator<T>;
  const ASecond: IFluentEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
  FSet := TDictionary<T, Boolean>.Create(FComparer);
  FOnSecond := False;
end;

destructor TFluentUnionEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TFluentUnionEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentUnionEnumerator<T>.ContainsValue(const AValue: T): Boolean;
var
  LKey: T;
begin
  for LKey in FSet.Keys do
    if FComparer.Equals(LKey, AValue) then
      Exit(True);
  Result := False;
end;

function TFluentUnionEnumerator<T>.MoveNext: Boolean;
begin
  while True do
  begin
    if not FOnSecond then
    begin
      if FSource.MoveNext then
      begin
        FCurrent := FSource.Current;
        if not ContainsValue(FCurrent) then
        begin
          FSet.Add(FCurrent, True);
          Result := True;
          Exit;
        end;
      end
      else
        FOnSecond := True;
    end
    else if FSecond.MoveNext then
    begin
      FCurrent := FSecond.Current;
      if not ContainsValue(FCurrent) then
      begin
        FSet.Add(FCurrent, True);
        Result := True;
        Exit;
      end;
    end
    else
      Exit(False);
  end;
end;

procedure TFluentUnionEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FSet.Clear;
  FOnSecond := False;
end;

{$IFDEF QUERYABLE}
{ TFluentUnionQueryable<T> }

constructor TFluentUnionQueryable<T>.Create(const ASource: IFluentQueryableBase<T>;
  const ASecond: IFluentQueryableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TFluentUnionQueryable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentUnionQueryableEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

function TFluentUnionQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Union pra SQL (ex.: UNION)
  Result := FSource.BuildQuery + ' UNION ' + FSecond.BuildQuery;
  // Exemplo fictício: 'SELECT * FROM Table1 UNION SELECT * FROM Table2'
end;

{ TFluentUnionQueryableEnumerator<T> }

constructor TFluentUnionQueryableEnumerator<T>.Create(const ASource: IFluentEnumerator<T>;
  const ASecond: IFluentEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
  FSet := TDictionary<T, Boolean>.Create(FComparer);
  FOnSecond := False;
end;

destructor TFluentUnionQueryableEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TFluentUnionQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentUnionQueryableEnumerator<T>._ContainsValue(const AValue: T): Boolean;
var
  LKey: T;
begin
  for LKey in FSet.Keys do
    if FComparer.Equals(LKey, AValue) then
      Exit(True);
  Result := False;
end;

function TFluentUnionQueryableEnumerator<T>.MoveNext: Boolean;
begin
  while True do
  begin
    if not FOnSecond then
    begin
      if FSource.MoveNext then
      begin
        FCurrent := FSource.Current;
        if not _ContainsValue(FCurrent) then
        begin
          FSet.Add(FCurrent, True);
          Result := True;
          Exit;
        end;
      end
      else
        FOnSecond := True;
    end
    else if FSecond.MoveNext then
    begin
      FCurrent := FSecond.Current;
      if not _ContainsValue(FCurrent) then
      begin
        FSet.Add(FCurrent, True);
        Result := True;
        Exit;
      end;
    end
    else
      Exit(False);
  end;
end;

procedure TFluentUnionQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FSet.Clear;
  FOnSecond := False;
end;
{$ENDIF}

end.



