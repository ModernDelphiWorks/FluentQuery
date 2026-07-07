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

unit Colligo.TakeWhile;

interface

uses
  SysUtils,
  Colligo;

type
  TColligoTakeWhileEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoTakeWhileEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FPredicate: TFunc<T, Boolean>;
    FCurrent: T;
    FDone: Boolean;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const APredicate: TFunc<T, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoTakeWhileEnumerable<T> }

constructor TColligoTakeWhileEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TColligoTakeWhileEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoTakeWhileEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TColligoTakeWhileEnumerator<T> }

constructor TColligoTakeWhileEnumerator<T>.Create(const ASource: IColligoEnumerator<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FDone := False;
end;

function TColligoTakeWhileEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoTakeWhileEnumerator<T>.MoveNext: Boolean;
begin
  if FDone or not FSource.MoveNext then
    Exit(False);
  FCurrent := FSource.Current;
  if not FPredicate(FCurrent) then
  begin
    FDone := True;
    Exit(False);
  end;
  Result := True;
end;

procedure TColligoTakeWhileEnumerator<T>.Reset;
begin
  FSource.Reset;
  FDone := False;
end;

end.



