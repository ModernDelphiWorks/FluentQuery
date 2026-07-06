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

unit LQColligo.SkipWhileIndexed;

interface

uses
  SysUtils,
  LQColligo;

type
  TLQColligoSkipWhileIndexedEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoSkipWhileIndexedEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
    FSkipped: Boolean;
    FIndex: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TLQColligoSkipWhileIndexedEnumerable<T> }

constructor TLQColligoSkipWhileIndexedEnumerable<T>.Create(
  const ASource: ILQColligoEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TLQColligoSkipWhileIndexedEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoSkipWhileIndexedEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TLQColligoSkipWhileIndexedEnumerator<T> }

constructor TLQColligoSkipWhileIndexedEnumerator<T>.Create(
  const ASource: ILQColligoEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FSkipped := False;
  FIndex := -1;
end;

function TLQColligoSkipWhileIndexedEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoSkipWhileIndexedEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoSkipWhileIndexedEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := False;
  FIndex := -1;
end;

end.



