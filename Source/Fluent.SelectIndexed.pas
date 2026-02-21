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

unit Fluent.SelectIndexed;

interface

uses
  SysUtils,
  Fluent;

type
  TFluentSelectIndexedEnumerable<T, TResult> = class(TFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<T>;
    FSelector: TFunc<T, Integer, TResult>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const ASelector: TFunc<T, Integer, TResult>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentSelectIndexedEnumerator<T, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSource: IFluentEnumerator<T>;
    FSelector: TFunc<T, Integer, TResult>;
    FIndex: Integer;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASelector: TFunc<T, Integer, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TFluentSelectIndexedEnumerable<T, TResult> }

constructor TFluentSelectIndexedEnumerable<T, TResult>.Create(
  const ASource: IFluentEnumerableBase<T>; const ASelector: TFunc<T, Integer, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TFluentSelectIndexedEnumerable<T, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentSelectIndexedEnumerator<T, TResult>.Create(FSource.GetEnumerator, FSelector);
end;

{ TFluentSelectIndexedEnumerator<T, TResult> }

constructor TFluentSelectIndexedEnumerator<T, TResult>.Create(
  const ASource: IFluentEnumerator<T>; const ASelector: TFunc<T, Integer, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
  FIndex := -1;
end;

function TFluentSelectIndexedEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentSelectIndexedEnumerator<T, TResult>.MoveNext: Boolean;
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

procedure TFluentSelectIndexedEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
end;

end.
