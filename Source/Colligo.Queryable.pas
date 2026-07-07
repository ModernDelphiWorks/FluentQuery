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

unit Colligo.Queryable;

interface

uses
  DB,
  Rtti,
  TypInfo,
  Classes,
  SysUtils,
  StrUtils,
  Generics.Collections,
  Generics.Defaults,
  FluentSQL.Interfaces,
  FluentSQL.Expression,
  FluentSQL.Utils,
  FluentSQL.Name,
  DataEngine.FactoryInterfaces,
  Colligo,
  Colligo.Core,
  Colligo.Expression;

const
  dbnMSSQL      = FluentSQL.Interfaces.dbnMSSQL;
  dbnMySQL      = FluentSQL.Interfaces.dbnMySQL;
  dbnFirebird   = FluentSQL.Interfaces.dbnFirebird;
  dbnSQLite     = FluentSQL.Interfaces.dbnSQLite;
  dbnInterbase  = FluentSQL.Interfaces.dbnInterbase;
  dbnDB2        = FluentSQL.Interfaces.dbnDB2;
  dbnOracle     = FluentSQL.Interfaces.dbnOracle;
  dbnInformix   = FluentSQL.Interfaces.dbnInformix;
  dbnPostgreSQL = FluentSQL.Interfaces.dbnPostgreSQL;
  dbnADS        = FluentSQL.Interfaces.dbnADS;
  dbnASA        = FluentSQL.Interfaces.dbnASA;
  dbnAbsoluteDB = FluentSQL.Interfaces.dbnAbsoluteDB;
  dbnMongoDB    = FluentSQL.Interfaces.dbnMongoDB;
  dbnElevateDB  = FluentSQL.Interfaces.dbnElevateDB;
  dbnNexusDB    = FluentSQL.Interfaces.dbnNexusDB;

type
  TDriverName = DataEngine.FactoryInterfaces.TDriverName;
  TFluentSQLDriver = FluentSQL.Interfaces.TFluentSQLDriver;
  IDBConnection = DataEngine.FactoryInterfaces.IDBConnection;
  IDBTransaction = DataEngine.FactoryInterfaces.IDBTransaction;
  IDBDataSet = DataEngine.FactoryInterfaces.IDBDataSet;
  IDBQuery = DataEngine.FactoryInterfaces.IDBQuery;

  TConnectionInitializer = reference to procedure(var ADatabase: TDriverName;
                                                  var AConnection: IDBConnection);

  IColligoQueryProvider<T> = interface;
  IGroupByQueryable<TKey, T> = interface;

  IColligoQueryProvider<T> = interface
    ['{A54C5B9B-89A3-41A8-99E7-EBAFD2758093}']
    function _GetFluentSQL: IFluentSQLAST;
    procedure _SetFluentSQL(const Value: IFluentSQLAST);
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
    function SetValue(const AColumnName: string; AColumnValue: Extended; ACurrencyPlaces: Integer): IColligoQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; AColumnValue: Double; ACurrencyPlaces: Integer): IColligoQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; AColumnValue: Currency; ACurrencyPlaces: Integer): IColligoQueryProvider<T>; overload;
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
    function Min: IColligoQueryProvider<T>; overload;
    function Max: IColligoQueryProvider<T>;
    function Sum(const AColumn: string; const AAlias: string = ''): IColligoQueryProvider<T>;
    function Average(const AColumn: string; const AAlias: string = ''): IColligoQueryProvider<T>;
    function Lower: IColligoQueryProvider<T>;
    function Upper: IColligoQueryProvider<T>;
    function SubString(const AStart: Integer; const ALength: Integer): IColligoQueryProvider<T>;
    function Date(const AValue: string): IColligoQueryProvider<T>;
    function Day(const AValue: string): IColligoQueryProvider<T>;
    function Month(const AValue: string): IColligoQueryProvider<T>;
    function Year(const AValue: string): IColligoQueryProvider<T>;
    function Concat(const AValue: array of string): IColligoQueryProvider<T>;
    function ToArray: IColligoArray<T>;
    function ToList: IColligoList<T>;
    function AsString: string;
    function Database: TDriverName;
    function Connection: IDBConnection;
    property FluentSQL: IFluentSQLAST read _GetFluentSQL write _SetFluentSQL;
  end;

  IColligoQueryableBase<T> = interface(IInterface)
    ['{5E8E37CE-6372-4FBB-872B-9687A24F63DD}']
    function GetEnumerator: IColligoEnumerator<T>;
    function BuildQuery: string;
  end;

  TColligoQueryableBase<T> = class abstract(TInterfacedObject, IColligoQueryableBase<T>)
  protected
    function GetEnumerator: IColligoEnumerator<T>; virtual; abstract;
    function BuildQuery: string; virtual; abstract;
  end;

  TColligoQueryable<T> = class(TColligoQueryableBase<T>)
  private
    FProvider: IColligoQueryProvider<T>;
  protected
    function GetEnumerator: IColligoEnumerator<T>; override;
    function BuildQuery: string; override;
  public
    constructor Create(const AProvider: IColligoQueryProvider<T>); overload;
  end;

  IColligoQueryable<T> = record
  private
    FQueryable: IColligoQueryableBase<T>;
    FEnumerable: IColligoEnumerable<T>;
    FProvider: IColligoQueryProvider<T>;
    FExpression: IColligoQueryExpression;
    function _GetEnumerable: IColligoEnumerable<T>;
    function _ExecuteScalar<TResult>(const ASql: string): TResult;
    function _ExecuteList(const ASql: string): IColligoList<T>;
    function _InitializeFluentSQL: IColligoQueryProvider<T>;
    function _GetDriverDatabase(const ADatabase: TDriverName): TFluentSQLDriver;
  public
    constructor Create(const AQueryable: IColligoQueryableBase<T>); overload;
    constructor CreateForDatabase(const AInitializer: TConnectionInitializer); overload;
    constructor CreateForDatabase(const ADatabase: TDriverName; const AConnection: IDBConnection;
      const AFluentSQL: IFluentSQLAST = nil); overload;
    function IsNotAssigned: Boolean;
    function QE: IColligoQueryExpression;
    function From(const ATableName: string): IColligoQueryable<T>; overload;
    function From(const ATableName: string; const AAlias: string): IColligoQueryable<T>; overload;
    function Where(const AExpression: string = ''): IColligoQueryable<T>; overload;
    function Where(const AExpression: array of const): IColligoQueryable<T>; overload;
    function Where(const AExpression: IColligoQueryExpression): IColligoQueryable<T>; overload;
    function InnerJoin(const ATableName: string): IColligoQueryable<T>; overload;
    function InnerJoin(const ATableName: string; const AAlias: string): IColligoQueryable<T>; overload;
    function OnCond(const AExpression: string): IColligoQueryable<T>; overload;
    function OnCond(const AExpression: array of const): IColligoQueryable<T>; overload;
    function Alias(const AAlias: string): IColligoQueryable<T>;
    function AndOpe(const AExpression: array of const): IColligoQueryable<T>; overload;
    function AndOpe(const AExpression: string): IColligoQueryable<T>; overload;
    function AndOpe(const AExpression: IColligoQueryExpression): IColligoQueryable<T>; overload;
    function OrOpe(const AExpression: array of const): IColligoQueryable<T>; overload;
    function OrOpe(const AExpression: string): IColligoQueryable<T>; overload;
    function OrOpe(const AExpression: IColligoQueryExpression): IColligoQueryable<T>; overload;
    function GroupBy(const AColumnName: string): IColligoQueryable<T>; overload;
    function GroupBy<TKey>(const AExpression: IColligoQueryExpression): IGroupByQueryable<TKey, T>; overload;
    function OrderBy(const AColumnName: string): IColligoQueryable<T>; overload;
    function OrderBy(const AExpression: IColligoQueryExpression): IColligoQueryable<T>; overload;
    function OrderByDesc(const AExpression: IColligoQueryExpression): IColligoQueryable<T>;
    function ThenBy(const AExpression: IColligoQueryExpression): IColligoQueryable<T>;
    function ThenByDescending(const AExpression: IColligoQueryExpression): IColligoQueryable<T>;
    function Take(const ACount: Integer): IColligoQueryable<T>;
    function Skip(const ACount: Integer): IColligoQueryable<T>;
    function Select(const AColumns: string = ''): IColligoQueryable<T>; overload;
    function Select(const AExpressions: TArray<IColligoQueryExpression>): IColligoQueryable<T>; overload;
    function Union(const ASecond: IColligoQueryable<T>): IColligoQueryable<T>;
    function Intersect(const ASecond: IColligoQueryable<T>): IColligoQueryable<T>;
    function Exclude(const ASecond: IColligoQueryable<T>): IColligoQueryable<T>;
    function Join<TInner, TResult>(const AInner: IColligoQueryable<TInner>;
      const AOuterKey: IColligoQueryExpression; const AInnerKey: IColligoQueryExpression;
      const AResultColumns: TArray<IColligoQueryExpression>): IColligoQueryable<TResult>;
    function Distinct: IColligoQueryable<T>;
