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

unit Fluent.Query.Provider;

interface

uses
  Rtti,
  Math,
  TypInfo,
  Classes,
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  CQuery.Operators,
  CQuery.Functions,
  CQuery.Interfaces,
  CQuery.Cases,
  CQuery.Select,
  CQuery.Utils,
  CQuery.Serialize,
  CQuery.Qualifier,
  CQuery.Ast,
  CQuery.Name,
  CQuery.Expression,
  CQuery.Register,
  DBEngine.FactoryInterfaces,
  System.Fluent,
  System.Fluent.Core,
  System.Fluent.Queryable,
  System.Fluent.Expression;

type
  TFluentQueryProvider<T> = class(TInterfacedObject, IFluentQueryProvider<T>)
  private
    FCQL: ICQueryAST;
    FConnection: IDBConnection;
    FDatabase: TDBEngineDriver;
    FOperator: ICQueryOperators;
    FFunction: ICQueryFunctions;
    FActiveExpr: ICQueryCriteriaExpression;
    FActiveValues: ICQueryNameValuePairs;
    FRegister: TCQueryRegister;
    FIsObject: Boolean;
    FSavedColumns: ICQueryNames;
    function _CreateJoin(AJoinType: TJoinType; const ATableName: String): IFluentQueryProvider<T>;
    function _GetDriverDatabase: TCQueryDriver;
    procedure _InitializeConnection(const AInitializer: TConnectionInitializer); overload;
    procedure _InitializeConnection(const ADriver: TDBEngineDriver; const AConnection: IDBConnection); overload;
    function _GetCQuery: ICQueryAST;
    procedure _SetCQuery(const Value: ICQueryAST);
  strict private
    constructor Create; overload;
    constructor Create(const AInitializer: TConnectionInitializer); overload;
    constructor Create(const ADriver: TDBEngineDriver; const AConnection: IDBConnection; const ACQL: ICQueryAST = nil); overload;
    destructor Destroy; override;
  public
    type
      TStrictPrivateCreate<T> = class
      public
        class function CreateProvider(const AInitializer: TConnectionInitializer): TFluentQueryProvider<T>; overload; static;
        class function CreateProvider(const ADriver: TDBEngineDriver; const AConnection: IDBConnection; const ACQL: ICQueryAST = nil): TFluentQueryProvider<T>; overload; static;
      end;
  public
    function AndOpe(const AExpression: array of const): IFluentQueryProvider<T>; overload;
    function AndOpe(const AExpression: string): IFluentQueryProvider<T>; overload;
    function Alias(const AAlias: string): IFluentQueryProvider<T>;
    function Clear: IFluentQueryProvider<T>;
    function ClearAll: IFluentQueryProvider<T>;
    function All: IFluentQueryProvider<T>;
    function Column(const AColumnName: string = ''): IFluentQueryProvider<T>; overload;
    function Column(const ATableName: string; const AColumnName: string): IFluentQueryProvider<T>; overload;
    function Column(const AColumnsName: array of const): IFluentQueryProvider<T>; overload;
    function Delete: IFluentQueryProvider<T>;
    function Desc: IFluentQueryProvider<T>;
    function DistinctSQL: IFluentQueryProvider<T>;
    function IsEmpty: Boolean;
    function Select(const AColumns: string = ''): IFluentQueryProvider<T>; overload;
    function From(const ATableName: string): IFluentQueryProvider<T>; overload;
    function From(const ATableName: string; const AAlias: string): IFluentQueryProvider<T>; overload;
    function GroupBy(const AColumnName: string = ''): IFluentQueryProvider<T>;
    function Having(const AExpression: string = ''): IFluentQueryProvider<T>; overload;
    function Having(const AExpression: array of const): IFluentQueryProvider<T>; overload;
    function Insert: IFluentQueryProvider<T>;
    function Into(const ATableName: string): IFluentQueryProvider<T>;
    function FullJoin(const ATableName: string): IFluentQueryProvider<T>; overload;
    function InnerJoin(const ATableName: string): IFluentQueryProvider<T>; overload;
    function LeftJoin(const ATableName: string): IFluentQueryProvider<T>; overload;
    function RightJoin(const ATableName: string): IFluentQueryProvider<T>; overload;
    function FullJoin(const ATableName: string; const AAlias: string): IFluentQueryProvider<T>; overload;
    function InnerJoin(const ATableName: string; const AAlias: string): IFluentQueryProvider<T>; overload;
    function LeftJoin(const ATableName: string; const AAlias: string): IFluentQueryProvider<T>; overload;
    function RightJoin(const ATableName: string; const AAlias: string): IFluentQueryProvider<T>; overload;
    function OnCond(const AExpression: string): IFluentQueryProvider<T>; overload;
    function OnCond(const AExpression: array of const): IFluentQueryProvider<T>; overload;
    function OrOpe(const AExpression: array of const): IFluentQueryProvider<T>; overload;
    function OrOpe(const AExpression: string): IFluentQueryProvider<T>; overload;
    function OrderBy(const AColumnName: string = ''): IFluentQueryProvider<T>;
    function SetValue(const AColumnName, AColumnValue: string): IFluentQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; AColumnValue: Integer): IFluentQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; AColumnValue: Extended; ADecimalPlaces: Integer): IFluentQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; AColumnValue: Double; ADecimalPlaces: Integer): IFluentQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; AColumnValue: Currency; ADecimalPlaces: Integer): IFluentQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; const AColumnValue: array of const): IFluentQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; const AColumnValue: TDate): IFluentQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; const AColumnValue: TDateTime): IFluentQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; const AColumnValue: TGUID): IFluentQueryProvider<T>; overload;
    function Values(const AColumnName, AColumnValue: string): IFluentQueryProvider<T>; overload;
    function Values(const AColumnName: string; const AColumnValue: array of const): IFluentQueryProvider<T>; overload;
    function First(const AValue: Integer): IFluentQueryProvider<T>;
    function Skip(const AValue: Integer): IFluentQueryProvider<T>;
    function Update(const ATableName: string): IFluentQueryProvider<T>;
    function Where(const AExpression: string = ''): IFluentQueryProvider<T>; overload;
    function Where(const AExpression: array of const): IFluentQueryProvider<T>; overload;
    function Equal(const AValue: string = ''): IFluentQueryProvider<T>; overload;
    function Equal(const AValue: Extended): IFluentQueryProvider<T>; overload;
    function Equal(const AValue: Integer): IFluentQueryProvider<T>; overload;
    function Equal(const AValue: TDate): IFluentQueryProvider<T>; overload;
    function Equal(const AValue: TDateTime): IFluentQueryProvider<T>; overload;
    function Equal(const AValue: TGUID): IFluentQueryProvider<T>; overload;
    function NotEqual(const AValue: string = ''): IFluentQueryProvider<T>; overload;
    function NotEqual(const AValue: Extended): IFluentQueryProvider<T>; overload;
    function NotEqual(const AValue: Integer): IFluentQueryProvider<T>; overload;
    function NotEqual(const AValue: TDate): IFluentQueryProvider<T>; overload;
    function NotEqual(const AValue: TDateTime): IFluentQueryProvider<T>; overload;
    function NotEqual(const AValue: TGUID): IFluentQueryProvider<T>; overload;
    function GreaterThan(const AValue: Extended): IFluentQueryProvider<T>; overload;
    function GreaterThan(const AValue: Integer): IFluentQueryProvider<T>; overload;
    function GreaterThan(const AValue: TDate): IFluentQueryProvider<T>; overload;
    function GreaterThan(const AValue: TDateTime): IFluentQueryProvider<T>; overload;
    function GreaterEqThan(const AValue: Extended): IFluentQueryProvider<T>; overload;
    function GreaterEqThan(const AValue: Integer): IFluentQueryProvider<T>; overload;
    function GreaterEqThan(const AValue: TDate): IFluentQueryProvider<T>; overload;
    function GreaterEqThan(const AValue: TDateTime): IFluentQueryProvider<T>; overload;
    function LessThan(const AValue: Extended): IFluentQueryProvider<T>; overload;
    function LessThan(const AValue: Integer): IFluentQueryProvider<T>; overload;
    function LessThan(const AValue: TDate): IFluentQueryProvider<T>; overload;
    function LessThan(const AValue: TDateTime): IFluentQueryProvider<T>; overload;
    function LessEqThan(const AValue: Extended): IFluentQueryProvider<T>; overload;
    function LessEqThan(const AValue: Integer): IFluentQueryProvider<T>; overload;
    function LessEqThan(const AValue: TDate): IFluentQueryProvider<T>; overload;
    function LessEqThan(const AValue: TDateTime): IFluentQueryProvider<T>; overload;
    function IsNull: IFluentQueryProvider<T>;
    function IsNotNull: IFluentQueryProvider<T>;
    function Like(const AValue: string): IFluentQueryProvider<T>;
    function LikeFull(const AValue: string): IFluentQueryProvider<T>;
    function LikeLeft(const AValue: string): IFluentQueryProvider<T>;
    function LikeRight(const AValue: string): IFluentQueryProvider<T>;
    function NotLike(const AValue: string): IFluentQueryProvider<T>;
    function NotLikeFull(const AValue: string): IFluentQueryProvider<T>;
    function NotLikeLeft(const AValue: string): IFluentQueryProvider<T>;
    function NotLikeRight(const AValue: string): IFluentQueryProvider<T>;
    function InValues(const AValue: TArray<Double>): IFluentQueryProvider<T>; overload;
    function InValues(const AValue: TArray<string>): IFluentQueryProvider<T>; overload;
    function InValues(const AValue: string): IFluentQueryProvider<T>; overload;
    function NotIn(const AValue: TArray<Double>): IFluentQueryProvider<T>; overload;
    function NotIn(const AValue: TArray<string>): IFluentQueryProvider<T>; overload;
    function NotIn(const AValue: string): IFluentQueryProvider<T>; overload;
    function Exists(const AValue: string): IFluentQueryProvider<T>;
    function NotExists(const AValue: string): IFluentQueryProvider<T>;
    function Count: IFluentQueryProvider<T>;
    function Lower: IFluentQueryProvider<T>;
    function Min: IFluentQueryProvider<T>; overload;
    function Max: IFluentQueryProvider<T>;
    function Upper: IFluentQueryProvider<T>;
    function SubString(const AStart: Integer; const ALength: Integer): IFluentQueryProvider<T>;
    function Date(const AValue: string): IFluentQueryProvider<T>;
    function Day(const AValue: string): IFluentQueryProvider<T>;
    function Month(const AValue: string): IFluentQueryProvider<T>;
    function Year(const AValue: string): IFluentQueryProvider<T>;
    function Concat(const AValue: array of string): IFluentQueryProvider<T>;
    function Sum(const AColumn: string; const AAlias: string = ''): IFluentQueryProvider<T>;
    function Average(const AColumn: string; const AAlias: string = ''): IFluentQueryProvider<T>;
    function ToArray: IFluentArray<T>;
    function ToList: IFluentList<T>;
    function AsString: string;
    function Database: TDBEngineDriver;
    function Connection: IDBConnection;
  end;

