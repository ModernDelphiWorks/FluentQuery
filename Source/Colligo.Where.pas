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

unit Colligo.Where;

interface

uses
  SysUtils,
  Colligo;

type
  TColligoWhereEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoWhereEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FPredicate: TFunc<T, Boolean>;
    FCurrent: T;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const APredicate: TFunc<T, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoFilterEnumerable<T> }

constructor TColligoWhereEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TColligoWhereEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoWhereEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TColligoFilterEnumerator<T> }

constructor TColligoWhereEnumerator<T>.Create(const ASource: IColligoEnumerator<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TColligoWhereEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoWhereEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if FPredicate(FCurrent) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TColligoWhereEnumerator<T>.Reset;
begin
  FSource.Reset;
end;


end.



