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

unit LQColligo.SelectMany;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  LQColligo;

type
  TLQColligoSelectManyEnumerable<T, TResult> = class(TInterfacedObject, ILQColligoEnumerableBase<TResult>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FSelector: TFunc<T, TArray<TResult>>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const ASelector: TFunc<T, TArray<TResult>>);
    function GetEnumerator: ILQColligoEnumerator<TResult>;
  end;

  TLQColligoSelectManyEnumerator<T, TResult> = class(TInterfacedObject, ILQColligoEnumerator<TResult>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSelector: TFunc<T, TArray<TResult>>;
    FCurrentArray: TArray<TResult>;
    FIndex: Integer;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ASelector: TFunc<T, TArray<TResult>>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TLQColligoSelectManyEnumerable<T, TResult> }

constructor TLQColligoSelectManyEnumerable<T, TResult>.Create(const ASource: ILQColligoEnumerableBase<T>;
  const ASelector: TFunc<T, TArray<TResult>>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TLQColligoSelectManyEnumerable<T, TResult>.GetEnumerator: ILQColligoEnumerator<TResult>;
begin
  Result := TLQColligoSelectManyEnumerator<T, TResult>.Create(FSource.GetEnumerator, FSelector);
end;

{ TLQColligoSelectManyEnumerator<T, TResult> }

constructor TLQColligoSelectManyEnumerator<T, TResult>.Create(const ASource: ILQColligoEnumerator<T>;
  const ASelector: TFunc<T, TArray<TResult>>);
begin
  FSource := ASource;
  FSelector := ASelector;
  FIndex := -1;
end;

function TLQColligoSelectManyEnumerator<T, TResult>.GetCurrent: TResult;
begin
  if (FIndex >= 0) and (FIndex < Length(FCurrentArray)) then
    Result := FCurrentArray[FIndex]
  else
    raise ERangeError.Create('Index out of bounds');
end;

function TLQColligoSelectManyEnumerator<T, TResult>.MoveNext: Boolean;
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

procedure TLQColligoSelectManyEnumerator<T, TResult>.Reset;
begin
  FIndex := -1;
  FSource.Reset;
end;

end.