//    function Cast<TResult>(const AConverter: TFunc<T, TResult>): IColligoQueryable<TResult>;
//    function OfType<TResult>(const AIsType: TFunc<T, Boolean>;
//      const AConverter: TFunc<T, TResult>): IColligoQueryable<TResult>;
    function Any(const AExpression: IColligoQueryExpression): Boolean; overload;
    function Any: Boolean; overload;
    function All(const AExpression: IColligoQueryExpression): Boolean;
    function Contains(const AValue: T; const AComparer: IEqualityComparer<T>): Boolean;
    function Count(const AExpression: IColligoQueryExpression): Integer; overload;
    function Count: Integer; overload;
    function LongCount(const AExpression: IColligoQueryExpression): Int64; overload;
    function LongCount: Int64; overload;
    function Min: T; overload;
    function Min(const AComparer: IComparer<T>): T; overload;
    function Min<TResult>(const AFieldName: string; const AAlias: string = ''): TResult; overload;
    function MinBy(const AFieldName: string): T;
    function Max: T; overload;
    function Max(const AComparer: IComparer<T>): T; overload;
    function Max<TResult>(const AFieldName: string; const AAlias: string = ''): TResult; overload;
    function MaxBy(const AFieldName: string): T;
    function Sum<TResult>(const AFieldName: string; const AAlias: string = ''): TResult;
    function Average<TResult>(const AFieldName: string; const AAlias: string = ''): TResult;
    function First(const AExpression: IColligoQueryExpression): T; overload;
    function First: T; overload;
    function FirstOrDefault(const AExpression: IColligoQueryExpression): T; overload;
    function FirstOrDefault: T; overload;
    function Last(const AExpression: IColligoQueryExpression): T; overload;
    function Last: T; overload;
    function LastOrDefault(const AExpression: IColligoQueryExpression): T; overload;
    function LastOrDefault: T; overload;
    function Single(const AExpression: IColligoQueryExpression): T; overload;
    function Single: T; overload;
    function SingleOrDefault(const AExpression: IColligoQueryExpression): T; overload;
    function SingleOrDefault: T; overload;
    function ElementAt(const AIndex: Integer): T;
    function ElementAtOrDefault(const AIndex: Integer): T;
