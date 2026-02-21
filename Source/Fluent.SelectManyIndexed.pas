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

{$include ./fluent4d.inc}

unit Fluent.SelectManyIndexed;

interface

uses
  SysUtils,
  Fluent;

type
  TFluentSelectManyIndexedEnumerable<T, TResult> = class(TFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<T>;
    FSelector: TFunc<T, Integer, IFluentArray<TResult>>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const ASelector: TFunc<T, Integer, IFluentArray<TResult>>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentSelectManyIndexedEnumerator<T, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSource: IFluentEnumerator<T>;
    FSelector: TFunc<T, Integer, IFluentArray<TResult>>;
    FCurrentArray: IFluentArray<TResult>;
    FIndex: Integer;
    FSourceIndex: Integer;
  public
    constructor Create(const ASource: IFluentEnumerator<T>;
      const ASelector: TFunc<T, Integer, IFluentArray<TResult>>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TFluentSelectManyIndexedEnumerable<T, TResult> }

constructor TFluentSelectManyIndexedEnumerable<T, TResult>.Create(
  const ASource: IFluentEnumerableBase<T>;
  const ASelector: TFunc<T, Integer, IFluentArray<TResult>>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TFluentSelectManyIndexedEnumerable<T, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentSelectManyIndexedEnumerator<T, TResult>.Create(FSource.GetEnumerator, FSelector);
end;

{ TFluentSelectManyIndexedEnumerator<T, TResult> }

constructor TFluentSelectManyIndexedEnumerator<T, TResult>.Create(
  const ASource: IFluentEnumerator<T>;
  const ASelector: TFunc<T, Integer, IFluentArray<TResult>>);
begin
  FSource := ASource;
  FSelector := ASelector;
  FIndex := -1;
  FSourceIndex := -1;
end;

function TFluentSelectManyIndexedEnumerator<T, TResult>.GetCurrent: TResult;
begin
  if (FIndex >= 0) and (FIndex < FCurrentArray.Length) then
    Result := FCurrentArray[FIndex]
  else
    raise ERangeError.Create('Index out of bounds');
end;

function TFluentSelectManyIndexedEnumerator<T, TResult>.MoveNext: Boolean;
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

procedure TFluentSelectManyIndexedEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
  FSourceIndex := -1;
  FCurrentArray := nil;
end;

end.
