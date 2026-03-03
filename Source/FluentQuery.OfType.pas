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

unit FluentQuery.OfType;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  {$ENDIF}
  SysUtils,
  FluentQuery;

type
  TFluentOfTypeEnumerable<T, TResult> = class(TFluentEnumerableBase<TResult>)
  private
    FSource: IFluentEnumerableBase<T>;
    FIsType: TFunc<T, Boolean>;
    FConverter: TFunc<T, TResult>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const AIsType: TFunc<T, Boolean>;
      const AConverter: TFunc<T, TResult>);
    function GetEnumerator: IFluentEnumerator<TResult>; override;
  end;

  TFluentOfTypeEnumerator<T, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
  private
    FSource: IFluentEnumerator<T>;
    FIsType: TFunc<T, Boolean>;
    FConverter: TFunc<T, TResult>;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const AIsType: TFunc<T, Boolean>;
      const AConverter: TFunc<T, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

//  {$IFDEF QUERYABLE}
//  TFluentOfTypeQueryable<T, TResult> = class(TFluentQueryableBase<TResult>, IFluentQueryableBase<TResult>)
//  private
//    FSource: IFluentQueryableBase<T>;
//    FIsType: TFunc<T, Boolean>;
//    FConverter: TFunc<T, TResult>;
//  public
//    constructor Create(const ASource: IFluentQueryableBase<T>;
//      const AIsType: TFunc<T, Boolean>;
//      const AConverter: TFunc<T, TResult>);
//    function GetEnumerator: IFluentEnumerator<TResult>; override;
//    function BuildQuery: string; override;
//  end;
//
//  TFluentOfTypeQueryableEnumerator<T, TResult> = class(TInterfacedObject, IFluentEnumerator<TResult>)
//  private
//    FSourceEnum: IFluentEnumerator<T>;
//    FIsType: TFunc<T, Boolean>;
//    FConverter: TFunc<T, TResult>;
//    FCurrent: TResult;
//  public
//    constructor Create(const ASource: IFluentEnumerator<T>;
//      const AIsType: TFunc<T, Boolean>;
//      const AConverter: TFunc<T, TResult>);
//    destructor Destroy; override;
//    function GetCurrent: TResult;
//    function MoveNext: Boolean;
//    procedure Reset;
//    property Current: TResult read GetCurrent;
//  end;
//  {$ENDIF}

implementation

{ TFluentOfTypeEnumerable<T, TResult> }

constructor TFluentOfTypeEnumerable<T, TResult>.Create(const ASource: IFluentEnumerableBase<T>;
  const AIsType: TFunc<T, Boolean>; const AConverter: TFunc<T, TResult>);
begin
  FSource := ASource;
  FIsType := AIsType;
  FConverter := AConverter;
end;

function TFluentOfTypeEnumerable<T, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
begin
  Result := TFluentOfTypeEnumerator<T, TResult>.Create(FSource.GetEnumerator, FIsType, FConverter);
end;

{ TFluentOfTypeEnumerator<T, TResult> }

constructor TFluentOfTypeEnumerator<T, TResult>.Create(const ASource: IFluentEnumerator<T>;
  const AIsType: TFunc<T, Boolean>; const AConverter: TFunc<T, TResult>);
begin
  FSource := ASource;
  FIsType := AIsType;
  FConverter := AConverter;
end;

function TFluentOfTypeEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TFluentOfTypeEnumerator<T, TResult>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    if FIsType(FSource.Current) then
    begin
      FCurrent := FConverter(FSource.Current);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TFluentOfTypeEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
end;

//{$IFDEF QUERYABLE}
//{ TFluentOfTypeQueryable<T, TResult> }
//
//constructor TFluentOfTypeQueryable<T, TResult>.Create(
//  const ASource: IFluentQueryableBase<T>;
//  const AIsType: TFunc<T, Boolean>;
//  const AConverter: TFunc<T, TResult>);
//begin
//  FSource := ASource;
//  FIsType := AIsType;
//  FConverter := AConverter;
//end;
//
//function TFluentOfTypeQueryable<T, TResult>.GetEnumerator: IFluentEnumerator<TResult>;
//begin
//  Result := TFluentOfTypeQueryableEnumerator<T, TResult>.Create(
//    FSource.GetEnumerator, FIsType, FConverter);
//end;
//
//function TFluentOfTypeQueryable<T, TResult>.BuildQuery: string;
//begin
//  // Placeholder: Traduzir para SQL, ex.: WHERE tipo = <TResult>
//  Result := FSource.BuildQuery + ' /* OfType<TResult> */';
//end;
//
//{ TFluentOfTypeQueryableEnumerator<T, TResult> }
//
//constructor TFluentOfTypeQueryableEnumerator<T, TResult>.Create(
//  const ASource: IFluentEnumerator<T>;
//  const AIsType: TFunc<T, Boolean>;
//  const AConverter: TFunc<T, TResult>);
//begin
//  FSourceEnum := ASource;
//  FIsType := AIsType;
//  FConverter := AConverter;
//end;
//
//destructor TFluentOfTypeQueryableEnumerator<T, TResult>.Destroy;
//begin
//  FSourceEnum := nil;
//  inherited;
//end;
//
//function TFluentOfTypeQueryableEnumerator<T, TResult>.GetCurrent: TResult;
//begin
//  Result := FCurrent;
//end;
//
//function TFluentOfTypeQueryableEnumerator<T, TResult>.MoveNext: Boolean;
//var
//  LItem: T;
//begin
//  while FSourceEnum.MoveNext do
//  begin
//    LItem := FSourceEnum.Current;
//    if FIsType(LItem) then
//    begin
//      FCurrent := FConverter(LItem);
//      Result := True;
//      Exit;
//    end;
//  end;
//  Result := False;
//end;
//
//procedure TFluentOfTypeQueryableEnumerator<T, TResult>.Reset;
//begin
//  FSourceEnum.Reset;
//  FCurrent := Default(TResult);
//end;
//{$ENDIF}

end.
