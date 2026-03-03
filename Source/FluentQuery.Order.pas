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

unit FluentQuery.Order;

interface

uses
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  FluentQuery;

type
  TFluentOrderEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FComparer: IComparer<T>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const AComparer: IComparer<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

implementation

uses
  FluentQuery.OrderBy;

{ TFluentOrderEnumerable<T> }

constructor TFluentOrderEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; const AComparer: IComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  if FComparer = nil then
    FComparer := TComparer<T>.Default;
end;

function TFluentOrderEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentOrderByEnumerator<T>.Create(FSource.GetEnumerator,
    function(A, B: T): Integer
    begin
      Result := FComparer.Compare(A, B);
    end);
end;

end.