//    function Aggregate<TAccumulate>(const ASeed: TAccumulate;
//      const AFunc: TFunc<TAccumulate, T, TAccumulate>): TAccumulate; overload;
//    function Aggregate<TAccumulate, TResult>(const ASeed: TAccumulate;
//      const AFunc: TFunc<TAccumulate, T, TAccumulate>;
//      const AResultSelector: TFunc<TAccumulate, TResult>): TResult; overload;
//    function Chunk(const ASize: Integer): IColligoChunkResult<T>;
    function ToArray: IColligoArray<T>;
    function ToList: IColligoList<T>;
    function AsString: string;
    function AsEnumerable: IColligoEnumerable<T>;
  end;

  IGroupByQueryable<TKey, T> = interface(IInterface)
    ['{A85DB3F6-E808-4E81-B386-75190087507B}']
    function GetEnumerator: IColligoEnumerator<IGrouping<TKey, T>>;
    function AsEnumerable: IColligoEnumerable<IGrouping<TKey, T>>;
    function ToList: IColligoList<IGrouping<TKey, T>>;
  end;

  TDataSetEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FDataSet: IDBDataSet;
    FIsFirst: Boolean;
    function ParseCurrent: T;
  public
    constructor Create(const ADataSet: IDBDataSet);
    destructor Destroy; override;
    procedure Reset;
    function MoveNext: Boolean;
    function GetCurrent: T;
    property Current: T read GetCurrent;
  end;

  TQE = class
  public
    class function New<T>(const ADatabase: TFluentSQLDriver): IColligoQueryExpression; static;
  end;

implementation

uses
  ModernSyntax.Tuple,
  Colligo.Parse,
  Colligo.Provider,
  Colligo.Adapters,
  Colligo.GroupBy,
  Colligo.Select,
  Colligo.Union,
  Colligo.Intersect,
  Colligo.Exclude,
  Colligo.Join,
  Colligo.OfType,
  Colligo.Cast;

{$IFDEF QUERYABLE}
{ IColligoQueryable<T> }

constructor IColligoQueryable<T>.Create(const AQueryable: IColligoQueryableBase<T>);
begin
  FQueryable := AQueryable;
  FEnumerable := _GetEnumerable;
  _InitializeFluentSQL;
end;

constructor IColligoQueryable<T>.CreateForDatabase(const AInitializer: TConnectionInitializer);
begin
  if not Assigned(AInitializer) then
    raise EArgumentNilException.Create('Connection initializer cannot be nil');
  FProvider := TColligoQueryProvider<T>.TStrictPrivateCreate<T>.CreateProvider(AInitializer);
  FQueryable := TColligoQueryable<T>.Create(FProvider);
  FEnumerable := _GetEnumerable;
  FExpression := TColligoQueryExpression<T>.Create(_GetDriverDatabase(FProvider.Database));
  _InitializeFluentSQL;
end;

constructor IColligoQueryable<T>.CreateForDatabase(const ADatabase: TDriverName;
  const AConnection: IDBConnection; const AFluentSQL: IFluentSQLAST);
begin
  if AConnection = nil then
    raise EArgumentNilException.Create('Connection cannot be nil');
  if TStrDriverName[ADatabase] = '' then
    raise EArgumentNilException.Create('Database type must be specified');
  FProvider := TColligoQueryProvider<T>.TStrictPrivateCreate<T>.CreateProvider(ADatabase, AConnection, AFluentSQL);
  FQueryable := TColligoQueryable<T>.Create(FProvider);
  FEnumerable := _GetEnumerable;
  FExpression := TColligoQueryExpression<T>.Create(_GetDriverDatabase(ADatabase));
  _InitializeFluentSQL;
end;

function IColligoQueryable<T>._GetEnumerable: IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(
    TQueryableToEnumerableAdapter<T>.Create(FQueryable),
    ftNone,
    TEqualityComparer<T>.Default
  );
end;

function IColligoQueryable<T>._InitializeFluentSQL: IColligoQueryProvider<T>;
begin
  Result := FProvider;
  if FProvider.FluentSQL.Select.IsEmpty then
    Result.Select('*');
end;

function IColligoQueryable<T>._ExecuteScalar<TResult>(const ASql: string): TResult;
var
  LSQL: string;
  LDataSet: IDBDataSet;
  LParserScalar: TColligoParseScalarDataSet<TResult>;
  LParserObject: TColligoParseObjectDataSet<TResult>;
  LContext: TRttiContext;
  LType: TRttiType;
  LList: IColligoList<TResult>;
begin
  LSQL := ASql;
  if LSQL.IsEmpty then
    raise EInvalidOperation.Create('Generated SQL is empty');

  LDataSet := FProvider.Connection.CreateDataSet(LSQL);
  if not Assigned(LDataSet) then
    raise EInvalidOperation.Create('Failed to create dataset for SQL: ' + LSQL);
  try
    LDataSet.Open;
    if not LDataSet.Active then
      raise EInvalidOperation.Create('Failed to open dataset for SQL: ' + LSQL);
    if LDataSet.Eof then
      raise EInvalidOperation.Create('Scalar query returned no results');
    if LDataSet.FieldCount = 0 then
      raise EInvalidOperation.Create('No fields returned for SQL: ' + LSQL);

    LContext := TRttiContext.Create;
    try
      LType := LContext.GetType(TypeInfo(TResult));
      if not Assigned(LType) then
        raise EInvalidOperation.Create('Type information not available for TResult');

      if LType.TypeKind in [tkClass, tkInterface] then
      begin
        LParserObject := TColligoParseObjectDataSet<TResult>.Create;
        try
          LList := LParserObject.ToList(LDataSet);
        finally
          LParserObject.Free;
        end;
      end
      else
      begin
        LParserScalar := TColligoParseScalarDataSet<TResult>.Create;
        try
          LList := LParserScalar.ToList(LDataSet);
        finally
          LParserScalar.Free;
        end;
      end;
      if LList.Count = 0 then
        raise EInvalidOperation.Create('Scalar query returned no results');
      Result := LList[0];
    finally
      LContext.Free;
    end;
  finally
    LDataSet.Close;
  end;
end;

function IColligoQueryable<T>._ExecuteList(const ASql: string): IColligoList<T>;
begin
  Result := FProvider.ToList;
end;

function IColligoQueryable<T>.Select(const AColumns: string): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.Select(IfThen(AColumns = EmptyStr, '*', AColumns));
  Result := Self;
end;

function IColligoQueryable<T>.From(const ATableName: string): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.From(ATableName);
  Result := Self;
end;

function IColligoQueryable<T>.From(const ATableName, AAlias: string): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.From(ATableName, AAlias);
  Result := Self;
