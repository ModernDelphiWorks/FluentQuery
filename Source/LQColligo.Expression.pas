{
  ------------------------------------------------------------------------------
  LQColligo
  Lazy Data Manipulation and LINQ-like collection querying library for Delphi and Lazarus.

  SPDX-License-Identifier: MIT
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the MIT License.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ./LQColligo.inc}

unit LQColligo.Expression;

interface

uses
  SysUtils,
  Variants,
  FluentSQL.Interfaces,
  FluentSQL.Register;

type
  ILQColligoQueryExpression = interface
    ['{EEC5343B-6FE5-4F2B-A919-E0C201651362}']
    function Field(const AFieldName: string): ILQColligoQueryExpression;
    function GreaterThan(const AValue: Integer): ILQColligoQueryExpression; overload;
    function GreaterThan(const AValue: Extended): ILQColligoQueryExpression; overload;
    function GreaterThan(const AValue: TDate): ILQColligoQueryExpression; overload;
    function GreaterThan(const AValue: TDateTime): ILQColligoQueryExpression; overload;
    function LessThan(const AValue: Integer): ILQColligoQueryExpression; overload;
    function LessThan(const AValue: Extended): ILQColligoQueryExpression; overload;
    function LessThan(const AValue: TDate): ILQColligoQueryExpression; overload;
    function LessThan(const AValue: TDateTime): ILQColligoQueryExpression; overload;
    function Equal(const AValue: Integer): ILQColligoQueryExpression; overload;
    function Equal(const AValue: Extended): ILQColligoQueryExpression; overload;
    function Equal(const AValue: string): ILQColligoQueryExpression; overload;
    function Equal(const AValue: TDate): ILQColligoQueryExpression; overload;
    function Equal(const AValue: TDateTime): ILQColligoQueryExpression; overload;
    function Equal(const AValue: TGUID): ILQColligoQueryExpression; overload;
    function NotEqual(const AValue: Integer): ILQColligoQueryExpression; overload;
    function NotEqual(const AValue: Extended): ILQColligoQueryExpression; overload;
    function NotEqual(const AValue: string): ILQColligoQueryExpression; overload;
    function NotEqual(const AValue: TDate): ILQColligoQueryExpression; overload;
    function NotEqual(const AValue: TDateTime): ILQColligoQueryExpression; overload;
    function NotEqual(const AValue: TGUID): ILQColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: Integer): ILQColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: Extended): ILQColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: TDate): ILQColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: TDateTime): ILQColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: Integer): ILQColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: Extended): ILQColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: TDate): ILQColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: TDateTime): ILQColligoQueryExpression; overload;
    function AndWith(const AFieldName: string): ILQColligoQueryExpression;
    function OrWith(const AFieldName: string): ILQColligoQueryExpression;
    function Negate: ILQColligoQueryExpression;
    function SubExpression(const AFieldName: string): ILQColligoQueryExpression;
    function InValues(const AValues: TArray<Integer>): ILQColligoQueryExpression; overload;
    function InValues(const AValues: TArray<Double>): ILQColligoQueryExpression; overload;
    function InValues(const AValues: TArray<string>): ILQColligoQueryExpression; overload;
    function InValues(const AValue: string): ILQColligoQueryExpression; overload;
    function NotInValues(const AValues: TArray<Integer>): ILQColligoQueryExpression; overload;
    function NotInValues(const AValues: TArray<Double>): ILQColligoQueryExpression; overload;
    function NotInValues(const AValues: TArray<string>): ILQColligoQueryExpression; overload;
    function NotInValues(const AValue: string): ILQColligoQueryExpression; overload;
    function Exists(const AValue: string): ILQColligoQueryExpression;
    function NotExists(const AValue: string): ILQColligoQueryExpression;
    function IsNull: ILQColligoQueryExpression;
    function IsNotNull: ILQColligoQueryExpression;
    function Contains(const AValue: string): ILQColligoQueryExpression;
    function StartsWith(const AValue: string): ILQColligoQueryExpression;
    function EndsWith(const AValue: string): ILQColligoQueryExpression;
    function Like(const AValue: string): ILQColligoQueryExpression;
    function NotLike(const AValue: string): ILQColligoQueryExpression;
    function EqualIgnoreCase(const AValue: string): ILQColligoQueryExpression;
