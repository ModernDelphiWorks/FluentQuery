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

unit Fluent.Queryable;

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
  CQuery.Interfaces,
  CQuery.Expression,
  CQuery.Utils,
  CQuery.Name,
  DBEngine.FactoryInterfaces,
  Fluent,
  Fluent.Core,
  Fluent.Expression;

const
  dbnMSSQL      = CQuery.Interfaces.dbnMSSQL;
  dbnMySQL      = CQuery.Interfaces.dbnMySQL;
  dbnFirebird   = CQuery.Interfaces.dbnFirebird;
  dbnSQLite     = CQuery.Interfaces.dbnSQLite;
  dbnInterbase  = CQuery.Interfaces.dbnInterbase;
  dbnDB2        = CQuery.Interfaces.dbnDB2;
  dbnOracle     = CQuery.Interfaces.dbnOracle;
  dbnInformix   = CQuery.Interfaces.dbnInformix;
  dbnPostgreSQL = CQuery.Interfaces.dbnPostgreSQL;
  dbnADS        = CQuery.Interfaces.dbnADS;
  dbnASA        = CQuery.Interfaces.dbnASA;
  dbnAbsoluteDB = CQuery.Interfaces.dbnAbsoluteDB;
  dbnMongoDB    = CQuery.Interfaces.dbnMongoDB;
  dbnElevateDB  = CQuery.Interfaces.dbnElevateDB;
  dbnNexusDB    = CQuery.Interfaces.dbnNexusDB;

