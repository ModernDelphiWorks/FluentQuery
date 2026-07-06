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
  TFluentTakeWhileIndexedEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentTakeWhileIndexedEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
    FIndex: Integer;
    FDone: Boolean;
    FCurrent: T;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentTakeWhileIndexedEnumerable<T> }

constructor TFluentTakeWhileIndexedEnumerable<T>.Create(
  const ASource: IFluentEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TFluentTakeWhileIndexedEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentTakeWhileIndexedEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TFluentTakeWhileIndexedEnumerator<T> }

constructor TFluentTakeWhileIndexedEnumerator<T>.Create(
  const ASource: IFluentEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FIndex := -1;
  FDone := False;
end;

function TFluentTakeWhileIndexedEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentTakeWhileIndexedEnumerator<T>.MoveNext: Boolean;
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

procedure TFluentTakeWhileIndexedEnumerator<T>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
  FDone := False;
end;

end.



