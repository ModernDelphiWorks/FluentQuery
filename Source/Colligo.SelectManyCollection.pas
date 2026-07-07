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

unit Colligo.SelectManyCollection;

interface

uses
  SysUtils,
  Colligo;

type
  TColligoSelectManyCollectionEnumerable<T, TCollection, TResult> = class(TColligoEnumerableBase<TResult>)
  private
    FSource: IColligoEnumerableBase<T>;
    FCollectionSelector: TFunc<T, TArray<TCollection>>;
    FResultSelector: TFunc<T, TCollection, TResult>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>;
      const ACollectionSelector: TFunc<T, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>);
    function GetEnumerator: IColligoEnumerator<TResult>; override;
  end;

  TColligoSelectManyCollectionEnumerator<T, TCollection, TResult> = class(TInterfacedObject, IColligoEnumerator<TResult>)
  private
    FSource: IColligoEnumerator<T>;
    FCollectionSelector: TFunc<T, TArray<TCollection>>;
    FResultSelector: TFunc<T, TCollection, TResult>;
    FCurrentArray: TArray<TCollection>;
    FIndex: Integer;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IColligoEnumerator<T>;
      const ACollectionSelector: TFunc<T, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TColligoSelectManyCollectionEnumerable<T, TCollection, TResult> }

constructor TColligoSelectManyCollectionEnumerable<T, TCollection, TResult>.Create(
  const ASource: IColligoEnumerableBase<T>;
  const ACollectionSelector: TFunc<T, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>);
begin
  FSource := ASource;
  FCollectionSelector := ACollectionSelector;
  FResultSelector := AResultSelector;
end;

function TColligoSelectManyCollectionEnumerable<T, TCollection, TResult>.GetEnumerator: IColligoEnumerator<TResult>;
begin
  Result := TColligoSelectManyCollectionEnumerator<T, TCollection, TResult>.Create(
    FSource.GetEnumerator, FCollectionSelector, FResultSelector);
end;

{ TColligoSelectManyCollectionEnumerator<T, TCollection, TResult> }

constructor TColligoSelectManyCollectionEnumerator<T, TCollection, TResult>.Create(
  const ASource: IColligoEnumerator<T>;
  const ACollectionSelector: TFunc<T, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>);
begin
  FSource := ASource;
  FCollectionSelector := ACollectionSelector;
  FResultSelector := AResultSelector;
  FIndex := -1;
end;

function TColligoSelectManyCollectionEnumerator<T, TCollection, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TColligoSelectManyCollectionEnumerator<T, TCollection, TResult>.MoveNext: Boolean;
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

procedure TColligoSelectManyCollectionEnumerator<T, TCollection, TResult>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
  FCurrentArray := nil;
end;

end.