type
  TDBEngineDriver = DBEngine.FactoryInterfaces.TDBEngineDriver;
  TCQueryDriver = CQuery.Interfaces.TCQueryDriver;
  IDBConnection = DBEngine.FactoryInterfaces.IDBConnection;
  IDBTransaction = DBEngine.FactoryInterfaces.IDBTransaction;
  IDBDataSet = DBEngine.FactoryInterfaces.IDBDataSet;
  IDBQuery = DBEngine.FactoryInterfaces.IDBQuery;

  TConnectionInitializer = reference to procedure(var ADatabase: TDBEngineDriver;
                                                  var AConnection: IDBConnection);

  IFluentQueryProvider<T> = interface;
  IGroupByQueryable<TKey, T> = interface;

  IFluentQueryProvider<T> = interface
    ['{A54C5B9B-89A3-41A8-99E7-EBAFD2758093}']
    function _GetCQuery: ICQueryAST;
    procedure _SetCQuery(const Value: ICQueryAST);
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
    function SetValue(const AColumnName: string; AColumnValue: Extended; ACurrencyPlaces: Integer): IFluentQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; AColumnValue: Double; ACurrencyPlaces: Integer): IFluentQueryProvider<T>; overload;
    function SetValue(const AColumnName: string; AColumnValue: Currency; ACurrencyPlaces: Integer): IFluentQueryProvider<T>; overload;
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
    function Min: IFluentQueryProvider<T>; overload;
    function Max: IFluentQueryProvider<T>;
    function Sum(const AColumn: string; const AAlias: string = ''): IFluentQueryProvider<T>;
    function Average(const AColumn: string; const AAlias: string = ''): IFluentQueryProvider<T>;
    function Lower: IFluentQueryProvider<T>;
    function Upper: IFluentQueryProvider<T>;
    function SubString(const AStart: Integer; const ALength: Integer): IFluentQueryProvider<T>;
    function Date(const AValue: string): IFluentQueryProvider<T>;
    function Day(const AValue: string): IFluentQueryProvider<T>;
    function Month(const AValue: string): IFluentQueryProvider<T>;
    function Year(const AValue: string): IFluentQueryProvider<T>;
    function Concat(const AValue: array of string): IFluentQueryProvider<T>;
    function ToArray: IFluentArray<T>;
    function ToList: IFluentList<T>;
    function AsString: string;
    function Database: TDBEngineDriver;
    function Connection: IDBConnection;
    property CQuery: ICQueryAST read _GetCQuery write _SetCQuery;
  end;

  IFluentQueryableBase<T> = interface(IInterface)
    ['{5E8E37CE-6372-4FBB-872B-9687A24F63DD}']
    function GetEnumerator: IFluentEnumerator<T>;
    function BuildQuery: string;
  end;

  TFluentQueryableBase<T> = class abstract(TInterfacedObject, IFluentQueryableBase<T>)
  protected
    function GetEnumerator: IFluentEnumerator<T>; virtual; abstract;
    function BuildQuery: string; virtual; abstract;
  end;

  TFluentQueryable<T> = class(TFluentQueryableBase<T>)
  private
    FProvider: IFluentQueryProvider<T>;
  protected
    function GetEnumerator: IFluentEnumerator<T>; override;
    function BuildQuery: string; override;
  public
    constructor Create(const AProvider: IFluentQueryProvider<T>); overload;
  end;

  IFluentQueryable<T> = record
  private
    FQueryable: IFluentQueryableBase<T>;
    FEnumerable: IFluentEnumerable<T>;
    FProvider: IFluentQueryProvider<T>;
    FExpression: IFluentQueryExpression;
    function _GetEnumerable: IFluentEnumerable<T>;
    function _ExecuteScalar<TResult>(const ASql: string): TResult;
    function _ExecuteList(const ASql: string): IFluentList<T>;
    function _InitializeICQL: IFluentQueryProvider<T>;
    function _GetDriverDatabase(const ADatabase: TDBEngineDriver): TCQueryDriver;
  public
    constructor Create(const AQueryable: IFluentQueryableBase<T>); overload;
    constructor CreateForDatabase(const AInitializer: TConnectionInitializer); overload;
    constructor CreateForDatabase(const ADatabase: TDBEngineDriver; const AConnection: IDBConnection;
      const ACQL: ICQueryAST = nil); overload;
    function IsNotAssigned: Boolean;
    function QE: IFluentQueryExpression;
    function From(const ATableName: string): IFluentQueryable<T>; overload;
    function From(const ATableName: string; const AAlias: string): IFluentQueryable<T>; overload;
    function Where(const AExpression: string = ''): IFluentQueryable<T>; overload;
    function Where(const AExpression: array of const): IFluentQueryable<T>; overload;
    function Where(const AExpression: IFluentQueryExpression): IFluentQueryable<T>; overload;
    function InnerJoin(const ATableName: string): IFluentQueryable<T>; overload;
    function InnerJoin(const ATableName: string; const AAlias: string): IFluentQueryable<T>; overload;
    function OnCond(const AExpression: string): IFluentQueryable<T>; overload;
    function OnCond(const AExpression: array of const): IFluentQueryable<T>; overload;
    function Alias(const AAlias: string): IFluentQueryable<T>;
    function AndOpe(const AExpression: array of const): IFluentQueryable<T>; overload;
    function AndOpe(const AExpression: string): IFluentQueryable<T>; overload;
    function AndOpe(const AExpression: IFluentQueryExpression): IFluentQueryable<T>; overload;
    function OrOpe(const AExpression: array of const): IFluentQueryable<T>; overload;
    function OrOpe(const AExpression: string): IFluentQueryable<T>; overload;
    function OrOpe(const AExpression: IFluentQueryExpression): IFluentQueryable<T>; overload;
    function GroupBy(const AColumnName: string): IFluentQueryable<T>; overload;
    function GroupBy<TKey>(const AExpression: IFluentQueryExpression): IGroupByQueryable<TKey, T>; overload;
    function OrderBy(const AColumnName: string): IFluentQueryable<T>; overload;
    function OrderBy(const AExpression: IFluentQueryExpression): IFluentQueryable<T>; overload;
    function OrderByDesc(const AExpression: IFluentQueryExpression): IFluentQueryable<T>;
    function ThenBy(const AExpression: IFluentQueryExpression): IFluentQueryable<T>;
    function ThenByDescending(const AExpression: IFluentQueryExpression): IFluentQueryable<T>;
    function Take(const ACount: Integer): IFluentQueryable<T>;
    function Skip(const ACount: Integer): IFluentQueryable<T>;
    function Select(const AColumns: string = ''): IFluentQueryable<T>; overload;
    function Select(const AExpressions: TArray<IFluentQueryExpression>): IFluentQueryable<T>; overload;
    function Union(const ASecond: IFluentQueryable<T>): IFluentQueryable<T>;
    function Intersect(const ASecond: IFluentQueryable<T>): IFluentQueryable<T>;
    function Exclude(const ASecond: IFluentQueryable<T>): IFluentQueryable<T>;
    function Join<TInner, TResult>(const AInner: IFluentQueryable<TInner>;
      const AOuterKey: IFluentQueryExpression; const AInnerKey: IFluentQueryExpression;
      const AResultColumns: TArray<IFluentQueryExpression>): IFluentQueryable<TResult>;
    function Distinct: IFluentQueryable<T>;
