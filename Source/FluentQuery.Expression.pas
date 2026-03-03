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

unit FluentQuery.Expression;

interface

uses
  SysUtils,
  Variants,
  FluentSQL.Interfaces,
  FluentSQL.Register;

type
  IFluentQueryExpression = interface
    ['{EEC5343B-6FE5-4F2B-A919-E0C201651362}']
    function Field(const AFieldName: string): IFluentQueryExpression;
    function GreaterThan(const AValue: Integer): IFluentQueryExpression; overload;
    function GreaterThan(const AValue: Extended): IFluentQueryExpression; overload;
    function GreaterThan(const AValue: TDate): IFluentQueryExpression; overload;
    function GreaterThan(const AValue: TDateTime): IFluentQueryExpression; overload;
    function LessThan(const AValue: Integer): IFluentQueryExpression; overload;
    function LessThan(const AValue: Extended): IFluentQueryExpression; overload;
    function LessThan(const AValue: TDate): IFluentQueryExpression; overload;
    function LessThan(const AValue: TDateTime): IFluentQueryExpression; overload;
    function Equal(const AValue: Integer): IFluentQueryExpression; overload;
    function Equal(const AValue: Extended): IFluentQueryExpression; overload;
    function Equal(const AValue: string): IFluentQueryExpression; overload;
    function Equal(const AValue: TDate): IFluentQueryExpression; overload;
    function Equal(const AValue: TDateTime): IFluentQueryExpression; overload;
    function Equal(const AValue: TGUID): IFluentQueryExpression; overload;
    function NotEqual(const AValue: Integer): IFluentQueryExpression; overload;
    function NotEqual(const AValue: Extended): IFluentQueryExpression; overload;
    function NotEqual(const AValue: string): IFluentQueryExpression; overload;
    function NotEqual(const AValue: TDate): IFluentQueryExpression; overload;
    function NotEqual(const AValue: TDateTime): IFluentQueryExpression; overload;
    function NotEqual(const AValue: TGUID): IFluentQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: Integer): IFluentQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: Extended): IFluentQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: TDate): IFluentQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: TDateTime): IFluentQueryExpression; overload;
    function LessThanOrEqual(const AValue: Integer): IFluentQueryExpression; overload;
    function LessThanOrEqual(const AValue: Extended): IFluentQueryExpression; overload;
    function LessThanOrEqual(const AValue: TDate): IFluentQueryExpression; overload;
    function LessThanOrEqual(const AValue: TDateTime): IFluentQueryExpression; overload;
    function AndWith(const AFieldName: string): IFluentQueryExpression;
    function OrWith(const AFieldName: string): IFluentQueryExpression;
    function Negate: IFluentQueryExpression;
    function SubExpression(const AFieldName: string): IFluentQueryExpression;
    function InValues(const AValues: TArray<Integer>): IFluentQueryExpression; overload;
    function InValues(const AValues: TArray<Double>): IFluentQueryExpression; overload;
    function InValues(const AValues: TArray<string>): IFluentQueryExpression; overload;
    function InValues(const AValue: string): IFluentQueryExpression; overload;
    function NotInValues(const AValues: TArray<Integer>): IFluentQueryExpression; overload;
    function NotInValues(const AValues: TArray<Double>): IFluentQueryExpression; overload;
    function NotInValues(const AValues: TArray<string>): IFluentQueryExpression; overload;
    function NotInValues(const AValue: string): IFluentQueryExpression; overload;
    function Exists(const AValue: string): IFluentQueryExpression;
    function NotExists(const AValue: string): IFluentQueryExpression;
    function IsNull: IFluentQueryExpression;
    function IsNotNull: IFluentQueryExpression;
    function Contains(const AValue: string): IFluentQueryExpression;
    function StartsWith(const AValue: string): IFluentQueryExpression;
    function EndsWith(const AValue: string): IFluentQueryExpression;
    function Like(const AValue: string): IFluentQueryExpression;
    function NotLike(const AValue: string): IFluentQueryExpression;
    function EqualIgnoreCase(const AValue: string): IFluentQueryExpression;
