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

unit LQColligo.SelectManyIndexed;

interface

uses
  SysUtils,
  LQColligo;

type
  TLQColligoSelectManyIndexedEnumerable<T, TResult> = class(TLQColligoEnumerableBase<TResult>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FSelector: TFunc<T, Integer, ILQColligoArray<TResult>>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>;
      const ASelector: TFunc<T, Integer, ILQColligoArray<TResult>>);
    function GetEnumerator: ILQColligoEnumerator<TResult>; override;
  end;

  TLQColligoSelectManyIndexedEnumerator<T, TResult> = class(TInterfacedObject, ILQColligoEnumerator<TResult>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSelector: TFunc<T, Integer, ILQColligoArray<TResult>>;
    FCurrentArray: ILQColligoArray<TResult>;
    FIndex: Integer;
    FSourceIndex: Integer;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>;
      const ASelector: TFunc<T, Integer, ILQColligoArray<TResult>>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TLQColligoSelectManyIndexedEnumerable<T, TResult> }

constructor TLQColligoSelectManyIndexedEnumerable<T, TResult>.Create(
  const ASource: ILQColligoEnumerableBase<T>;
  const ASelector: TFunc<T, Integer, ILQColligoArray<TResult>>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TLQColligoSelectManyIndexedEnumerable<T, TResult>.GetEnumerator: ILQColligoEnumerator<TResult>;
begin
  Result := TLQColligoSelectManyIndexedEnumerator<T, TResult>.Create(FSource.GetEnumerator, FSelector);
end;

{ TLQColligoSelectManyIndexedEnumerator<T, TResult> }

constructor TLQColligoSelectManyIndexedEnumerator<T, TResult>.Create(
  const ASource: ILQColligoEnumerator<T>;
  const ASelector: TFunc<T, Integer, ILQColligoArray<TResult>>);
begin
  FSource := ASource;
  FSelector := ASelector;
  FIndex := -1;
  FSourceIndex := -1;
end;

function TLQColligoSelectManyIndexedEnumerator<T, TResult>.GetCurrent: TResult;
begin
  if (FIndex >= 0) and (FIndex < FCurrentArray.Length) then
    Result := FCurrentArray[FIndex]
  else
    raise ERangeError.Create('Index out of bounds');
end;

function TLQColligoSelectManyIndexedEnumerator<T, TResult>.MoveNext: Boolean;
begin
  while True do
  begin
    if (FIndex >= 0) and (FIndex < FCurrentArray.Length - 1) then
    begin
      Inc(FIndex);
      Result := True;
      Exit;
    end;
    if not FSource.MoveNext then
    begin
      Result := False;
      Exit;
    end;
    Inc(FSourceIndex);
    FCurrentArray := FSelector(FSource.Current, FSourceIndex);
    FIndex := 0;
    if FCurrentArray.Length > 0 then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TLQColligoSelectManyIndexedEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
  FSourceIndex := -1;
  FCurrentArray := nil;
end;

end.



