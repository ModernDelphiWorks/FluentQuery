{
                          Apache License
                      Version 2.0, January 2004
                   http://www.apache.org/licenses/

       Licensed under the Apache License, Version 2.0 (the "License");
       you may not use this file except in compliance with the License.
       You may obtain a copy of the License at

             http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing, software
       distributed under the License is distributed on an "AS IS" BASIS,
       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
       See the License for the specific language governing permissions and
       limitations under the License.
}

{
  @abstract(Fluent4D: Fluent Data Processing Framework for Delphi)
  @description(A powerful and intuitive framework for fluent-style data manipulation in Delphi)
  @created(03 Abr 2025)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @Discord(https://discord.gg/T2zJC8zX)
}

{$include ./FluentQuery.inc}

unit FluentQuery.SelectManyCollection;

interface

uses
  SysUtils,
  FluentQuery;

type
  TFluentSelectManyCollectionEnumerable<T, TCollection, TResult> = class(TFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<T>;
    FCollectionSelector: TFunc<T, TArray<TCollection>>;
    FResultSelector: TFunc<T, TCollection, TResult>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const ACollectionSelector: TFunc<T, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentSelectManyCollectionEnumerator<T, TCollection, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSource: IFluentEnumerator<T>;
    FCollectionSelector: TFunc<T, TArray<TCollection>>;
    FResultSelector: TFunc<T, TCollection, TResult>;
    FCurrentArray: TArray<TCollection>;
    FIndex: Integer;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IFluentEnumerator<T>;
      const ACollectionSelector: TFunc<T, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TFluentSelectManyCollectionEnumerable<T, TCollection, TResult> }

constructor TFluentSelectManyCollectionEnumerable<T, TCollection, TResult>.Create(
  const ASource: IFluentEnumerableBase<T>;
  const ACollectionSelector: TFunc<T, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>);
begin
  FSource := ASource;
  FCollectionSelector := ACollectionSelector;
  FResultSelector := AResultSelector;
end;

function TFluentSelectManyCollectionEnumerable<T, TCollection, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentSelectManyCollectionEnumerator<T, TCollection, TResult>.Create(
    FSource.GetEnumerator, FCollectionSelector, FResultSelector);
end;

{ TFluentSelectManyCollectionEnumerator<T, TCollection, TResult> }

constructor TFluentSelectManyCollectionEnumerator<T, TCollection, TResult>.Create(
  const ASource: IFluentEnumerator<T>;
  const ACollectionSelector: TFunc<T, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>);
begin
  FSource := ASource;
  FCollectionSelector := ACollectionSelector;
  FResultSelector := AResultSelector;
  FIndex := -1;
end;

function TFluentSelectManyCollectionEnumerator<T, TCollection, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentSelectManyCollectionEnumerator<T, TCollection, TResult>.MoveNext: Boolean;
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

procedure TFluentSelectManyCollectionEnumerator<T, TCollection, TResult>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
  FCurrentArray := nil;
end;

end.