//    function Cast<TResult>(const AConverter: TFunc<T, TResult>): IFluentQueryable<TResult>;
//    function OfType<TResult>(const AIsType: TFunc<T, Boolean>;
//      const AConverter: TFunc<T, TResult>): IFluentQueryable<TResult>;
    function Any(const AExpression: IFluentQueryExpression): Boolean; overload;
    function Any: Boolean; overload;
    function All(const AExpression: IFluentQueryExpression): Boolean;
    function Contains(const AValue: T; const AComparer: IEqualityComparer<T>): Boolean;
    function Count(const AExpression: IFluentQueryExpression): Integer; overload;
    function Count: Integer; overload;
    function LongCount(const AExpression: IFluentQueryExpression): Int64; overload;
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
    function First(const AExpression: IFluentQueryExpression): T; overload;
    function First: T; overload;
    function FirstOrDefault(const AExpression: IFluentQueryExpression): T; overload;
    function FirstOrDefault: T; overload;
    function Last(const AExpression: IFluentQueryExpression): T; overload;
    function Last: T; overload;
    function LastOrDefault(const AExpression: IFluentQueryExpression): T; overload;
    function LastOrDefault: T; overload;
    function Single(const AExpression: IFluentQueryExpression): T; overload;
    function Single: T; overload;
    function SingleOrDefault(const AExpression: IFluentQueryExpression): T; overload;
    function SingleOrDefault: T; overload;
    function ElementAt(const AIndex: Integer): T;
    function ElementAtOrDefault(const AIndex: Integer): T;
//    function Aggregate<TAccumulate>(const ASeed: TAccumulate;
//      const AFunc: TFunc<TAccumulate, T, TAccumulate>): TAccumulate; overload;
//    function Aggregate<TAccumulate, TResult>(const ASeed: TAccumulate;
//      const AFunc: TFunc<TAccumulate, T, TAccumulate>;
//      const AResultSelector: TFunc<TAccumulate, TResult>): TResult; overload;
//    function Chunk(const ASize: Integer): IFluentChunkResult<T>;
    function ToArray: IFluentArray<T>;
    function ToList: IFluentList<T>;
    function AsString: string;
    function AsEnumerable: IFluentEnumerable<T>;
  end;

  IGroupByQueryable<TKey, T> = interface(IInterface)
    ['{A85DB3F6-E808-4E81-B386-75190087507B}']
    function GetEnumerator: IFluentEnumerator<IGrouping<TKey, T>>;
    function AsEnumerable: IFluentEnumerable<IGrouping<TKey, T>>;
    function ToList: IFluentList<IGrouping<TKey, T>>;
  end;

  TDataSetEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
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
    class function New<T>(const ADatabase: TCQueryDriver): IFluentQueryExpression; static;
  end;

implementation

uses
  System.Evolution.Tuple,
  System.Fluent.Parse,
  System.Fluent.Query.Provider,
  System.Fluent.Adapters,
  System.Fluent.GroupBy,
  System.Fluent.Select,
  System.Fluent.Union,
  System.Fluent.Intersect,
  System.Fluent.Exclude,
  System.Fluent.Join,
  System.Fluent.OfType,
  System.Fluent.Cast;

{$IFDEF QUERYABLE}
{ IFluentQueryable<T> }

constructor IFluentQueryable<T>.Create(const AQueryable: IFluentQueryableBase<T>);
begin
  FQueryable := AQueryable;
  FEnumerable := _GetEnumerable;
  _InitializeICQL;
end;

constructor IFluentQueryable<T>.CreateForDatabase(const AInitializer: TConnectionInitializer);
begin
  if not Assigned(AInitializer) then
    raise EArgumentNilException.Create('Connection initializer cannot be nil');
  FProvider := TFluentQueryProvider<T>.TStrictPrivateCreate<T>.CreateProvider(AInitializer);
  FQueryable := TFluentQueryable<T>.Create(FProvider);
  FEnumerable := _GetEnumerable;
  FExpression := TFluentQueryExpression<T>.Create(_GetDriverDatabase(FProvider.Database));
  _InitializeICQL;
end;

constructor IFluentQueryable<T>.CreateForDatabase(const ADatabase: TDBEngineDriver;
  const AConnection: IDBConnection; const ACQL: ICQueryAST);
begin
  if AConnection = nil then
    raise EArgumentNilException.Create('Connection cannot be nil');
  if TStrDBEngineDriver[ADatabase] = '' then
    raise EArgumentNilException.Create('Database type must be specified');
  FProvider := TFluentQueryProvider<T>.TStrictPrivateCreate<T>.CreateProvider(ADatabase, AConnection, ACQL);
  FQueryable := TFluentQueryable<T>.Create(FProvider);
  FEnumerable := _GetEnumerable;
  FExpression := TFluentQueryExpression<T>.Create(_GetDriverDatabase(ADatabase));
  _InitializeICQL;