end;

function IColligoQueryable<T>.Where(const AExpression: string): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.Where(AExpression);
  Result := Self;
end;

function IColligoQueryable<T>.Where(const AExpression: array of const): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.Where(AExpression);
  Result := Self;
end;

function IColligoQueryable<T>.InnerJoin(const ATableName: string): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.InnerJoin(ATableName);
  Result := Self;
end;

function IColligoQueryable<T>.InnerJoin(const ATableName, AAlias: string): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.InnerJoin(ATableName, AAlias);
  Result := Self;
end;

function IColligoQueryable<T>.OnCond(const AExpression: string): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.OnCond(AExpression);
  Result := Self;
end;

function IColligoQueryable<T>.OnCond(const AExpression: array of const): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.OnCond(AExpression);
  Result := Self;
end;

function IColligoQueryable<T>.Alias(const AAlias: string): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.Alias(AAlias);
  Result := Self;
end;

function IColligoQueryable<T>.AndOpe(const AExpression: array of const): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.AndOpe(AExpression);
  Result := Self;
end;

function IColligoQueryable<T>.AndOpe(const AExpression: string): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.AndOpe(AExpression);
  Result := Self;
end;

function IColligoQueryable<T>.OrOpe(const AExpression: array of const): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.OrOpe(AExpression);
  Result := Self;
end;

function IColligoQueryable<T>.OrOpe(const AExpression: string): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.OrOpe(AExpression);
  Result := Self;
end;

function IColligoQueryable<T>.GroupBy(const AColumnName: string): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.GroupBy(AColumnName);
  Result := Self;
end;

function IColligoQueryable<T>.GroupBy<TKey>(const AExpression: IColligoQueryExpression): IGroupByQueryable<TKey, T>;
var
  LColumnName: string;
begin
  if not Assigned(AExpression) then
    raise EArgumentNilException.Create('Selector cannot be nil');

  LColumnName := AExpression.Serialize;
  if LColumnName.IsEmpty then
    raise EInvalidOperation.Create('Could not extract column name from selector');

  FProvider.GroupBy(LColumnName);
  Result := TColligoGroupByQueryable<TKey, T>.Create(FQueryable, AExpression, FProvider);
end;

function IColligoQueryable<T>.OrderBy(const AColumnName: string): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.OrderBy(AColumnName);
  Result := Self;
end;

function IColligoQueryable<T>.OrderBy(const AExpression: IColligoQueryExpression): IColligoQueryable<T>;
var
  LColumnName: string;
begin
  if not Assigned(AExpression) then
    raise EArgumentNilException.Create('Selector cannot be nil');

  LColumnName := AExpression.Serialize;
  if LColumnName.IsEmpty then
    raise EInvalidOperation.Create('Could not extract column name from selector');

  FProvider.OrderBy(LColumnName);
  Result := Self;
end;

function IColligoQueryable<T>.OrderByDesc(const AExpression: IColligoQueryExpression): IColligoQueryable<T>;
var
  LColumnName: string;
begin
  if not Assigned(AExpression) then
    raise EArgumentNilException.Create('Selector cannot be nil');

  LColumnName := AExpression.Serialize;
  if LColumnName.IsEmpty then
    raise EInvalidOperation.Create('Could not extract column name from selector');

  FProvider.OrderBy(LColumnName).Desc;
  Result := Self;
end;

function IColligoQueryable<T>.OrOpe(const AExpression: IColligoQueryExpression): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.OrOpe(AExpression.Serialize);
  Result := Self;
end;

function IColligoQueryable<T>.QE: IColligoQueryExpression;
begin
  Result := FExpression;
end;

function IColligoQueryable<T>.ThenBy(const AExpression: IColligoQueryExpression): IColligoQueryable<T>;
var
  LColumnName: string;
begin
  if not Assigned(AExpression) then
    raise EArgumentNilException.Create('Expression cannot be nil');

  LColumnName := AExpression.Serialize;
  if LColumnName.IsEmpty then
    raise EInvalidOperation.Create('Could not extract column name from selector');

  FProvider.FluentSQL.OrderBy.Columns.Add.Name := LColumnName;
  (FProvider.FluentSQL.OrderBy.Columns[Pred(FProvider.FluentSQL.OrderBy.Columns.Count)] as IFluentSQLOrderByColumn).Direction := dirAscending;
  Result := Self;
end;

function IColligoQueryable<T>.ThenByDescending(const AExpression: IColligoQueryExpression): IColligoQueryable<T>;
var
  LColumnName: string;
begin
  if not Assigned(AExpression) then
    raise EArgumentNilException.Create('Expression cannot be nil');

  LColumnName := AExpression.Serialize;
  if LColumnName.IsEmpty then
    raise EInvalidOperation.Create('Could not extract column name from selector');

  FProvider.FluentSQL.OrderBy.Columns.Add.Name := LColumnName;
  (FProvider.FluentSQL.OrderBy.Columns[Pred(FProvider.FluentSQL.OrderBy.Columns.Count)] as IFluentSQLOrderByColumn).Direction := dirDescending;
  Result := Self;
end;

function IColligoQueryable<T>.Take(const ACount: Integer): IColligoQueryable<T>;
begin
  if ACount < 1 then
    raise EArgumentException.Create('ACount must be greater than 0');
  FProvider.First(ACount);
  Result := Self;
end;

function IColligoQueryable<T>.Skip(const ACount: Integer): IColligoQueryable<T>;
begin
  Result := IColligoQueryable<T>.Create(FQueryable);
  FProvider.Skip(ACount);
  Result := Self;
end;

function IColligoQueryable<T>.Select(const AExpressions: TArray<IColligoQueryExpression>): IColligoQueryable<T>;
var
  LExpression: IColligoQueryExpression;
  LColumnName: string;