implementation

uses
  System.Fluent.Parse;

constructor TFluentQueryProvider<T>.Create(const AInitializer: TConnectionInitializer);
begin
  inherited Create;
  _InitializeConnection(AInitializer);
  FRegister := TCQueryRegister.Create;
  FOperator := TCQueryOperators.Create(_GetDriverDatabase);
  FFunction := TCQueryFunctions.Create(_GetDriverDatabase, FRegister);
  FCQL := TCQueryAST.Create(_GetDriverDatabase, FRegister);
  FCQL.Clear;
  FIsObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
  FSavedColumns := TCQueryNames.Create;
end;

constructor TFluentQueryProvider<T>.Create(const ADriver: TDBEngineDriver;
  const AConnection: IDBConnection; const ACQL: ICQueryAST);
begin
  inherited Create;
  _InitializeConnection(ADriver, AConnection);
  FRegister := TCQueryRegister.Create;
  FOperator := TCQueryOperators.Create(_GetDriverDatabase);
  FFunction := TCQueryFunctions.Create(_GetDriverDatabase, FRegister);
  FCQL := ACQL;
  if FCQL = nil then
  begin
    FCQL := TCQueryAST.Create(_GetDriverDatabase, FRegister);
    FCQL.Clear;
  end;
  FIsObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
  FSavedColumns := TCQueryNames.Create;