//    function AsString: string;
    function Serialize: string;
  end;

  TFluentQueryExpression<T> = class(TInterfacedObject, IFluentQueryExpression)
  private
    FCQL: IFluentSQLAST;
    FRegister: TFluentSQLRegister;
    FExpression: IFluentSQLCriteriaExpression;
    FOperator: IFluentSQLOperators;
    FCurrentField: string;
    FIsSubExpression: Boolean;
    FDatabase: TFluentSQLDriver;
    function _CreateOperator(ACompare: TFluentSQLOperatorCompare; AValue: Variant; ADataType: TFluentSQLDataFieldType): IFluentSQLOperator;
    function _ConvertIntegersToDoubles(const AValues: TArray<Integer>): TArray<Double>;
  public
    constructor Create(const ADatabase: TFluentSQLDriver);
    destructor Destroy; override;
    function Field(const AFieldName: string): IFluentQueryExpression;
    function GreaterThan(const AValue: Integer): IFluentQueryExpression; overload;
    function GreaterThan(const AValue: Extended): IFluentQueryExpression; overload;
    function GreaterThan(const AValue: TDate): IFluentQueryExpression; overload;
    function GreaterThan(const AValue: TDateTime): IFluentQueryExpression; overload;
    function LessThan(const AValue: Integer): IFluentQueryExpression; overload;
    function LessThan(const AValue: Extended): IFluentQueryExpression; overload;
    function LessThan(const AValue: TDate): IFluentQueryExpression; overload;
    function LessThan(const AValue: TDateTime): IFluentQueryExpression; overload;
    function Equal(const AValue: Integer): IFluentQueryExpression; overload;
    function Equal(const AValue: Extended): IFluentQueryExpression; overload;
    function Equal(const AValue: string): IFluentQueryExpression; overload;
    function Equal(const AValue: TDate): IFluentQueryExpression; overload;
    function Equal(const AValue: TDateTime): IFluentQueryExpression; overload;
    function Equal(const AValue: TGUID): IFluentQueryExpression; overload;
    function NotEqual(const AValue: Integer): IFluentQueryExpression; overload;
    function NotEqual(const AValue: Extended): IFluentQueryExpression; overload;
    function NotEqual(const AValue: string): IFluentQueryExpression; overload;
    function NotEqual(const AValue: TDate): IFluentQueryExpression; overload;
    function NotEqual(const AValue: TDateTime): IFluentQueryExpression; overload;
    function NotEqual(const AValue: TGUID): IFluentQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: Integer): IFluentQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: Extended): IFluentQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: TDate): IFluentQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: TDateTime): IFluentQueryExpression; overload;
    function LessThanOrEqual(const AValue: Integer): IFluentQueryExpression; overload;
    function LessThanOrEqual(const AValue: Extended): IFluentQueryExpression; overload;
    function LessThanOrEqual(const AValue: TDate): IFluentQueryExpression; overload;
    function LessThanOrEqual(const AValue: TDateTime): IFluentQueryExpression; overload;
    function AndWith(const AFieldName: string): IFluentQueryExpression;
    function OrWith(const AFieldName: string): IFluentQueryExpression;
    function Negate: IFluentQueryExpression;
    function SubExpression(const AFieldName: string): IFluentQueryExpression;
    function InValues(const AValues: TArray<Integer>): IFluentQueryExpression; overload;
    function InValues(const AValues: TArray<Double>): IFluentQueryExpression; overload;
    function InValues(const AValues: TArray<string>): IFluentQueryExpression; overload;
    function InValues(const AValue: string): IFluentQueryExpression; overload;
    function NotInValues(const AValues: TArray<Integer>): IFluentQueryExpression; overload;
    function NotInValues(const AValues: TArray<Double>): IFluentQueryExpression; overload;
    function NotInValues(const AValues: TArray<string>): IFluentQueryExpression; overload;
    function NotInValues(const AValue: string): IFluentQueryExpression; overload;
    function Exists(const AValue: string): IFluentQueryExpression;
    function NotExists(const AValue: string): IFluentQueryExpression;
    function IsNull: IFluentQueryExpression;
    function IsNotNull: IFluentQueryExpression;
    function Contains(const AValue: string): IFluentQueryExpression;
    function StartsWith(const AValue: string): IFluentQueryExpression;
    function EndsWith(const AValue: string): IFluentQueryExpression;
    function Like(const AValue: string): IFluentQueryExpression;
    function NotLike(const AValue: string): IFluentQueryExpression;
    function EqualIgnoreCase(const AValue: string): IFluentQueryExpression;
    function Serialize: string;