//    function AsString: string;
    function Serialize: string;
  end;

  TLQColligoQueryExpression<T> = class(TInterfacedObject, ILQColligoQueryExpression)
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
    function Field(const AFieldName: string): ILQColligoQueryExpression;
    function GreaterThan(const AValue: Integer): ILQColligoQueryExpression; overload;
    function GreaterThan(const AValue: Extended): ILQColligoQueryExpression; overload;
    function GreaterThan(const AValue: TDate): ILQColligoQueryExpression; overload;
    function GreaterThan(const AValue: TDateTime): ILQColligoQueryExpression; overload;
    function LessThan(const AValue: Integer): ILQColligoQueryExpression; overload;
    function LessThan(const AValue: Extended): ILQColligoQueryExpression; overload;
    function LessThan(const AValue: TDate): ILQColligoQueryExpression; overload;
    function LessThan(const AValue: TDateTime): ILQColligoQueryExpression; overload;
    function Equal(const AValue: Integer): ILQColligoQueryExpression; overload;
    function Equal(const AValue: Extended): ILQColligoQueryExpression; overload;
    function Equal(const AValue: string): ILQColligoQueryExpression; overload;
    function Equal(const AValue: TDate): ILQColligoQueryExpression; overload;
    function Equal(const AValue: TDateTime): ILQColligoQueryExpression; overload;
    function Equal(const AValue: TGUID): ILQColligoQueryExpression; overload;
    function NotEqual(const AValue: Integer): ILQColligoQueryExpression; overload;
    function NotEqual(const AValue: Extended): ILQColligoQueryExpression; overload;
    function NotEqual(const AValue: string): ILQColligoQueryExpression; overload;
    function NotEqual(const AValue: TDate): ILQColligoQueryExpression; overload;
    function NotEqual(const AValue: TDateTime): ILQColligoQueryExpression; overload;
    function NotEqual(const AValue: TGUID): ILQColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: Integer): ILQColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: Extended): ILQColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: TDate): ILQColligoQueryExpression; overload;
    function GreaterThanOrEqual(const AValue: TDateTime): ILQColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: Integer): ILQColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: Extended): ILQColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: TDate): ILQColligoQueryExpression; overload;
    function LessThanOrEqual(const AValue: TDateTime): ILQColligoQueryExpression; overload;
    function AndWith(const AFieldName: string): ILQColligoQueryExpression;
    function OrWith(const AFieldName: string): ILQColligoQueryExpression;
    function Negate: ILQColligoQueryExpression;
    function SubExpression(const AFieldName: string): ILQColligoQueryExpression;
    function InValues(const AValues: TArray<Integer>): ILQColligoQueryExpression; overload;
    function InValues(const AValues: TArray<Double>): ILQColligoQueryExpression; overload;
    function InValues(const AValues: TArray<string>): ILQColligoQueryExpression; overload;
    function InValues(const AValue: string): ILQColligoQueryExpression; overload;
    function NotInValues(const AValues: TArray<Integer>): ILQColligoQueryExpression; overload;
    function NotInValues(const AValues: TArray<Double>): ILQColligoQueryExpression; overload;
    function NotInValues(const AValues: TArray<string>): ILQColligoQueryExpression; overload;
    function NotInValues(const AValue: string): ILQColligoQueryExpression; overload;
    function Exists(const AValue: string): ILQColligoQueryExpression;
    function NotExists(const AValue: string): ILQColligoQueryExpression;
    function IsNull: ILQColligoQueryExpression;
    function IsNotNull: ILQColligoQueryExpression;
    function Contains(const AValue: string): ILQColligoQueryExpression;
    function StartsWith(const AValue: string): ILQColligoQueryExpression;
    function EndsWith(const AValue: string): ILQColligoQueryExpression;
    function Like(const AValue: string): ILQColligoQueryExpression;
    function NotLike(const AValue: string): ILQColligoQueryExpression;
    function EqualIgnoreCase(const AValue: string): ILQColligoQueryExpression;
    function Serialize: string;
//    function AsString: string;
  end;

implementation

uses
  FluentSQL.Expression,
  FluentSQL.Operators,
  FluentSQL.Ast;

constructor TLQColligoQueryExpression<T>.Create(const ADatabase: TFluentSQLDriver);
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

destructor TLQColligoQueryExpression<T>.Destroy;
begin
  FFluentSQL := nil;
  FExpression := nil;
  FOperator := nil;
  FRegister.Free;
  inherited;
end;

function TLQColligoQueryExpression<T>._CreateOperator(ACompare: TFluentSQLOperatorCompare; AValue: Variant; ADataType: TFluentSQLDataFieldType): IFluentSQLOperator;
begin
  Result := TFluentSQLOperator.Create(FDatabase);
  Result.ColumnName := FCurrentField;
  Result.Compare := ACompare;
  Result.Value := AValue;
  Result.DataType := ADataType;
end;

function TLQColligoQueryExpression<T>._ConvertIntegersToDoubles(const AValues: TArray<Integer>): TArray<Double>;
var
  LFor: Integer;
begin
  SetLength(Result, Length(AValues));
  for LFor := 0 to Length(AValues) - 1 do
    Result[LFor] := AValues[LFor];
end;

