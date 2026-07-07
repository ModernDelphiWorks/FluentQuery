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

unit Colligo.Provider;

interface

uses
  Rtti,
  Math,
  TypInfo,
  Classes,
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  FluentSQL.Operators,
  FluentSQL.Functions,
  FluentSQL.Interfaces,
  FluentSQL.Cases,
  FluentSQL.Select,
  FluentSQL.Utils,
  FluentSQL.Serialize,
  FluentSQL.Qualifier,
  FluentSQL.Ast,
  FluentSQL.Name,
  FluentSQL.Expression,
  FluentSQL.Register,
  DataEngine.FactoryInterfaces,
  Colligo,
  Colligo.Core,
  Colligo.Queryable,
  Colligo.Expression;

type
  TColligoQueryProvider<T> = class(TInterfacedObject, IColligoQueryProvider<T>)
  private
    FFluentSQL: IFluentSQLAST;
    FConnection: IDBConnection;
    FDatabase: TDriverName;
    FOperator: IFluentSQLOperators;
    FFunction: IFluentSQLFunctions;
    FActiveExpr: IFluentSQLCriteriaExpression;
    FActiveValues: IFluentSQLNameValuePairs;
    FRegister: TFluentSQLRegister;
    FIsObject: Boolean;
    FSavedColumns: IFluentSQLNames;
    function _CreateJoin(AJoinType: TJoinType; const ATableName: String): IColligoQueryProvider<T>;
    function _GetDriverDatabase: TFluentSQLDriver;
    procedure _InitializeConnection(const AInitializer: TConnectionInitializer); overload;
    procedure _InitializeConnection(const ADriver: TDriverName; const AConnection: IDBConnection); overload;
    function _GetFluentSQL: IFluentSQLAST;
    procedure _SetFluentSQL(const Value: IFluentSQLAST);
  strict private
    constructor Create; overload;
    constructor Create(const AInitializer: TConnectionInitializer); overload;
    constructor Create(const ADriver: TDriverName; const AConnection: IDBConnection; const AFluentSQL: IFluentSQLAST = nil); overload;
    destructor Destroy; override;
  public
    type
      TStrictPrivateCreate<T> = class
      public
        class function CreateProvider(const AInitializer: TConnectionInitializer): TColligoQueryProvider<T>; overload; static;
        class function CreateProvider(const ADriver: TDriverName; const AConnection: IDBConnection; const AFluentSQL: IFluentSQLAST = nil): TColligoQueryProvider<T>; overload; static;
      end;
  public
    function AndOpe(const AExpression: array of const): IColligoQueryProvider<T>; overload;
    function AndOpe(const AExpression: string): IColligoQueryProvider<T>; overload;
    function Alias(const AAlias: string): IColligoQueryProvider<T>;
    function Clear: IColligoQueryProvider<T>;
    function ClearAll: IColligoQueryProvider<T>;
    function All: IColligoQueryProvider<T>;
    function Column(const AColumnName: string = ''): IColligoQueryProvider<T>; overload;
    function Column(const ATableName: string; const AColumnName: string): IColligoQueryProvider<T>; overload;
    function Column(const AColumnsName: array of const): IColligoQueryProvider<T>; overload;
    function Delete: IColligoQueryProvider<T>;
    function Desc: IColligoQueryProvider<T>;
    function DistinctSQL: IColligoQueryProvider<T>;
    function IsEmpty: Boolean;
    function Select(const AColumns: string = ''): IColligoQueryProvider<T>; overload;
    function From(const ATableName: string): IColligoQueryProvider<T>; overload;
    function From(const ATableName: string; const AAlias: string): IColligoQueryProvider<T>; overload;
    function GroupBy(const AColumnName: string = ''): IColligoQueryProvider<T>;
    function Having(const AExpression: string = ''): IColligoQueryProvider<T>; overload;
    function Having(const AExpression: array of const): IColligoQueryProvider<T>; overload;
    function Insert: IColligoQueryProvider<T>;
    function Into(const ATableName: string): IColligoQueryProvider<T>;
    function FullJoin(const ATableName: string): IColligoQueryProvider<T>; overload;
    function InnerJoin(const ATableName: string): IColligoQueryProvider<T>; overload;
    function LeftJoin(const ATableName: string): IColligoQueryProvider<T>; overload;
    function RightJoin(const ATableName: string): IColligoQueryProvider<T>; overload;
    function FullJoin(const ATableName: string; const AAlias: string): IColligoQueryProvider<T>; overload;
    function InnerJoin(const ATableName: string; const AAlias: string): IColligoQueryProvider<T>; overload;
    function LeftJoin(const ATableName: string; const AAlias: string): IColligoQueryProvider<T>; overload;
    function RightJoin(const ATableName: string; const AAlias: string): IColligoQueryProvider<T>; overload;
    function OnCond(const AExpression: string): IColligoQueryProvider<T>; overload;
    function OnCond(const AExpression: array of const): IColligoQueryProvider<T>; overload;
    function OrOpe(const AExpression: array of const): IColligoQueryProvider<T>; overload;
    function OrOpe(const AExpression: string): IColligoQueryProvider<T>; overload;
    function OrderBy(const AColumnName: string = ''): IColligoQueryProvider<T>;
    function SetValue(const AColumnName, AColumnValue: string): IColligoQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; AColumnValue: Integer): IColligoQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; AColumnValue: Extended; ADecimalPlaces: Integer): IColligoQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; AColumnValue: Double; ADecimalPlaces: Integer): IColligoQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; AColumnValue: Currency; ADecimalPlaces: Integer): IColligoQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; const AColumnValue: array of const): IColligoQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; const AColumnValue: TDate): IColligoQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; const AColumnValue: TDateTime): IColligoQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; const AColumnValue: TGUID): IColligoQueryProvider<T>; overload;
    function Values(const AColumnName, AColumnValue: string): IColligoQueryProvider<T>; overload;
    function Values(const AColumnName: string; const AColumnValue: array of const): IColligoQueryProvider<T>; overload;
    function First(const AValue: Integer): IColligoQueryProvider<T>;
    function Skip(const AValue: Integer): IColligoQueryProvider<T>;
    function Update(const ATableName: string): IColligoQueryProvider<T>;
    function Where(const AExpression: string = ''): IColligoQueryProvider<T>; overload;
    function Where(const AExpression: array of const): IColligoQueryProvider<T>; overload;
    function Equal(const AValue: string = ''): IColligoQueryProvider<T>; overload;
    function Equal(const AValue: Extended): IColligoQueryProvider<T>; overload;
    function Equal(const AValue: Integer): IColligoQueryProvider<T>; overload;
    function Equal(const AValue: TDate): IColligoQueryProvider<T>; overload;
    function Equal(const AValue: TDateTime): IColligoQueryProvider<T>; overload;
    function Equal(const AValue: TGUID): IColligoQueryProvider<T>; overload;
    function NotEqual(const AValue: string = ''): IColligoQueryProvider<T>; overload;
    function NotEqual(const AValue: Extended): IColligoQueryProvider<T>; overload;
    function NotEqual(const AValue: Integer): IColligoQueryProvider<T>; overload;
    function NotEqual(const AValue: TDate): IColligoQueryProvider<T>; overload;
    function NotEqual(const AValue: TDateTime): IColligoQueryProvider<T>; overload;
    function NotEqual(const AValue: TGUID): IColligoQueryProvider<T>; overload;
    function GreaterThan(const AValue: Extended): IColligoQueryProvider<T>; overload;
    function GreaterThan(const AValue: Integer): IColligoQueryProvider<T>; overload;
    function GreaterThan(const AValue: TDate): IColligoQueryProvider<T>; overload;
    function GreaterThan(const AValue: TDateTime): IColligoQueryProvider<T>; overload;
    function GreaterEqThan(const AValue: Extended): IColligoQueryProvider<T>; overload;
    function GreaterEqThan(const AValue: Integer): IColligoQueryProvider<T>; overload;
    function GreaterEqThan(const AValue: TDate): IColligoQueryProvider<T>; overload;
    function GreaterEqThan(const AValue: TDateTime): IColligoQueryProvider<T>; overload;
    function LessThan(const AValue: Extended): IColligoQueryProvider<T>; overload;
    function LessThan(const AValue: Integer): IColligoQueryProvider<T>; overload;
    function LessThan(const AValue: TDate): IColligoQueryProvider<T>; overload;
    function LessThan(const AValue: TDateTime): IColligoQueryProvider<T>; overload;
    function LessEqThan(const AValue: Extended): IColligoQueryProvider<T>; overload;
    function LessEqThan(const AValue: Integer): IColligoQueryProvider<T>; overload;
    function LessEqThan(const AValue: TDate): IColligoQueryProvider<T>; overload;
    function LessEqThan(const AValue: TDateTime): IColligoQueryProvider<T>; overload;
    function IsNull: IColligoQueryProvider<T>;
    function IsNotNull: IColligoQueryProvider<T>;
    function Like(const AValue: string): IColligoQueryProvider<T>;
    function LikeFull(const AValue: string): IColligoQueryProvider<T>;
    function LikeLeft(const AValue: string): IColligoQueryProvider<T>;
    function LikeRight(const AValue: string): IColligoQueryProvider<T>;
    function NotLike(const AValue: string): IColligoQueryProvider<T>;
    function NotLikeFull(const AValue: string): IColligoQueryProvider<T>;
    function NotLikeLeft(const AValue: string): IColligoQueryProvider<T>;
    function NotLikeRight(const AValue: string): IColligoQueryProvider<T>;
    function InValues(const AValue: TArray<Double>): IColligoQueryProvider<T>; overload;
    function InValues(const AValue: TArray<string>): IColligoQueryProvider<T>; overload;
    function InValues(const AValue: string): IColligoQueryProvider<T>; overload;
    function NotIn(const AValue: TArray<Double>): IColligoQueryProvider<T>; overload;
    function NotIn(const AValue: TArray<string>): IColligoQueryProvider<T>; overload;
    function NotIn(const AValue: string): IColligoQueryProvider<T>; overload;
    function Exists(const AValue: string): IColligoQueryProvider<T>;
    function NotExists(const AValue: string): IColligoQueryProvider<T>;
    function Count: IColligoQueryProvider<T>;
    function Lower: IColligoQueryProvider<T>;
    function Min: IColligoQueryProvider<T>; overload;
    function Max: IColligoQueryProvider<T>;
    function Upper: IColligoQueryProvider<T>;
    function SubString(const AStart: Integer; const ALength: Integer): IColligoQueryProvider<T>;
    function Date(const AValue: string): IColligoQueryProvider<T>;
    function Day(const AValue: string): IColligoQueryProvider<T>;
    function Month(const AValue: string): IColligoQueryProvider<T>;
    function Year(const AValue: string): IColligoQueryProvider<T>;
    function Concat(const AValue: array of string): IColligoQueryProvider<T>;
    function Sum(const AColumn: string; const AAlias: string = ''): IColligoQueryProvider<T>;
    function Average(const AColumn: string; const AAlias: string = ''): IColligoQueryProvider<T>;
    function ToArray: IColligoArray<T>;
    function ToList: IColligoList<T>;
    function AsString: string;
    function Database: TDriverName;
    function Connection: IDBConnection;
  end;