end;

function IFluentQueryable<T>._GetEnumerable: IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TQueryableToEnumerableAdapter<T>.Create(FQueryable),
    ftNone,
    TEqualityComparer<T>.Default
  );
end;

function IFluentQueryable<T>._InitializeICQL: IFluentQueryProvider<T>;
begin
  Result := FProvider;
  if FProvider.CQuery.Select.IsEmpty then
    Result.Select('*');
end;

function IFluentQueryable<T>._ExecuteScalar<TResult>(const ASql: string): TResult;
var
  LSQL: string;
  LDataSet: IDBDataSet;
  LParserScalar: TFluentParseScalarDataSet<TResult>;
  LParserObject: TFluentParseObjectDataSet<TResult>;
  LContext: TRttiContext;
  LType: TRttiType;
  LList: IFluentList<TResult>;
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
        LParserObject := TFluentParseObjectDataSet<TResult>.Create;
        try
          LList := LParserObject.ToList(LDataSet);
        finally
          LParserObject.Free;
        end;
      end
      else
      begin
        LParserScalar := TFluentParseScalarDataSet<TResult>.Create;
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

function IFluentQueryable<T>._ExecuteList(const ASql: string): IFluentList<T>;
begin
  Result := FProvider.ToList;
end;

function IFluentQueryable<T>.Select(const AColumns: string): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.Select(IfThen(AColumns = EmptyStr, '*', AColumns));
  Result := Self;
end;

function IFluentQueryable<T>.From(const ATableName: string): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.From(ATableName);
  Result := Self;
end;

function IFluentQueryable<T>.From(const ATableName, AAlias: string): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.From(ATableName, AAlias);
  Result := Self;
end;

function IFluentQueryable<T>.Where(const AExpression: string): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.Where(AExpression);
  Result := Self;
end;

function IFluentQueryable<T>.Where(const AExpression: array of const): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.Where(AExpression);
  Result := Self;
end;

function IFluentQueryable<T>.InnerJoin(const ATableName: string): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.InnerJoin(ATableName);
  Result := Self;
end;

function IFluentQueryable<T>.InnerJoin(const ATableName, AAlias: string): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.InnerJoin(ATableName, AAlias);
  Result := Self;
end;

function IFluentQueryable<T>.OnCond(const AExpression: string): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.OnCond(AExpression);
  Result := Self;
end;

function IFluentQueryable<T>.OnCond(const AExpression: array of const): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.OnCond(AExpression);
  Result := Self;
end;

function IFluentQueryable<T>.Alias(const AAlias: string): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.Alias(AAlias);
  Result := Self;
end;

function IFluentQueryable<T>.AndOpe(const AExpression: array of const): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.AndOpe(AExpression);
  Result := Self;
end;

function IFluentQueryable<T>.AndOpe(const AExpression: string): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.AndOpe(AExpression);
  Result := Self;
end;

function IFluentQueryable<T>.OrOpe(const AExpression: array of const): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.OrOpe(AExpression);
  Result := Self;
end;

function IFluentQueryable<T>.OrOpe(const AExpression: string): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.OrOpe(AExpression);
  Result := Self;
end;

function IFluentQueryable<T>.GroupBy(const AColumnName: string): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.GroupBy(AColumnName);
  Result := Self;
end;

function IFluentQueryable<T>.GroupBy<TKey>(const AExpression: IFluentQueryExpression): IGroupByQueryable<TKey, T>;
var
  LColumnName: string;
begin
  if not Assigned(AExpression) then
    raise EArgumentNilException.Create('Selector cannot be nil');

  LColumnName := AExpression.Serialize;
  if LColumnName.IsEmpty then
    raise EInvalidOperation.Create('Could not extract column name from selector');

  FProvider.GroupBy(LColumnName);
  Result := TFluentGroupByQueryable<TKey, T>.Create(FQueryable, AExpression, FProvider);
end;

function IFluentQueryable<T>.OrderBy(const AColumnName: string): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.OrderBy(AColumnName);
  Result := Self;
end;

function IFluentQueryable<T>.OrderBy(const AExpression: IFluentQueryExpression): IFluentQueryable<T>;
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

function IFluentQueryable<T>.OrderByDesc(const AExpression: IFluentQueryExpression): IFluentQueryable<T>;
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

function IFluentQueryable<T>.OrOpe(const AExpression: IFluentQueryExpression): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.OrOpe(AExpression.Serialize);
  Result := Self;
end;

function IFluentQueryable<T>.QE: IFluentQueryExpression;
begin
  Result := FExpression;
end;

