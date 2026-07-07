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

unit Colligo.Zip;

interface

uses
  SysUtils,
  Colligo;

type
  TColligoZipEnumerable<T, TSecond, TResult> = class(TColligoEnumerableBase<TResult>)
  private
    FSource1: IColligoEnumerableBase<T>;
    FSource2: IColligoEnumerableBase<TSecond>;
    FSelector: TFunc<T, TSecond, TResult>;
  public
    constructor Create(const ASource1: IColligoEnumerableBase<T>; const ASource2: IColligoEnumerableBase<TSecond>;
      const ASelector: TFunc<T, TSecond, TResult>);
    function GetEnumerator: IColligoEnumerator<TResult>; override;
  end;

  TColligoZipEnumerator<T, TSecond, TResult> = class(TInterfacedObject, IColligoEnumerator<TResult>)
  private
    FSource1: IColligoEnumerator<T>;
    FSource2: IColligoEnumerator<TSecond>;
    FSelector: TFunc<T, TSecond, TResult>;
    FCurrent: TResult;
  public
    constructor Create(const ASource1: IColligoEnumerator<T>; const ASource2: IColligoEnumerator<TSecond>;
      const ASelector: TFunc<T, TSecond, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TColligoZipEnumerable<T, TSecond, TResult> }

constructor TColligoZipEnumerable<T, TSecond, TResult>.Create(const ASource1: IColligoEnumerableBase<T>;
  const ASource2: IColligoEnumerableBase<TSecond>; const ASelector: TFunc<T, TSecond, TResult>);
begin
  FSource1 := ASource1;
  FSource2 := ASource2;
  FSelector := ASelector;
end;

function TColligoZipEnumerable<T, TSecond, TResult>.GetEnumerator: IColligoEnumerator<TResult>;
begin
  Result := TColligoZipEnumerator<T, TSecond, TResult>.Create(FSource1.GetEnumerator, FSource2.GetEnumerator, FSelector);
end;

{ TColligoZipEnumerator<T, TSecond, TResult> }

constructor TColligoZipEnumerator<T, TSecond, TResult>.Create(const ASource1: IColligoEnumerator<T>;
  const ASource2: IColligoEnumerator<TSecond>; const ASelector: TFunc<T, TSecond, TResult>);
begin
  FSource1 := ASource1;
  FSource2 := ASource2;
  FSelector := ASelector;
end;

function TColligoZipEnumerator<T, TSecond, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TColligoZipEnumerator<T, TSecond, TResult>.MoveNext: Boolean;
begin
  if FSource1.MoveNext and FSource2.MoveNext then
  begin
    FCurrent := FSelector(FSource1.Current, FSource2.Current);
    Result := True;
  end
  else
    Result := False;
end;

procedure TColligoZipEnumerator<T, TSecond, TResult>.Reset;
begin
  FSource1.Reset;
  FSource2.Reset;
end;

end.



