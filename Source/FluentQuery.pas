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

unit FluentQuery;

interface

uses
  Rtti,
  Math,
  Types,
  Classes,
  StrUtils,
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  FluentQuery.Core;

type
  IFluentEnumerableAdapter<TResult> = interface;
  IGroupByEnumerable<TKey, T> = interface;
  IGrouping<TKey, T> = interface;
  IFluentArray<T> = interface;
  IFluentList<T> = interface;
//  IFluentChunkResult<T> = interface;

  IFluentEnumerator<T> = interface(IInterface)
    ['{E2DEBD49-1094-41A5-A817-48FB81A6F6F2}']
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  IFluentEnumerableBase<T> = interface(IInterface)
    ['{B68572C5-32C6-436A-B39B-D8DA06E33C14}']
    function GetEnumerator: IFluentEnumerator<T>;
  end;

  TFluentEnumerableBase<T> = class abstract(TInterfacedObject, IFluentEnumerableBase<T>)
  protected
    function GetEnumerator: IFluentEnumerator<T>; virtual; abstract;
  end;

  IFluentEnumerable<T> = record
  private
    FEnumerator: IFluentEnumerableBase<T>;
    FFluentType: TFluentType;
    FComparer: IEqualityComparer<T>;
    FIsValid: Boolean;
    type
      TFluentCompare = class
      public
        class function Compare(const AEnumerator: IFluentEnumerableBase<T>;
          const AValue: T; const AComparer: IEqualityComparer<T>): Boolean; static;
      end;
    function _IsEmpty: Boolean;
  public
    constructor Create(const AEnumerator: IFluentEnumerableBase<T>;
      const AFluentType: TFluentType = ftNone; const AComparer: IEqualityComparer<T> = nil);
    function IsNotAssigned: Boolean;
    function GetEnumerator: IFluentEnumerator<T>;
    function Where(const APredicate: TFunc<T, Boolean>): IFluentEnumerable<T>;
    function Take(const ACount: Integer): IFluentEnumerable<T>;
    function Skip(const ACount: Integer): IFluentEnumerable<T>;
    function Distinct: IFluentEnumerable<T>; overload;
    function Distinct(const AComparer: IEqualityComparer<T>): IFluentEnumerable<T>; overload;
    function DistinctBy<TKey>(const AKeySelector: TFunc<T, TKey>): IFluentEnumerable<T>;
    function Aggregate(const AReducer: TFunc<T, T, T>): T; overload;
    function Aggregate<TAcc>(const AInitialValue: TAcc; const AAccumulator: TFunc<TAcc, T, TAcc>): TAcc; overload;
    function Aggregate<TAccumulate, TResult>(const AInitialValue: TAccumulate;
      const AAccumulator: TFunc<TAccumulate, T, TAccumulate>;
      const AResultSelector: TFunc<TAccumulate, TResult>): TResult; overload;
    function AggregateBy<TKey, TAccumulate>(const AKeySelector: TFunc<T, TKey>;
      const ASeed: TAccumulate; const AAccumulator: TFunc<TAccumulate, T, TAccumulate>;
      const AComparer: IEqualityComparer<TKey> = nil): TDictionary<TKey, TAccumulate>; overload;
    function AggregateBy<TKey, TAccumulate>(const AKeySelector: TFunc<T, TKey>;
      const ASeedFactory: TFunc<TKey, TAccumulate>; const AAccumulator: TFunc<TAccumulate, T, TAccumulate>;
      const AComparer: IEqualityComparer<TKey> = nil): TDictionary<TKey, TAccumulate>; overload;
    function Sum(const ASelector: TFunc<T, Double>): Double; overload;
    function Sum(const ASelector: TFunc<T, Integer>): Integer; overload;
    function SumCurrency(const ASelector: TFunc<T, Currency>): Currency; overload;
    function SumInt32(const ASelector: TFunc<T, Int32>): Int32; overload;
    function Sum(const ASelector: TFunc<T, Int64>): Int64; overload;
    function Sum(const ASelector: TFunc<T, Single>): Single; overload;
    function Sum(const ASelector: TFunc<T, NullableInt32>): NullableInt32; overload;
    function Sum(const ASelector: TFunc<T, NullableInt64>): NullableInt64; overload;
    function Sum(const ASelector: TFunc<T, NullableSingle>): NullableSingle; overload;
    function Sum(const ASelector: TFunc<T, NullableDouble>): NullableDouble; overload;
    function Sum(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency; overload;
    function MinBy<TKey>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: TFunc<TKey, TKey, Integer>): T;
    function MaxBy<TKey>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: TFunc<TKey, TKey, Integer>): T;
    function Any: Boolean; overload;
    function Any(const APredicate: TFunc<T, Boolean>): Boolean; overload;
    function All(const APredicate: TFunc<T, Boolean>): Boolean;
    function Contains(const AValue: T): Boolean; overload;
    function Contains(const AValue: T; const AComparer: IEqualityComparer<T>): Boolean; overload;
    function First: T; overload;
    function First(const APredicate: TFunc<T, Boolean>): T; overload;
    function FirstOrDefault: T; overload;
    function FirstOrDefault(const APredicate: TFunc<T, Boolean>): T; overload;
    function Last: T; overload;
    function Last(const APredicate: TFunc<T, Boolean>): T; overload;
    function LastOrDefault: T; overload;
    function LastOrDefault(const APredicate: TFunc<T, Boolean>): T; overload;
    function Count: Integer; overload;
    function Count(const APredicate: TFunc<T, Boolean>): Integer; overload;
    function LongCount: Int64; overload;
    function LongCount(const APredicate: TFunc<T, Boolean>): Int64; overload;
    function Zip<TSecond, TResult>(const ASecond: IFluentEnumerable<TSecond>;
      const AResultSelector: TFunc<T, TSecond, TResult>): IFluentEnumerable<TResult>;
    function OfType<TResult>(const AIsType: TFunc<T, Boolean>; const AConverter: TFunc<T, TResult>): IFluentEnumerable<TResult>;
    function Exclude(const ASecond: IFluentEnumerable<T>): IFluentEnumerable<T>;
    function Intersect(const ASecond: IFluentEnumerable<T>): IFluentEnumerable<T>;
    function Union(const ASecond: IFluentEnumerable<T>): IFluentEnumerable<T>;
    function Concat(const ASecond: IFluentEnumerable<T>): IFluentEnumerable<T>;
    function SequenceEqual(const ASecond: IFluentEnumerable<T>): Boolean;
    function Single: T; overload;
    function Single(const APredicate: TFunc<T, Boolean>): T; overload;
    function SingleOrDefault: T; overload;
    function SingleOrDefault(const APredicate: TFunc<T, Boolean>): T; overload;
    function ElementAt(const AIndex: Integer): T;
    function ElementAtOrDefault(const AIndex: Integer): T;
    function OrderBy(const AComparer: TFunc<T, T, Integer>): IFluentEnumerable<T>; overload;
    function OrderBy<TKey>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: IComparer<TKey>): IFluentEnumerable<T>; overload;
    function OrderByDesc(const AComparer: TFunc<T, T, Integer>): IFluentEnumerable<T>;
    function GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>): IGroupByEnumerable<TKey, T>; overload;
    function GroupBy<TKey, TElement>(const AKeySelector: TFunc<T, TKey>;
      const AElementSelector: TFunc<T, TElement>): IGroupByEnumerable<TKey, TElement>; overload;
    function GroupBy<TKey, TResult>(const AKeySelector: TFunc<T, TKey>;
      const AResultSelector: TFunc<TKey, IFluentEnumerableAdapter<T>, TResult>): IFluentEnumerable<TResult>; overload;
    function Join<TInner, TKey, TResult>(const AInner: IFluentEnumerable<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, TInner, TResult>): IFluentEnumerable<TResult>;
    function GroupJoin<TInner, TKey, TResult>(const AInner: IFluentEnumerable<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, IFluentEnumerableAdapter<TInner>, TResult>): IFluentEnumerable<TResult>;
    function ToHashSet: THashSet<T>;
    function ToLookup<TKey, TElement>(const AKeySelector: TFunc<T, TKey>;
      const AElementSelector: TFunc<T, TElement>): TDictionary<TKey, TList<TElement>>;
    function UnionBy<TKey>(const ASecond: IFluentEnumerable<T>;
      const AKeySelector: TFunc<T, TKey>): IFluentEnumerable<T>;
    function Append(const AElement: T): IFluentEnumerable<T>;
    function Cast<TResult>: IFluentEnumerable<TResult>;
    function DefaultIfEmpty: IFluentEnumerable<T>; overload;
    function DefaultIfEmpty(const ADefaultValue: T): IFluentEnumerable<T>; overload;
    function ExcludeBy<TKey>(const ASecond: IFluentEnumerable<TKey>;
      const AKeySelector: TFunc<T, TKey>): IFluentEnumerable<T>;
    function IntersectBy<TKey>(const ASecond: IFluentEnumerable<TKey>;
      const AKeySelector: TFunc<T, TKey>): IFluentEnumerable<T>;
    function Prepend(const AElement: T): IFluentEnumerable<T>;
    function Reverse: IFluentEnumerable<T>;
    function SkipLast(const ACount: Integer): IFluentEnumerable<T>;
    function TakeLast(const ACount: Integer): IFluentEnumerable<T>;
    function Average(const ASelector: TFunc<T, Double>): Double; overload;
    function Average(const ASelector: TFunc<T, Currency>): Currency; overload;
    function Average(const ASelector: TFunc<T, Int32>): Double; overload;
    function Average(const ASelector: TFunc<T, Int64>): Double; overload;
    function Average(const ASelector: TFunc<T, Single>): Double; overload;
    function Average(const ASelector: TFunc<T, NullableInt32>): Double; overload;
    function Average(const ASelector: TFunc<T, NullableInt64>): Double; overload;
    function Average(const ASelector: TFunc<T, NullableSingle>): Double; overload;
    function Average(const ASelector: TFunc<T, NullableDouble>): Double; overload;
    function Average(const ASelector: TFunc<T, NullableCurrency>): Currency; overload;