end;

constructor TFluentQueryProvider<T>.Create;
begin
  raise Exception.CreateFmt(
    'Class %s cannot be instantiated directly using Create. ' +
    'Please use an appropriate factory method.', [Self.ClassName]
  );
end;

destructor TFluentQueryProvider<T>.Destroy;
begin
  FCQL := nil;
  FActiveExpr := nil;
  FActiveValues := nil;
  FOperator := nil;
  FFunction := nil;
  FSavedColumns := nil;
  FRegister.Free;
  inherited;
end;

function TFluentQueryProvider<T>.AndOpe(const AExpression: array of const): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.AndOpe(TUtils.SqlParamsToStr(AExpression));
  Result := Self;
end;

function TFluentQueryProvider<T>.AndOpe(const AExpression: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.AndOpe(AExpression);
  Result := Self;
end;

function TFluentQueryProvider<T>.Alias(const AAlias: string): IFluentQueryProvider<T>;
begin
  if FCQL.Select.TableNames.Count > 0 then
    FCQL.Select.TableNames[FCQL.Select.TableNames.Count - 1].Alias := AAlias
  else if FCQL.Joins.Count > 0 then
    FCQL.Joins[FCQL.Joins.Count - 1].JoinedTable.Alias := AAlias;
  Result := Self;
end;

function TFluentQueryProvider<T>.Clear: IFluentQueryProvider<T>;
begin
  FCQL.Clear;
  FSavedColumns.Clear;
  Result := Self;
end;

function TFluentQueryProvider<T>.ClearAll: IFluentQueryProvider<T>;
begin
  FCQL.Clear;
  FSavedColumns.Clear;
  Result := Self;
end;

function TFluentQueryProvider<T>.All: IFluentQueryProvider<T>;
begin
  FCQL.Select.Columns.Clear;
  FCQL.Select.Columns.Add.Name := '*';
  FSavedColumns.Clear;
  FSavedColumns.Add.Name := '*';
  Result := Self;
end;

function TFluentQueryProvider<T>.Column(const AColumnName: string = ''): IFluentQueryProvider<T>;
begin
  FCQL.Select.Columns.Add.Name := AColumnName;
  FSavedColumns.Add.Name := AColumnName;
  Result := Self;
end;

function TFluentQueryProvider<T>.Column(const ATableName: string; const AColumnName: string): IFluentQueryProvider<T>;
begin
  Result := Column(ATableName + '.' + AColumnName);
end;

function TFluentQueryProvider<T>.Column(const AColumnsName: array of const): IFluentQueryProvider<T>;
begin
  Result := Column(TUtils.SqlParamsToStr(AColumnsName));
end;

function TFluentQueryProvider<T>.Delete: IFluentQueryProvider<T>;
begin
  FCQL.Delete.TableNames.Clear;
  Result := Self;
end;

function TFluentQueryProvider<T>.Desc: IFluentQueryProvider<T>;
begin
  if FCQL.OrderBy.Columns.Count > 0 then
    (FCQL.OrderBy.Columns[FCQL.OrderBy.Columns.Count - 1] as ICQueryOrderByColumn).Direction := dirDescending;
  Result := Self;
end;

function TFluentQueryProvider<T>.DistinctSQL: IFluentQueryProvider<T>;
var
  LQualifier: ICQuerySelectQualifier;
begin
  LQualifier := FCQL.Select.Qualifiers.Add;
  LQualifier.Qualifier := sqDistinct;
  Result := Self;
end;

function TFluentQueryProvider<T>.IsEmpty: Boolean;
begin
  Result := FCQL.IsEmpty;
end;

function TFluentQueryProvider<T>.Select(const AColumns: string = ''): IFluentQueryProvider<T>;
var
  LColumns: TArray<string>;
  I: Integer;
begin
  FCQL.Select.Columns.Clear;
  FSavedColumns.Clear;
  if AColumns = '' then
  begin
    FCQL.Select.Columns.Add.Name := '*';
    FSavedColumns.Add.Name := '*';
  end
  else
  begin
    LColumns := AColumns.Split([', ']);
    for I := 0 to High(LColumns) do
    begin
      FCQL.Select.Columns.Add.Name := LColumns[I];
      FSavedColumns.Add.Name := LColumns[I];
    end;
  end;
  Result := Self;
end;

function TFluentQueryProvider<T>.From(const ATableName: string): IFluentQueryProvider<T>;
begin
  FCQL.Select.TableNames.Clear;
  FCQL.Select.TableNames.Add.Name := ATableName;
  Result := Self;
end;

function TFluentQueryProvider<T>.From(const ATableName: string; const AAlias: string): IFluentQueryProvider<T>;
begin
  FCQL.Select.TableNames.Clear;
  FCQL.Select.TableNames.Add.Name := ATableName;
  FCQL.Select.TableNames[0].Alias := AAlias;
  Result := Self;
end;

function TFluentQueryProvider<T>.GroupBy(const AColumnName: string = ''): IFluentQueryProvider<T>;
begin
  FCQL.GroupBy.Columns.Clear;
  if AColumnName <> '' then
    FCQL.GroupBy.Columns.Add.Name := AColumnName;
  Result := Self;
end;

function TFluentQueryProvider<T>.Having(const AExpression: string = ''): IFluentQueryProvider<T>;
begin
  FCQL.Having.Expression.Clear;
  if AExpression <> '' then
    FCQL.Having.Expression.Term := AExpression;
  Result := Self;
end;

function TFluentQueryProvider<T>.Having(const AExpression: array of const): IFluentQueryProvider<T>;
begin
  Result := Having(TUtils.SqlParamsToStr(AExpression));
end;

function TFluentQueryProvider<T>.Insert: IFluentQueryProvider<T>;
begin
  FCQL.Insert.Columns.Clear;
  FActiveValues := FCQL.Insert.Values;
  Result := Self;
end;

function TFluentQueryProvider<T>.Into(const ATableName: string): IFluentQueryProvider<T>;
begin
  FCQL.Insert.TableName := ATableName;
  Result := Self;
end;

function TFluentQueryProvider<T>.FullJoin(const ATableName: string): IFluentQueryProvider<T>;
begin
  Result := _CreateJoin(jtFULL, ATableName);
end;

function TFluentQueryProvider<T>.InnerJoin(const ATableName: string): IFluentQueryProvider<T>;
begin
  Result := _CreateJoin(jtINNER, ATableName);
end;

function TFluentQueryProvider<T>.LeftJoin(const ATableName: string): IFluentQueryProvider<T>;
begin
  Result := _CreateJoin(jtLEFT, ATableName);
end;

function TFluentQueryProvider<T>.RightJoin(const ATableName: string): IFluentQueryProvider<T>;
begin
  Result := _CreateJoin(jtRIGHT, ATableName);
end;

function TFluentQueryProvider<T>.FullJoin(const ATableName: string; const AAlias: string): IFluentQueryProvider<T>;
begin
  FullJoin(ATableName);
  FCQL.Joins[FCQL.Joins.Count - 1].JoinedTable.Alias := AAlias;
  Result := Self;
end;

function TFluentQueryProvider<T>.InnerJoin(const ATableName: string; const AAlias: string): IFluentQueryProvider<T>;
begin
  InnerJoin(ATableName);
  FCQL.Joins[FCQL.Joins.Count - 1].JoinedTable.Alias := AAlias;
  Result := Self;
end;

function TFluentQueryProvider<T>.LeftJoin(const ATableName: string; const AAlias: string): IFluentQueryProvider<T>;
begin
  LeftJoin(ATableName);
  FCQL.Joins[FCQL.Joins.Count - 1].JoinedTable.Alias := AAlias;
  Result := Self;
end;

function TFluentQueryProvider<T>.RightJoin(const ATableName: string; const AAlias: string): IFluentQueryProvider<T>;
begin
  RightJoin(ATableName);
  FCQL.Joins[FCQL.Joins.Count - 1].JoinedTable.Alias := AAlias;
  Result := Self;
end;

function TFluentQueryProvider<T>._CreateJoin(AJoinType: TJoinType; const ATableName: String): IFluentQueryProvider<T>;
var
  LJoin: ICQueryJoin;
begin
  LJoin := FCQL.Joins.Add;
  LJoin.JoinType := AJoinType;
  LJoin.JoinedTable.Name := ATableName;
  FActiveExpr := TCQueryCriteriaExpression.Create(LJoin.Condition);
  Result := Self;
end;

function TFluentQueryProvider<T>._GetCQuery: ICQueryAST;
begin
  Result := FCQL;
end;

function TFluentQueryProvider<T>._GetDriverDatabase: TCQueryDriver;
begin
  case FDatabase of
    dnMSSQL: Result := dbnMSSQL;
    dnMySQL: Result := dbnMySQL;
    dnFirebird: Result := dbnFirebird;
    dnSQLite: Result := dbnSQLite;
    dnInterbase: Result := dbnInterbase;
    dnDB2: Result := dbnDB2;
    dnOracle: Result := dbnOracle;
    dnInformix: Result := dbnInformix;
    dnPostgreSQL: Result := dbnPostgreSQL;
    dnADS: Result := dbnADS;
    dnASA: Result := dbnASA;
    dnAbsoluteDB: Result := dbnAbsoluteDB;
    dnMongoDB: Result := dbnMongoDB;
    dnElevateDB: Result := dbnElevateDB;
    dnNexusDB: Result := dbnNexusDB;
  end;
end;

procedure TFluentQueryProvider<T>._InitializeConnection(const ADriver: TDBEngineDriver;
  const AConnection: IDBConnection);
begin
  if AConnection = nil then
    raise EArgumentNilException.Create('Connection cannot be nil');
  if TStrDBEngineDriver[ADriver] = '' then
    raise EArgumentNilException.Create('Database type must be specified');

  FDatabase := ADriver;
  FConnection := AConnection;
end;

procedure TFluentQueryProvider<T>._SetCQuery(const Value: ICQueryAST);
begin
  FCQL := Value;
end;

procedure TFluentQueryProvider<T>._InitializeConnection(const AInitializer: TConnectionInitializer);
begin
  if not Assigned(AInitializer) then
    raise EArgumentNilException.Create('Connection initializer cannot be nil');

  AInitializer(FDatabase, FConnection);

  if FConnection = nil then
    raise EInvalidOperation.Create('Connection cannot be nil');
  if TStrDBEngineDriver[FDatabase] = '' then
    raise EInvalidOperation.Create('Database type must be specified');
end;

function TFluentQueryProvider<T>.OnCond(const AExpression: string): IFluentQueryProvider<T>;
begin
  if FCQL.Joins.Count > 0 then
    FActiveExpr.AndOpe(AExpression);
  Result := Self;
end;

function TFluentQueryProvider<T>.OnCond(const AExpression: array of const): IFluentQueryProvider<T>;
begin
  Result := OnCond(TUtils.SqlParamsToStr(AExpression));
end;

function TFluentQueryProvider<T>.OrOpe(const AExpression: array of const): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.OrOpe(TUtils.SqlParamsToStr(AExpression));
  Result := Self;
end;

function TFluentQueryProvider<T>.OrOpe(const AExpression: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.OrOpe(AExpression);
  Result := Self;
end;

function TFluentQueryProvider<T>.OrderBy(const AColumnName: string = ''): IFluentQueryProvider<T>;
begin
  FCQL.OrderBy.Columns.Clear;
  if AColumnName <> '' then
    FCQL.OrderBy.Columns.Add.Name := AColumnName;
  Result := Self;
end;

function TFluentQueryProvider<T>.SetValue(const AColumnName, AColumnValue: string): IFluentQueryProvider<T>;
var
  LPair: ICQueryNameValue;
begin
  if Assigned(FActiveValues) then
  begin
    LPair := FActiveValues.Add;
    LPair.Name := AColumnName;
    LPair.Value := QuotedStr(AColumnValue);
  end;
  Result := Self;
end;

function TFluentQueryProvider<T>.SetValue(const AColumnName: string; AColumnValue: Integer): IFluentQueryProvider<T>;
begin
  Result := SetValue(AColumnName, IntToStr(AColumnValue));
end;

function TFluentQueryProvider<T>.SetValue(const AColumnName: string; AColumnValue: Extended; ADecimalPlaces: Integer): IFluentQueryProvider<T>;
var
  LFormat: TFormatSettings;
begin
  LFormat.DecimalSeparator := '.';
  Result := SetValue(AColumnName, Format('%.' + IntToStr(ADecimalPlaces) + 'f', [AColumnValue], LFormat));
end;

function TFluentQueryProvider<T>.SetValue(const AColumnName: string; AColumnValue: Double; ADecimalPlaces: Integer): IFluentQueryProvider<T>;
var
  LFormat: TFormatSettings;
begin
  LFormat.DecimalSeparator := '.';
  Result := SetValue(AColumnName, Format('%.' + IntToStr(ADecimalPlaces) + 'f', [AColumnValue], LFormat));
end;

function TFluentQueryProvider<T>.SetValue(const AColumnName: string; AColumnValue: Currency; ADecimalPlaces: Integer): IFluentQueryProvider<T>;
var
  LFormat: TFormatSettings;
begin
  LFormat.DecimalSeparator := '.';
  Result := SetValue(AColumnName, Format('%.' + IntToStr(ADecimalPlaces) + 'f', [AColumnValue], LFormat));
end;

function TFluentQueryProvider<T>.SetValue(const AColumnName: string; const AColumnValue: array of const): IFluentQueryProvider<T>;
begin
  Result := SetValue(AColumnName, TUtils.SqlParamsToStr(AColumnValue));
end;

function TFluentQueryProvider<T>.SetValue(const AColumnName: string; const AColumnValue: TDate): IFluentQueryProvider<T>;
begin
  Result := SetValue(AColumnName, QuotedStr(TUtils.DateToSQLFormat(_GetDriverDatabase, AColumnValue)));
end;

function TFluentQueryProvider<T>.SetValue(const AColumnName: string; const AColumnValue: TDateTime): IFluentQueryProvider<T>;
begin
  Result := SetValue(AColumnName, QuotedStr(TUtils.DateTimeToSQLFormat(_GetDriverDatabase, AColumnValue)));
end;

function TFluentQueryProvider<T>.SetValue(const AColumnName: string; const AColumnValue: TGUID): IFluentQueryProvider<T>;
begin
  Result := SetValue(AColumnName, TUtils.GuidStrToSQLFormat(_GetDriverDatabase, AColumnValue));
end;

function TFluentQueryProvider<T>.Values(const AColumnName, AColumnValue: string): IFluentQueryProvider<T>;
begin
  Result := SetValue(AColumnName, AColumnValue);
end;

function TFluentQueryProvider<T>.Values(const AColumnName: string; const AColumnValue: array of const): IFluentQueryProvider<T>;
begin
  Result := SetValue(AColumnName, AColumnValue);
end;

function TFluentQueryProvider<T>.First(const AValue: Integer): IFluentQueryProvider<T>;
var
  LQualifier: ICQuerySelectQualifier;
begin
  LQualifier := FCQL.Select.Qualifiers.Add;
  LQualifier.Qualifier := sqFirst;
  LQualifier.Value := AValue;
  FCQL.Select.Qualifiers.Add(LQualifier);
  Result := Self;
end;

function TFluentQueryProvider<T>.Skip(const AValue: Integer): IFluentQueryProvider<T>;
var
  LQualifier: ICQuerySelectQualifier;
begin
  LQualifier := FCQL.Select.Qualifiers.Add;
  LQualifier.Qualifier := sqSkip;
  LQualifier.Value := AValue;
  FCQL.Select.Qualifiers.Add(LQualifier);
  Result := Self;
end;

function TFluentQueryProvider<T>.Update(const ATableName: string): IFluentQueryProvider<T>;
begin
  FCQL.Update.TableName := ATableName;
  FActiveValues := FCQL.Update.Values;
  Result := Self;
end;

function TFluentQueryProvider<T>.Where(const AExpression: string = ''): IFluentQueryProvider<T>;
begin
  FCQL.Where.Expression.Clear;
  if AExpression <> '' then
    FCQL.Where.Expression.Term := AExpression;
  FActiveExpr := TCQueryCriteriaExpression.Create(FCQL.Where.Expression);
  Result := Self;
end;

function TFluentQueryProvider<T>.Where(const AExpression: array of const): IFluentQueryProvider<T>;
begin
  Result := Where(TUtils.SqlParamsToStr(AExpression));
end;

function TFluentQueryProvider<T>.Equal(const AValue: string = ''): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.Equal(const AValue: Extended): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.Equal(const AValue: Integer): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.Equal(const AValue: TDate): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.Equal(const AValue: TDateTime): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.Equal(const AValue: TGUID): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotEqual(const AValue: string = ''): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotEqual(const AValue: Extended): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotEqual(const AValue: Integer): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotEqual(const AValue: TDate): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotEqual(const AValue: TDateTime): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotEqual(const AValue: TGUID): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.GreaterThan(const AValue: Extended): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.GreaterThan(const AValue: Integer): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.GreaterThan(const AValue: TDate): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.GreaterThan(const AValue: TDateTime): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.GreaterEqThan(const AValue: Extended): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.GreaterEqThan(const AValue: Integer): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.GreaterEqThan(const AValue: TDate): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.GreaterEqThan(const AValue: TDateTime): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.LessThan(const AValue: Extended): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.LessThan(const AValue: Integer): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.LessThan(const AValue: TDate): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.LessThan(const AValue: TDateTime): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.LessEqThan(const AValue: Extended): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.LessEqThan(const AValue: Integer): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.LessEqThan(const AValue: TDate): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.LessEqThan(const AValue: TDateTime): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.IsNull: IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNull);
  Result := Self;
end;

function TFluentQueryProvider<T>.IsNotNull: IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotNull);
  Result := Self;