implementation

uses
  Colligo.Parse;

constructor TColligoQueryProvider<T>.Create(const AInitializer: TConnectionInitializer);
begin
  inherited Create;
  _InitializeConnection(AInitializer);
  FRegister := TFluentSQLRegister.Create;
  FOperator := TFluentSQLOperators.Create(_GetDriverDatabase);
  FFunction := TFluentSQLFunctions.Create(_GetDriverDatabase, FRegister);
  FFluentSQL := TFluentSQLAST.Create(_GetDriverDatabase, FRegister);
  FFluentSQL.Clear;
  FIsObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
  FSavedColumns := TFluentSQLNames.Create;
end;

constructor TColligoQueryProvider<T>.Create(const ADriver: TDriverName;
  const AConnection: IDBConnection; const AFluentSQL: IFluentSQLAST);
begin
  inherited Create;
  _InitializeConnection(ADriver, AConnection);
  FRegister := TFluentSQLRegister.Create;
  FOperator := TFluentSQLOperators.Create(_GetDriverDatabase);
  FFunction := TFluentSQLFunctions.Create(_GetDriverDatabase, FRegister);
  FFluentSQL := AFluentSQL;
  if FFluentSQL = nil then
  begin
    FFluentSQL := TFluentSQLAST.Create(_GetDriverDatabase, FRegister);
    FFluentSQL.Clear;
  end;
  FIsObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
  FSavedColumns := TFluentSQLNames.Create;
