{
  ------------------------------------------------------------------------------
  Colligo
  Lazy Data Manipulation and LINQ-like collection querying library for Delphi and Lazarus.

  SPDX-License-Identifier: MIT
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the MIT License.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ./Colligo.inc}

unit Colligo.Expression;

interface

uses
  SysUtils,
  Variants,
  FluentSQL.Interfaces,
  FluentSQL.Register;

type
  IColligoQueryExpression = interface
    ['{EEC5343B-6FE5-4F2B-A919-E0C201651362}']
    function Field(const AFieldName: string): IColligoQueryExpression;
    function GreaterThan(const AValue: Integer): IColligoQueryExpression; overload;
    function GreaterThan(const AValue: Extended): IColligoQueryExpression; overload;
    function GreaterThan(const AValue: TDate): IColligoQueryExpression; overload;
    function GreaterThan(const AValue: TDateTime): IColligoQueryExpression; overload;
    function LessThan(const AValue: Integer): IColligoQueryExpression; overload;
    function LessThan(const AValue: Extended): IColligoQueryExpression; overload;
    function LessThan(const AValue: TDate): IColligoQueryExpression; overload;
    function LessThan(const AValue: TDateTime): IColligoQueryExpression; overload;
    function Equal(const AValue: Integer): IColligoQueryExpression; overload;
    function Equal(const AValue: Extended): IColligoQueryExpression; overload;
    function Equal(const AValue: string): IColligoQueryExpression; overload;
    function Equal(const AValue: TDate): IColligoQueryExpression; overload;
    function Equal(const AValue: TDateTime): IColligoQueryExpression; overload;
    function Equal(const AValue: TGUID): IColligoQueryExpression; overload;
    function NotEqual(const AValue: Integer): IColligoQueryExpression; overload;
    function NotEqual(const AValue: Extended): IColligoQueryExpression; overload;
    function NotEqual(const AValue: string): IColligoQueryExpression; overload;
    function NotEqual(const AValue: TDate): IColligoQueryExpression; overload;
    function NotEqual(const AValue: TDateTime): IColligoQueryExpression; overload;
    function NotEqual(const AValue: TGUID): IColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: Integer): IColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: Extended): IColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: TDate): IColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: TDateTime): IColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: Integer): IColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: Extended): IColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: TDate): IColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: TDateTime): IColligoQueryExpression; overload;
    function AndWith(const AFieldName: string): IColligoQueryExpression;
    function OrWith(const AFieldName: string): IColligoQueryExpression;
    function Negate: IColligoQueryExpression;
    function SubExpression(const AFieldName: string): IColligoQueryExpression;
    function InValues(const AValues: TArray<Integer>): IColligoQueryExpression; overload;
    function InValues(const AValues: TArray<Double>): IColligoQueryExpression; overload;
    function InValues(const AValues: TArray<string>): IColligoQueryExpression; overload;
    function InValues(const AValue: string): IColligoQueryExpression; overload;
    function NotInValues(const AValues: TArray<Integer>): IColligoQueryExpression; overload;
    function NotInValues(const AValues: TArray<Double>): IColligoQueryExpression; overload;
    function NotInValues(const AValues: TArray<string>): IColligoQueryExpression; overload;
    function NotInValues(const AValue: string): IColligoQueryExpression; overload;
    function Exists(const AValue: string): IColligoQueryExpression;
    function NotExists(const AValue: string): IColligoQueryExpression;
    function IsNull: IColligoQueryExpression;
    function IsNotNull: IColligoQueryExpression;
    function Contains(const AValue: string): IColligoQueryExpression;
    function StartsWith(const AValue: string): IColligoQueryExpression;
    function EndsWith(const AValue: string): IColligoQueryExpression;
    function Like(const AValue: string): IColligoQueryExpression;
    function NotLike(const AValue: string): IColligoQueryExpression;
    function EqualIgnoreCase(const AValue: string): IColligoQueryExpression;