begin
  if Length(AExpressions) = 0 then
    raise EArgumentNilException.Create('Expressions cannot be empty');

  FProvider.FluentSQL.Select.Columns.Clear;
  for LExpression in AExpressions do
  begin
    if not Assigned(LExpression) then
      raise EArgumentNilException.Create('Expression cannot be nil');

    LColumnName := LExpression.Serialize;
    if LColumnName.IsEmpty then
      raise EInvalidOperation.Create('Could not extract column name from selector');

   FProvider.FluentSQL.Select.Columns.Add.Name := LColumnName;
  end;
  Result := Self;
end;

function IColligoQueryable<T>.Union(const ASecond: IColligoQueryable<T>): IColligoQueryable<T>;
begin
  Result := IColligoQueryable<T>.Create(
    TColligoUnionQueryable<T>.Create(FQueryable, ASecond.FQueryable, nil)
  );
end;

function IColligoQueryable<T>.Intersect(const ASecond: IColligoQueryable<T>): IColligoQueryable<T>;
begin
  Result := IColligoQueryable<T>.Create(
    TColligoIntersectQueryable<T>.Create(FQueryable, ASecond.FQueryable, nil)
  );
end;

function IColligoQueryable<T>.Exclude(const ASecond: IColligoQueryable<T>): IColligoQueryable<T>;
begin
  Result := IColligoQueryable<T>.Create(
    TColligoExcludeQueryable<T>.Create(FQueryable, ASecond.FQueryable, nil)
  );
end;

function IColligoQueryable<T>.Join<TInner, TResult>(const AInner: IColligoQueryable<TInner>;
  const AOuterKey: IColligoQueryExpression; const AInnerKey: IColligoQueryExpression;
  const AResultColumns: TArray<IColligoQueryExpression>): IColligoQueryable<TResult>;
var
  LOuterKeyName, LInnerKeyName, LInnerTableName: string;
  LExpression: IColligoQueryExpression;
  LColumnName: string;
  LJoinQuery: TColligoJoinQueryable<TInner, TResult, T>;
  LNewProvider: IColligoQueryProvider<TResult>;
begin
  if not Assigned(AInner.FProvider) then
    raise EArgumentNilException.Create('Inner query cannot be nil');
  if not Assigned(AOuterKey) then
    raise EArgumentNilException.Create('Outer key expression cannot be nil');
  if not Assigned(AInnerKey) then
    raise EArgumentNilException.Create('Inner key expression cannot be nil');
  if Length(AResultColumns) = 0 then
    raise EArgumentNilException.Create('Result columns cannot be empty');

  LOuterKeyName := AOuterKey.Serialize;
  LInnerKeyName := AInnerKey.Serialize;
  if LOuterKeyName.IsEmpty then
    raise EInvalidOperation.Create('Could not extract outer key column name');
  if LInnerKeyName.IsEmpty then
    raise EInvalidOperation.Create('Could not extract inner key column name');

  LInnerTableName := AInner.FProvider.FluentSQL.Select.TableNames[0].Serialize;
  if LInnerTableName.IsEmpty then
    raise EInvalidOperation.Create('Could not extract inner table name');


  FProvider.FluentSQL.Select.Columns.Clear;
  FProvider.InnerJoin(LInnerTableName);
  FProvider.OnCond(LOuterKeyName + ' = ' + LInnerKeyName);
  for LExpression in AResultColumns do
  begin
    if not Assigned(LExpression) then
      raise EArgumentNilException.Create('Result column expression cannot be nil');

    LColumnName := LExpression.Serialize;
    if LColumnName.IsEmpty then
      raise EInvalidOperation.Create('Could not extract result column name');

    FProvider.FluentSQL.Select.Columns.Add.Name := LColumnName;
  end;
  LNewProvider := TColligoQueryProvider<TResult>.TStrictPrivateCreate<TResult>
                                               .CreateProvider(FProvider.Database,
                                                               FProvider.Connection,
                                                               FProvider.FluentSQL);
  LJoinQuery := TColligoJoinQueryable<TInner, TResult, T>.Create(LNewProvider);
  try
    Result := LJoinQuery.AsQueryable;
  finally
    LJoinQuery.Free;
  end;
end;

function IColligoQueryable<T>.Distinct: IColligoQueryable<T>;
begin
  Result := IColligoQueryable<T>.Create(FQueryable);
  FProvider.DistinctSQL;
end;

//function IColligoQueryable<T>.OfType<TResult>(
//  const AIsType: TFunc<T, Boolean>;
//  const AConverter: TFunc<T, TResult>): IColligoQueryable<TResult>;
//begin
//  if not Assigned(AIsType) then
//    raise EArgumentNilException.Create('IsType cannot be nil');
//  if not Assigned(AConverter) then
//    raise EArgumentNilException.Create('Converter cannot be nil');
//  Result := IColligoQueryable<TResult>.Create(
//    TColligoOfTypeQueryable<T, TResult>.Create(FQueryable, AIsType, AConverter)
//  );
//end;

//function IColligoQueryable<T>.Cast<TResult>(const AConverter: TFunc<T, TResult>): IColligoQueryable<TResult>;
//begin
//  if not Assigned(AConverter) then
//    raise EArgumentNilException.Create('Converter cannot be nil');
//  Result := IColligoQueryable<TResult>.Create(
//    TColligoCastQueryable<T, TResult>.Create(FQueryable, AConverter)
//  );
//end;

function IColligoQueryable<T>.Any(const AExpression: IColligoQueryExpression): Boolean;
begin
  FProvider.Where('NOT (' + AExpression.Serialize + ')');
  FProvider.Count;
  Result := _ExecuteScalar<Integer>(FQueryable.BuildQuery) > 0;
end;

function IColligoQueryable<T>.Any: Boolean;
begin
  Result := _ExecuteScalar<Integer>(FQueryable.BuildQuery) > 0;
end;

function IColligoQueryable<T>.All(const AExpression: IColligoQueryExpression): Boolean;
begin
  FProvider.Where('NOT (' + AExpression.Serialize + ')');
  FProvider.Count;
  Result := _ExecuteScalar<Integer>(FQueryable.BuildQuery) = 0;
end;