end;

constructor TColligoQueryProvider<T>.Create;
begin
  raise Exception.CreateFmt(
    'Class %s cannot be instantiated directly using Create. ' +
    'Please use an appropriate factory method.', [Self.ClassName]
  );
end;

destructor TColligoQueryProvider<T>.Destroy;
begin
  FFluentSQL := nil;
  FActiveExpr := nil;
  FActiveValues := nil;
  FOperator := nil;
  FFunction := nil;
  FSavedColumns := nil;
  FRegister.Free;
  inherited;
end;

function TColligoQueryProvider<T>.AndOpe(const AExpression: array of const): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.AndOpe(TUtils.SqlParamsToStr(AExpression));
  Result := Self;
end;

function TColligoQueryProvider<T>.AndOpe(const AExpression: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.AndOpe(AExpression);
  Result := Self;
end;

function TColligoQueryProvider<T>.Alias(const AAlias: string): IColligoQueryProvider<T>;
begin
  if FFluentSQL.Select.TableNames.Count > 0 then
    FFluentSQL.Select.TableNames[FFluentSQL.Select.TableNames.Count - 1].Alias := AAlias
  else if FFluentSQL.Joins.Count > 0 then
    FFluentSQL.Joins[FFluentSQL.Joins.Count - 1].JoinedTable.Alias := AAlias;
  Result := Self;
end;

function TColligoQueryProvider<T>.Clear: IColligoQueryProvider<T>;
begin
  FFluentSQL.Clear;
  FSavedColumns.Clear;
  Result := Self;
end;

function TColligoQueryProvider<T>.ClearAll: IColligoQueryProvider<T>;
begin
  FFluentSQL.Clear;
  FSavedColumns.Clear;
  Result := Self;
end;

function TColligoQueryProvider<T>.All: IColligoQueryProvider<T>;
begin
  FFluentSQL.Select.Columns.Clear;
  FFluentSQL.Select.Columns.Add.Name := '*';
  FSavedColumns.Clear;
  FSavedColumns.Add.Name := '*';
  Result := Self;
end;

function TColligoQueryProvider<T>.Column(const AColumnName: string = ''): IColligoQueryProvider<T>;
begin
  FFluentSQL.Select.Columns.Add.Name := AColumnName;
  FSavedColumns.Add.Name := AColumnName;
  Result := Self;
end;

function TColligoQueryProvider<T>.Column(const ATableName: string; const AColumnName: string): IColligoQueryProvider<T>;
begin
  Result := Column(ATableName + '.' + AColumnName);
end;

function TColligoQueryProvider<T>.Column(const AColumnsName: array of const): IColligoQueryProvider<T>;
begin
  Result := Column(TUtils.SqlParamsToStr(AColumnsName));
end;

function TColligoQueryProvider<T>.Delete: IColligoQueryProvider<T>;
begin
  FFluentSQL.Delete.TableNames.Clear;
  Result := Self;
end;

function TColligoQueryProvider<T>.Desc: IColligoQueryProvider<T>;
begin
  if FFluentSQL.OrderBy.Columns.Count > 0 then
    (FFluentSQL.OrderBy.Columns[FFluentSQL.OrderBy.Columns.Count - 1] as IFluentSQLOrderByColumn).Direction := dirDescending;
  Result := Self;
end;

function TColligoQueryProvider<T>.DistinctSQL: IColligoQueryProvider<T>;
var
  LQualifier: IFluentSQLSelectQualifier;
begin
  LQualifier := FFluentSQL.Select.Qualifiers.Add;
  LQualifier.Qualifier := sqDistinct;
  Result := Self;
end;

function TColligoQueryProvider<T>.IsEmpty: Boolean;
begin
  Result := FFluentSQL.IsEmpty;
end;

function TColligoQueryProvider<T>.Select(const AColumns: string = ''): IColligoQueryProvider<T>;
var
  LColumns: TArray<string>;
  I: Integer;
begin
  FFluentSQL.Select.Columns.Clear;
  FSavedColumns.Clear;
  if AColumns = '' then
  begin
    FFluentSQL.Select.Columns.Add.Name := '*';
    FSavedColumns.Add.Name := '*';
  end
  else
  begin
    LColumns := AColumns.Split([', ']);
    for I := 0 to High(LColumns) do
    begin
      FFluentSQL.Select.Columns.Add.Name := LColumns[I];
      FSavedColumns.Add.Name := LColumns[I];
    end;
  end;
  Result := Self;
end;

function TColligoQueryProvider<T>.From(const ATableName: string): IColligoQueryProvider<T>;
begin
  FFluentSQL.Select.TableNames.Clear;
  FFluentSQL.Select.TableNames.Add.Name := ATableName;
  Result := Self;
end;

function TColligoQueryProvider<T>.From(const ATableName: string; const AAlias: string): IColligoQueryProvider<T>;
begin
  FFluentSQL.Select.TableNames.Clear;
  FFluentSQL.Select.TableNames.Add.Name := ATableName;
  FFluentSQL.Select.TableNames[0].Alias := AAlias;
  Result := Self;
end;

function TColligoQueryProvider<T>.GroupBy(const AColumnName: string = ''): IColligoQueryProvider<T>;
begin
  FFluentSQL.GroupBy.Columns.Clear;
  if AColumnName <> '' then
    FFluentSQL.GroupBy.Columns.Add.Name := AColumnName;
  Result := Self;
end;

function TColligoQueryProvider<T>.Having(const AExpression: string = ''): IColligoQueryProvider<T>;
begin
  FFluentSQL.Having.Expression.Clear;
  if AExpression <> '' then
    FFluentSQL.Having.Expression.Term := AExpression;
  Result := Self;
end;

function TColligoQueryProvider<T>.Having(const AExpression: array of const): IColligoQueryProvider<T>;
begin
  Result := Having(TUtils.SqlParamsToStr(AExpression));
end;

function TColligoQueryProvider<T>.Insert: IColligoQueryProvider<T>;
begin
  FFluentSQL.Insert.Columns.Clear;
  FActiveValues := FFluentSQL.Insert.Values;
  Result := Self;
end;

function TColligoQueryProvider<T>.Into(const ATableName: string): IColligoQueryProvider<T>;
begin
  FFluentSQL.Insert.TableName := ATableName;
  Result := Self;
end;

function TColligoQueryProvider<T>.FullJoin(const ATableName: string): IColligoQueryProvider<T>;
begin
  Result := _CreateJoin(jtFULL, ATableName);
end;

function TColligoQueryProvider<T>.InnerJoin(const ATableName: string): IColligoQueryProvider<T>;
begin
  Result := _CreateJoin(jtINNER, ATableName);
end;

function TColligoQueryProvider<T>.LeftJoin(const ATableName: string): IColligoQueryProvider<T>;
begin
  Result := _CreateJoin(jtLEFT, ATableName);
end;

function TColligoQueryProvider<T>.RightJoin(const ATableName: string): IColligoQueryProvider<T>;
begin
  Result := _CreateJoin(jtRIGHT, ATableName);
end;

function TColligoQueryProvider<T>.FullJoin(const ATableName: string; const AAlias: string): IColligoQueryProvider<T>;
begin
  FullJoin(ATableName);
  FFluentSQL.Joins[FFluentSQL.Joins.Count - 1].JoinedTable.Alias := AAlias;
  Result := Self;
end;

function TColligoQueryProvider<T>.InnerJoin(const ATableName: string; const AAlias: string): IColligoQueryProvider<T>;
begin
  InnerJoin(ATableName);
  FFluentSQL.Joins[FFluentSQL.Joins.Count - 1].JoinedTable.Alias := AAlias;
  Result := Self;
end;

function TColligoQueryProvider<T>.LeftJoin(const ATableName: string; const AAlias: string): IColligoQueryProvider<T>;
begin
  LeftJoin(ATableName);
  FFluentSQL.Joins[FFluentSQL.Joins.Count - 1].JoinedTable.Alias := AAlias;
  Result := Self;
end;

function TColligoQueryProvider<T>.RightJoin(const ATableName: string; const AAlias: string): IColligoQueryProvider<T>;
begin
  RightJoin(ATableName);
  FFluentSQL.Joins[FFluentSQL.Joins.Count - 1].JoinedTable.Alias := AAlias;
  Result := Self;
end;

function TColligoQueryProvider<T>._CreateJoin(AJoinType: TJoinType; const ATableName: String): IColligoQueryProvider<T>;
var
  LJoin: IFluentSQLJoin;
begin
  LJoin := FFluentSQL.Joins.Add;
  LJoin.JoinType := AJoinType;
  LJoin.JoinedTable.Name := ATableName;
  FActiveExpr := TFluentSQLCriteriaExpression.Create(LJoin.Condition);
  Result := Self;
end;

function TColligoQueryProvider<T>._GetFluentSQL: IFluentSQLAST;
begin
  Result := FFluentSQL;
end;

function TColligoQueryProvider<T>._GetDriverDatabase: TFluentSQLDriver;
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

procedure TColligoQueryProvider<T>._InitializeConnection(const ADriver: TDriverName;
  const AConnection: IDBConnection);
begin
  if AConnection = nil then
    raise EArgumentNilException.Create('Connection cannot be nil');
  if TStrDriverName[ADriver] = '' then
    raise EArgumentNilException.Create('Database type must be specified');

  FDatabase := ADriver;
  FConnection := AConnection;
end;

procedure TColligoQueryProvider<T>._SetFluentSQL(const Value: IFluentSQLAST);
begin
  FFluentSQL := Value;
end;

procedure TColligoQueryProvider<T>._InitializeConnection(const AInitializer: TConnectionInitializer);
begin
  if not Assigned(AInitializer) then
    raise EArgumentNilException.Create('Connection initializer cannot be nil');

  AInitializer(FDatabase, FConnection);

  if FConnection = nil then
    raise EInvalidOperation.Create('Connection cannot be nil');
  if TStrDriverName[FDatabase] = '' then
    raise EInvalidOperation.Create('Database type must be specified');
end;

function TColligoQueryProvider<T>.OnCond(const AExpression: string): IColligoQueryProvider<T>;
begin
  if FFluentSQL.Joins.Count > 0 then
    FActiveExpr.AndOpe(AExpression);
  Result := Self;
end;

function TColligoQueryProvider<T>.OnCond(const AExpression: array of const): IColligoQueryProvider<T>;
begin
  Result := OnCond(TUtils.SqlParamsToStr(AExpression));
end;

function TColligoQueryProvider<T>.OrOpe(const AExpression: array of const): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.OrOpe(TUtils.SqlParamsToStr(AExpression));
  Result := Self;
end;

function TColligoQueryProvider<T>.OrOpe(const AExpression: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.OrOpe(AExpression);
  Result := Self;
end;

function TColligoQueryProvider<T>.OrderBy(const AColumnName: string = ''): IColligoQueryProvider<T>;
begin
  FFluentSQL.OrderBy.Columns.Clear;
  if AColumnName <> '' then
    FFluentSQL.OrderBy.Columns.Add.Name := AColumnName;
  Result := Self;
end;

function TColligoQueryProvider<T>.SetValue(const AColumnName, AColumnValue: string): IColligoQueryProvider<T>;
var
  LPair: IFluentSQLNameValue;
begin
  if Assigned(FActiveValues) then
  begin
    LPair := FActiveValues.Add;
    LPair.Name := AColumnName;
    LPair.Value := QuotedStr(AColumnValue);
  end;
  Result := Self;
end;

function TColligoQueryProvider<T>.SetValue(const AColumnName: string; AColumnValue: Integer): IColligoQueryProvider<T>;
begin
  Result := SetValue(AColumnName, IntToStr(AColumnValue));
end;

function TColligoQueryProvider<T>.SetValue(const AColumnName: string; AColumnValue: Extended; ADecimalPlaces: Integer): IColligoQueryProvider<T>;
var
  LFormat: TFormatSettings;
begin
  LFormat.DecimalSeparator := '.';
  Result := SetValue(AColumnName, Format('%.' + IntToStr(ADecimalPlaces) + 'f', [AColumnValue], LFormat));
end;

function TColligoQueryProvider<T>.SetValue(const AColumnName: string; AColumnValue: Double; ADecimalPlaces: Integer): IColligoQueryProvider<T>;
var
  LFormat: TFormatSettings;
begin
  LFormat.DecimalSeparator := '.';
  Result := SetValue(AColumnName, Format('%.' + IntToStr(ADecimalPlaces) + 'f', [AColumnValue], LFormat));
end;

function TColligoQueryProvider<T>.SetValue(const AColumnName: string; AColumnValue: Currency; ADecimalPlaces: Integer): IColligoQueryProvider<T>;
var
  LFormat: TFormatSettings;
begin
  LFormat.DecimalSeparator := '.';
  Result := SetValue(AColumnName, Format('%.' + IntToStr(ADecimalPlaces) + 'f', [AColumnValue], LFormat));
end;

function TColligoQueryProvider<T>.SetValue(const AColumnName: string; const AColumnValue: array of const): IColligoQueryProvider<T>;
begin
  Result := SetValue(AColumnName, TUtils.SqlParamsToStr(AColumnValue));
end;

function TColligoQueryProvider<T>.SetValue(const AColumnName: string; const AColumnValue: TDate): IColligoQueryProvider<T>;
begin
  Result := SetValue(AColumnName, QuotedStr(TUtils.DateToSQLFormat(_GetDriverDatabase, AColumnValue)));
end;

function TColligoQueryProvider<T>.SetValue(const AColumnName: string; const AColumnValue: TDateTime): IColligoQueryProvider<T>;
begin
  Result := SetValue(AColumnName, QuotedStr(TUtils.DateTimeToSQLFormat(_GetDriverDatabase, AColumnValue)));
end;

function TColligoQueryProvider<T>.SetValue(const AColumnName: string; const AColumnValue: TGUID): IColligoQueryProvider<T>;
begin
  Result := SetValue(AColumnName, TUtils.GuidStrToSQLFormat(_GetDriverDatabase, AColumnValue));
end;

function TColligoQueryProvider<T>.Values(const AColumnName, AColumnValue: string): IColligoQueryProvider<T>;
begin
  Result := SetValue(AColumnName, AColumnValue);
end;

function TColligoQueryProvider<T>.Values(const AColumnName: string; const AColumnValue: array of const): IColligoQueryProvider<T>;
begin
  Result := SetValue(AColumnName, AColumnValue);
end;

function TColligoQueryProvider<T>.First(const AValue: Integer): IColligoQueryProvider<T>;
var
  LQualifier: IFluentSQLSelectQualifier;
begin
  LQualifier := FFluentSQL.Select.Qualifiers.Add;
  LQualifier.Qualifier := sqFirst;
  LQualifier.Value := AValue;
  FFluentSQL.Select.Qualifiers.Add(LQualifier);
  Result := Self;
end;

function TColligoQueryProvider<T>.Skip(const AValue: Integer): IColligoQueryProvider<T>;
var
  LQualifier: IFluentSQLSelectQualifier;
begin
  LQualifier := FFluentSQL.Select.Qualifiers.Add;
  LQualifier.Qualifier := sqSkip;
  LQualifier.Value := AValue;
  FFluentSQL.Select.Qualifiers.Add(LQualifier);
  Result := Self;
end;

function TColligoQueryProvider<T>.Update(const ATableName: string): IColligoQueryProvider<T>;
begin
  FFluentSQL.Update.TableName := ATableName;
  FActiveValues := FFluentSQL.Update.Values;
  Result := Self;
end;

function TColligoQueryProvider<T>.Where(const AExpression: string = ''): IColligoQueryProvider<T>;
begin
  FFluentSQL.Where.Expression.Clear;
  if AExpression <> '' then
    FFluentSQL.Where.Expression.Term := AExpression;
  FActiveExpr := TFluentSQLCriteriaExpression.Create(FFluentSQL.Where.Expression);
  Result := Self;
end;

function TColligoQueryProvider<T>.Where(const AExpression: array of const): IColligoQueryProvider<T>;
begin
  Result := Where(TUtils.SqlParamsToStr(AExpression));
end;

function TColligoQueryProvider<T>.Equal(const AValue: string = ''): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.Equal(const AValue: Extended): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.Equal(const AValue: Integer): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.Equal(const AValue: TDate): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.Equal(const AValue: TDateTime): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.Equal(const AValue: TGUID): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsEqual(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotEqual(const AValue: string = ''): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotEqual(const AValue: Extended): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotEqual(const AValue: Integer): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotEqual(const AValue: TDate): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotEqual(const AValue: TDateTime): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotEqual(const AValue: TGUID): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotEqual(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.GreaterThan(const AValue: Extended): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.GreaterThan(const AValue: Integer): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.GreaterThan(const AValue: TDate): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.GreaterThan(const AValue: TDateTime): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.GreaterEqThan(const AValue: Extended): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.GreaterEqThan(const AValue: Integer): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.GreaterEqThan(const AValue: TDate): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.GreaterEqThan(const AValue: TDateTime): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsGreaterEqThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.LessThan(const AValue: Extended): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.LessThan(const AValue: Integer): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.LessThan(const AValue: TDate): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.LessThan(const AValue: TDateTime): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.LessEqThan(const AValue: Extended): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.LessEqThan(const AValue: Integer): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.LessEqThan(const AValue: TDate): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.LessEqThan(const AValue: TDateTime): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLessEqThan(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.IsNull: IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNull);
  Result := Self;
end;

function TColligoQueryProvider<T>.IsNotNull: IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotNull);
  Result := Self;
end;

function TColligoQueryProvider<T>.Like(const AValue: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLike(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.LikeFull(const AValue: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLikeFull(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.LikeLeft(const AValue: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLikeLeft(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.LikeRight(const AValue: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsLikeRight(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotLike(const AValue: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotLike(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotLikeFull(const AValue: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotLikeFull(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotLikeLeft(const AValue: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotLikeLeft(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotLikeRight(const AValue: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotLikeRight(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.InValues(const AValue: TArray<Double>): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsIn(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.InValues(const AValue: TArray<string>): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsIn(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.InValues(const AValue: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsIn(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotIn(const AValue: TArray<Double>): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotIn(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotIn(const AValue: TArray<string>): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotIn(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotIn(const AValue: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotIn(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.Exists(const AValue: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsExists(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.NotExists(const AValue: string): IColligoQueryProvider<T>;
begin
  if Assigned(FActiveExpr) then
    FActiveExpr.Ope(FOperator.IsNotExists(AValue));
  Result := Self;
end;

function TColligoQueryProvider<T>.Count: IColligoQueryProvider<T>;
var
  LColumn: IFluentSQLName;
  LNewColumn: IFluentSQLName;
  LFor: Integer;
begin
  FSavedColumns.Clear;
  for LFor := 0 to FFluentSQL.Select.Columns.Count - 1 do
  begin
    LNewColumn := FSavedColumns.Add;
    LNewColumn.Name := FFluentSQL.Select.Columns[LFor].Name;
    LNewColumn.Alias := FFluentSQL.Select.Columns[LFor].Alias;
  end;
  FFluentSQL.Select.Columns.Clear;
  LColumn := FFluentSQL.Select.Columns.Add;
  if FSavedColumns.Count > 1 then
    LColumn.Name := FFunction.Count('*')
  else
    LColumn.Name := FFunction.Count(FSavedColumns.Columns[0].Name);
  FFluentSQL.ASTName := LColumn;
  Result := Self;
end;

function TColligoQueryProvider<T>.Lower: IColligoQueryProvider<T>;
var
  LColumn: IFluentSQLName;
begin
  if FFluentSQL.Select.Columns.Count > 0 then
  begin
    LColumn := FFluentSQL.Select.Columns[0];
    FFluentSQL.ASTName := LColumn;
    LColumn.Name := FFunction.Lower(LColumn.Name);
  end;
  Result := Self;
end;

function TColligoQueryProvider<T>.Min: IColligoQueryProvider<T>;
var
  LColumn: IFluentSQLName;
begin
  if FFluentSQL.Select.Columns.Count > 0 then
  begin
    LColumn := FFluentSQL.Select.Columns[0];
    FFluentSQL.ASTName := LColumn;
    LColumn.Name := FFunction.Min(LColumn.Name);
  end;
  Result := Self;
end;

function TColligoQueryProvider<T>.Max: IColligoQueryProvider<T>;
var
  LColumn: IFluentSQLName;
begin
  if FFluentSQL.Select.Columns.Count > 0 then
  begin
    LColumn := FFluentSQL.Select.Columns[0];
    FFluentSQL.ASTName := LColumn;
    LColumn.Name := FFunction.Max(LColumn.Name);
  end;
  Result := Self;
end;

function TColligoQueryProvider<T>.Upper: IColligoQueryProvider<T>;
var
  LColumn: IFluentSQLName;
begin
  if FFluentSQL.Select.Columns.Count > 0 then
  begin
    LColumn := FFluentSQL.Select.Columns[0];
    FFluentSQL.ASTName := LColumn;
    LColumn.Name := FFunction.Upper(LColumn.Name);
  end;
  Result := Self;
end;

function TColligoQueryProvider<T>.SubString(const AStart: Integer; const ALength: Integer): IColligoQueryProvider<T>;
var
  LColumn: IFluentSQLName;
begin
  if FFluentSQL.Select.Columns.Count > 0 then
  begin
    LColumn := FFluentSQL.Select.Columns[0];
    FFluentSQL.ASTName := LColumn;
    LColumn.Name := FFunction.SubString(LColumn.Name, AStart, ALength);
  end;
  Result := Self;
end;

function TColligoQueryProvider<T>.Database: TDriverName;
begin
  Result := FDatabase;
end;

function TColligoQueryProvider<T>.Date(const AValue: string): IColligoQueryProvider<T>;
begin
  FFluentSQL.Select.Columns.Add.Name := FFunction.Date(AValue);
  FSavedColumns.Add.Name := FFunction.Date(AValue);
  Result := Self;
end;

function TColligoQueryProvider<T>.Day(const AValue: string): IColligoQueryProvider<T>;
begin
  FFluentSQL.Select.Columns.Add.Name := FFunction.Day(AValue);
  FSavedColumns.Add.Name := FFunction.Day(AValue);
  Result := Self;
end;

function TColligoQueryProvider<T>.Month(const AValue: string): IColligoQueryProvider<T>;
begin
  FFluentSQL.Select.Columns.Add.Name := FFunction.Month(AValue);
  FSavedColumns.Add.Name := FFunction.Month(AValue);
  Result := Self;
end;

function TColligoQueryProvider<T>.Year(const AValue: string): IColligoQueryProvider<T>;
begin
  FFluentSQL.Select.Columns.Add.Name := FFunction.Year(AValue);
  FSavedColumns.Add.Name := FFunction.Year(AValue);
  Result := Self;
end;

function TColligoQueryProvider<T>.Concat(const AValue: array of string): IColligoQueryProvider<T>;
begin
  FFluentSQL.Select.Columns.Add.Name := FFunction.Concat(AValue);
  FSavedColumns.Add.Name := FFunction.Concat(AValue);
  Result := Self;
end;

function TColligoQueryProvider<T>.Connection: IDBConnection;
begin
  Result := FConnection;
end;

function TColligoQueryProvider<T>.Sum(const AColumn: string; const AAlias: string): IColligoQueryProvider<T>;
var
  LColumn: IFluentSQLName;
begin
  FFluentSQL.Select.Columns.Clear;
  LColumn := FFluentSQL.Select.Columns.Add;
  LColumn.Name := FFunction.Sum(AColumn);
  LColumn.Alias := AAlias;
  FSavedColumns.Clear;
  FSavedColumns.Add.Name := LColumn.Name;
  Result := Self;
end;

function TColligoQueryProvider<T>.Average(const AColumn: string; const AAlias: string): IColligoQueryProvider<T>;
var
  LColumn: IFluentSQLName;
begin
  FFluentSQL.Select.Columns.Clear;
  LColumn := FFluentSQL.Select.Columns.Add;
  LColumn.Name := FFunction.Average(AColumn);
  LColumn.Alias := AAlias;
  FSavedColumns.Clear;
  FSavedColumns.Add.Name := LColumn.Name;
  Result := Self;
end;

function TColligoQueryProvider<T>.ToArray: IColligoArray<T>;
begin
  Result := ToList.ToArray;
end;

function TColligoQueryProvider<T>.ToList: IColligoList<T>;
var
  LSQL: string;
  LDataSet: IDBDataSet;
  LParserScalar: TColligoParseScalarDataSet<T>;
  LParserObject: TColligoParseObjectDataSet<T>;
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
        LParserObject := TColligoParseObjectDataSet<T>.Create;
        try
          Result := LParserObject.ToList(LDataSet);
        finally
          LParserObject.Free;
        end;
      end
      else
      begin
        LParserScalar := TColligoParseScalarDataSet<T>.Create;
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

function TColligoQueryProvider<T>.AsString: string;
var
  LSerialize: IFluentSQLSerialize;
begin
  Result := '';
  LSerialize := FRegister.Serialize(_GetDriverDatabase);
  if Assigned(LSerialize) then
    Result := LSerialize.AsString(FFluentSQL);
end;

{ TColligoQueryProvider<T>.TStrictPrivateCreate<T> }

class function TColligoQueryProvider<T>.TStrictPrivateCreate<T>.CreateProvider(
  const AInitializer: TConnectionInitializer): TColligoQueryProvider<T>;
begin
  Result := TColligoQueryProvider<T>.Create(AInitializer);
end;

class function TColligoQueryProvider<T>.TStrictPrivateCreate<T>.CreateProvider(
  const ADriver: TDriverName; const AConnection: IDBConnection; const AFluentSQL: IFluentSQLAST): TColligoQueryProvider<T>;
begin
  Result := TColligoQueryProvider<T>.Create(ADriver, AConnection, AFluentSQL);
end;

end.