function IFluentQueryable<T>.ThenBy(const AExpression: IFluentQueryExpression): IFluentQueryable<T>;
var
  LColumnName: string;
begin
  if not Assigned(AExpression) then
    raise EArgumentNilException.Create('Expression cannot be nil');

  LColumnName := AExpression.Serialize;
  if LColumnName.IsEmpty then
    raise EInvalidOperation.Create('Could not extract column name from selector');

  FProvider.CQuery.OrderBy.Columns.Add.Name := LColumnName;
  (FProvider.CQuery.OrderBy.Columns[Pred(FProvider.CQuery.OrderBy.Columns.Count)] as ICQueryOrderByColumn).Direction := dirAscending;
  Result := Self;
end;

function IFluentQueryable<T>.ThenByDescending(const AExpression: IFluentQueryExpression): IFluentQueryable<T>;
var
  LColumnName: string;
begin
  if not Assigned(AExpression) then
    raise EArgumentNilException.Create('Expression cannot be nil');

  LColumnName := AExpression.Serialize;
  if LColumnName.IsEmpty then
    raise EInvalidOperation.Create('Could not extract column name from selector');

  FProvider.CQuery.OrderBy.Columns.Add.Name := LColumnName;
  (FProvider.CQuery.OrderBy.Columns[Pred(FProvider.CQuery.OrderBy.Columns.Count)] as ICQueryOrderByColumn).Direction := dirDescending;
  Result := Self;
end;

function IFluentQueryable<T>.Take(const ACount: Integer): IFluentQueryable<T>;
begin
  if ACount < 1 then
    raise EArgumentException.Create('ACount must be greater than 0');
  FProvider.First(ACount);
  Result := Self;
end;

function IFluentQueryable<T>.Skip(const ACount: Integer): IFluentQueryable<T>;
begin
  Result := IFluentQueryable<T>.Create(FQueryable);
  FProvider.Skip(ACount);
  Result := Self;
end;

function IFluentQueryable<T>.Select(const AExpressions: TArray<IFluentQueryExpression>): IFluentQueryable<T>;
var
  LExpression: IFluentQueryExpression;
  LColumnName: string;
begin
  if Length(AExpressions) = 0 then
    raise EArgumentNilException.Create('Expressions cannot be empty');

  FProvider.CQuery.Select.Columns.Clear;
  for LExpression in AExpressions do
  begin
    if not Assigned(LExpression) then
      raise EArgumentNilException.Create('Expression cannot be nil');

    LColumnName := LExpression.Serialize;
    if LColumnName.IsEmpty then
      raise EInvalidOperation.Create('Could not extract column name from selector');

   FProvider.CQuery.Select.Columns.Add.Name := LColumnName;
  end;
  Result := Self;
end;

function IFluentQueryable<T>.Union(const ASecond: IFluentQueryable<T>): IFluentQueryable<T>;
begin
  Result := IFluentQueryable<T>.Create(
    TFluentUnionQueryable<T>.Create(FQueryable, ASecond.FQueryable, nil)
  );
end;

function IFluentQueryable<T>.Intersect(const ASecond: IFluentQueryable<T>): IFluentQueryable<T>;
begin
  Result := IFluentQueryable<T>.Create(
    TFluentIntersectQueryable<T>.Create(FQueryable, ASecond.FQueryable, nil)
  );
end;

function IFluentQueryable<T>.Exclude(const ASecond: IFluentQueryable<T>): IFluentQueryable<T>;
begin
  Result := IFluentQueryable<T>.Create(
    TFluentExcludeQueryable<T>.Create(FQueryable, ASecond.FQueryable, nil)
  );
end;

function IFluentQueryable<T>.Join<TInner, TResult>(const AInner: IFluentQueryable<TInner>;
  const AOuterKey: IFluentQueryExpression; const AInnerKey: IFluentQueryExpression;
  const AResultColumns: TArray<IFluentQueryExpression>): IFluentQueryable<TResult>;