function IColligoQueryable<T>.Contains(const AValue: T;
  const AComparer: IEqualityComparer<T>): Boolean;
begin
  Result := FEnumerable.Contains(AValue, AComparer);
end;

function IColligoQueryable<T>.Count(const AExpression: IColligoQueryExpression): Integer;
begin
  FProvider.Where(AExpression.Serialize);
  FProvider.Count;
  Result := _ExecuteScalar<Integer>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.Count: Integer;
begin
  FProvider.Count;
  Result := _ExecuteScalar<Integer>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.LongCount(const AExpression: IColligoQueryExpression): Int64;
var
  LColumns: string;
begin
  if not Assigned(FProvider) then
    raise EInvalidOperation.Create('Query provider is not assigned');

  LColumns := FProvider.FluentSQL.Select.Columns.Serialize;
  FProvider.Where(AExpression.Serialize);
  FProvider.Count;
  Result := _ExecuteScalar<Int64>(FQueryable.BuildQuery);
  FProvider.FluentSQL.Select.Columns.Clear;
  FProvider.Column(LColumns);
end;

function IColligoQueryable<T>.LongCount: Int64;
begin
  FProvider.Count;
  Result := _ExecuteScalar<Int64>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.Min: T;
begin
  FProvider.Min;
  Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.Min(const AComparer: IComparer<T>): T;
begin
  Result := FEnumerable.Min(AComparer);
end;

function IColligoQueryable<T>.Min<TResult>(const AFieldName: string; const AAlias: string): TResult;
var
  LColumn: IFluentSQLName;
begin
  if AFieldName = EmptyStr then
    raise EInvalidOperation.Create('Field name cannot be empty');

  FProvider.FluentSQL.Select.Columns.Clear;
  LColumn := FProvider.FluentSQL.Select.Columns.Add;
  LColumn.Name := AFieldName;
  LColumn.Alias := AAlias;
  FProvider.Min;
  Result := _ExecuteScalar<TResult>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.MinBy(const AFieldName: string): T;
var
  LColumn: IFluentSQLName;
  LFor: Integer;
  LFound: Boolean;
begin
  if AFieldName = EmptyStr then
    raise EInvalidOperation.Create('Field name cannot be empty');

  LFound := False;
  for LFor := 0 to FProvider.FluentSQL.Select.Columns.Count - 1 do
  begin
    LColumn := FProvider.FluentSQL.Select.Columns[LFor];
    if SameText(LColumn.Name, AFieldName) then
    begin
      LFound := True;
      Break;
    end;
  end;
  if not LFound then
    raise EInvalidOperation.CreateFmt('Column "%s" not found in the query.', [AFieldName]);

  FProvider.OrderBy(AFieldName);
  FProvider.First(1);
  Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.Max: T;
begin
  FProvider.Max;
  Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.Max(const AComparer: IComparer<T>): T;
begin
  Result := FEnumerable.Max(AComparer);
end;

function IColligoQueryable<T>.Max<TResult>(const AFieldName: string; const AAlias: string): TResult;
var
  LColumn: IFluentSQLName;
begin
  if AFieldName = EmptyStr then
    raise EInvalidOperation.Create('Field name cannot be empty');

  FProvider.FluentSQL.Select.Columns.Clear;
  LColumn := FProvider.FluentSQL.Select.Columns.Add;
  LColumn.Name := AFieldName;
  LColumn.Alias := AAlias;
  FProvider.Max;
  Result := _ExecuteScalar<TResult>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.MaxBy(const AFieldName: string): T;
var
  LColumn: IFluentSQLName;
  LFor: Integer;
  LFound: Boolean;
begin
  if AFieldName = EmptyStr then
    raise EInvalidOperation.Create('Field name cannot be empty');

  LFound := False;
  for LFor := 0 to FProvider.FluentSQL.Select.Columns.Count - 1 do
  begin
    LColumn := FProvider.FluentSQL.Select.Columns[LFor];
    if SameText(LColumn.Name, AFieldName) then
    begin
      LFound := True;
      Break;
    end;
  end;
  if not LFound then
    raise EInvalidOperation.CreateFmt('Column "%s" not found in the query.', [AFieldName]);

  FProvider.OrderBy(AFieldName).Desc;
  FProvider.First(1);
  Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.Sum<TResult>(const AFieldName: string; const AAlias: string): TResult;
var
  LColumn: IFluentSQLName;
  LFor: Integer;
  LFound: Boolean;
  LTypeInfo: PTypeInfo;
begin
  if AFieldName = EmptyStr then
    raise EInvalidOperation.Create('Field name cannot be empty');

  LTypeInfo := TypeInfo(TResult);
  if not (LTypeInfo^.Kind in [tkInteger, tkInt64, tkFloat]) then
    raise EInvalidOperation.CreateFmt('Invalid result type "%s" for Sum. Expected Integer, Int64, or Float.', [LTypeInfo^.Name]);

  LFound := False;
  for LFor := 0 to FProvider.FluentSQL.Select.Columns.Count - 1 do
  begin
    LColumn := FProvider.FluentSQL.Select.Columns[LFor];
    if SameText(LColumn.Name, AFieldName) then
    begin
      LFound := True;
      Break;
    end;
  end;
  if not LFound then
    raise EInvalidOperation.CreateFmt('Column "%s" not found in the query.', [AFieldName]);

  FProvider.Sum(AFieldName, AAlias);
  Result := _ExecuteScalar<TResult>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.Average<TResult>(const AFieldName: string; const AAlias: string): TResult;
var
  LColumn: IFluentSQLName;
  LFor: Integer;
  LFound: Boolean;
  LTypeInfo: PTypeInfo;