function TLQColligoQueryExpression<T>.GreaterThan(const AValue: Integer): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.GreaterThan(const AValue: Extended): ILQColligoQueryExpression;
begin
  FExpression.Ope(FCurrentField + ' ' + FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.GreaterThan(const AValue: TDate): ILQColligoQueryExpression;
begin
  FExpression.Ope(FCurrentField + ' ' + FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.GreaterThan(const AValue: TDateTime): ILQColligoQueryExpression;
begin
  FExpression.Ope(FCurrentField + ' ' + FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.LessThan(const AValue: Integer): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.LessThan(const AValue: Extended): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.LessThan(const AValue: TDate): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.LessThan(const AValue: TDateTime): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.Equal(const AValue: Integer): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.Equal(const AValue: Extended): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.Equal(const AValue: string): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(QuotedStr(AValue)));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.Equal(const AValue: TDate): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.Equal(const AValue: TDateTime): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.Equal(const AValue: TGUID): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.NotEqual(const AValue: Integer): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.NotEqual(const AValue: Extended): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.NotEqual(const AValue: string): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(QuotedStr(AValue)));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.NotEqual(const AValue: TDate): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.NotEqual(const AValue: TDateTime): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.NotEqual(const AValue: TGUID): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.GreaterThanOrEqual(const AValue: Integer): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.GreaterThanOrEqual(const AValue: Extended): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.GreaterThanOrEqual(const AValue: TDate): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.GreaterThanOrEqual(const AValue: TDateTime): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.LessThanOrEqual(const AValue: Integer): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.LessThanOrEqual(const AValue: Extended): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.LessThanOrEqual(const AValue: TDate): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.LessThanOrEqual(const AValue: TDateTime): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.AndWith(const AFieldName: string): ILQColligoQueryExpression;
begin
  FExpression.AndOpe(AFieldName);
  Result := Self;
end;

function TLQColligoQueryExpression<T>.OrWith(const AFieldName: string): ILQColligoQueryExpression;
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

function TLQColligoQueryExpression<T>.Negate: ILQColligoQueryExpression;
begin
  FExpression.Ope('NOT (' + FExpression.AsString + ')');
  Result := Self;
end;

function TLQColligoQueryExpression<T>.SubExpression(const AFieldName: string): ILQColligoQueryExpression;
begin
  FIsSubExpression := True;
  FCurrentField := AFieldName;
  Result := Self;
end;

function TLQColligoQueryExpression<T>.InValues(const AValues: TArray<Integer>): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsIn(_ConvertIntegersToDoubles(AValues)));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.InValues(const AValues: TArray<Double>): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsIn(AValues));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.InValues(const AValues: TArray<string>): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsIn(AValues));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.InValues(const AValue: string): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsIn(AValue));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.NotInValues(const AValues: TArray<Integer>): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotIn(_ConvertIntegersToDoubles(AValues)));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.NotInValues(const AValues: TArray<Double>): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotIn(AValues));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.NotInValues(const AValues: TArray<string>): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotIn(AValues));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.NotInValues(const AValue: string): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotIn(QuotedStr(AValue)));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.Exists(const AValue: string): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsExists(QuotedStr(AValue)));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.Field(const AFieldName: string): ILQColligoQueryExpression;
begin
  FCurrentField := AFieldName;
  FFluentSQL.Where.Expression.Term := FCurrentField;
  Result := Self;
end;

function TLQColligoQueryExpression<T>.NotExists(const AValue: string): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotExists(QuotedStr(AValue)));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.IsNull: ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNull);
  Result := Self;
end;

function TLQColligoQueryExpression<T>.IsNotNull: ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotNull);
  Result := Self;
end;

//function TLQColligoQueryExpression<T>.AsString: string;
//var
//  LSerialize: IFluentSQLSerialize;
//begin
//  Result := '';
//  LSerialize := FRegister.Serialize(FDatabase);
//  if Assigned(LSerialize) then
//    Result := LSerialize.AsString(FFluentSQL);
//end;

function TLQColligoQueryExpression<T>.Serialize: string;
begin
  Result := FExpression.Expression.Serialize;
end;

function TLQColligoQueryExpression<T>.Contains(const AValue: string): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLikeFull(QuotedStr(AValue)));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.StartsWith(const AValue: string): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLikeRight(QuotedStr(AValue)));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.EndsWith(const AValue: string): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLikeLeft(QuotedStr(AValue)));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.Like(const AValue: string): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsLike(QuotedStr(AValue)));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.NotLike(const AValue: string): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsNotLike(QuotedStr(AValue)));
  Result := Self;
end;

function TLQColligoQueryExpression<T>.EqualIgnoreCase(const AValue: string): ILQColligoQueryExpression;
begin
  FExpression.Ope(FOperator.IsEqual(UpperCase(QuotedStr(AValue))));
  Result := Self;
end;

end.



