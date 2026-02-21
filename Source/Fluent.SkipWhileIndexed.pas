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

unit Fluent.SkipWhileIndexed;

interface

uses
  SysUtils,
  Fluent;

type
  TFluentSkipWhileIndexedEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentSkipWhileIndexedEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FPredicate: TFunc<T, Integer, Boolean>;
    FSkipped: Boolean;
    FIndex: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentSkipWhileIndexedEnumerable<T> }

constructor TFluentSkipWhileIndexedEnumerable<T>.Create(
  const ASource: IFluentEnumerableBase<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TFluentSkipWhileIndexedEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentSkipWhileIndexedEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TFluentSkipWhileIndexedEnumerator<T> }

constructor TFluentSkipWhileIndexedEnumerator<T>.Create(
  const ASource: IFluentEnumerator<T>; const APredicate: TFunc<T, Integer, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FSkipped := False;
  FIndex := -1;
end;

function TFluentSkipWhileIndexedEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentSkipWhileIndexedEnumerator<T>.MoveNext: Boolean;
begin
  if not FSkipped then
  begin
    while FSource.MoveNext do
    begin
      Inc(FIndex);
      if not FPredicate(FSource.Current, FIndex) then
      begin
        FCurrent := FSource.Current;
        FSkipped := True;
        Result := True;
        Exit;
      end;
    end;
    FSkipped := True;
  end;
  Result := FSource.MoveNext;
  if Result then
  begin
    Inc(FIndex);
    FCurrent := FSource.Current;
  end;
end;

procedure TFluentSkipWhileIndexedEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := False;
  FIndex := -1;
end;

end.