begin
  if AFieldName = EmptyStr then
    raise EInvalidOperation.Create('Field name cannot be empty');

  LTypeInfo := TypeInfo(TResult);
  if not (LTypeInfo^.Kind in [tkInteger, tkInt64, tkFloat]) then
    raise EInvalidOperation.CreateFmt('Invalid result type "%s" for Average. Expected Integer, Int64, or Float.', [LTypeInfo^.Name]);

  LFound := False;
  for LFor := 0 to FProvider.FluentSQL.Select.Columns.Count - 1 do
  begin
    LColumn := FProvider.FluentSQL.Select.Columns[LFor];
    if SameText(LColumn.Name, AFieldName) then
    begin
      LFound := True;
      Break;
    end;
  end;
  if not LFound then
    raise EInvalidOperation.CreateFmt('Column "%s" not found in the query.', [AFieldName]);

  FProvider.Average(AFieldName, AAlias);
  Result := _ExecuteScalar<TResult>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.First(const AExpression: IColligoQueryExpression): T;
begin
  FProvider.Where(AExpression.Serialize);
  FProvider.First(1);
  Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.First: T;
begin
  Result := Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.FirstOrDefault(const AExpression: IColligoQueryExpression): T;
begin
  FProvider.Where(AExpression.Serialize);
  FProvider.First(1);
  try
    Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
  except
    on E: EInvalidOperation do
      if Pos('Scalar query returned no results', E.Message) > 0 then
        Result := Default(T)
      else
        raise;
  end;
end;

function IColligoQueryable<T>.FirstOrDefault: T;
begin
  FProvider.Count;
  if _ExecuteScalar<Integer>(FQueryable.BuildQuery) > 0 then
    Result := Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery)
  else
    Result := Default(T);
end;

function IColligoQueryable<T>.Last(const AExpression: IColligoQueryExpression): T;
begin
  FProvider.Where(AExpression.Serialize);
  FProvider.OrderBy('ID').Desc;
  FProvider.First(1);
  Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.Last: T;
begin
  Result := OrderByDesc(nil).Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.LastOrDefault(const AExpression: IColligoQueryExpression): T;
begin
  FProvider.Where(AExpression.Serialize);
  FProvider.OrderBy('ID').Desc;
  FProvider.First(1);
  try
    Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
  except
    on E: EInvalidOperation do
      if Pos('Scalar query returned no results', E.Message) > 0 then
        Result := Default(T)
      else
        raise;
  end;
end;

function IColligoQueryable<T>.LastOrDefault: T;
begin
  FProvider.Count;
  if _ExecuteScalar<Integer>(FQueryable.BuildQuery) > 0 then
    Result := OrderByDesc(nil).Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery)
  else
    Result := Default(T);
end;

function IColligoQueryable<T>.Single(const AExpression: IColligoQueryExpression): T;
var
  LCount: Integer;
  LColumns: string;
begin
  LColumns := FProvider.FluentSQL.Select.Columns.Serialize;
  FProvider.Where(AExpression.Serialize);
  FProvider.Count;
  LCount := _ExecuteScalar<Integer>(FQueryable.BuildQuery);
  if LCount <> 1 then
    raise EInvalidOperation.Create('Sequence contains ' + IntToStr(LCount) + ' elements; expected exactly one');

  FProvider.FluentSQL.Select.Columns.Clear;
  FProvider.Column(LColumns);
  FProvider.Where(AExpression.Serialize);
  FProvider.First(1);
  Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.Single: T;
var
  LCount: Integer;
begin
  FProvider.Count;
  LCount := _ExecuteScalar<Integer>(FQueryable.BuildQuery);
  if LCount = 1 then
    Result := Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery)
  else
    raise EInvalidOperation.Create('Sequence contains more than one element or is empty');
end;

function IColligoQueryable<T>.SingleOrDefault(const AExpression: IColligoQueryExpression): T;
var
  LCount: Integer;
  LColumns: string;
begin
  if not Assigned(FProvider) then
    raise EInvalidOperation.Create('Query provider is not assigned');
  LColumns := FProvider.FluentSQL.Select.Columns.Serialize;
  FProvider.Where(AExpression.Serialize);
  FProvider.Count;
  LCount := _ExecuteScalar<Integer>(FQueryable.BuildQuery);
  if LCount > 1 then
    raise EInvalidOperation.Create('Sequence contains ' + IntToStr(LCount) + ' elements; expected zero or one');

  if LCount > 0 then
  begin
    FProvider.FluentSQL.Select.Columns.Clear;
    FProvider.Column(LColumns);
    FProvider.Where(AExpression.Serialize);
    FProvider.First(1);
    Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
  end
  else
    Result := Default(T);
end;

function IColligoQueryable<T>.SingleOrDefault: T;
var
  LCount: Integer;
begin
  FProvider.Count;
  LCount := _ExecuteScalar<Integer>(FQueryable.BuildQuery);
  if LCount = 1 then
    Result := Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery)
  else if LCount = 0 then
    Result := Default(T)
  else
    raise EInvalidOperation.Create('Sequence contains more than one element');
end;

function IColligoQueryable<T>.ElementAt(const AIndex: Integer): T;
begin
  Result := Skip(AIndex).Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.ElementAtOrDefault(const AIndex: Integer): T;
begin
  FProvider.Count;
  if Skip(AIndex)._ExecuteScalar<Integer>(FQueryable.BuildQuery) > 0 then
    Result := Skip(AIndex).Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery)
  else
    Result := Default(T);
end;

//function IColligoQueryable<T>.Aggregate<TAccumulate>(
//  const ASeed: TAccumulate;
//  const AFunc: TFunc<TAccumulate, T, TAccumulate>): TAccumulate;
//begin
//  Result := FEnumerable.Aggregate<TAccumulate>(ASeed, AFunc);
//end;

//function IColligoQueryable<T>.Aggregate<TAccumulate, TResult>(
//  const ASeed: TAccumulate;
//  const AFunc: TFunc<TAccumulate, T, TAccumulate>;
//  const AResultSelector: TFunc<TAccumulate, TResult>): TResult;
//begin
//  Result := FEnumerable.Aggregate<TAccumulate, TResult>(ASeed, AFunc, AResultSelector);
//end;

//function IColligoQueryable<T>.Chunk(const ASize: Integer): IColligoChunkResult<T>;
//begin
//  Result := FEnumerable.Chunk(ASize);
//end;