// Esse cara por motivo não descoberto ainda, só suposição, trava o compilador.
//    function Chunk(const ASize: Integer): IFluentChunkResult<T>;
    function CountBy<TKey>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey> = nil): TDictionary<TKey, Integer>;
    function Max: T; overload;
    function Max(const AComparer: IComparer<T>): T; overload;
    function Max(const AComparer: TFunc<T, T, Integer>): T; overload;
    function Max(const ASelector: TFunc<T, Currency>): Currency; overload;
    function Max(const ASelector: TFunc<T, Double>): Double; overload;
    function Max(const ASelector: TFunc<T, Int32>): Int32; overload;
    function Max(const ASelector: TFunc<T, Int64>): Int64; overload;
    function Max(const ASelector: TFunc<T, Single>): Single; overload;
    function Max(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency; overload;
    function Max(const ASelector: TFunc<T, NullableDouble>): NullableDouble; overload;
    function Max(const ASelector: TFunc<T, NullableInt32>): NullableInt32; overload;
    function Max(const ASelector: TFunc<T, NullableInt64>): NullableInt64; overload;
    function Max(const ASelector: TFunc<T, NullableSingle>): NullableSingle; overload;
    function Max<TResult>(const ASelector: TFunc<T, TResult>): TResult; overload;
    function Min: T; overload;
    function Min(const AComparer: TFunc<T, T, Integer>): T; overload;
    function Min(const ASelector: TFunc<T, Currency>): Currency; overload;
    function Min(const ASelector: TFunc<T, Double>): Double; overload;
    function Min(const ASelector: TFunc<T, Int32>): Int32; overload;
    function Min(const ASelector: TFunc<T, Int64>): Int64; overload;
    function Min(const ASelector: TFunc<T, Single>): Single; overload;
    function Min(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency; overload;
    function Min(const ASelector: TFunc<T, NullableDouble>): NullableDouble; overload;
    function Min(const ASelector: TFunc<T, NullableInt32>): NullableInt32; overload;
    function Min(const ASelector: TFunc<T, NullableInt64>): NullableInt64; overload;
    function Min(const ASelector: TFunc<T, NullableSingle>): NullableSingle; overload;
    function Min<TResult>(const ASelector: TFunc<T, TResult>): TResult; overload;
    function Min(const AComparer: IComparer<T>): T; overload;
    function Order: IFluentEnumerable<T>; overload;
    function Order(const AComparer: IComparer<T>): IFluentEnumerable<T>; overload;
    function OrderDescending: IFluentEnumerable<T>; overload;
    function OrderDescending(const AComparer: IComparer<T>): IFluentEnumerable<T>; overload;
    function Select<TResult>(const ASelector: TFunc<T, TResult>): IFluentEnumerable<TResult>; overload;
    function Select<TResult>(const ASelector: TFunc<T, Integer, TResult>): IFluentEnumerable<TResult>; overload;
    function SelectMany<TResult>(const ASelector: TFunc<T, TArray<TResult>>): IFluentEnumerable<TResult>; overload;
    function SelectMany<TResult>(const ASelector: TFunc<T, Integer, IFluentArray<TResult>>): IFluentEnumerable<TResult>; overload;
    function SelectMany<TCollection, TResult>(
      const ACollectionSelector: TFunc<T, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>): IFluentEnumerable<TResult>; overload;
    function SelectMany<TCollection, TResult>(
      const ACollectionSelector: TFunc<T, Integer, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>): IFluentEnumerable<TResult>; overload;
    function SkipWhile(const APredicate: TFunc<T, Boolean>): IFluentEnumerable<T>; overload;
    function SkipWhile(const APredicate: TFunc<T, Integer, Boolean>): IFluentEnumerable<T>; overload;
    function TakeWhile(const APredicate: TFunc<T, Boolean>): IFluentEnumerable<T>; overload;
    function TakeWhile(const APredicate: TFunc<T, Integer, Boolean>): IFluentEnumerable<T>; overload;
    function ToDictionary<TKey, TValue>(const AKeySelector: TFunc<T, TKey>;
      const AValueSelector: TFunc<T, TValue>): TDictionary<TKey, TValue>; overload;
    function ToDictionary<TKey, TValue>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, T>; overload;
    function ToDictionary<TKey, TValue>(const AKeySelector: TFunc<T, TKey>;
      const AValueSelector: TFunc<T, TValue>;
      const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, TValue>; overload;
    function TryGetNonEnumeratedCount(out ACount: Integer): Boolean;
    function ThenBy<TKey>(const AKeySelector: TFunc<T, TKey>): IFluentEnumerable<T>;
    function ThenByDescending<TKey>(const AKeySelector: TFunc<T, TKey>): IFluentEnumerable<T>;
    function ToArray: IFluentArray<T>;
    function ToList: IFluentList<T>;
  end;

  IGroupByEnumerable<TKey, T> = interface(IInterface)
    ['{A85DB3F6-E808-4E81-B386-75190087507B}']
    function GetEnumerator: IFluentEnumerator<IGrouping<TKey, T>>;
    function AsEnumerable: IFluentEnumerable<IGrouping<TKey, T>>;
  end;

  IGrouping<TKey, T> = interface(IInterface)
    ['{87B4E3F7-C092-44D1-B682-0B03C0202BF0}']
    function GetKey: TKey;
    function GetItems: IFluentEnumerable<T>;
    property Key: TKey read GetKey;
    property Items: IFluentEnumerable<T> read GetItems;
  end;

  TFluentGrouping<TKey, T> = class(TInterfacedObject, IGrouping<TKey, T>)
  private
    FKey: TKey;
    FItems: IFluentEnumerable<T>;
  public
    constructor Create(const AKey: TKey; const AItems: IFluentEnumerable<T>);
    function GetKey: TKey;
    function GetItems: IFluentEnumerable<T>;
    property Key: TKey read GetKey;
    property Items: IFluentEnumerable<T> read GetItems;
  end;

//  IFluentChunkResult<T> = interface(IInterface)
//    ['{1148CD41-1C5F-44DA-A4EF-C200AC3F2D5A}']
//    function GetEnumerator: IFluentEnumerator<TArray<T>>;
//    function AsEnumerable: IFluentEnumerable<TArray<T>>;
//  end;

  IFluentEnumerableAdapter<TResult> = interface(IInterface)
    ['{69303F43-C266-437F-A790-4038CFDA0680}']
    function AsEnumerable: IFluentEnumerable<TResult>;
  end;

  IFluentArray<T> = interface(IInterface)
    ['{E3DF6D61-1A52-466E-8B16-CF7AAC574A02}']
    function GetItem(AIndex: NativeInt): T;
    procedure SetItem(AIndex: NativeInt; const AValue: T);
    function _GetArray: TArray<T>;
    procedure SetItems(const AItems: TArray<T>);
    function AsEnumerable: IFluentEnumerable<T>;
    function GetEnumerator: IFluentEnumerator<T>;
    function Length: Integer;
    property ArrayData: TArray<T> read _GetArray;
    property Items[AIndex: NativeInt]: T read GetItem write SetItem; default;
  end;

  ICollections<T> = interface(IFluentEnumerableBase<T>)
    ['{1F1B87DA-2722-40E3-899F-5622CA9BE807}']
    function Count: NativeInt;
    function Contains(const AItem: T): Boolean;
    function Remove(const AItem: T): Boolean;
    function AsEnumerable: IFluentEnumerable<T>;
    function GetEnumerator: IFluentEnumerator<T>;
    procedure Add(const AItem: T);
    procedure CopyTo(AArray: array of T; AIndex: Integer);
    procedure Clear;
  end;

  IFluentList<T> = interface(ICollections<T>)
    ['{2749C02A-9973-4747-A4D3-29376DFD6242}']
    function GetCapacity: NativeInt;
    procedure SetCapacity(const AValue: NativeInt);
    function GetItem(AIndex: NativeInt): T;
    procedure SetItem(AIndex: NativeInt; const AValue: T);
    function GetList: IFluentArray<T>;
    function GetComparer: IComparer<T>;
    procedure SetOnNotify(const AValue: TCollectionNotifyEvent<T>);
    function GetOnNotify: TCollectionNotifyEvent<T>;
    procedure AddRange(const AValues: array of T); overload;
    procedure AddRange(const ACollection: IEnumerable<T>); overload;
    procedure AddRange(const ACollection: TEnumerable<T>); overload;
    procedure Insert(const AIndex: NativeInt; const AValue: T);
    procedure InsertRange(const AIndex: NativeInt; const AValues: array of T; ACount: NativeInt); overload;
    procedure InsertRange(const AIndex: NativeInt; const AValues: array of T); overload;
    procedure InsertRange(const AIndex: NativeInt; const ACollection: IEnumerable<T>); overload;
    procedure InsertRange(const AIndex: NativeInt; const ACollection: TEnumerable<T>); overload;
    procedure Pack;
    procedure Delete(const AIndex: NativeInt);
    procedure DeleteRange(const AIndex, ACount: NativeInt);
    procedure Exchange(const AIndex1, AIndex2: NativeInt);
    procedure Move(const ACurIndex, ANewIndex: NativeInt);
    procedure Reverse;
    procedure Sort; overload;
    procedure Sort(const AComparer: IComparer<T>); overload;
    procedure Sort(const AComparer: IComparer<T>; AIndex, ACount: NativeInt); overload;
    procedure TrimExcess;
    function RemoveItem(const AValue: T; Direction: TDirection): NativeInt;
    function ExtractItem(const AValue: T; Direction: TDirection): T;
    function Extract(const AValue: T): T;
    function ExtractAt(constIndex: NativeInt): T;
    function First: T;
    function Last: T;
    function Expand: IFluentList<T>;
    function IndexOf(const AValue: T): NativeInt;
    function IndexOfItem(const AValue: T; Direction: TDirection): NativeInt;
    function LastIndexOf(const AValue: T): NativeInt;
    function BinarySearch(const AItem: T; out FoundIndex: NativeInt): Boolean; overload;
    function BinarySearch(const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>): Boolean; overload;
    function BinarySearch(const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>; AIndex, Count: NativeInt): Boolean; overload;
    function IsEmpty: Boolean;
    function ToArray: IFluentArray<T>;
    property Capacity: NativeInt read GetCapacity write SetCapacity;
    property Items[AIndex: NativeInt]: T read GetItem write SetItem; default;
    property List: IFluentArray<T> read GetList;
    property Comparer: IComparer<T> read GetComparer;
    property OnNotify: TCollectionNotifyEvent<T> read GetOnNotify write SetOnNotify;
  end;

  IFluentDictionary<K, V> = interface(ICollections<TPair<K, V>>)
    ['{CF242859-D62D-4277-91B3-D4E389793E7C}']
    procedure SetCapacity(const AValue: NativeInt);
    procedure SetItem(const AKey: K; const AValue: V);
    procedure SetOnKeyNotify(const AValue: TCollectionNotifyEvent<K>);
    procedure SetOnValueNotify(const AValue: TCollectionNotifyEvent<V>);
    function GetCapacity: NativeInt;
    function GetItem(const AKey: K): V;
    function GetGrowThreshold: NativeInt;
    function GetCollisions: NativeInt;
    function GetKeys: TDictionary<K, V>.TKeyCollection;
    function GetValues: TDictionary<K, V>.TValueCollection;
    function GetComparer: IEqualityComparer<K>;
    function GetOnKeyNotify: TCollectionNotifyEvent<K>;
    function GetOnValueNotify: TCollectionNotifyEvent<V>;
    procedure TrimExcess;
    procedure AddRange(const Dictionary: TDictionary<K, V>); overload;
    procedure AddRange(const AItems: TEnumerable<TPair<K, V>>); overload;
    procedure AddOrSetValue(const AKey: K; const AValue: V);
    procedure Clear;
    procedure Add(const AKey: K; const AValue: V); overload;
    procedure Add(const AItem: TPair<K, V>); overload;
    function Remove(const AKey: K): Boolean; overload;
    function Remove(const AItem: TPair<K, V>): Boolean; overload;
    function Contains(const AValue: TPair<K, V>): Boolean;
    function Count: NativeInt;
    function ExtractPair(const AKey: K): TPair<K, V>;
    function TryGetValue(const AKey: K; var AValue: V): Boolean;
    function TryAdd(const AKey: K; const AValue: V): Boolean;
    function ContainsKey(const AKey: K): Boolean;
    function ContainsValue(const AValue: V): Boolean;
    function IsEmpty: Boolean;
    function ToArray: IFluentArray<TPair<K, V>>;
    property Capacity: NativeInt read GetCapacity write SetCapacity;
    property GrowThreshold: NativeInt read GetGrowThreshold;
    property Collisions: NativeInt read GetCollisions;
    property Keys: TDictionary<K, V>.TKeyCollection read GetKeys;
    property Values: TDictionary<K, V>.TValueCollection read GetValues;
    property Comparer: IEqualityComparer<K> read GetComparer;
    property Items[const AKey: K]: V read GetItem write SetItem; default;
    property OnKeyNotify: TCollectionNotifyEvent<K> read GetOnKeyNotify write SetOnKeyNotify;
    property OnValueNotify: TCollectionNotifyEvent<V> read GetOnValueNotify write SetOnValueNotify;
  end;

implementation

uses
  FluentQuery.Collections,
  FluentQuery.Adapters,
  FluentQuery.SkipWhile,
  FluentQuery.Where,
  FluentQuery.Select,
  FluentQuery.Take,
  FluentQuery.OrderBy,
  FluentQuery.Skip,
  FluentQuery.Distinct,
  FluentQuery.TakeWhile,
  FluentQuery.GroupBy,
  FluentQuery.GroupJoin,
  FluentQuery.OfType,
  FluentQuery.SelectMany,
  FluentQuery.Zip,
  FluentQuery.Join,
  FluentQuery.Exclude,
  FluentQuery.Union,
  FluentQuery.Intersect,
  FluentQuery.Concat,
  FluentQuery.Order,
//  Fluent.Chunk,
  FluentQuery.Cast,
  FluentQuery.SkipWhileIndexed,
  FluentQuery.SelectIndexed,
  FluentQuery.TakeWhileIndexed,
  FluentQuery.SelectManyCollection,
  FluentQuery.SelectManyIndexed,
  FluentQuery.ThenBy,
  FluentQuery.SelectManyCollectionIndexed;

{ IFluentEnumerable<T> }

constructor IFluentEnumerable<T>.Create(const AEnumerator: IFluentEnumerableBase<T>;
  const AFluentType: TFluentType; const AComparer: IEqualityComparer<T>);
begin
  FEnumerator := AEnumerator;
  FFluentType := AFluentType;
  FComparer := AComparer;
  if FComparer = nil then
    FComparer := TEqualityComparer<T>.Default;
  FIsValid := True;
end;

function IFluentEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := FEnumerator.GetEnumerator;
end;

function IFluentEnumerable<T>.Where(const APredicate: TFunc<T, Boolean>): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TFluentWhereEnumerable<T>.Create(FEnumerator, APredicate),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.Take(const ACount: Integer): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TFluentTakeEnumerable<T>.Create(FEnumerator, ACount),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.Skip(const ACount: Integer): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TFluentSkipEnumerable<T>.Create(FEnumerator, ACount),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.OrderBy(const AComparer: TFunc<T, T, Integer>): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TFluentOrderByEnumerable<T>.Create(FEnumerator, AComparer),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.OrderBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: IComparer<TKey>): IFluentEnumerable<T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AComparer) then
    raise EArgumentNilException.Create('Comparer cannot be nil');
  Result := IFluentEnumerable<T>.Create(
    TFluentOrderByEnumerable<T>.Create(FEnumerator,
      function(A, B: T): Integer
      begin
        Result := AComparer.Compare(AKeySelector(A), AKeySelector(B));
      end),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.OrderByDesc(const AComparer: TFunc<T, T, Integer>): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TFluentOrderByEnumerable<T>.Create(FEnumerator,
      function(A, B: T): Integer
      begin
        Result := -AComparer(A, B);
      end),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.OrderDescending(const AComparer: IComparer<T>): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TFluentOrderEnumerable<T>.Create(FEnumerator,
      TComparer<T>.Construct(
        function(const Left, Right: T): Integer
        begin
          if AComparer = nil then
            Result := -TComparer<T>.Default.Compare(Left, Right)
          else
            Result := -AComparer.Compare(Left, Right);
        end)),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.OrderDescending: IFluentEnumerable<T>;
begin
  Result := OrderDescending(nil);
end;

function IFluentEnumerable<T>.Distinct: IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TFluentDistinctEnumerable<T>.Create(FEnumerator, FComparer),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.Distinct(const AComparer: IEqualityComparer<T>): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TFluentDistinctEnumerable<T>.Create(FEnumerator, AComparer),
    FFluentType,
    AComparer
  );
end;

function IFluentEnumerable<T>.Select<TResult>(const ASelector: TFunc<T, TResult>): IFluentEnumerable<TResult>;
begin
  Result := IFluentEnumerable<TResult>.Create(
    TFluentSelectEnumerable<T, TResult>.Create(FEnumerator, ASelector),
    FFluentType,
    TEqualityComparer<TResult>.Default
  );
end;

function IFluentEnumerable<T>.Aggregate(const AReducer: TFunc<T, T, T>): T;
var
  LEnum: IFluentEnumerator<T>;
  LResult: T;
  LHasValue: Boolean;
begin
  LResult := Default(T);
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end
    else
      LResult := AReducer(LResult, LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LResult;
end;

function IFluentEnumerable<T>.Aggregate<TAcc>(const AInitialValue: TAcc;
  const AAccumulator: TFunc<TAcc, T, TAcc>): TAcc;
var
  LEnum: IFluentEnumerator<T>;
  LResult: TAcc;
begin
  LEnum := GetEnumerator;
  LResult := AInitialValue;
  while LEnum.MoveNext do
    LResult := AAccumulator(LResult, LEnum.Current);
  Result := LResult;
end;

function IFluentEnumerable<T>.Aggregate<TAccumulate, TResult>(
  const AInitialValue: TAccumulate;
  const AAccumulator: TFunc<TAccumulate, T, TAccumulate>;
  const AResultSelector: TFunc<TAccumulate, TResult>): TResult;
var
  LEnum: IFluentEnumerator<T>;
  LResult: TAccumulate;
begin
  if not Assigned(AAccumulator) then
    raise EArgumentNilException.Create('Accumulator cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  LEnum := GetEnumerator;
  LResult := AInitialValue;
  while LEnum.MoveNext do
    LResult := AAccumulator(LResult, LEnum.Current);
  Result := AResultSelector(LResult);
end;

function IFluentEnumerable<T>.AggregateBy<TKey, TAccumulate>(
  const AKeySelector: TFunc<T, TKey>;
  const ASeedFactory: TFunc<TKey, TAccumulate>;
  const AAccumulator: TFunc<TAccumulate, T, TAccumulate>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, TAccumulate>;
var
  LEnum: IFluentEnumerator<T>;
  LDict: TDictionary<TKey, TAccumulate>;
  LKey: TKey;
  LAccum: TAccumulate;
begin
  LDict := TDictionary<TKey, TAccumulate>.Create(AComparer);
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
    begin
      LKey := AKeySelector(LEnum.Current);
      if LDict.TryGetValue(LKey, LAccum) then
        LAccum := AAccumulator(LAccum, LEnum.Current)
      else
        LAccum := AAccumulator(ASeedFactory(LKey), LEnum.Current);
      LDict.AddOrSetValue(LKey, LAccum);
    end;
    Result := LDict;
  except
    LDict.Free;
    raise;
  end;
end;

function IFluentEnumerable<T>.AggregateBy<TKey, TAccumulate>(
  const AKeySelector: TFunc<T, TKey>;
  const ASeed: TAccumulate;
  const AAccumulator: TFunc<TAccumulate, T, TAccumulate>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, TAccumulate>;
var
  LEnum: IFluentEnumerator<T>;
  LDict: TDictionary<TKey, TAccumulate>;
  LKey: TKey;
  LAccum: TAccumulate;
begin
  LDict := TDictionary<TKey, TAccumulate>.Create(AComparer);
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
    begin
      LKey := AKeySelector(LEnum.Current);
      if LDict.TryGetValue(LKey, LAccum) then
        LAccum := AAccumulator(LAccum, LEnum.Current)
      else
        LAccum := AAccumulator(ASeed, LEnum.Current);
      LDict.AddOrSetValue(LKey, LAccum);
    end;
    Result := LDict;
  except
    LDict.Free;
    raise;
  end;
end;

function IFluentEnumerable<T>.Sum(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Double;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function IFluentEnumerable<T>.Sum(const ASelector: TFunc<T, Integer>): Integer;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Integer;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function IFluentEnumerable<T>.SumCurrency(const ASelector: TFunc<T, Currency>): Currency;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Currency;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function IFluentEnumerable<T>.SumInt32(const ASelector: TFunc<T, Int32>): Int32;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Int32;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function IFluentEnumerable<T>.Sum(const ASelector: TFunc<T, Int64>): Int64;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Int64;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    LSum := LSum + ASelector(LEnum.Current);
  Result := LSum;
end;

function IFluentEnumerable<T>.Sum(const ASelector: TFunc<T, Single>): Single;
var
  LEnum: IFluentEnumerator<T>;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  Result := 0;
  while LEnum.MoveNext do
    Result := Result + ASelector(LEnum.Current);
end;

function IFluentEnumerable<T>.Sum(const ASelector: TFunc<T, NullableInt32>): NullableInt32;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Int32;
  LValue: NullableInt32;
  LCount: Integer;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      LSum := LSum + LValue.Value;
      Inc(LCount);
    end;
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence or no valid values.');
  Result := NullableInt32.Create(LSum);
end;

function IFluentEnumerable<T>.Sum(const ASelector: TFunc<T, NullableInt64>): NullableInt64;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Int64;
  LCount: Integer;
  LValue: NullableInt64;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      LSum := LSum + LValue.Value;
      Inc(LCount);
    end;
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence or no valid values.');
  Result := NullableInt64.Create(LSum);
end;

function IFluentEnumerable<T>.Sum(const ASelector: TFunc<T, NullableSingle>): NullableSingle;
var
  LEnum: IFluentEnumerator<T>;
  LValue: NullableSingle;
  LHasValue: Boolean;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  Result := NullableSingle.Create(0);
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      if not LHasValue then
      begin
        Result := LValue;
        LHasValue := True;
      end
      else
        Result := NullableSingle.Create(Result.Value + LValue.Value);
    end;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Empty sequence or no valid values.');
end;

function IFluentEnumerable<T>.Sum(const ASelector: TFunc<T, NullableDouble>): NullableDouble;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Double;
  LCount: Integer;
  LValue: NullableDouble;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      LSum := LSum + LValue.Value;
      Inc(LCount);
    end;
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence or no valid values.');
  Result := NullableDouble.Create(LSum);
end;

function IFluentEnumerable<T>.Average(const ASelector: TFunc<T, Currency>): Currency;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Currency;
  LCount: Integer;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LSum := LSum + ASelector(LEnum.Current);
    Inc(LCount);
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence.');
  Result := LSum / LCount;
end;

function IFluentEnumerable<T>.Average(const ASelector: TFunc<T, Int32>): Double;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Int64;
  LCount: Integer;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LSum := LSum + ASelector(LEnum.Current);
    Inc(LCount);
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence.');
  Result := LSum / LCount;
end;

function IFluentEnumerable<T>.Average(const ASelector: TFunc<T, Int64>): Double;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Int64;
  LCount: Integer;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LSum := LSum + ASelector(LEnum.Current);
    Inc(LCount);
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence.');
  Result := LSum / LCount;
end;

function IFluentEnumerable<T>.Average(const ASelector: TFunc<T, Single>): Double;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Double;
  LCount: Integer;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LSum := LSum + ASelector(LEnum.Current);
    Inc(LCount);
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence.');
  Result := LSum / LCount;
end;

function IFluentEnumerable<T>.Average(const ASelector: TFunc<T, NullableInt32>): Double;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Int64;
  LCount: Integer;
  LValue: NullableInt32;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      LSum := LSum + LValue.Value;
      Inc(LCount);
    end;
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence or no valid values.');
  Result := LSum / LCount;
end;

function IFluentEnumerable<T>.Average(const ASelector: TFunc<T, NullableInt64>): Double;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Int64;
  LCount: Integer;
  LValue: NullableInt64;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      LSum := LSum + LValue.Value;
      Inc(LCount);
    end;
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence or no valid values.');
  Result := LSum / LCount;
end;

function IFluentEnumerable<T>.Average(const ASelector: TFunc<T, NullableSingle>): Double;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Double;
  LCount: Integer;
  LValue: NullableSingle;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      LSum := LSum + LValue.Value;
      Inc(LCount);
    end;
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence or no valid values.');
  Result := LSum / LCount;
end;

function IFluentEnumerable<T>.Average(const ASelector: TFunc<T, NullableDouble>): Double;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Double;
  LCount: Integer;
  LValue: NullableDouble;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      LSum := LSum + LValue.Value;
      Inc(LCount);
    end;
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence or no valid values.');
  Result := LSum / LCount;
end;

function IFluentEnumerable<T>.Average(const ASelector: TFunc<T, NullableCurrency>): Currency;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Currency;
  LCount: Integer;
  LValue: NullableCurrency;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      LSum := LSum + LValue.Value;
      Inc(LCount);
    end;
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence or no valid values.');
  Result := LSum / LCount;
end;

function IFluentEnumerable<T>.Average(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Double;
  LCount: Integer;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LSum := LSum + ASelector(LEnum.Current);
    Inc(LCount);
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence.');
  Result := LSum / LCount;
end;

function IFluentEnumerable<T>.Min: T;
var
  LEnum: IFluentEnumerator<T>;
  LResult: T;
  LHasValue: Boolean;
begin
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := Default(T);
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end
    else if TComparer<T>.Default.Compare(LEnum.Current, LResult) < 0 then
      LResult := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements.');
  Result := LResult;
end;

function IFluentEnumerable<T>.Max: T;
var
  LEnum: IFluentEnumerator<T>;
  LResult: T;
  LHasValue: Boolean;
begin
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := Default(T);
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end
    else if TComparer<T>.Default.Compare(LEnum.Current, LResult) > 0 then
      LResult := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements.');
  Result := LResult;
end;

function IFluentEnumerable<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
var
  LEnum: IFluentEnumerator<T>;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    if not Assigned(APredicate) or APredicate(LEnum.Current) then
      Exit(True);
  end;
  Result := False;
end;

function IFluentEnumerable<T>.Any: Boolean;
begin
  Result := GetEnumerator.MoveNext;
end;

function IFluentEnumerable<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
var
  LEnum: IFluentEnumerator<T>;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate cannot be nil');
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    if not APredicate(LEnum.Current) then
      Exit(False);
  end;
  Result := True;
end;

function IFluentEnumerable<T>.Contains(const AValue: T): Boolean;
begin
  Result := TFluentCompare.Compare(FEnumerator, AValue, FComparer);
end;

function IFluentEnumerable<T>.Contains(const AValue: T;
  const AComparer: IEqualityComparer<T>): Boolean;
var
  LEnum: IFluentEnumerator<T>;
begin
  if not Assigned(AComparer) then
    raise EArgumentNilException.Create('Comparer cannot be nil');
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    if AComparer.Equals(LEnum.Current, AValue) then
      Exit(True);
  Result := False;
end;

function IFluentEnumerable<T>.First: T;
begin
  Result := First(nil);
end;

function IFluentEnumerable<T>.First(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IFluentEnumerator<T>;
  LItem: T;
  LFound: Boolean;
begin
  LItem := Default(T);
  LEnum := GetEnumerator;
  LFound := False;
  while LEnum.MoveNext do
  begin
    LItem := LEnum.Current;
    if not Assigned(APredicate) or APredicate(LItem) then
    begin
      LFound := True;
      Break;
    end;
  end;
  if LFound then
    Result := LItem
  else
    raise EInvalidOperation.Create('Nenhum elemento encontrado');
end;

function IFluentEnumerable<T>.FirstOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IFluentEnumerator<T>;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    if not Assigned(APredicate) or APredicate(LEnum.Current) then
      Exit(LEnum.Current);
  end;
  Result := Default(T);
end;

function IFluentEnumerable<T>.FirstOrDefault: T;
begin
  Result := FirstOrDefault(nil);
end;

function IFluentEnumerable<T>.Last(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IFluentEnumerator<T>;
  LResult: T;
  LHasValue: Boolean;
begin
  LResult := Default(T);
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not Assigned(APredicate) or APredicate(LEnum.Current) then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no matching element');
  Result := LResult;
end;

function IFluentEnumerable<T>.Last: T;
begin
  Result := Last(nil);
end;

function IFluentEnumerable<T>.LastOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IFluentEnumerator<T>;
  LResult: T;
  LHasValue: Boolean;
begin
  LResult := Default(T);
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not Assigned(APredicate) or APredicate(LEnum.Current) then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end;
  end;
  if not LHasValue then
    Result := Default(T)
  else
    Result := LResult;
end;

function IFluentEnumerable<T>.LastOrDefault: T;
begin
  Result := LastOrDefault(nil);
end;

function IFluentEnumerable<T>.Count(const APredicate: TFunc<T, Boolean>): Integer;
var
  LEnum: IFluentEnumerator<T>;
  LCount: Integer;
begin
  LEnum := GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    if not Assigned(APredicate) or APredicate(LEnum.Current) then
      Inc(LCount);
  end;
  Result := LCount;
end;

function IFluentEnumerable<T>.CountBy<TKey>(
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, Integer>;
var
  LEnum: IFluentEnumerator<T>;
  LDict: TDictionary<TKey, Integer>;
  LKey: TKey;
  LCount: Integer;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  LDict := TDictionary<TKey, Integer>.Create(AComparer);
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
    begin
      LKey := AKeySelector(LEnum.Current);
      if LDict.TryGetValue(LKey, LCount) then
        LDict[LKey] := LCount + 1
      else
        LDict.Add(LKey, 1);
    end;
    Result := LDict;
  except
    LDict.Free;
    raise;
  end;
end;

function IFluentEnumerable<T>.Count: Integer;
begin
  Result := Count(nil);
end;

function IFluentEnumerable<T>.LongCount(const APredicate: TFunc<T, Boolean>): Int64;
var
  LEnum: IFluentEnumerator<T>;
  LCount: Int64;
begin
  LEnum := GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    if not Assigned(APredicate) or APredicate(LEnum.Current) then
      Inc(LCount);
  end;
  Result := LCount;
end;

function IFluentEnumerable<T>.LongCount: Int64;
begin
  Result := LongCount(nil);
end;

function IFluentEnumerable<T>.TakeWhile(const APredicate: TFunc<T, Boolean>): IFluentEnumerable<T>;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate cannot be nil');
  Result := IFluentEnumerable<T>.Create(
    TFluentTakeWhileEnumerable<T>.Create(FEnumerator, APredicate),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.SkipWhile(const APredicate: TFunc<T, Boolean>): IFluentEnumerable<T>;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate cannot be nil');
  Result := IFluentEnumerable<T>.Create(
    TFluentSkipWhileEnumerable<T>.Create(FEnumerator, APredicate),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.ToArray: IFluentArray<T>;
var
  LEnum: IFluentEnumerator<T>;
  LList: IFluentList<T>;
begin
  LList := TFluentList<T>.Create;
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      LList.Add(LEnum.Current);
    Result := LList.ToArray;
  finally
    LList := nil;
  end;
end;

function IFluentEnumerable<T>.ToDictionary<TKey, TValue>(
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, T>;
begin
  Result := ToDictionary<TKey, T>(AKeySelector, function(x: T): T begin Result := x end, AComparer);
end;

function IFluentEnumerable<T>.ToDictionary<TKey, TValue>(
  const AKeySelector: TFunc<T, TKey>;
  const AValueSelector: TFunc<T, TValue>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, TValue>;
var
  LEnum: IFluentEnumerator<T>;
  LDict: TDictionary<TKey, TValue>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AValueSelector) then
    raise EArgumentNilException.Create('Value selector cannot be nil');
  LDict := TDictionary<TKey, TValue>.Create(AComparer);
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      LDict.Add(AKeySelector(LEnum.Current), AValueSelector(LEnum.Current));
    Result := LDict;
  except
    LDict.Free;
    raise;
  end;
end;

function IFluentEnumerable<T>.ToList: IFluentList<T>;
var
  LList: IFluentList<T>;
  LEnum: IFluentEnumerator<T>;
begin
  LList := TFluentList<T>.Create;
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    LList.Add(LEnum.Current);
  Result := LList;
end;

function IFluentEnumerable<T>.ToDictionary<TKey, TValue>(
  const AKeySelector: TFunc<T, TKey>;
  const AValueSelector: TFunc<T, TValue>): TDictionary<TKey, TValue>;
begin
  Result := ToDictionary<TKey, TValue>(AKeySelector, AValueSelector, nil);
end;

function IFluentEnumerable<T>.GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>): IGroupByEnumerable<TKey, T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  Result := TFluentGroupByEnumerable<TKey, T>.Create(FEnumerator, AKeySelector);
end;

function IFluentEnumerable<T>.GroupBy<TKey, TElement>(
  const AKeySelector: TFunc<T, TKey>;
  const AElementSelector: TFunc<T, TElement>): IGroupByEnumerable<TKey, TElement>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AElementSelector) then
    raise EArgumentNilException.Create('Element selector cannot be nil');
  Result := TFluentGroupByEnumerable<TKey, TElement, T>.Create(
    FEnumerator,
    AKeySelector,
    AElementSelector);
end;

function IFluentEnumerable<T>.GroupBy<TKey, TResult>(
  const AKeySelector: TFunc<T, TKey>;
  const AResultSelector: TFunc<TKey, IFluentEnumerableAdapter<T>, TResult>): IFluentEnumerable<TResult>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := IFluentEnumerable<TResult>.Create(
    TFluentGroupByResultEnumerable<TKey, T, TResult>.Create(
      FEnumerator, AKeySelector, AResultSelector),
    FFluentType,
    TEqualityComparer<TResult>.Default
  );
end;

function IFluentEnumerable<T>.Zip<TSecond, TResult>(const ASecond: IFluentEnumerable<TSecond>;
  const AResultSelector: TFunc<T, TSecond, TResult>): IFluentEnumerable<TResult>;
begin
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := IFluentEnumerable<TResult>.Create(
    TFluentZipEnumerable<T, TSecond, TResult>.Create(FEnumerator, ASecond.FEnumerator, AResultSelector),
    FFluentType,
    TEqualityComparer<TResult>.Default
  );
end;

function IFluentEnumerable<T>.OfType<TResult>(const AIsType: TFunc<T, Boolean>;
  const AConverter: TFunc<T, TResult>): IFluentEnumerable<TResult>;
begin
  if not Assigned(AIsType) then
    raise EArgumentNilException.Create('IsType cannot be nil');
  if not Assigned(AConverter) then
    raise EArgumentNilException.Create('Converter cannot be nil');
  Result := IFluentEnumerable<TResult>.Create(
    TFluentOfTypeEnumerable<T, TResult>.Create(FEnumerator, AIsType, AConverter),
    FFluentType,
    TEqualityComparer<TResult>.Default
  );
end;

function IFluentEnumerable<T>.Exclude(const ASecond: IFluentEnumerable<T>): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TFluentExcludeEnumerable<T>.Create(FEnumerator, ASecond.FEnumerator, FComparer),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.Intersect(const ASecond: IFluentEnumerable<T>): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TFluentIntersectEnumerable<T>.Create(FEnumerator, ASecond.FEnumerator, FComparer),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.Union(const ASecond: IFluentEnumerable<T>): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TFluentUnionEnumerable<T>.Create(FEnumerator, ASecond.FEnumerator, FComparer),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.Concat(const ASecond: IFluentEnumerable<T>): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TFluentConcatEnumerable<T>.Create(FEnumerator, ASecond.FEnumerator),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.SequenceEqual(const ASecond: IFluentEnumerable<T>): Boolean;
var
  LEnum1, LEnum2: IFluentEnumerator<T>;
begin
  LEnum1 := GetEnumerator;
  LEnum2 := ASecond.GetEnumerator;
  while LEnum1.MoveNext and LEnum2.MoveNext do
    if not FComparer.Equals(LEnum1.Current, LEnum2.Current) then
      Exit(False);
  Result := not (LEnum1.MoveNext or LEnum2.MoveNext);
end;

function IFluentEnumerable<T>.Single(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IFluentEnumerator<T>;
  LFound: Boolean;
  LResult: T;
begin
  LResult := Default(T);
  LEnum := GetEnumerator;
  LFound := False;
  while LEnum.MoveNext do
  begin
    if not Assigned(APredicate) or APredicate(LEnum.Current) then
    begin
      if LFound then
        raise EInvalidOperation.Create('Sequence contains more than one matching element');
      LResult := LEnum.Current;
      LFound := True;
    end;
  end;
  if not LFound then
    raise EInvalidOperation.Create('Sequence contains no matching element');
  Result := LResult;
end;

function IFluentEnumerable<T>.Single: T;
begin
  Result := Single(nil);
end;

function IFluentEnumerable<T>.SingleOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IFluentEnumerator<T>;
  LFound: Boolean;
  LResult: T;
begin
  LResult := Default(T);
  LEnum := GetEnumerator;
  LFound := False;
  while LEnum.MoveNext do
  begin
    if not Assigned(APredicate) or APredicate(LEnum.Current) then
    begin
      if LFound then
        raise EInvalidOperation.Create('Sequence contains more than one matching element');
      LResult := LEnum.Current;
      LFound := True;
    end;
  end;
  Result := LResult;
end;

function IFluentEnumerable<T>.SingleOrDefault: T;
begin
  Result := SingleOrDefault(nil);
end;

function IFluentEnumerable<T>.ElementAt(const AIndex: Integer): T;
var
  LEnum: IFluentEnumerator<T>;
  LCount: Integer;
begin
  if AIndex < 0 then
    raise EArgumentOutOfRangeException.Create('Index must be non-negative');
  LEnum := GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    if LCount = AIndex then
      Exit(LEnum.Current);
    Inc(LCount);
  end;
  raise EArgumentOutOfRangeException.Create('Index out of range');
end;

function IFluentEnumerable<T>.ElementAtOrDefault(const AIndex: Integer): T;
var
  LEnum: IFluentEnumerator<T>;
  LCount: Integer;
begin
  if AIndex < 0 then
    Exit(Default(T));
  LEnum := GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    if LCount = AIndex then
      Exit(LEnum.Current);
    Inc(LCount);
  end;
  Result := Default(T);
end;

function IFluentEnumerable<T>.DistinctBy<TKey>(const AKeySelector: TFunc<T, TKey>): IFluentEnumerable<T>;
var
  LSeenKeys: TDictionary<TKey, T>;
  LEnum: IFluentEnumerator<T>;
  LItems: TArray<T>;
  LItem: T;
  LIndex: Integer;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  LSeenKeys := TDictionary<TKey, T>.Create;
  try
    LEnum := GetEnumerator;
    SetLength(LItems, 0);
    LIndex := 0;
    while LEnum.MoveNext do
    begin
      LItem := LEnum.Current;
      if not LSeenKeys.ContainsKey(AKeySelector(LItem)) then
      begin
        LSeenKeys.Add(AKeySelector(LItem), LItem);
        SetLength(LItems, LIndex + 1);
        LItems[LIndex] := LItem;
        Inc(LIndex);
      end;
    end;
    Result := IFluentEnumerable<T>.Create(
      TArrayAdapter<T>.Create(LItems),
      FFluentType,
      FComparer
    );
  finally
    LSeenKeys.Free;
  end;
end;

function IFluentEnumerable<T>.Min(const AComparer: TFunc<T, T, Integer>): T;
var
  LEnum: IFluentEnumerator<T>;
  LResult: T;
  LHasValue: Boolean;
begin
  if not Assigned(AComparer) then
    raise EArgumentNilException.Create('Comparer cannot be nil');
  LResult := Default(T);
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LResult) < 0 then
      LResult := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements.');
  Result := LResult;
end;

function IFluentEnumerable<T>.Max(const AComparer: TFunc<T, T, Integer>): T;
var
  LEnum: IFluentEnumerator<T>;
  LResult: T;
  LHasValue: Boolean;
begin
  if not Assigned(AComparer) then
    raise EArgumentNilException.Create('Comparer cannot be nil');
  LResult := Default(T);
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer(LEnum.Current, LResult) > 0 then
      LResult := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements.');
  Result := LResult;
end;

function IFluentEnumerable<T>.GroupJoin<TInner, TKey, TResult>(const AInner: IFluentEnumerable<TInner>;
  const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
  const AResultSelector: TFunc<T, IFluentEnumerableAdapter<TInner>, TResult>): IFluentEnumerable<TResult>;
begin
  if not Assigned(AOuterKeySelector) then
    raise EArgumentNilException.Create('Outer key selector cannot be nil');
  if not Assigned(AInnerKeySelector) then
    raise EArgumentNilException.Create('Inner key selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := IFluentEnumerable<TResult>.Create(
    TFluentGroupJoinEnumerable<T, TInner, TKey, TResult>.Create(FEnumerator, AInner.FEnumerator, AOuterKeySelector, AInnerKeySelector, AResultSelector),
    FFluentType,
    TEqualityComparer<TResult>.Default
  );
end;

function IFluentEnumerable<T>.Join<TInner, TKey, TResult>(const AInner: IFluentEnumerable<TInner>;
  const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
  const AResultSelector: TFunc<T, TInner, TResult>): IFluentEnumerable<TResult>;
begin
  if not Assigned(AOuterKeySelector) then
    raise EArgumentNilException.Create('Outer key selector cannot be nil');
  if not Assigned(AInnerKeySelector) then
    raise EArgumentNilException.Create('Inner key selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := IFluentEnumerable<TResult>.Create(
    TFluentJoinEnumerable<T, TInner, TKey, TResult>.Create(FEnumerator, AInner.FEnumerator, AOuterKeySelector, AInnerKeySelector, AResultSelector),
    FFluentType,
    TEqualityComparer<TResult>.Default
  );
end;

function IFluentEnumerable<T>.MinBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: TFunc<TKey, TKey, Integer>): T;
var
  LEnum: IFluentEnumerator<T>;
  LResult: T;
  LMinKey: TKey;
  LKey: TKey;
  LHasValue: Boolean;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AComparer) then
    raise EArgumentNilException.Create('Comparer cannot be nil');
  LResult := Default(T);
  LMinKey := Default(TKey);
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LMinKey := AKeySelector(LResult);
      LHasValue := True;
    end
    else
    begin
      LKey := AKeySelector(LEnum.Current);
      if AComparer(LKey, LMinKey) < 0 then
      begin
        LMinKey := LKey;
        LResult := LEnum.Current;
      end;
    end;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LResult;
end;

function IFluentEnumerable<T>.Max(const ASelector: TFunc<T, Single>): Single;
var
  LEnum: IFluentEnumerator<T>;
  LHasValue: Boolean;
begin
  Result := 0;
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      Result := ASelector(LEnum.Current);
      LHasValue := True;
    end
    else if ASelector(LEnum.Current) > Result then
      Result := ASelector(LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Empty sequence.');
end;

function IFluentEnumerable<T>.Max(const ASelector: TFunc<T, Int64>): Int64;
var
  LEnum: IFluentEnumerator<T>;
  LResult: Int64;
  LHasValue: Boolean;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := 0;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := ASelector(LEnum.Current);
      LHasValue := True;
    end
    else if ASelector(LEnum.Current) > LResult then
      LResult := ASelector(LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Empty sequence.');
  Result := LResult;
end;

function IFluentEnumerable<T>.Max(const ASelector: TFunc<T, Int32>): Int32;
var
  LEnum: IFluentEnumerator<T>;
  LResult: Int32;
  LHasValue: Boolean;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := 0;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := ASelector(LEnum.Current);
      LHasValue := True;
    end
    else if ASelector(LEnum.Current) > LResult then
      LResult := ASelector(LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Empty sequence.');
  Result := LResult;
end;

function IFluentEnumerable<T>.Max(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: IFluentEnumerator<T>;
  LResult: Double;
  LHasValue: Boolean;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := 0;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := ASelector(LEnum.Current);
      LHasValue := True;
    end
    else if ASelector(LEnum.Current) > LResult then
      LResult := ASelector(LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Empty sequence.');
  Result := LResult;
end;

function IFluentEnumerable<T>.Max(const ASelector: TFunc<T, Currency>): Currency;
var
  LEnum: IFluentEnumerator<T>;
  LResult: Currency;
  LHasValue: Boolean;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := 0;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := ASelector(LEnum.Current);
      LHasValue := True;
    end
    else if ASelector(LEnum.Current) > LResult then
      LResult := ASelector(LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Empty sequence.');
  Result := LResult;
end;

function IFluentEnumerable<T>.Max(const ASelector: TFunc<T, NullableSingle>): NullableSingle;
var
  LEnum: IFluentEnumerator<T>;
  LResult: NullableSingle;
  LValue: NullableSingle;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      if not LResult.HasValue or (LValue.Value > LResult.Value) then
        LResult := LValue;
    end;
  end;
  Result := LResult;
end;

function IFluentEnumerable<T>.Max(const ASelector: TFunc<T, NullableInt64>): NullableInt64;
var
  LEnum: IFluentEnumerator<T>;
  LResult: NullableInt64;
  LValue: NullableInt64;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      if not LResult.HasValue or (LValue.Value > LResult.Value) then
        LResult := LValue;
    end;
  end;
  Result := LResult;
end;

function IFluentEnumerable<T>.Max(const ASelector: TFunc<T, NullableInt32>): NullableInt32;
var
  LEnum: IFluentEnumerator<T>;
  LResult: NullableInt32;
  LValue: NullableInt32;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      if not LResult.HasValue or (LValue.Value > LResult.Value) then
        LResult := LValue;
    end;
  end;
  Result := LResult;
end;

function IFluentEnumerable<T>.Max(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency;
var
  LEnum: IFluentEnumerator<T>;
  LResult: NullableCurrency;
  LValue: NullableCurrency;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      if not LResult.HasValue or (LValue.Value > LResult.Value) then
        LResult := LValue;
    end;
  end;
  Result := LResult;
end;

function IFluentEnumerable<T>.Max(const ASelector: TFunc<T, NullableDouble>): NullableDouble;
var
  LEnum: IFluentEnumerator<T>;
  LResult: NullableDouble;
  LValue: NullableDouble;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      if not LResult.HasValue or (LValue.Value > LResult.Value) then
        LResult := LValue;
    end;
  end;
  Result := LResult;
end;

function IFluentEnumerable<T>.MaxBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: TFunc<TKey, TKey, Integer>): T;
var
  LEnum: IFluentEnumerator<T>;
  LResult: T;
  LMaxKey: TKey;
  LKey: TKey;
  LHasValue: Boolean;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AComparer) then
    raise EArgumentNilException.Create('Comparer cannot be nil');
  LResult := Default(T);
  LMaxKey := Default(TKey);
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LMaxKey := AKeySelector(LResult);
      LHasValue := True;
    end
    else
    begin
      LKey := AKeySelector(LEnum.Current);
      if AComparer(LKey, LMaxKey) > 0 then
      begin
        LMaxKey := LKey;
        LResult := LEnum.Current;
      end;
    end;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence contains no elements');
  Result := LResult;
end;

function IFluentEnumerable<T>._IsEmpty: Boolean;
begin
  Result := not FIsValid;
end;

function IFluentEnumerable<T>.ToHashSet: THashSet<T>;
var
  LEnum: IFluentEnumerator<T>;
begin
  Result := THashSet<T>.Create(FComparer);
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      Result.Add(LEnum.Current);
  except
    Result.Free;
    raise;
  end;
end;

function IFluentEnumerable<T>.ToLookup<TKey, TElement>(const AKeySelector: TFunc<T, TKey>;
  const AElementSelector: TFunc<T, TElement>): TDictionary<TKey, TList<TElement>>;
var
  LEnum: IFluentEnumerator<T>;
  LKey: TKey;
  LElement: TElement;
  LList: TList<TElement>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AElementSelector) then
    raise EArgumentNilException.Create('Element selector cannot be nil');
  Result := TDictionary<TKey, TList<TElement>>.Create;
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
    begin
      LKey := AKeySelector(LEnum.Current);
      LElement := AElementSelector(LEnum.Current);
      if not Result.TryGetValue(LKey, LList) then
      begin
        LList := TList<TElement>.Create;
        Result.Add(LKey, LList);
      end;
      LList.Add(LElement);
    end;
  except
    for LList in Result.Values do
      LList.Free;
    Result.Free;
    raise;
  end;
end;

function IFluentEnumerable<T>.TryGetNonEnumeratedCount(out ACount: Integer): Boolean;
begin
  if FEnumerator is TListAdapter<T> then
  begin
    ACount := (FEnumerator as TListAdapter<T>).Count;
    Result := True;
  end
  else if FEnumerator is TArrayAdapter<T> then
  begin
    ACount := (FEnumerator as TArrayAdapter<T>).Count;
    Result := True;
  end
  else
  begin
    ACount := 0;
    Result := False;
  end;
end;

function IFluentEnumerable<T>.ThenBy<TKey>(const AKeySelector: TFunc<T, TKey>): IFluentEnumerable<T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  Result := IFluentEnumerable<T>.Create(
    TFluentThenByEnumerable<TKey, T>.Create(FEnumerator, AKeySelector, False, nil),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.ThenByDescending<TKey>(const AKeySelector: TFunc<T, TKey>): IFluentEnumerable<T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  Result := IFluentEnumerable<T>.Create(
    TFluentThenByEnumerable<TKey, T>.Create(FEnumerator, AKeySelector, True, nil),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.UnionBy<TKey>(const ASecond: IFluentEnumerable<T>;
  const AKeySelector: TFunc<T, TKey>): IFluentEnumerable<T>;
var
  LEnum: IFluentEnumerator<T>;
  LKeys: TDictionary<TKey, T>;
  LList: TList<T>;
  LKey: TKey;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  Result := Default(IFluentEnumerable<T>);
  LKeys := TDictionary<TKey, T>.Create;
  LList := TList<T>.Create;
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
    begin
      LKey := AKeySelector(LEnum.Current);
      if not LKeys.ContainsKey(LKey) then
      begin
        LKeys.Add(LKey, LEnum.Current);
        LList.Add(LEnum.Current);
      end;
    end;

    LEnum := ASecond.GetEnumerator;
    while LEnum.MoveNext do
    begin
      LKey := AKeySelector(LEnum.Current);
      if not LKeys.ContainsKey(LKey) then
      begin
        LKeys.Add(LKey, LEnum.Current);
        LList.Add(LEnum.Current);
      end;
    end;

    Result := IFluentEnumerable<T>.Create(TListAdapter<T>.Create(LList, True));
  finally
    LKeys.Free;
    if Result._IsEmpty then
      LList.Free;
  end;
end;

function IFluentEnumerable<T>.Append(const AElement: T): IFluentEnumerable<T>;
var
  LList: TList<T>;
  LEnum: IFluentEnumerator<T>;
begin
  Result := Default(IFluentEnumerable<T>);
  LList := TList<T>.Create;
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      LList.Add(LEnum.Current);
    LList.Add(AElement);
    Result := IFluentEnumerable<T>.Create(TListAdapter<T>.Create(LList, True));
  finally
    if Result._IsEmpty then
      LList.Free;
  end;
end;

function IFluentEnumerable<T>.Cast<TResult>: IFluentEnumerable<TResult>;
var
  LList: TList<TResult>;
  LEnum: IFluentEnumerator<T>;
begin
  Result := Default(IFluentEnumerable<TResult>);
  LList := TList<TResult>.Create;
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      LList.Add(TValue.From<T>(LEnum.Current).AsType<TResult>);
    Result := IFluentEnumerable<TResult>.Create(TListAdapter<TResult>.Create(LList, True));
  finally
    if Result._IsEmpty then
      LList.Free;
  end;
end;

//function IFluentEnumerable<T>.Chunk(const ASize: Integer): IFluentChunkResult<T>;
//begin
//  if ASize <= 0 then
//    raise EArgumentOutOfRangeException.Create('Size must be positive');
//  Result := TFluentChunkResult<T>.Create(FEnumerator, ASize);
//end;

function IFluentEnumerable<T>.DefaultIfEmpty: IFluentEnumerable<T>;
var
  LList: TList<T>;
  LEnum: IFluentEnumerator<T>;
begin
  Result := Default(IFluentEnumerable<T>);
  LList := TList<T>.Create;
  try
    LEnum := GetEnumerator;
    if LEnum.MoveNext then
    begin
      repeat
        LList.Add(LEnum.Current);
      until not LEnum.MoveNext;
    end
    else
      LList.Add(Default(T));
    Result := IFluentEnumerable<T>.Create(TListAdapter<T>.Create(LList, True));
  finally
    if Result._IsEmpty then
      LList.Free;
  end;
end;

function IFluentEnumerable<T>.DefaultIfEmpty(const ADefaultValue: T): IFluentEnumerable<T>;
var
  LList: TList<T>;
  LEnum: IFluentEnumerator<T>;
begin
  Result := Default(IFluentEnumerable<T>);
  LList := TList<T>.Create;
  try
    LEnum := GetEnumerator;
    if LEnum.MoveNext then
    begin
      repeat
        LList.Add(LEnum.Current);
      until not LEnum.MoveNext;
    end
    else
      LList.Add(ADefaultValue);
    Result := IFluentEnumerable<T>.Create(TListAdapter<T>.Create(LList, True));
  finally
    if Result._IsEmpty then
      LList.Free;
  end;
end;

function IFluentEnumerable<T>.ExcludeBy<TKey>(const ASecond: IFluentEnumerable<TKey>;
  const AKeySelector: TFunc<T, TKey>): IFluentEnumerable<T>;
var
  LEnum: IFluentEnumerator<T>;
  LKeys: TDictionary<TKey, Boolean>;
  LList: TList<T>;
  LKey: TKey;
  LEnumSecond: IFluentEnumerator<TKey>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  Result := Default(IFluentEnumerable<T>);
  LKeys := TDictionary<TKey, Boolean>.Create;
  LList := TList<T>.Create;
  try
    LEnumSecond := ASecond.GetEnumerator;
    while LEnumSecond.MoveNext do
      LKeys.TryAdd(LEnumSecond.Current, True);

    LEnum := GetEnumerator;
    while LEnum.MoveNext do
    begin
      LKey := AKeySelector(LEnum.Current);
      if not LKeys.ContainsKey(LKey) then
        LList.Add(LEnum.Current);
    end;
    Result := IFluentEnumerable<T>.Create(TListAdapter<T>.Create(LList, True));
  finally
    LKeys.Free;
    if Result._IsEmpty then
      LList.Free;
  end;
end;

function IFluentEnumerable<T>.IntersectBy<TKey>(const ASecond: IFluentEnumerable<TKey>;
  const AKeySelector: TFunc<T, TKey>): IFluentEnumerable<T>;
var
  LEnum: IFluentEnumerator<T>;
  LKeys: TDictionary<TKey, Boolean>;
  LList: TList<T>;
  LKey: TKey;
  LEnumSecond: IFluentEnumerator<TKey>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  Result := Default(IFluentEnumerable<T>);
  LKeys := TDictionary<TKey, Boolean>.Create;
  LList := TList<T>.Create;
  try
    LEnumSecond := ASecond.GetEnumerator;
    while LEnumSecond.MoveNext do
      LKeys.TryAdd(LEnumSecond.Current, True);

    LEnum := GetEnumerator;
    while LEnum.MoveNext do
    begin
      LKey := AKeySelector(LEnum.Current);
      if LKeys.ContainsKey(LKey) then
        LList.Add(LEnum.Current);
    end;
    Result := IFluentEnumerable<T>.Create(TListAdapter<T>.Create(LList, True));
  finally
    LKeys.Free;
    if Result._IsEmpty then
      LList.Free;
  end;
end;

function IFluentEnumerable<T>.IsNotAssigned: Boolean;
begin
  Result := not TEqualityComparer<IFluentEnumerable<T>>.Default.Equals(Self, Default(IFluentEnumerable<T>));
end;

function IFluentEnumerable<T>.Prepend(const AElement: T): IFluentEnumerable<T>;
var
  LList: TList<T>;
  LEnum: IFluentEnumerator<T>;
begin
  Result := Default(IFluentEnumerable<T>);
  LList := TList<T>.Create;
  try
    LList.Add(AElement);
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      LList.Add(LEnum.Current);
    Result := IFluentEnumerable<T>.Create(TListAdapter<T>.Create(LList, True));
  finally
    if Result._IsEmpty then
      LList.Free;
  end;
end;

function IFluentEnumerable<T>.Reverse: IFluentEnumerable<T>;
var
  LList: TList<T>;
  LEnum: IFluentEnumerator<T>;
begin
  Result := Default(IFluentEnumerable<T>);
  LList := TList<T>.Create;
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      LList.Insert(0, LEnum.Current);
    Result := IFluentEnumerable<T>.Create(TListAdapter<T>.Create(LList, True));
  finally
    if Result._IsEmpty then
      LList.Free;
  end;
end;

function IFluentEnumerable<T>.SkipLast(const ACount: Integer): IFluentEnumerable<T>;
var
  LList: TList<T>;
  LEnum: IFluentEnumerator<T>;
  LTempList: TList<T>;
  LIndex: Integer;
begin
  Result := Default(IFluentEnumerable<T>);
  if ACount <= 0 then
    Exit(Self);

  LTempList := TList<T>.Create;
  LList := TList<T>.Create;
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      LTempList.Add(LEnum.Current);

    LIndex := 0;
    while LIndex < LTempList.Count - ACount do
    begin
      LList.Add(LTempList[LIndex]);
      Inc(LIndex);
    end;

    Result := IFluentEnumerable<T>.Create(TListAdapter<T>.Create(LList, True));
  finally
    LTempList.Free;
    if Result._IsEmpty then
      LList.Free;
  end;
end;

function IFluentEnumerable<T>.SkipWhile(
  const APredicate: TFunc<T, Integer, Boolean>): IFluentEnumerable<T>;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate cannot be nil');
  Result := IFluentEnumerable<T>.Create(
    TFluentSkipWhileIndexedEnumerable<T>.Create(FEnumerator, APredicate),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.TakeLast(const ACount: Integer): IFluentEnumerable<T>;
var
  LList: TList<T>;
  LEnum: IFluentEnumerator<T>;
  LTempList: TList<T>;
  LIndex: Integer;
begin
  Result := Default(IFluentEnumerable<T>);
  if ACount <= 0 then
    Exit(Default(IFluentEnumerable<T>));

  LTempList := TList<T>.Create;
  LList := TList<T>.Create;
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      LTempList.Add(LEnum.Current);

    LIndex := Math.Max(0, LTempList.Count - ACount);
    while LIndex < LTempList.Count do
    begin
      LList.Add(LTempList[LIndex]);
      Inc(LIndex);
    end;

    Result := IFluentEnumerable<T>.Create(TListAdapter<T>.Create(LList, True));
  finally
    LTempList.Free;
    if Result._IsEmpty then
      LList.Free;
  end;
end;

function IFluentEnumerable<T>.TakeWhile(
  const APredicate: TFunc<T, Integer, Boolean>): IFluentEnumerable<T>;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate cannot be nil');
  Result := IFluentEnumerable<T>.Create(
    TFluentTakeWhileIndexedEnumerable<T>.Create(FEnumerator, APredicate),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.Max<TResult>(const ASelector: TFunc<T, TResult>): TResult;
var
  LEnum: IFluentEnumerator<T>;
  LResult: TResult;
  LHasValue: Boolean;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := Default(TResult);
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := ASelector(LEnum.Current);
      LHasValue := True;
    end
    else
    begin
      if TComparer<TResult>.Default.Compare(ASelector(LEnum.Current), LResult) > 0 then
        LResult := ASelector(LEnum.Current);
    end;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence is empty.');
  Result := LResult;
end;

function IFluentEnumerable<T>.Max(const AComparer: IComparer<T>): T;
var
  LEnum: IFluentEnumerator<T>;
  LResult: T;
  LHasValue: Boolean;
begin
  if not Assigned(AComparer) then
    raise EArgumentNilException.Create('Comparer cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := Default(T);
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer.Compare(LEnum.Current, LResult) > 0 then
      LResult := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Empty sequence');
  Result := LResult;
end;

function IFluentEnumerable<T>.Min(const ASelector: TFunc<T, Single>): Single;
var
  LEnum: IFluentEnumerator<T>;
  LHasValue: Boolean;
begin
  Result := 0;
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      Result := ASelector(LEnum.Current);
      LHasValue := True;
    end
    else if ASelector(LEnum.Current) < Result then
      Result := ASelector(LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence is empty.');
end;

function IFluentEnumerable<T>.Min(const ASelector: TFunc<T, Int64>): Int64;
var
  LEnum: IFluentEnumerator<T>;
  LResult: Int64;
  LHasValue: Boolean;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := 0;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := ASelector(LEnum.Current);
      LHasValue := True;
    end
    else if ASelector(LEnum.Current) < LResult then
      LResult := ASelector(LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Empty sequence.');
  Result := LResult;
end;

function IFluentEnumerable<T>.Min(const ASelector: TFunc<T, Int32>): Int32;
var
  LEnum: IFluentEnumerator<T>;
  LResult: Int32;
  LHasValue: Boolean;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := 0;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := ASelector(LEnum.Current);
      LHasValue := True;
    end
    else if ASelector(LEnum.Current) < LResult then
      LResult := ASelector(LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Empty sequence.');
  Result := LResult;
end;

function IFluentEnumerable<T>.Min(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: IFluentEnumerator<T>;
  LResult: Double;
  LHasValue: Boolean;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := 0;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := ASelector(LEnum.Current);
      LHasValue := True;
    end
    else if ASelector(LEnum.Current) < LResult then
      LResult := ASelector(LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Empty sequence.');
  Result := LResult;
end;

function IFluentEnumerable<T>.Min(const ASelector: TFunc<T, Currency>): Currency;
var
  LEnum: IFluentEnumerator<T>;
  LResult: Currency;
  LHasValue: Boolean;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := 0;
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := ASelector(LEnum.Current);
      LHasValue := True;
    end
    else if ASelector(LEnum.Current) < LResult then
      LResult := ASelector(LEnum.Current);
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Empty sequence.');
  Result := LResult;
end;

function IFluentEnumerable<T>.Min(const ASelector: TFunc<T, NullableSingle>): NullableSingle;
var
  LEnum: IFluentEnumerator<T>;
  LResult: NullableSingle;
  LValue: NullableSingle;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      if not LResult.HasValue or (LValue.Value < LResult.Value) then
        LResult := LValue;
    end;
  end;
  Result := LResult;
end;

function IFluentEnumerable<T>.Min(const ASelector: TFunc<T, NullableInt64>): NullableInt64;
var
  LEnum: IFluentEnumerator<T>;
  LResult: NullableInt64;
  LValue: NullableInt64;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      if not LResult.HasValue or (LValue.Value < LResult.Value) then
        LResult := LValue;
    end;
  end;
  Result := LResult;
end;

function IFluentEnumerable<T>.Min(const ASelector: TFunc<T, NullableInt32>): NullableInt32;
var
  LEnum: IFluentEnumerator<T>;
  LResult: NullableInt32;
  LValue: NullableInt32;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      if not LResult.HasValue or (LValue.Value < LResult.Value) then
        LResult := LValue;
    end;
  end;
  Result := LResult;
end;

function IFluentEnumerable<T>.Min(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency;
var
  LEnum: IFluentEnumerator<T>;
  LResult: NullableCurrency;
  LValue: NullableCurrency;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      if not LResult.HasValue or (LValue.Value < LResult.Value) then
        LResult := LValue;
    end;
  end;
  Result := LResult;
end;

function IFluentEnumerable<T>.Min(const ASelector: TFunc<T, NullableDouble>): NullableDouble;
var
  LEnum: IFluentEnumerator<T>;
  LResult: NullableDouble;
  LValue: NullableDouble;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      if not LResult.HasValue or (LValue.Value < LResult.Value) then
        LResult := LValue;
    end;
  end;
  Result := LResult;
end;

function IFluentEnumerable<T>.Min<TResult>(const ASelector: TFunc<T, TResult>): TResult;
var
  LEnum: IFluentEnumerator<T>;
  LResult: TResult;
  LHasValue: Boolean;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := Default(TResult);
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := ASelector(LEnum.Current);
      LHasValue := True;
    end
    else
    begin
      if TComparer<TResult>.Default.Compare(ASelector(LEnum.Current), LResult) < 0 then
        LResult := ASelector(LEnum.Current);
    end;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Sequence is empty');
  Result := LResult;
end;

function IFluentEnumerable<T>.Min(const AComparer: IComparer<T>): T;
var
  LEnum: IFluentEnumerator<T>;
  LResult: T;
  LHasValue: Boolean;
begin
  if not Assigned(AComparer) then
    raise EArgumentNilException.Create('Comparer cannot be nil');
  LEnum := GetEnumerator;
  LHasValue := False;
  LResult := Default(T);
  while LEnum.MoveNext do
  begin
    if not LHasValue then
    begin
      LResult := LEnum.Current;
      LHasValue := True;
    end
    else if AComparer.Compare(LEnum.Current, LResult) < 0 then
      LResult := LEnum.Current;
  end;
  if not LHasValue then
    raise EInvalidOperation.Create('Empty sequence');
  Result := LResult;
end;

function IFluentEnumerable<T>.SelectMany<TCollection, TResult>(
  const ACollectionSelector: TFunc<T, Integer, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>): IFluentEnumerable<TResult>;
begin
  if not Assigned(ACollectionSelector) then
    raise EArgumentNilException.Create('Collection selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := IFluentEnumerable<TResult>.Create(
    TFluentSelectManyCollectionIndexedEnumerable<T, TCollection, TResult>.Create(
      FEnumerator, ACollectionSelector, AResultSelector),
    FFluentType,
    TEqualityComparer<TResult>.Default
  );
end;

function IFluentEnumerable<T>.SelectMany<TCollection, TResult>(
  const ACollectionSelector: TFunc<T, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>): IFluentEnumerable<TResult>;
begin
  if not Assigned(ACollectionSelector) then
    raise EArgumentNilException.Create('Collection selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := IFluentEnumerable<TResult>.Create(
    TFluentSelectManyCollectionEnumerable<T, TCollection, TResult>.Create(
      FEnumerator, ACollectionSelector, AResultSelector),
    FFluentType,
    TEqualityComparer<TResult>.Default
  );
end;

function IFluentEnumerable<T>.SelectMany<TResult>(
  const ASelector: TFunc<T, Integer, IFluentArray<TResult>>): IFluentEnumerable<TResult>;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  Result := IFluentEnumerable<TResult>.Create(
    TFluentSelectManyIndexedEnumerable<T, TResult>.Create(FEnumerator, ASelector),
    FFluentType,
    TEqualityComparer<TResult>.Default
  );
end;

function IFluentEnumerable<T>.SelectMany<TResult>(const ASelector: TFunc<T, TArray<TResult>>): IFluentEnumerable<TResult>;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  Result := IFluentEnumerable<TResult>.Create(
    TFluentSelectManyEnumerable<T, TResult>.Create(FEnumerator, ASelector),
    FFluentType,
    TEqualityComparer<TResult>.Default
  );
end;

function IFluentEnumerable<T>.Select<TResult>(
  const ASelector: TFunc<T, Integer, TResult>): IFluentEnumerable<TResult>;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  Result := IFluentEnumerable<TResult>.Create(
    TFluentSelectIndexedEnumerable<T, TResult>.Create(FEnumerator, ASelector),
    FFluentType,
    TEqualityComparer<TResult>.Default
  );
end;

function IFluentEnumerable<T>.Order(const AComparer: IComparer<T>): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TFluentOrderEnumerable<T>.Create(FEnumerator, AComparer),
    FFluentType,
    FComparer
  );
end;

function IFluentEnumerable<T>.Order: IFluentEnumerable<T>;
begin
  Result := Order(nil);
end;

function IFluentEnumerable<T>.Sum(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency;
var
  LEnum: IFluentEnumerator<T>;
  LSum: Double;
  LCount: Integer;
  LValue: NullableCurrency;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    if LValue.HasValue then
    begin
      LSum := LSum + LValue.Value;
      Inc(LCount);
    end;
  end;
  if LCount = 0 then
    raise EInvalidOperation.Create('Empty sequence or no valid values.');
  Result := NullableCurrency.Create(LSum);
end;

{ IFluentEnumerable<T>.TFluentCompare }

class function IFluentEnumerable<T>.TFluentCompare.Compare(
  const AEnumerator: IFluentEnumerableBase<T>; const AValue: T;
  const AComparer: IEqualityComparer<T>): Boolean;
var
  LEnum: IFluentEnumerator<T>;
begin
  LEnum := AEnumerator.GetEnumerator;
  while LEnum.MoveNext do
    if AComparer.Equals(LEnum.Current, AValue) then
      Exit(True);
  Result := False;
end;

{ TFluentGrouping<TKey, T> }

constructor TFluentGrouping<TKey, T>.Create(const AKey: TKey; const AItems: IFluentEnumerable<T>);
begin
  FKey := AKey;
  FItems := AItems;
end;

function TFluentGrouping<TKey, T>.GetKey: TKey;
begin
  Result := FKey;
end;

function TFluentGrouping<TKey, T>.GetItems: IFluentEnumerable<T>;
begin
  Result := FItems;
end;

end.