end;

function TFluentQueryProvider<T>.Like(const AValue: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLike(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.LikeFull(const AValue: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLikeFull(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.LikeLeft(const AValue: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLikeLeft(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.LikeRight(const AValue: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLikeRight(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotLike(const AValue: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotLike(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotLikeFull(const AValue: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotLikeFull(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotLikeLeft(const AValue: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotLikeLeft(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotLikeRight(const AValue: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotLikeRight(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.InValues(const AValue: TArray<Double>): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsIn(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.InValues(const AValue: TArray<string>): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsIn(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.InValues(const AValue: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsIn(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotIn(const AValue: TArray<Double>): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotIn(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotIn(const AValue: TArray<string>): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotIn(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotIn(const AValue: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotIn(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.Exists(const AValue: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsExists(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.NotExists(const AValue: string): IFluentQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotExists(AValue));
  Result := Self;
end;

function TFluentQueryProvider<T>.Count: IFluentQueryProvider<T>;
var
  LColumn: ICQueryName;
  LNewColumn: ICQueryName;
  LFor: Integer;
begin
  FSavedColumns.Clear;
  for LFor := 0 to FCQL.Select.Columns.Count - 1 do
  begin
    LNewColumn := FSavedColumns.Add;
    LNewColumn.Name := FCQL.Select.Columns[LFor].Name;
    LNewColumn.Alias := FCQL.Select.Columns[LFor].Alias;
  end;
  FCQL.Select.Columns.Clear;
  LColumn := FCQL.Select.Columns.Add;
  if FSavedColumns.Count > 1 then
    LColumn.Name := FFunction.Count('*')
  else
    LColumn.Name := FFunction.Count(FSavedColumns.Columns[0].Name);
  FCQL.ASTName := LColumn;
  Result := Self;
end;

function TFluentQueryProvider<T>.Lower: IFluentQueryProvider<T>;
var
  LColumn: ICQueryName;
begin
  if FCQL.Select.Columns.Count > 0 then
  begin
    LColumn := FCQL.Select.Columns[0];
    FCQL.ASTName := LColumn;
    LColumn.Name := FFunction.Lower(LColumn.Name);
  end;
  Result := Self;
end;

function TFluentQueryProvider<T>.Min: IFluentQueryProvider<T>;
var
  LColumn: ICQueryName;
begin
  if FCQL.Select.Columns.Count > 0 then
  begin
    LColumn := FCQL.Select.Columns[0];
    FCQL.ASTName := LColumn;
    LColumn.Name := FFunction.Min(LColumn.Name);
  end;
  Result := Self;
end;

function TFluentQueryProvider<T>.Max: IFluentQueryProvider<T>;
var
  LColumn: ICQueryName;
begin
  if FCQL.Select.Columns.Count > 0 then
  begin
    LColumn := FCQL.Select.Columns[0];
    FCQL.ASTName := LColumn;
    LColumn.Name := FFunction.Max(LColumn.Name);
  end;
  Result := Self;
end;

function TFluentQueryProvider<T>.Upper: IFluentQueryProvider<T>;
var
  LColumn: ICQueryName;
begin
  if FCQL.Select.Columns.Count > 0 then
  begin
    LColumn := FCQL.Select.Columns[0];
    FCQL.ASTName := LColumn;
    LColumn.Name := FFunction.Upper(LColumn.Name);
  end;
  Result := Self;
end;

function TFluentQueryProvider<T>.SubString(const AStart: Integer; const ALength: Integer): IFluentQueryProvider<T>;
var
  LColumn: ICQueryName;
begin
  if FCQL.Select.Columns.Count > 0 then
  begin
    LColumn := FCQL.Select.Columns[0];
    FCQL.ASTName := LColumn;
    LColumn.Name := FFunction.SubString(LColumn.Name, AStart, ALength);
  end;
  Result := Self;
end;

function TFluentQueryProvider<T>.Database: TDBEngineDriver;
begin
  Result := FDatabase;
end;

function TFluentQueryProvider<T>.Date(const AValue: string): IFluentQueryProvider<T>;
begin
  FCQL.Select.Columns.Add.Name := FFunction.Date(AValue);
  FSavedColumns.Add.Name := FFunction.Date(AValue);
  Result := Self;
end;

function TFluentQueryProvider<T>.Day(const AValue: string): IFluentQueryProvider<T>;
begin
  FCQL.Select.Columns.Add.Name := FFunction.Day(AValue);
  FSavedColumns.Add.Name := FFunction.Day(AValue);
  Result := Self;
end;

function TFluentQueryProvider<T>.Month(const AValue: string): IFluentQueryProvider<T>;
begin
  FCQL.Select.Columns.Add.Name := FFunction.Month(AValue);
  FSavedColumns.Add.Name := FFunction.Month(AValue);
  Result := Self;
end;

function TFluentQueryProvider<T>.Year(const AValue: string): IFluentQueryProvider<T>;
begin
  FCQL.Select.Columns.Add.Name := FFunction.Year(AValue);
  FSavedColumns.Add.Name := FFunction.Year(AValue);
  Result := Self;
end;

function TFluentQueryProvider<T>.Concat(const AValue: array of string): IFluentQueryProvider<T>;
begin
  FCQL.Select.Columns.Add.Name := FFunction.Concat(AValue);
  FSavedColumns.Add.Name := FFunction.Concat(AValue);
  Result := Self;
end;

function TFluentQueryProvider<T>.Connection: IDBConnection;
begin
  Result := FConnection;
end;

function TFluentQueryProvider<T>.Sum(const AColumn: string; const AAlias: string): IFluentQueryProvider<T>;
var
  LColumn: ICQueryName;
begin
  FCQL.Select.Columns.Clear;
  LColumn := FCQL.Select.Columns.Add;
  LColumn.Name := FFunction.Sum(AColumn);
  LColumn.Alias := AAlias;
  FSavedColumns.Clear;
  FSavedColumns.Add.Name := LColumn.Name;
  Result := Self;
end;

function TFluentQueryProvider<T>.Average(const AColumn: string; const AAlias: string): IFluentQueryProvider<T>;
var
  LColumn: ICQueryName;
begin
  FCQL.Select.Columns.Clear;
  LColumn := FCQL.Select.Columns.Add;
  LColumn.Name := FFunction.Average(AColumn);
  LColumn.Alias := AAlias;
  FSavedColumns.Clear;
  FSavedColumns.Add.Name := LColumn.Name;
  Result := Self;
end;

function TFluentQueryProvider<T>.ToArray: IFluentArray<T>;
begin
  Result := ToList.ToArray;
end;

function TFluentQueryProvider<T>.ToList: IFluentList<T>;
var
  LSQL: string;
  LDataSet: IDBDataSet;
  LParserScalar: TFluentParseScalarDataSet<T>;
  LParserObject: TFluentParseObjectDataSet<T>;
  LContext: TRttiContext;
  LType: TRttiType;
begin
  Result := nil;
  LSQL := AsString;
  if LSQL = '' then
    raise EInvalidOperation.Create('SQL query is empty');

  if not Assigned(FConnection) then
    raise EInvalidOperation.Create('Database connection is not assigned');

  LDataSet := FConnection.CreateDataSet(LSQL);
  if not Assigned(LDataSet) then
    raise EInvalidOperation.Create('Failed to create dataset for SQL: ' + LSQL);

  try
    LDataSet.Open;
    if not LDataSet.Active then
      raise EInvalidOperation.Create('Failed to open dataset for SQL: ' + LSQL);

    if LDataSet.FieldCount = 0 then
      raise EInvalidOperation.Create('No fields returned for SQL: ' + LSQL);

    LContext := TRttiContext.Create;
    try
      LType := LContext.GetType(TypeInfo(T));
      if not Assigned(LType) then
        raise EInvalidOperation.Create('Type information not available for T');

      if LType.TypeKind in [tkClass, tkInterface] then
      begin
        LParserObject := TFluentParseObjectDataSet<T>.Create;
        try
          Result := LParserObject.ToList(LDataSet);
        finally
          LParserObject.Free;
        end;
      end
      else
      begin
        LParserScalar := TFluentParseScalarDataSet<T>.Create;
        try
          Result := LParserScalar.ToList(LDataSet);
        finally
          LParserScalar.Free;
        end;
      end;
    finally
      LContext.Free;
    end;
  finally
    LDataSet.Close;
  end;
end;

function TFluentQueryProvider<T>.AsString: string;
var
  LSerialize: ICQuerySerialize;
begin
  Result := '';
  LSerialize := FRegister.Serialize(_GetDriverDatabase);
  if Assigned(LSerialize) then
    Result := LSerialize.AsString(FCQL);
end;

{ TFluentQueryProvider<T>.TStrictPrivateCreate<T> }

class function TFluentQueryProvider<T>.TStrictPrivateCreate<T>.CreateProvider(
  const AInitializer: TConnectionInitializer): TFluentQueryProvider<T>;
begin
  Result := TFluentQueryProvider<T>.Create(AInitializer);
end;

class function TFluentQueryProvider<T>.TStrictPrivateCreate<T>.CreateProvider(
  const ADriver: TDBEngineDriver; const AConnection: IDBConnection; const ACQL: ICQueryAST): TFluentQueryProvider<T>;
begin
  Result := TFluentQueryProvider<T>.Create(ADriver, AConnection, ACQL);
end;

end.