var
  LOuterKeyName, LInnerKeyName, LInnerTableName: string;
  LExpression: IFluentQueryExpression;
  LColumnName: string;
  LJoinQuery: TFluentJoinQueryable<TInner, TResult, T>;
  LNewProvider: IFluentQueryProvider<TResult>;
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

  LInnerTableName := AInner.FProvider.CQuery.Select.TableNames[0].Serialize;
  if LInnerTableName.IsEmpty then
    raise EInvalidOperation.Create('Could not extract inner table name');


  FProvider.CQuery.Select.Columns.Clear;
  FProvider.InnerJoin(LInnerTableName);
  FProvider.OnCond(LOuterKeyName + ' = ' + LInnerKeyName);
  for LExpression in AResultColumns do
  begin
    if not Assigned(LExpression) then
      raise EArgumentNilException.Create('Result column expression cannot be nil');

    LColumnName := LExpression.Serialize;
    if LColumnName.IsEmpty then
      raise EInvalidOperation.Create('Could not extract result column name');

    FProvider.CQuery.Select.Columns.Add.Name := LColumnName;
  end;
  LNewProvider := TFluentQueryProvider<TResult>.TStrictPrivateCreate<TResult>
                                               .CreateProvider(FProvider.Database,
                                                               FProvider.Connection,
                                                               FProvider.CQuery);
  LJoinQuery := TFluentJoinQueryable<TInner, TResult, T>.Create(LNewProvider);
  try
    Result := LJoinQuery.AsQueryable;
  finally
    LJoinQuery.Free;
  end;
end;

function IFluentQueryable<T>.Distinct: IFluentQueryable<T>;
begin
  Result := IFluentQueryable<T>.Create(FQueryable);
  FProvider.DistinctSQL;
end;

//function IFluentQueryable<T>.OfType<TResult>(
//  const AIsType: TFunc<T, Boolean>;
//  const AConverter: TFunc<T, TResult>): IFluentQueryable<TResult>;
//begin
//  if not Assigned(AIsType) then
//    raise EArgumentNilException.Create('IsType cannot be nil');
//  if not Assigned(AConverter) then
//    raise EArgumentNilException.Create('Converter cannot be nil');
//  Result := IFluentQueryable<TResult>.Create(
//    TFluentOfTypeQueryable<T, TResult>.Create(FQueryable, AIsType, AConverter)
//  );
//end;

//function IFluentQueryable<T>.Cast<TResult>(const AConverter: TFunc<T, TResult>): IFluentQueryable<TResult>;
//begin
//  if not Assigned(AConverter) then
//    raise EArgumentNilException.Create('Converter cannot be nil');
//  Result := IFluentQueryable<TResult>.Create(
//    TFluentCastQueryable<T, TResult>.Create(FQueryable, AConverter)
//  );
//end;

function IFluentQueryable<T>.Any(const AExpression: IFluentQueryExpression): Boolean;
begin
  FProvider.Where('NOT (' + AExpression.Serialize + ')');
  FProvider.Count;
  Result := _ExecuteScalar<Integer>(FQueryable.BuildQuery) > 0;
end;

function IFluentQueryable<T>.Any: Boolean;
begin
  Result := _ExecuteScalar<Integer>(FQueryable.BuildQuery) > 0;
end;

function IFluentQueryable<T>.All(const AExpression: IFluentQueryExpression): Boolean;
begin
  FProvider.Where('NOT (' + AExpression.Serialize + ')');
  FProvider.Count;
  Result := _ExecuteScalar<Integer>(FQueryable.BuildQuery) = 0;
end;

function IFluentQueryable<T>.Contains(const AValue: T;
  const AComparer: IEqualityComparer<T>): Boolean;
begin
  Result := FEnumerable.Contains(AValue, AComparer);
end;

