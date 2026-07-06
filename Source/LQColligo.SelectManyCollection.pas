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

unit LQColligo.SelectManyCollection;

interface

uses
  SysUtils,
  LQColligo;

type
  TLQColligoSelectManyCollectionEnumerable<T, TCollection, TResult> = class(TLQColligoEnumerableBase<TResult>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FCollectionSelector: TFunc<T, TArray<TCollection>>;
    FResultSelector: TFunc<T, TCollection, TResult>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>;
      const ACollectionSelector: TFunc<T, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>);
    function GetEnumerator: ILQColligoEnumerator<TResult>; override;
  end;

  TLQColligoSelectManyCollectionEnumerator<T, TCollection, TResult> = class(TInterfacedObject, ILQColligoEnumerator<TResult>)
  private
    FSource: ILQColligoEnumerator<T>;
    FCollectionSelector: TFunc<T, TArray<TCollection>>;
    FResultSelector: TFunc<T, TCollection, TResult>;
    FCurrentArray: TArray<TCollection>;
    FIndex: Integer;
    FCurrent: TResult;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>;
      const ACollectionSelector: TFunc<T, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TLQColligoSelectManyCollectionEnumerable<T, TCollection, TResult> }

constructor TLQColligoSelectManyCollectionEnumerable<T, TCollection, TResult>.Create(
  const ASource: ILQColligoEnumerableBase<T>;
  const ACollectionSelector: TFunc<T, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>);
begin
  FSource := ASource;
  FCollectionSelector := ACollectionSelector;
  FResultSelector := AResultSelector;
end;

function TLQColligoSelectManyCollectionEnumerable<T, TCollection, TResult>.GetEnumerator: ILQColligoEnumerator<TResult>;
begin
  Result := TLQColligoSelectManyCollectionEnumerator<T, TCollection, TResult>.Create(
    FSource.GetEnumerator, FCollectionSelector, FResultSelector);
end;

{ TLQColligoSelectManyCollectionEnumerator<T, TCollection, TResult> }

constructor TLQColligoSelectManyCollectionEnumerator<T, TCollection, TResult>.Create(
  const ASource: ILQColligoEnumerator<T>;
  const ACollectionSelector: TFunc<T, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>);
begin
  FSource := ASource;
  FCollectionSelector := ACollectionSelector;
  FResultSelector := AResultSelector;
  FIndex := -1;
end;

function TLQColligoSelectManyCollectionEnumerator<T, TCollection, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TLQColligoSelectManyCollectionEnumerator<T, TCollection, TResult>.MoveNext: Boolean;
var
  LSourceItem: T;
begin
  LSourceItem := Default(T);
  while True do
  begin
    if (FIndex >= 0) and (FIndex < Length(FCurrentArray) - 1) then
    begin
      Inc(FIndex);
      FCurrent := FResultSelector(LSourceItem, FCurrentArray[FIndex]);
      Result := True;
      Exit;
    end;
    if not FSource.MoveNext then
    begin
      Result := False;
      Exit;
    end;
    LSourceItem := FSource.Current;
    FCurrentArray := FCollectionSelector(LSourceItem);
    FIndex := 0;
    if Length(FCurrentArray) > 0 then
    begin
      FCurrent := FResultSelector(LSourceItem, FCurrentArray[FIndex]);
      Result := True;
      Exit;
    end;
  end;
end;

procedure TLQColligoSelectManyCollectionEnumerator<T, TCollection, TResult>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
  FCurrentArray := nil;
end;

end.



