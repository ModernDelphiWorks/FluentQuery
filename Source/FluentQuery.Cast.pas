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

unit FluentQuery.Cast;

interface

//uses
//  {$IFDEF QUERYABLE}
//  System.Fluent.Queryable,
//  {$ENDIF}
//  SysUtils,
//  System.Fluent;

//{$IFDEF QUERYABLE}
//type
//  TFluentCastQueryable<T, TResult> = class(TFluentQueryableBase<TResult>, IFluentQueryableBase<TResult>)
//  private
//    FSource: IFluentQueryableBase<T>;
//    FConverter: TFunc<T, TResult>;
//  public
//    constructor Create(const ASource: IFluentQueryableBase<T>;
//      const AConverter: TFunc<T, TResult>);
//    function GetEnumerator: IFluentEnumerator<TResult>; override;
//    function BuildQuery: string; override;
//  end;
//
//  TFluentCastQueryableEnumerator<T, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
//  private
//    FSourceEnum: IFluentEnumerator<T>;
//    FConverter: TFunc<T, TResult>;
//    FCurrent: TResult;
//  public
//    constructor Create(const ASource: IFluentEnumerator<T>;
//      const AConverter: TFunc<T, TResult>);
//    destructor Destroy; override;
//    function GetCurrent: TResult;
//    function MoveNext: Boolean;
//    procedure Reset;
//    property Current: TResult read GetCurrent;
//  end;
//{$ENDIF}

implementation

//{$IFDEF QUERYABLE}
//{ TFluentCastQueryable<T, TResult> }
//
//constructor TFluentCastQueryable<T, TResult>.Create(
//  const ASource: IFluentQueryableBase<T>;
//  const AConverter: TFunc<T, TResult>);
//begin
//  FSource := ASource;
//  FConverter := AConverter;
//end;
//
//function TFluentCastQueryable<T, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
//begin
//  Result := TFluentCastQueryableEnumerator<T, TResult>.Create(
//    FSource.GetEnumerator, FConverter);
//end;
//
//function TFluentCastQueryable<T, TResult>.BuildQuery: string;
//begin
//  // Placeholder: Traduzir para SQL, ex.: CAST(<column> AS <TResult>)
//  Result := FSource.BuildQuery + ' /* Cast<TResult> */';
//end;
//
//{ TFluentCastQueryableEnumerator<T, TResult> }
//
//constructor TFluentCastQueryableEnumerator<T, TResult>.Create(
//  const ASource: IFluentEnumerator<T>;
//  const AConverter: TFunc<T, TResult>);
//begin
//  FSourceEnum := ASource;
//  FConverter := AConverter;
//end;
//
//destructor TFluentCastQueryableEnumerator<T, TResult>.Destroy;
//begin
//  FSourceEnum := nil;
//  inherited;
//end;
//
//function TFluentCastQueryableEnumerator<T, TResult>.GetCurrent: TResult;
//begin
//  Result := FCurrent;
//end;
//
//function TFluentCastQueryableEnumerator<T, TResult>.MoveNext: Boolean;
//begin
//  if FSourceEnum.MoveNext then
//  begin
//    try
//      FCurrent := FConverter(FSourceEnum.Current);
//      Result := True;
//    except
//      on E: Exception do
//        raise EInvalidCast.Create('Cannot cast value: ' + E.Message);
//    end;
//  end
//  else
//    Result := False;
//end;
//
//procedure TFluentCastQueryableEnumerator<T, TResult>.Reset;
//begin
//  FSourceEnum.Reset;
//  FCurrent := Default(TResult);
//end;
//{$ENDIF}

end.
