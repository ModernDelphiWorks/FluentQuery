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

unit LQColligo.SelectIndexed;

interface

uses
  SysUtils,
  LQColligo;

type
  TLQColligoSelectIndexedEnumerable<T, TResult> = class(TLQColligoEnumerableBase<TResult>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FSelector: TFunc<T, Integer, TResult>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const ASelector: TFunc<T, Integer, TResult>);
    function GetEnumerator: ILQColligoEnumerator<TResult>; override;
  end;

  TLQColligoSelectIndexedEnumerator<T, TResult> = class(TInterfacedObject, ILQColligoEnumerator<TResult>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSelector: TFunc<T, Integer, TResult>;
    FIndex: Integer;
    FCurrent: TResult;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ASelector: TFunc<T, Integer, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TLQColligoSelectIndexedEnumerable<T, TResult> }

constructor TLQColligoSelectIndexedEnumerable<T, TResult>.Create(
  const ASource: ILQColligoEnumerableBase<T>; const ASelector: TFunc<T, Integer, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TLQColligoSelectIndexedEnumerable<T, TResult>.GetEnumerator: ILQColligoEnumerator<TResult>;
begin
  Result := TLQColligoSelectIndexedEnumerator<T, TResult>.Create(FSource.GetEnumerator, FSelector);
end;

{ TLQColligoSelectIndexedEnumerator<T, TResult> }

constructor TLQColligoSelectIndexedEnumerator<T, TResult>.Create(
  const ASource: ILQColligoEnumerator<T>; const ASelector: TFunc<T, Integer, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
  FIndex := -1;
end;

function TLQColligoSelectIndexedEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TLQColligoSelectIndexedEnumerator<T, TResult>.MoveNext: Boolean;
begin
  if FSource.MoveNext then
  begin
    Inc(FIndex);
    FCurrent := FSelector(FSource.Current, FIndex);
    Result := True;
  end
  else
    Result := False;
end;

procedure TLQColligoSelectIndexedEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
end;

end.



