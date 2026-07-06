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

unit LQColligo.TakeWhileIndexed;

interface

uses
  SysUtils,
  LQColligo;

type
  TLQColligoTakeWhileIndexedEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoTakeWhileIndexedEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
    FIndex: Integer;
    FDone: Boolean;
    FCurrent: T;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TLQColligoTakeWhileIndexedEnumerable<T> }

constructor TLQColligoTakeWhileIndexedEnumerable<T>.Create(
  const ASource: ILQColligoEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TLQColligoTakeWhileIndexedEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoTakeWhileIndexedEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TLQColligoTakeWhileIndexedEnumerator<T> }

constructor TLQColligoTakeWhileIndexedEnumerator<T>.Create(
  const ASource: ILQColligoEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FIndex := -1;
  FDone := False;
end;

function TLQColligoTakeWhileIndexedEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoTakeWhileIndexedEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoTakeWhileIndexedEnumerator<T>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
  FDone := False;
end;

end.



