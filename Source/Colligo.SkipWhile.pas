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

unit Colligo.SkipWhile;

interface

uses
  SysUtils,
  Colligo;

type
  TColligoSkipWhileEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoSkipWhileEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FPredicate: TFunc<T, Boolean>;
    FSkipped: Boolean;
    FCurrent: T;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const APredicate: TFunc<T, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoSkipWhileEnumerable<T> }

constructor TColligoSkipWhileEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>;
  const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TColligoSkipWhileEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoSkipWhileEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TColligoSkipWhileEnumerator<T> }

constructor TColligoSkipWhileEnumerator<T>.Create(const ASource: IColligoEnumerator<T>;
  const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FSkipped := False;
end;

function TColligoSkipWhileEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoSkipWhileEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoSkipWhileEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := False;
end;


end.



