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

unit Colligo.SkipWhileIndexed;

interface

uses
  SysUtils,
  Colligo;

type
  TColligoSkipWhileIndexedEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoSkipWhileIndexedEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
    FSkipped: Boolean;
    FIndex: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoSkipWhileIndexedEnumerable<T> }

constructor TColligoSkipWhileIndexedEnumerable<T>.Create(
  const ASource: IColligoEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TColligoSkipWhileIndexedEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoSkipWhileIndexedEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TColligoSkipWhileIndexedEnumerator<T> }

constructor TColligoSkipWhileIndexedEnumerator<T>.Create(
  const ASource: IColligoEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FSkipped := False;
  FIndex := -1;
end;

function TColligoSkipWhileIndexedEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoSkipWhileIndexedEnumerator<T>.MoveNext: Boolean;
begin
  if not FSkipped then
  begin
    while FSource.MoveNext do
    begin
      Inc(FIndex);
      if not FPredicate(FSource.Current, FIndex) then
      begin
        FCurrent := FSource.Current;
        FSkipped := True;
        Result := True;
        Exit;
      end;
    end;
    FSkipped := True;
  end;
  Result := FSource.MoveNext;
  if Result then
  begin
    Inc(FIndex);
    FCurrent := FSource.Current;
  end;
end;

procedure TColligoSkipWhileIndexedEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := False;
  FIndex := -1;
end;

end.