//    function AsString: string;
    function Serialize: string;
  end;

  TColligoQueryExpression<T> = class(TInterfacedObject, IColligoQueryExpression)
  private
    FFluentSQL: IFluentSQLAST;
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
    function Field(const AFieldName: string): IColligoQueryExpression;
    function GreaterThan(const AValue: Integer): IColligoQueryExpression; overload;
    function GreaterThan(const AValue: Extended): IColligoQueryExpression; overload;
    function GreaterThan(const AValue: TDate): IColligoQueryExpression; overload;
    function GreaterThan(const AValue: TDateTime): IColligoQueryExpression; overload;
    function LessThan(const AValue: Integer): IColligoQueryExpression; overload;
    function LessThan(const AValue: Extended): IColligoQueryExpression; overload;
    function LessThan(const AValue: TDate): IColligoQueryExpression; overload;
    function LessThan(const AValue: TDateTime): IColligoQueryExpression; overload;
    function Equal(const AValue: Integer): IColligoQueryExpression; overload;
    function Equal(const AValue: Extended): IColligoQueryExpression; overload;
    function Equal(const AValue: string): IColligoQueryExpression; overload;
    function Equal(const AValue: TDate): IColligoQueryExpression; overload;
    function Equal(const AValue: TDateTime): IColligoQueryExpression; overload;
    function Equal(const AValue: TGUID): IColligoQueryExpression; overload;
    function NotEqual(const AValue: Integer): IColligoQueryExpression; overload;
    function NotEqual(const AValue: Extended): IColligoQueryExpression; overload;
    function NotEqual(const AValue: string): IColligoQueryExpression; overload;
    function NotEqual(const AValue: TDate): IColligoQueryExpression; overload;
    function NotEqual(const AValue: TDateTime): IColligoQueryExpression; overload;
    function NotEqual(const AValue: TGUID): IColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: Integer): IColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: Extended): IColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: TDate): IColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: TDateTime): IColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: Integer): IColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: Extended): IColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: TDate): IColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: TDateTime): IColligoQueryExpression; overload;
    function AndWith(const AFieldName: string): IColligoQueryExpression;
    function OrWith(const AFieldName: string): IColligoQueryExpression;
    function Negate: IColligoQueryExpression;
    function SubExpression(const AFieldName: string): IColligoQueryExpression;
    function InValues(const AValues: TArray<Integer>): IColligoQueryExpression; overload;
    function InValues(const AValues: TArray<Double>): IColligoQueryExpression; overload;
    function InValues(const AValues: TArray<string>): IColligoQueryExpression; overload;
    function InValues(const AValue: string): IColligoQueryExpression; overload;
    function NotInValues(const AValues: TArray<Integer>): IColligoQueryExpression; overload;
    function NotInValues(const AValues: TArray<Double>): IColligoQueryExpression; overload;
    function NotInValues(const AValues: TArray<string>): IColligoQueryExpression; overload;
    function NotInValues(const AValue: string): IColligoQueryExpression; overload;
    function Exists(const AValue: string): IColligoQueryExpression;
    function NotExists(const AValue: string): IColligoQueryExpression;
    function IsNull: IColligoQueryExpression;
    function IsNotNull: IColligoQueryExpression;
    function Contains(const AValue: string): IColligoQueryExpression;
    function StartsWith(const AValue: string): IColligoQueryExpression;
    function EndsWith(const AValue: string): IColligoQueryExpression;
    function Like(const AValue: string): IColligoQueryExpression;
    function NotLike(const AValue: string): IColligoQueryExpression;
    function EqualIgnoreCase(const AValue: string): IColligoQueryExpression;
    function Serialize: string;
//    function AsString: string;
  end;

implementation

uses
  FluentSQL.Expression,
  FluentSQL.Operators,
  FluentSQL.Ast;

constructor TColligoQueryExpression<T>.Create(const ADatabase: TFluentSQLDriver);
begin
  inherited Create;
  FIsSubExpression := False;
  FDatabase := ADatabase;
  FRegister := TFluentSQLRegister.Create;
  FFluentSQL := TFluentSQLAST.Create(FDatabase, FRegister);
  FFluentSQL.Clear;
  FExpression := TFluentSQLCriteriaExpression.Create(FFluentSQL.Where.Expression);
  FOperator := TFluentSQLOperators.Create(FDatabase);
end;

destructor TColligoQueryExpression<T>.Destroy;
begin
  FFluentSQL := nil;
  FExpression := nil;
  FOperator := nil;
  FRegister.Free;
  inherited;
end;

function TColligoQueryExpression<T>._CreateOperator(ACompare: TFluentSQLOperatorCompare; AValue: Variant; ADataType: TFluentSQLDataFieldType): IFluentSQLOperator;
begin
  Result := TFluentSQLOperator.Create(FDatabase);
  Result.ColumnName := FCurrentField;
  Result.Compare := ACompare;
  Result.Value := AValue;
  Result.DataType := ADataType;
end;

function TColligoQueryExpression<T>._ConvertIntegersToDoubles(const AValues: TArray<Integer>): TArray<Double>;
var
  LFor: Integer;
begin
  SetLength(Result, Length(AValues));
  for LFor := 0 to Length(AValues) - 1 do
    Result[LFor] := AValues[LFor];
end;

