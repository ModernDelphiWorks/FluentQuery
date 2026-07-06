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

unit LQColligo.Where;

interface

uses
  SysUtils,
  LQColligo;

type
  TLQColligoWhereEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoWhereEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FPredicate: TFunc<T, Boolean>;
    FCurrent: T;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const APredicate: TFunc<T, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TLQColligoFilterEnumerable<T> }

constructor TLQColligoWhereEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TLQColligoWhereEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoWhereEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TLQColligoFilterEnumerator<T> }

constructor TLQColligoWhereEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TLQColligoWhereEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoWhereEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoWhereEnumerator<T>.Reset;
begin
  FSource.Reset;
end;


end.