//    function AsString: string;
  end;

implementation

uses
  FluentSQL.Expression,
  FluentSQL.Operators,
  FluentSQL.Ast;

constructor TFluentQueryExpression<T>.Create(const ADatabase: TFluentSQLDriver);
begin
  inherited Create;
  FIsSubExpression := False;
  FDatabase := ADatabase;
  FRegister := TFluentSQLRegister.Create;
  FCQL := TFluentSQLAST.Create(FDatabase, FRegister);
  FCQL.Clear;
  FExpression := TFluentSQLCriteriaExpression.Create(FCQL.Where.Expression);
  FOperator := TFluentSQLOperators.Create(FDatabase);
end;

destructor TFluentQueryExpression<T>.Destroy;
begin
  FCQL := nil;
  FExpression := nil;
  FOperator := nil;
  FRegister.Free;
  inherited;
end;

function TFluentQueryExpression<T>._CreateOperator(ACompare: TFluentSQLOperatorCompare; AValue: Variant; ADataType: TFluentSQLDataFieldType): IFluentSQLOperator;
begin
  Result := TFluentSQLOperator.Create(FDatabase);
  Result.ColumnName := FCurrentField;
  Result.Compare := ACompare;
  Result.Value := AValue;
  Result.DataType := ADataType;
end;

function TFluentQueryExpression<T>._ConvertIntegersToDoubles(const AValues: TArray<Integer>): TArray<Double>;
var
  LFor: Integer;
begin
  SetLength(Result, Length(AValues));
  for LFor := 0 to Length(AValues) - 1 do
    Result[LFor] := AValues[LFor];
end;

function TFluentQueryExpression<T>.GreaterThan(const AValue: Integer): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.GreaterThan(const AValue: Extended): IFluentQueryExpression;
begin
  FExpression.Ope(FCurrentField + ' ' + FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.GreaterThan(const AValue: TDate): IFluentQueryExpression;
begin
  FExpression.Ope(FCurrentField + ' ' + FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.GreaterThan(const AValue: TDateTime): IFluentQueryExpression;
begin
  FExpression.Ope(FCurrentField + ' ' + FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.LessThan(const AValue: Integer): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.LessThan(const AValue: Extended): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.LessThan(const AValue: TDate): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.LessThan(const AValue: TDateTime): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.Equal(const AValue: Integer): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.Equal(const AValue: Extended): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.Equal(const AValue: string): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(QuotedStr(AValue)));
  Result := Self;
end;

function TFluentQueryExpression<T>.Equal(const AValue: TDate): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.Equal(const AValue: TDateTime): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.Equal(const AValue: TGUID): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.NotEqual(const AValue: Integer): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.NotEqual(const AValue: Extended): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.NotEqual(const AValue: string): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(QuotedStr(AValue)));
  Result := Self;
end;

function TFluentQueryExpression<T>.NotEqual(const AValue: TDate): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.NotEqual(const AValue: TDateTime): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.NotEqual(const AValue: TGUID): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.GreaterThanOrEqual(const AValue: Integer): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.GreaterThanOrEqual(const AValue: Extended): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.GreaterThanOrEqual(const AValue: TDate): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.GreaterThanOrEqual(const AValue: TDateTime): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.LessThanOrEqual(const AValue: Integer): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.LessThanOrEqual(const AValue: Extended): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.LessThanOrEqual(const AValue: TDate): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.LessThanOrEqual(const AValue: TDateTime): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.AndWith(const AFieldName: string): IFluentQueryExpression;
begin
  FExpression.AndOpe(AFieldName);
  Result := Self;
end;

function TFluentQueryExpression<T>.OrWith(const AFieldName: string): IFluentQueryExpression;
begin
  if FIsSubExpression then
  begin
    FExpression.OrOpe(FExpression.AsString);
    FIsSubExpression := False;
  end
  else
    FExpression.OrOpe('');
  FCurrentField := AFieldName;
  Result := Self;
end;

function TFluentQueryExpression<T>.Negate: IFluentQueryExpression;
begin
  FExpression.Ope('NOT (' + FExpression.AsString + ')');
  Result := Self;
end;

function TFluentQueryExpression<T>.SubExpression(const AFieldName: string): IFluentQueryExpression;
begin
  FIsSubExpression := True;
  FCurrentField := AFieldName;
  Result := Self;
end;

function TFluentQueryExpression<T>.InValues(const AValues: TArray<Integer>): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsIn(_ConvertIntegersToDoubles(AValues)));
  Result := Self;
