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

unit LQColligo.Union;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  LQColligo;

type
  TLQColligoUnionEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FSecond: ILQColligoEnumerableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>;
      const ASecond: ILQColligoEnumerableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoUnionEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSecond: ILQColligoEnumerator<T>;
    FSet: TDictionary<T, Boolean>;
    FCurrent: T;
    FOnSecond: Boolean;
    FComparer: IEqualityComparer<T>;
    function ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ASecond: ILQColligoEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TLQColligoUnionQueryable<T> = class(TLQColligoQueryableBase<T>)
  private
    FSource: ILQColligoQueryableBase<T>;
    FSecond: ILQColligoQueryableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: ILQColligoQueryableBase<T>; const ASecond: ILQColligoQueryableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TLQColligoUnionQueryableEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSecond: ILQColligoEnumerator<T>;
    FSet: TDictionary<T, Boolean>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    FOnSecond: Boolean;
    function _ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ASecond: ILQColligoEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TLQColligoUnionEnumerable<T> }

constructor TLQColligoUnionEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>;
  const ASecond: ILQColligoEnumerableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TLQColligoUnionEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoUnionEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

{ TLQColligoUnionEnumerator<T> }

constructor TLQColligoUnionEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>;
  const ASecond: ILQColligoEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
  FSet := TDictionary<T, Boolean>.Create(FComparer);
  FOnSecond := False;
end;

destructor TLQColligoUnionEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TLQColligoUnionEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoUnionEnumerator<T>.ContainsValue(const AValue: T): Boolean;
begin
  // O(1) hash lookup — the dictionary was already built with FComparer.
  Result := FSet.ContainsKey(AValue);
end;

function TLQColligoUnionEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoUnionEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FSet.Clear;
  FOnSecond := False;
end;

{$IFDEF QUERYABLE}
{ TLQColligoUnionQueryable<T> }

constructor TLQColligoUnionQueryable<T>.Create(const ASource: ILQColligoQueryableBase<T>;
  const ASecond: ILQColligoQueryableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TLQColligoUnionQueryable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoUnionQueryableEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

function TLQColligoUnionQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Union pra SQL (ex.: UNION)
  Result := FSource.BuildQuery + ' UNION ' + FSecond.BuildQuery;
  // Exemplo fictício: 'SELECT * FROM Table1 UNION SELECT * FROM Table2'
end;

{ TLQColligoUnionQueryableEnumerator<T> }

constructor TLQColligoUnionQueryableEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>;
  const ASecond: ILQColligoEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
  FSet := TDictionary<T, Boolean>.Create(FComparer);
  FOnSecond := False;
end;

destructor TLQColligoUnionQueryableEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TLQColligoUnionQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoUnionQueryableEnumerator<T>._ContainsValue(const AValue: T): Boolean;
begin
  // O(1) hash lookup — the dictionary was already built with FComparer.
  Result := FSet.ContainsKey(AValue);
end;

function TLQColligoUnionQueryableEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoUnionQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSecond.Reset;
  FSet.Clear;
  FOnSecond := False;
end;
{$ENDIF}

end.



