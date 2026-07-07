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

unit Colligo.SelectMany;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Colligo;

type
  TColligoSelectManyEnumerable<T, TResult> = class(TInterfacedObject, IColligoEnumerableBase<TResult>)
  private
    FSource: IColligoEnumerableBase<T>;
    FSelector: TFunc<T, TArray<TResult>>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const ASelector: TFunc<T, TArray<TResult>>);
    function GetEnumerator: IColligoEnumerator<TResult>;
  end;

  TColligoSelectManyEnumerator<T, TResult> = class(TInterfacedObject, IColligoEnumerator<TResult>)
  private
    FSource: IColligoEnumerator<T>;
    FSelector: TFunc<T, TArray<TResult>>;
    FCurrentArray: TArray<TResult>;
    FIndex: Integer;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ASelector: TFunc<T, TArray<TResult>>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TColligoSelectManyEnumerable<T, TResult> }

constructor TColligoSelectManyEnumerable<T, TResult>.Create(const ASource: IColligoEnumerableBase<T>;
  const ASelector: TFunc<T, TArray<TResult>>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TColligoSelectManyEnumerable<T, TResult>.GetEnumerator: IColligoEnumerator<TResult>;
begin
  Result := TColligoSelectManyEnumerator<T, TResult>.Create(FSource.GetEnumerator, FSelector);
end;

{ TColligoSelectManyEnumerator<T, TResult> }

constructor TColligoSelectManyEnumerator<T, TResult>.Create(const ASource: IColligoEnumerator<T>;
  const ASelector: TFunc<T, TArray<TResult>>);
begin
  FSource := ASource;
  FSelector := ASelector;
  FIndex := -1;
end;

function TColligoSelectManyEnumerator<T, TResult>.GetCurrent: TResult;
begin
  if (FIndex >= 0) and (FIndex < Length(FCurrentArray)) then
    Result := FCurrentArray[FIndex]
  else
    raise ERangeError.Create('Index out of bounds');
end;

function TColligoSelectManyEnumerator<T, TResult>.MoveNext: Boolean;
begin
  while True do
  begin
    if (FIndex >= 0) and (FIndex < Length(FCurrentArray) - 1) then
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
    FCurrentArray := FSelector(FSource.Current);
    FIndex := 0;
    if Length(FCurrentArray) > 0 then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TColligoSelectManyEnumerator<T, TResult>.Reset;
begin
  FIndex := -1;
  FSource.Reset;
end;

end.