function IColligoQueryable<T>.ToArray: IColligoArray<T>;
begin
  Result := _ExecuteList(FQueryable.BuildQuery).ToArray;
end;

function IColligoQueryable<T>.ToList: IColligoList<T>;
begin
  Result := _ExecuteList(FQueryable.BuildQuery);
end;

function IColligoQueryable<T>.AsString: string;
begin
  Result := FProvider.AsString;
end;

function IColligoQueryable<T>.AsEnumerable: IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(
    TQueryableToEnumerableAdapter<T>.Create(FQueryable),
    ftNone,
    TEqualityComparer<T>.Default
  );
end;

function IColligoQueryable<T>.IsNotAssigned: Boolean;
begin
  Result := not TEqualityComparer<IColligoQueryable<T>>.Default.Equals(Self, Default(IColligoQueryable<T>));
end;

function IColligoQueryable<T>._GetDriverDatabase(const ADatabase: TDriverName): TFluentSQLDriver;
begin
  case ADatabase of
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

function IColligoQueryable<T>.AndOpe(const AExpression: IColligoQueryExpression): IColligoQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.AndOpe(AExpression.Serialize);
  Result := Self;
end;

function IColligoQueryable<T>.Where(const AExpression: IColligoQueryExpression): IColligoQueryable<T>;
begin
  FProvider.Where(AExpression.Serialize);
  Result := Self;
end;

{ TColligoQueryable<T> }

constructor TColligoQueryable<T>.Create(const AProvider: IColligoQueryProvider<T>);
begin
  FProvider := AProvider;
end;

function TColligoQueryable<T>.GetEnumerator: IColligoEnumerator<T>;
var
  LSql: string;
  LDataSet: IDBDataSet;
begin
  LSql := BuildQuery;
  LDataSet := FProvider.Connection.CreateDataSet(LSql);
  Result := TDataSetEnumerator<T>.Create(LDataSet);
end;

function TColligoQueryable<T>.BuildQuery: string;
begin
  if Assigned(FProvider) then
    Result := FProvider.AsString
  else
    raise EInvalidOperation.Create('Provider not assigned for query building');
end;
{$ENDIF}

{ TDataSetEnumerator<T> }

constructor TDataSetEnumerator<T>.Create(const ADataSet: IDBDataSet);
begin
  inherited Create;
  FDataSet := ADataSet;
  FIsFirst := True;
end;

destructor TDataSetEnumerator<T>.Destroy;
begin
  if Assigned(FDataSet) then
    FDataSet.Close;
  inherited;
end;

function TDataSetEnumerator<T>.ParseCurrent: T;
var
  LKeys: TArray<string>;
  LValues: TArray<TValue>;
  LFor: Integer;
  LField: TField;
  LTuple: TTuple<string>;
  LValue: TValue;
  LResult: T;
begin
  if FDataSet.FieldCount > 1 then
  begin
    SetLength(LKeys, FDataSet.FieldCount);
    SetLength(LValues, FDataSet.FieldCount);
    for LFor := 0 to FDataSet.FieldCount - 1 do
    begin
      LField := FDataSet.Fields[LFor];
      if not Assigned(LField) then
        raise EInvalidOperation.Create('Field at index ' + IntToStr(LFor) + ' is nil');

      LKeys[LFor] := Trim(LField.FieldName);
      case LField.DataType of
        ftString, ftWideString:
          LValues[LFor] := TValue.From(LField.AsString);
        ftInteger, ftSmallint, ftWord, ftLargeint:
          LValues[LFor] := TValue.From(LField.AsInteger);
        ftFloat, ftCurrency:
          LValues[LFor] := TValue.From(LField.AsFloat);
        ftDate, ftDateTime:
          LValues[LFor] := TValue.From(LField.AsDateTime);
        ftBoolean:
          LValues[LFor] := TValue.From(LField.AsBoolean);
        else
          raise EInvalidCast.Create('Unsupported field type: ' + GetEnumName(TypeInfo(TFieldType), Ord(LField.DataType)));
      end;
    end;
    LTuple := TTuple<string>.New(LKeys, LValues);
    LValue := TValue.From(LTuple);
    if not LValue.TryAsType<T>(LResult) then
      raise EInvalidCast.Create('Cannot convert tuple to type T');
    Result := LResult;
  end
  else
  begin
    LField := FDataSet.Fields[0];
    if not Assigned(LField) then
      raise EInvalidOperation.Create('Field at index 0 is nil');

    case LField.DataType of
      ftString, ftWideString:
        LValue := TValue.From(LField.AsString);
      ftInteger, ftSmallint, ftWord, ftLargeint:
        LValue := TValue.From(LField.AsInteger);
      ftFloat, ftCurrency:
        LValue := TValue.From(LField.AsFloat);
      ftDate, ftDateTime:
        LValue := TValue.From(LField.AsDateTime);
      ftBoolean:
        LValue := TValue.From(LField.AsBoolean);
      else
        raise EInvalidCast.Create('Unsupported field type: ' + GetEnumName(TypeInfo(TFieldType), Ord(LField.DataType)));
    end;

    if not LValue.TryAsType<T>(LResult) then
      raise EInvalidCast.Create('Cannot convert field ''' + LField.FieldName + ''' to type T');
    Result := LResult;
  end;
end;

procedure TDataSetEnumerator<T>.Reset;
begin

end;

function TDataSetEnumerator<T>.MoveNext: Boolean;
begin
  if FIsFirst then
  begin
    FIsFirst := False;
    Result := not FDataSet.Eof;
  end
  else
  begin
    FDataSet.Next;
    Result := not FDataSet.Eof;
  end;
end;

function TDataSetEnumerator<T>.GetCurrent: T;
begin
  if FDataSet.Eof then
    raise EInvalidOperation.Create('No current record in dataset');
  Result := ParseCurrent;
end;

{ ColligoQE }

class function TQE.New<T>(const ADatabase: TFluentSQLDriver): IColligoQueryExpression;
begin
  Result := TColligoQueryExpression<T>.Create(ADatabase);
end;

end.



