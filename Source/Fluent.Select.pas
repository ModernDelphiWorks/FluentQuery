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

unit Fluent.Select;

interface

uses
  {$IFDEF QUERYABLE}
  Fluent.Queryable,
  {$ENDIF}
  SysUtils,
  Fluent;

type
  TFluentSelectEnumerable<T, TResult> = class(TFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<T>;
    FSelector: TFunc<T, TResult>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const ASelector: TFunc<T, TResult>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentSelectEnumerator<T, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSource: IFluentEnumerator<T>;
    FSelector: TFunc<T, TResult>;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASelector: TFunc<T, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TFluentSelectQueryable<T, TResult> = class(TFluentQueryableBase<TResult>)
  private
    FSource: IFluentQueryableBase<T>;
    FSelector: TFunc<T, TResult>;
  public
    constructor Create(const ASource: IFluentQueryableBase<T>; const ASelector: TFunc<T, TResult>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
    function BuildQuery: string; override;
  end;
  {$ENDIF}

implementation

{ TFluentMapEnumerable<T, TResult> }

constructor TFluentSelectEnumerable<T, TResult>.Create(const ASource: IFluentEnumerableBase<T>; const ASelector: TFunc<T, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TFluentSelectEnumerable<T, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentSelectEnumerator<T, TResult>.Create(FSource.GetEnumerator, FSelector);
end;

{ TFluentMapEnumerator<T, TResult> }

constructor TFluentSelectEnumerator<T, TResult>.Create(const ASource: IFluentEnumerator<T>; const ASelector: TFunc<T, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TFluentSelectEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentSelectEnumerator<T, TResult>.MoveNext: Boolean;
begin
  if FSource.MoveNext then
  begin
    FCurrent := FSelector(FSource.Current);
    Result := True;
  end
  else
    Result := False;
end;

procedure TFluentSelectEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
end;

{$IFDEF QUERYABLE}
{ TFluentSelectQueryable}

constructor TFluentSelectQueryable<T, TResult>.Create(const ASource: IFluentQueryableBase<T>;
  const ASelector: TFunc<T, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TFluentSelectQueryable<T, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  // Placeholder: Implementar iteração com FSelector
  Result := FSource.GetEnumerator as IFluentEnumerator<TResult>; // Ajustar depois
end;

function TFluentSelectQueryable<T, TResult>.BuildQuery: string;
begin
  // Placeholder: Converter FSelector pra SELECT via ICQL
  Result := FSource.BuildQuery; // + ' SELECT ColumnName'
  // Exemplo real: Result := FSource.Select('ColumnName').AsString;
end;
{$ENDIF}

end.
