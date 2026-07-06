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

unit LQColligo.TakeWhile;

interface

uses
  SysUtils,
  LQColligo;

type
  TLQColligoTakeWhileEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoTakeWhileEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FPredicate: TFunc<T, Boolean>;
    FCurrent: T;
    FDone: Boolean;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const APredicate: TFunc<T, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TLQColligoTakeWhileEnumerable<T> }

constructor TLQColligoTakeWhileEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TLQColligoTakeWhileEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoTakeWhileEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TLQColligoTakeWhileEnumerator<T> }

constructor TLQColligoTakeWhileEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FDone := False;
end;

function TLQColligoTakeWhileEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoTakeWhileEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoTakeWhileEnumerator<T>.Reset;
begin
  FSource.Reset;
  FDone := False;
end;

end.



