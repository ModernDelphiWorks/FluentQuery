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

unit Fluent.TakeWhile;

interface

uses
  SysUtils,
  Fluent;

type
  TFluentTakeWhileEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FPredicate: TFunc<T, Boolean>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentTakeWhileEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FPredicate: TFunc<T, Boolean>;
    FCurrent: T;
    FDone: Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const APredicate: TFunc<T, Boolean>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentTakeWhileEnumerable<T> }

constructor TFluentTakeWhileEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
end;

function TFluentTakeWhileEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentTakeWhileEnumerator<T>.Create(FSource.GetEnumerator, FPredicate);
end;

{ TFluentTakeWhileEnumerator<T> }

constructor TFluentTakeWhileEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; const APredicate: TFunc<T, Boolean>);
begin
  FSource := ASource;
  FPredicate := APredicate;
  FDone := False;
end;

function TFluentTakeWhileEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentTakeWhileEnumerator<T>.MoveNext: Boolean;
begin
  if FDone or not FSource.MoveNext then
    Exit(False);
  FCurrent := FSource.Current;
  if not FPredicate(FCurrent) then
  begin
    FDone := True;
    Exit(False);
  end;
  Result := True;
end;

procedure TFluentTakeWhileEnumerator<T>.Reset;
begin
  FSource.Reset;
  FDone := False;
end;

end.
