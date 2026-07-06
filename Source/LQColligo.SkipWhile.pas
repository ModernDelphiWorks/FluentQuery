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

unit LQColligo.SkipWhile;

interface

uses
  SysUtils,
  LQColligo;

type
  TLQColligoSkipWhileEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoSkipWhileEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FPredicate: TFunc<T, Boolean>;
    FSkipped: Boolean;
    FCurrent: T;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const APredicate: TFunc<T, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TLQColligoSkipWhileEnumerable<T> }

constructor TLQColligoSkipWhileEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>;
  const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TLQColligoSkipWhileEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoSkipWhileEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TLQColligoSkipWhileEnumerator<T> }

constructor TLQColligoSkipWhileEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>;
  const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FSkipped := False;
end;

function TLQColligoSkipWhileEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoSkipWhileEnumerator<T>.MoveNext: Boolean;
begin
  if not FSkipped then
  begin
    while FSource.MoveNext do
    begin
      if not FPredicate(FSource.Current) then
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
    FCurrent := FSource.Current;
end;

procedure TLQColligoSkipWhileEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := False;
end;


end.



