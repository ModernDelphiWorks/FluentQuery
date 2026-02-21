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

unit Fluent.OrderBy;

interface

uses
  SysUtils,
  Fluent,
  Fluent.Collections;

type
  TFluentOrderByEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FComparer: TFunc<T, T, Integer>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const AComparer: TFunc<T, T, Integer>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentOrderByEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FItems: TArray<T>;
    FIndex: Integer;
  public
    constructor Create(const ASource: IFluentEnumerator<T>;
      const AComparer: TFunc<T, T, Integer>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

uses
  Generics.Collections,
  Generics.Defaults;

{ TFluentOrderByEnumerable<T> }

constructor TFluentOrderByEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>;
  const AComparer: TFunc<T, T, Integer>);
begin
  FSource := ASource;
  FComparer := AComparer;
end;

function TFluentOrderByEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentOrderByEnumerator<T>.Create(FSource.GetEnumerator, FComparer);
end;

{ TFluentOrderByEnumerator<T> }

//constructor TFluentOrderByEnumerator<T>.Create(const ASource: IFluentEnumerator<T>;
//  const AComparer: TFunc<T, T, Integer>);
//var
//  LList: IFluentList<T>;
//begin
//  LList := TFluentList<T>.Create;
//  while ASource.MoveNext do
//    LList.Add(ASource.Current);
//  FItems := LList.ToArray.ArrayData;
//  TArray.Sort<T>(FItems, TComparer<T>.Construct(
//    function(const Left, Right: T): Integer
//    begin
//      Result := AComparer(Left, Right);
//    end));
//  FIndex := -1;
//end;

constructor TFluentOrderByEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; const AComparer: TFunc<T, T, Integer>);
var
  LList: IFluentList<T>;
begin
  LList := TFluentList<T>.Create;
  while ASource.MoveNext do
  begin
    if not TEqualityComparer<T>.Default.Equals(ASource.Current, Default(T)) then
      LList.Add(ASource.Current);
  end;
  FItems := LList.ToArray.ArrayData;
  TArray.Sort<T>(FItems, TComparer<T>.Construct(
    function(const Left, Right: T): Integer
    begin
      Result := AComparer(Left, Right);
    end));
  FIndex := -1;
end;

function TFluentOrderByEnumerator<T>.GetCurrent: T;
begin
  Result := FItems[FIndex];
end;

function TFluentOrderByEnumerator<T>.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < Length(FItems);
end;

procedure TFluentOrderByEnumerator<T>.Reset;
begin
  FIndex := -1;
end;

end.