function TColligoQueryExpression<T>.GreaterThan(const AValue: Integer): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.GreaterThan(const AValue: Extended): IColligoQueryExpression;
begin
  FExpression.Ope(FCurrentField + ' ' + FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.GreaterThan(const AValue: TDate): IColligoQueryExpression;
begin
  FExpression.Ope(FCurrentField + ' ' + FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.GreaterThan(const AValue: TDateTime): IColligoQueryExpression;
begin
  FExpression.Ope(FCurrentField + ' ' + FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.LessThan(const AValue: Integer): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.LessThan(const AValue: Extended): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.LessThan(const AValue: TDate): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.LessThan(const AValue: TDateTime): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.Equal(const AValue: Integer): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.Equal(const AValue: Extended): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.Equal(const AValue: string): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(QuotedStr(AValue)));
  Result := Self;
end;

function TColligoQueryExpression<T>.Equal(const AValue: TDate): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.Equal(const AValue: TDateTime): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.Equal(const AValue: TGUID): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.NotEqual(const AValue: Integer): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.NotEqual(const AValue: Extended): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.NotEqual(const AValue: string): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(QuotedStr(AValue)));
  Result := Self;
end;

function TColligoQueryExpression<T>.NotEqual(const AValue: TDate): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.NotEqual(const AValue: TDateTime): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.NotEqual(const AValue: TGUID): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.GreaterThanOrEqual(const AValue: Integer): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.GreaterThanOrEqual(const AValue: Extended): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.GreaterThanOrEqual(const AValue: TDate): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.GreaterThanOrEqual(const AValue: TDateTime): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.LessThanOrEqual(const AValue: Integer): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.LessThanOrEqual(const AValue: Extended): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.LessThanOrEqual(const AValue: TDate): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.LessThanOrEqual(const AValue: TDateTime): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.AndWith(const AFieldName: string): IColligoQueryExpression;
begin
  FExpression.AndOpe(AFieldName);
  Result := Self;
end;

function TColligoQueryExpression<T>.OrWith(const AFieldName: string): IColligoQueryExpression;
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

function TColligoQueryExpression<T>.Negate: IColligoQueryExpression;
begin
  FExpression.Ope('NOT (' + FExpression.AsString + ')');
  Result := Self;
end;

function TColligoQueryExpression<T>.SubExpression(const AFieldName: string): IColligoQueryExpression;
begin
  FIsSubExpression := True;
  FCurrentField := AFieldName;
  Result := Self;
end;

function TColligoQueryExpression<T>.InValues(const AValues: TArray<Integer>): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsIn(_ConvertIntegersToDoubles(AValues)));
  Result := Self;
end;

function TColligoQueryExpression<T>.InValues(const AValues: TArray<Double>): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsIn(AValues));
  Result := Self;
end;

function TColligoQueryExpression<T>.InValues(const AValues: TArray<string>): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsIn(AValues));
  Result := Self;
end;

function TColligoQueryExpression<T>.InValues(const AValue: string): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsIn(AValue));
  Result := Self;
end;

function TColligoQueryExpression<T>.NotInValues(const AValues: TArray<Integer>): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotIn(_ConvertIntegersToDoubles(AValues)));
  Result := Self;
end;

function TColligoQueryExpression<T>.NotInValues(const AValues: TArray<Double>): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotIn(AValues));
  Result := Self;
end;

function TColligoQueryExpression<T>.NotInValues(const AValues: TArray<string>): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotIn(AValues));
  Result := Self;
end;

function TColligoQueryExpression<T>.NotInValues(const AValue: string): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotIn(QuotedStr(AValue)));
  Result := Self;
end;

function TColligoQueryExpression<T>.Exists(const AValue: string): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsExists(QuotedStr(AValue)));
  Result := Self;
end;

function TColligoQueryExpression<T>.Field(const AFieldName: string): IColligoQueryExpression;
begin
  FCurrentField := AFieldName;
  FFluentSQL.Where.Expression.Term := FCurrentField;
  Result := Self;
end;

function TColligoQueryExpression<T>.NotExists(const AValue: string): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotExists(QuotedStr(AValue)));
  Result := Self;
end;

function TColligoQueryExpression<T>.IsNull: IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNull);
  Result := Self;
end;

function TColligoQueryExpression<T>.IsNotNull: IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotNull);
  Result := Self;
end;

//function TColligoQueryExpression<T>.AsString: string;
//var
//  LSerialize: IFluentSQLSerialize;
//begin
//  Result := '';
//  LSerialize := FRegister.Serialize(FDatabase);
//  if Assigned(LSerialize) then
//    Result := LSerialize.AsString(FFluentSQL);
//end;

function TColligoQueryExpression<T>.Serialize: string;
begin
  Result := FExpression.Expression.Serialize;
end;

function TColligoQueryExpression<T>.Contains(const AValue: string): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLikeFull(QuotedStr(AValue)));
  Result := Self;
end;

function TColligoQueryExpression<T>.StartsWith(const AValue: string): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLikeRight(QuotedStr(AValue)));
  Result := Self;
end;

function TColligoQueryExpression<T>.EndsWith(const AValue: string): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLikeLeft(QuotedStr(AValue)));
  Result := Self;
end;

function TColligoQueryExpression<T>.Like(const AValue: string): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLike(QuotedStr(AValue)));
  Result := Self;
end;

function TColligoQueryExpression<T>.NotLike(const AValue: string): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotLike(QuotedStr(AValue)));
  Result := Self;
end;

function TColligoQueryExpression<T>.EqualIgnoreCase(const AValue: string): IColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(UpperCase(QuotedStr(AValue))));
  Result := Self;
end;

end.



