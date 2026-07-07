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

unit Colligo.TakeWhileIndexed;

interface

uses
  SysUtils,
  Colligo;

type
  TColligoTakeWhileIndexedEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoTakeWhileIndexedEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
    FIndex: Integer;
    FDone: Boolean;
    FCurrent: T;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoTakeWhileIndexedEnumerable<T> }

constructor TColligoTakeWhileIndexedEnumerable<T>.Create(
  const ASource: IColligoEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TColligoTakeWhileIndexedEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoTakeWhileIndexedEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TColligoTakeWhileIndexedEnumerator<T> }

constructor TColligoTakeWhileIndexedEnumerator<T>.Create(
  const ASource: IColligoEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FIndex := -1;
  FDone := False;
end;

function TColligoTakeWhileIndexedEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoTakeWhileIndexedEnumerator<T>.MoveNext: Boolean;
begin
  if FDone or not FSource.MoveNext then
    Exit(False);
  Inc(FIndex);
  FCurrent := FSource.Current;
  if not FPredicate(FCurrent, FIndex) then
  begin
    FDone := True;
    Exit(False);
  end;
  Result := True;
end;

procedure TColligoTakeWhileIndexedEnumerator<T>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
  FDone := False;
end;

end.



