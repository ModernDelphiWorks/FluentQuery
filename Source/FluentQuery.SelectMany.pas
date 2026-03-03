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

unit FluentQuery.SelectMany;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  {$ENDIF}
  SysUtils,
  FluentQuery;

type
  TFluentSelectManyEnumerable<T, TResult> = class(TInterfacedObject, IFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<T>;
    FSelector: TFunc<T, TArray<TResult>>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const ASelector: TFunc<T, TArray<TResult>>);
    function GetEnumerator: IFluentEnumerator<TResult>;
  end;

  TFluentSelectManyEnumerator<T, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSource: IFluentEnumerator<T>;
    FSelector: TFunc<T, TArray<TResult>>;
    FCurrentArray: TArray<TResult>;
    FIndex: Integer;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASelector: TFunc<T, TArray<TResult>>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TFluentSelectManyEnumerable<T, TResult> }

constructor TFluentSelectManyEnumerable<T, TResult>.Create(const ASource: IFluentEnumerableBase<T>;
  const ASelector: TFunc<T, TArray<TResult>>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TFluentSelectManyEnumerable<T, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentSelectManyEnumerator<T, TResult>.Create(FSource.GetEnumerator, FSelector);
end;

{ TFluentSelectManyEnumerator<T, TResult> }

constructor TFluentSelectManyEnumerator<T, TResult>.Create(const ASource: IFluentEnumerator<T>;
  const ASelector: TFunc<T, TArray<TResult>>);
begin
  FSource := ASource;
  FSelector := ASelector;
  FIndex := -1;
end;

function TFluentSelectManyEnumerator<T, TResult>.GetCurrent: TResult;
begin
  if (FIndex >= 0) and (FIndex < Length(FCurrentArray)) then
    Result := FCurrentArray[FIndex]
  else
    raise ERangeError.Create('Index out of bounds');
end;

function TFluentSelectManyEnumerator<T, TResult>.MoveNext: Boolean;
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

procedure TFluentSelectManyEnumerator<T, TResult>.Reset;
begin
  FIndex := -1;
  FSource.Reset;
end;

end.