function IFluentQueryable<T>.Count(const AExpression: IFluentQueryExpression): Integer;
begin
  FProvider.Where(AExpression.Serialize);
  FProvider.Count;
  Result := _ExecuteScalar<Integer>(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.Count: Integer;
begin
  FProvider.Count;
  Result := _ExecuteScalar<Integer>(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.LongCount(const AExpression: IFluentQueryExpression): Int64;
var
  LColumns: string;
begin
  if not Assigned(FProvider) then
    raise EInvalidOperation.Create('Query provider is not assigned');

  LColumns := FProvider.CQuery.Select.Columns.Serialize;
  FProvider.Where(AExpression.Serialize);
  FProvider.Count;
  Result := _ExecuteScalar<Int64>(FQueryable.BuildQuery);
  FProvider.CQuery.Select.Columns.Clear;
  FProvider.Column(LColumns);
end;

function IFluentQueryable<T>.LongCount: Int64;
begin
  FProvider.Count;
  Result := _ExecuteScalar<Int64>(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.Min: T;
begin
  FProvider.Min;
  Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.Min(const AComparer: IComparer<T>): T;
begin
  Result := FEnumerable.Min(AComparer);
end;

function IFluentQueryable<T>.Min<TResult>(const AFieldName: string; const AAlias: string): TResult;
var
  LColumn: ICQueryName;
begin
  if AFieldName = EmptyStr then
    raise EInvalidOperation.Create('Field name cannot be empty');

  FProvider.CQuery.Select.Columns.Clear;
  LColumn := FProvider.CQuery.Select.Columns.Add;
  LColumn.Name := AFieldName;
  LColumn.Alias := AAlias;
  FProvider.Min;
  Result := _ExecuteScalar<TResult>(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.MinBy(const AFieldName: string): T;
var
  LColumn: ICQueryName;
  LFor: Integer;
  LFound: Boolean;
begin
  if AFieldName = EmptyStr then
    raise EInvalidOperation.Create('Field name cannot be empty');

  LFound := False;
  for LFor := 0 to FProvider.CQuery.Select.Columns.Count - 1 do
  begin
    LColumn := FProvider.CQuery.Select.Columns[LFor];
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

function IFluentQueryable<T>.Max: T;
begin
  FProvider.Max;
  Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.Max(const AComparer: IComparer<T>): T;
begin
  Result := FEnumerable.Max(AComparer);
end;

function IFluentQueryable<T>.Max<TResult>(const AFieldName: string; const AAlias: string): TResult;
var
  LColumn: ICQueryName;
begin
  if AFieldName = EmptyStr then
    raise EInvalidOperation.Create('Field name cannot be empty');

  FProvider.CQuery.Select.Columns.Clear;
  LColumn := FProvider.CQuery.Select.Columns.Add;
  LColumn.Name := AFieldName;
  LColumn.Alias := AAlias;
  FProvider.Max;
  Result := _ExecuteScalar<TResult>(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.MaxBy(const AFieldName: string): T;
var
  LColumn: ICQueryName;
  LFor: Integer;
  LFound: Boolean;
begin
  if AFieldName = EmptyStr then
    raise EInvalidOperation.Create('Field name cannot be empty');

  LFound := False;
  for LFor := 0 to FProvider.CQuery.Select.Columns.Count - 1 do
  begin
    LColumn := FProvider.CQuery.Select.Columns[LFor];
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

function IFluentQueryable<T>.Sum<TResult>(const AFieldName: string; const AAlias: string): TResult;
var
  LColumn: ICQueryName;
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
  for LFor := 0 to FProvider.CQuery.Select.Columns.Count - 1 do
  begin
    LColumn := FProvider.CQuery.Select.Columns[LFor];
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

function IFluentQueryable<T>.Average<TResult>(const AFieldName: string; const AAlias: string): TResult;
var
  LColumn: ICQueryName;
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
  for LFor := 0 to FProvider.CQuery.Select.Columns.Count - 1 do
  begin
    LColumn := FProvider.CQuery.Select.Columns[LFor];
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

function IFluentQueryable<T>.First(const AExpression: IFluentQueryExpression): T;
begin
  FProvider.Where(AExpression.Serialize);
  FProvider.First(1);
  Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.First: T;
begin
  Result := Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.FirstOrDefault(const AExpression: IFluentQueryExpression): T;
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

function IFluentQueryable<T>.FirstOrDefault: T;
begin
  FProvider.Count;
  if _ExecuteScalar<Integer>(FQueryable.BuildQuery) > 0 then
    Result := Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery)
  else
    Result := Default(T);
end;

function IFluentQueryable<T>.Last(const AExpression: IFluentQueryExpression): T;
begin
  FProvider.Where(AExpression.Serialize);
  FProvider.OrderBy('ID').Desc;
  FProvider.First(1);
  Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.Last: T;
begin
  Result := OrderByDesc(nil).Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.LastOrDefault(const AExpression: IFluentQueryExpression): T;
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

function IFluentQueryable<T>.LastOrDefault: T;
begin
  FProvider.Count;
  if _ExecuteScalar<Integer>(FQueryable.BuildQuery) > 0 then
    Result := OrderByDesc(nil).Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery)
  else
    Result := Default(T);
end;

function IFluentQueryable<T>.Single(const AExpression: IFluentQueryExpression): T;
var
  LCount: Integer;
  LColumns: string;
begin
  LColumns := FProvider.CQuery.Select.Columns.Serialize;
  FProvider.Where(AExpression.Serialize);
  FProvider.Count;
  LCount := _ExecuteScalar<Integer>(FQueryable.BuildQuery);
  if LCount <> 1 then
    raise EInvalidOperation.Create('Sequence contains ' + IntToStr(LCount) + ' elements; expected exactly one');

  FProvider.CQuery.Select.Columns.Clear;
  FProvider.Column(LColumns);
  FProvider.Where(AExpression.Serialize);
  FProvider.First(1);
  Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.Single: T;
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

function IFluentQueryable<T>.SingleOrDefault(const AExpression: IFluentQueryExpression): T;
var
  LCount: Integer;
  LColumns: string;
begin
  if not Assigned(FProvider) then
    raise EInvalidOperation.Create('Query provider is not assigned');
  LColumns := FProvider.CQuery.Select.Columns.Serialize;
  FProvider.Where(AExpression.Serialize);
  FProvider.Count;
  LCount := _ExecuteScalar<Integer>(FQueryable.BuildQuery);
  if LCount > 1 then
    raise EInvalidOperation.Create('Sequence contains ' + IntToStr(LCount) + ' elements; expected zero or one');

  if LCount > 0 then
  begin
    FProvider.CQuery.Select.Columns.Clear;
    FProvider.Column(LColumns);
    FProvider.Where(AExpression.Serialize);
    FProvider.First(1);
    Result := _ExecuteScalar<T>(FQueryable.BuildQuery);
  end
  else
    Result := Default(T);
end;

function IFluentQueryable<T>.SingleOrDefault: T;
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

function IFluentQueryable<T>.ElementAt(const AIndex: Integer): T;
begin
  Result := Skip(AIndex).Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.ElementAtOrDefault(const AIndex: Integer): T;
begin
  FProvider.Count;
  if Skip(AIndex)._ExecuteScalar<Integer>(FQueryable.BuildQuery) > 0 then
    Result := Skip(AIndex).Take(1)._ExecuteScalar<T>(FQueryable.BuildQuery)
  else
    Result := Default(T);
end;

//function IFluentQueryable<T>.Aggregate<TAccumulate>(
//  const ASeed: TAccumulate;
//  const AFunc: TFunc<TAccumulate, T, TAccumulate>): TAccumulate;
//begin
//  Result := FEnumerable.Aggregate<TAccumulate>(ASeed, AFunc);
//end;

//function IFluentQueryable<T>.Aggregate<TAccumulate, TResult>(
//  const ASeed: TAccumulate;
//  const AFunc: TFunc<TAccumulate, T, TAccumulate>;
//  const AResultSelector: TFunc<TAccumulate, TResult>): TResult;
//begin
//  Result := FEnumerable.Aggregate<TAccumulate, TResult>(ASeed, AFunc, AResultSelector);
//end;

//function IFluentQueryable<T>.Chunk(const ASize: Integer): IFluentChunkResult<T>;
//begin
//  Result := FEnumerable.Chunk(ASize);
//end;

function IFluentQueryable<T>.ToArray: IFluentArray<T>;
begin
  Result := _ExecuteList(FQueryable.BuildQuery).ToArray;
end;

function IFluentQueryable<T>.ToList: IFluentList<T>;
begin
  Result := _ExecuteList(FQueryable.BuildQuery);
end;

function IFluentQueryable<T>.AsString: string;
begin
  Result := FProvider.AsString;
end;

function IFluentQueryable<T>.AsEnumerable: IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TQueryableToEnumerableAdapter<T>.Create(FQueryable),
    ftNone,
    TEqualityComparer<T>.Default
  );
end;

function IFluentQueryable<T>.IsNotAssigned: Boolean;
begin
  Result := not TEqualityComparer<IFluentQueryable<T>>.Default.Equals(Self, Default(IFluentQueryable<T>));
end;

function IFluentQueryable<T>._GetDriverDatabase(const ADatabase: TDBEngineDriver): TCQueryDriver;
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

function IFluentQueryable<T>.AndOpe(const AExpression: IFluentQueryExpression): IFluentQueryable<T>;
begin
  if Assigned(FProvider) then
    FProvider.AndOpe(AExpression.Serialize);
  Result := Self;
end;

function IFluentQueryable<T>.Where(const AExpression: IFluentQueryExpression): IFluentQueryable<T>;
begin
  FProvider.Where(AExpression.Serialize);
  Result := Self;
end;

{ TFluentQueryable<T> }

constructor TFluentQueryable<T>.Create(const AProvider: IFluentQueryProvider<T>);
begin
  FProvider := AProvider;
end;

function TFluentQueryable<T>.GetEnumerator: IFluentEnumerator<T>;
var
  LSql: string;
  LDataSet: IDBDataSet;
begin
  LSql := BuildQuery;
  LDataSet := FProvider.Connection.CreateDataSet(LSql);
  Result := TDataSetEnumerator<T>.Create(LDataSet);
end;

function TFluentQueryable<T>.BuildQuery: string;
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

{ FluentQE }

class function TQE.New<T>(const ADatabase: TCQueryDriver): IFluentQueryExpression;
begin
  Result := TFluentQueryExpression<T>.Create(ADatabase);
end;

end.