end;

function TFluentQueryExpression<T>.InValues(const AValues: TArray<Double>): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsIn(AValues));
  Result := Self;
end;

function TFluentQueryExpression<T>.InValues(const AValues: TArray<string>): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsIn(AValues));
  Result := Self;
end;

function TFluentQueryExpression<T>.InValues(const AValue: string): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsIn(AValue));
  Result := Self;
end;

function TFluentQueryExpression<T>.NotInValues(const AValues: TArray<Integer>): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotIn(_ConvertIntegersToDoubles(AValues)));
  Result := Self;
end;

function TFluentQueryExpression<T>.NotInValues(const AValues: TArray<Double>): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotIn(AValues));
  Result := Self;
end;

function TFluentQueryExpression<T>.NotInValues(const AValues: TArray<string>): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotIn(AValues));
  Result := Self;
end;

function TFluentQueryExpression<T>.NotInValues(const AValue: string): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotIn(QuotedStr(AValue)));
  Result := Self;
end;

function TFluentQueryExpression<T>.Exists(const AValue: string): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsExists(QuotedStr(AValue)));
  Result := Self;
end;

function TFluentQueryExpression<T>.Field(const AFieldName: string): IFluentQueryExpression;
begin
  FCurrentField := AFieldName;
  FCQL.Where.Expression.Term := FCurrentField;
  Result := Self;
end;

function TFluentQueryExpression<T>.NotExists(const AValue: string): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotExists(QuotedStr(AValue)));
  Result := Self;
end;

function TFluentQueryExpression<T>.IsNull: IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNull);
  Result := Self;
end;

function TFluentQueryExpression<T>.IsNotNull: IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotNull);
  Result := Self;
end;

//function TFluentQueryExpression<T>.AsString: string;
//var
//  LSerialize: IFluentSQLSerialize;
//begin
//  Result := '';
//  LSerialize := FRegister.Serialize(FDatabase);
//  if Assigned(LSerialize) then
//    Result := LSerialize.AsString(FCQL);
//end;

function TFluentQueryExpression<T>.Serialize: string;
begin
  Result := FExpression.Expression.Serialize;
end;

function TFluentQueryExpression<T>.Contains(const AValue: string): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsLikeFull(QuotedStr(AValue)));
  Result := Self;
end;

function TFluentQueryExpression<T>.StartsWith(const AValue: string): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsLikeRight(QuotedStr(AValue)));
  Result := Self;
end;

function TFluentQueryExpression<T>.EndsWith(const AValue: string): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsLikeLeft(QuotedStr(AValue)));
  Result := Self;
end;

function TFluentQueryExpression<T>.Like(const AValue: string): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsLike(QuotedStr(AValue)));
  Result := Self;
end;

function TFluentQueryExpression<T>.NotLike(const AValue: string): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotLike(QuotedStr(AValue)));
  Result := Self;
end;

function TFluentQueryExpression<T>.EqualIgnoreCase(const AValue: string): IFluentQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(UpperCase(QuotedStr(AValue))));
  Result := Self;
end;

end.
