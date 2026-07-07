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

unit Colligo.Union;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  Colligo;

type
  TColligoUnionEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FSecond: IColligoEnumerableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>;
      const ASecond: IColligoEnumerableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoUnionEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FSecond: IColligoEnumerator<T>;
    FSet: TDictionary<T, Boolean>;
    FCurrent: T;
    FOnSecond: Boolean;
    FComparer: IEqualityComparer<T>;
    function ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ASecond: IColligoEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TColligoUnionQueryable<T> = class(TColligoQueryableBase<T>)
  private
    FSource: IColligoQueryableBase<T>;
    FSecond: IColligoQueryableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IColligoQueryableBase<T>; const ASecond: IColligoQueryableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IColligoEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TColligoUnionQueryableEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FSecond: IColligoEnumerator<T>;
    FSet: TDictionary<T, Boolean>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    FOnSecond: Boolean;
    function _ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ASecond: IColligoEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TColligoUnionEnumerable<T> }

constructor TColligoUnionEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>;
  const ASecond: IColligoEnumerableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TColligoUnionEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoUnionEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

{ TColligoUnionEnumerator<T> }

constructor TColligoUnionEnumerator<T>.Create(const ASource: IColligoEnumerator<T>;
  const ASecond: IColligoEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
  FSet := TDictionary<T, Boolean>.Create(FComparer);
  FOnSecond := False;
end;

destructor TColligoUnionEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TColligoUnionEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoUnionEnumerator<T>.ContainsValue(const AValue: T): Boolean;
begin
  // O(1) hash lookup — the dictionary was already built with FComparer.
  Result := FSet.ContainsKey(AValue);
end;

function TColligoUnionEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoUnionEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FSet.Clear;
  FOnSecond := False;
end;

{$IFDEF QUERYABLE}
{ TColligoUnionQueryable<T> }

constructor TColligoUnionQueryable<T>.Create(const ASource: IColligoQueryableBase<T>;
  const ASecond: IColligoQueryableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TColligoUnionQueryable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoUnionQueryableEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

function TColligoUnionQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Union pra SQL (ex.: UNION)
  Result := FSource.BuildQuery + ' UNION ' + FSecond.BuildQuery;
  // Exemplo fictício: 'SELECT * FROM Table1 UNION SELECT * FROM Table2'
end;

{ TColligoUnionQueryableEnumerator<T> }

constructor TColligoUnionQueryableEnumerator<T>.Create(const ASource: IColligoEnumerator<T>;
  const ASecond: IColligoEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
  FSet := TDictionary<T, Boolean>.Create(FComparer);
  FOnSecond := False;
end;

destructor TColligoUnionQueryableEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TColligoUnionQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoUnionQueryableEnumerator<T>._ContainsValue(const AValue: T): Boolean;
begin
  // O(1) hash lookup — the dictionary was already built with FComparer.
  Result := FSet.ContainsKey(AValue);
end;

function TColligoUnionQueryableEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoUnionQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FSet.Clear;
  FOnSecond := False;
end;
{$ENDIF}

end.



