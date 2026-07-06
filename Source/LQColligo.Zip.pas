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

unit LQColligo.Zip;

interface

uses
  SysUtils,
  LQColligo;

type
  TLQColligoZipEnumerable<T, TSecond, TResult> = class(TLQColligoEnumerableBase<TResult>)
  private
    FSource1: ILQColligoEnumerableBase<T>;
    FSource2: ILQColligoEnumerableBase<TSecond>;
    FSelector: TFunc<T, TSecond, TResult>;
  public
    constructor Create(const ASource1: ILQColligoEnumerableBase<T>; const ASource2: ILQColligoEnumerableBase<TSecond>;
      const ASelector: TFunc<T, TSecond, TResult>);
    function GetEnumerator: ILQColligoEnumerator<TResult>; override;
  end;

  TLQColligoZipEnumerator<T, TSecond, TResult> = class(TInterfacedObject, ILQColligoEnumerator<TResult>)
  private
    FSource1: ILQColligoEnumerator<T>;
    FSource2: ILQColligoEnumerator<TSecond>;
    FSelector: TFunc<T, TSecond, TResult>;
    FCurrent: TResult;
  public
    constructor Create(const ASource1: ILQColligoEnumerator<T>; const ASource2: ILQColligoEnumerator<TSecond>;
      const ASelector: TFunc<T, TSecond, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TLQColligoZipEnumerable<T, TSecond, TResult> }

constructor TLQColligoZipEnumerable<T, TSecond, TResult>.Create(const ASource1: ILQColligoEnumerableBase<T>;
  const ASource2: ILQColligoEnumerableBase<TSecond>; const ASelector: TFunc<T, TSecond, TResult>);
begin
  FSource1 := ASource1;
  FSource2 := ASource2;
  FSelector := ASelector;
end;

function TLQColligoZipEnumerable<T, TSecond, TResult>.GetEnumerator: ILQColligoEnumerator<TResult>;
begin
  Result := TLQColligoZipEnumerator<T, TSecond, TResult>.Create(FSource1.GetEnumerator, FSource2.GetEnumerator, FSelector);
end;

{ TLQColligoZipEnumerator<T, TSecond, TResult> }

constructor TLQColligoZipEnumerator<T, TSecond, TResult>.Create(const ASource1: ILQColligoEnumerator<T>;
  const ASource2: ILQColligoEnumerator<TSecond>; const ASelector: TFunc<T, TSecond, TResult>);
begin
  FSource1 := ASource1;
  FSource2 := ASource2;
  FSelector := ASelector;
end;

function TLQColligoZipEnumerator<T, TSecond, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TLQColligoZipEnumerator<T, TSecond, TResult>.MoveNext: Boolean;
begin
  if FSource1.MoveNext and FSource2.MoveNext then
  begin
    FCurrent := FSelector(FSource1.Current, FSource2.Current);
    Result := True;
  end
  else
    Result := False;
end;

procedure TLQColligoZipEnumerator<T, TSecond, TResult>.Reset;
begin
  FSource1.Reset;
  FSource2.Reset;
end;

end.



