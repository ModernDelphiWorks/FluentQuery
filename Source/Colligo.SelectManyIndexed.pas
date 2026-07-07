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

unit Colligo.SelectManyIndexed;

interface

uses
  SysUtils,
  Colligo;

type
  TColligoSelectManyIndexedEnumerable<T, TResult> = class(TColligoEnumerableBase<TResult>)
  private
    FSource: IColligoEnumerableBase<T>;
    FSelector: TFunc<T, Integer, IColligoArray<TResult>>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>;
      const ASelector: TFunc<T, Integer, IColligoArray<TResult>>);
    function GetEnumerator: IColligoEnumerator<TResult>; override;
  end;

  TColligoSelectManyIndexedEnumerator<T, TResult> = class(TInterfacedObject, IColligoEnumerator<TResult>)
  private
    FSource: IColligoEnumerator<T>;
    FSelector: TFunc<T, Integer, IColligoArray<TResult>>;
    FCurrentArray: IColligoArray<TResult>;
    FIndex: Integer;
    FSourceIndex: Integer;
  public
    constructor Create(const ASource: IColligoEnumerator<T>;
      const ASelector: TFunc<T, Integer, IColligoArray<TResult>>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TColligoSelectManyIndexedEnumerable<T, TResult> }

constructor TColligoSelectManyIndexedEnumerable<T, TResult>.Create(
  const ASource: IColligoEnumerableBase<T>;
  const ASelector: TFunc<T, Integer, IColligoArray<TResult>>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TColligoSelectManyIndexedEnumerable<T, TResult>.GetEnumerator: IColligoEnumerator<TResult>;
begin
  Result := TColligoSelectManyIndexedEnumerator<T, TResult>.Create(FSource.GetEnumerator, FSelector);
end;

{ TColligoSelectManyIndexedEnumerator<T, TResult> }

constructor TColligoSelectManyIndexedEnumerator<T, TResult>.Create(
  const ASource: IColligoEnumerator<T>;
  const ASelector: TFunc<T, Integer, IColligoArray<TResult>>);
begin
  FSource := ASource;
  FSelector := ASelector;
  FIndex := -1;
  FSourceIndex := -1;
end;

function TColligoSelectManyIndexedEnumerator<T, TResult>.GetCurrent: TResult;
begin
  if (FIndex >= 0) and (FIndex < FCurrentArray.Length) then
    Result := FCurrentArray[FIndex]
  else
    raise ERangeError.Create('Index out of bounds');
end;

function TColligoSelectManyIndexedEnumerator<T, TResult>.MoveNext: Boolean;
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

procedure TColligoSelectManyIndexedEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
  FSourceIndex := -1;
  FCurrentArray := nil;
end;

end.



