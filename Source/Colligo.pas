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

unit Colligo;

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
  Colligo.Core;

type
  IColligoEnumerableAdapter<TResult> = interface;
  IGroupByEnumerable<TKey, T> = interface;
  IGrouping<TKey, T> = interface;
  IColligoArray<T> = interface;
  IColligoList<T> = interface;
//  IColligoChunkResult<T> = interface;

  IColligoEnumerator<T> = interface(IInterface)
    ['{E2DEBD49-1094-41A5-A817-48FB81A6F6F2}']
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  IColligoEnumerableBase<T> = interface(IInterface)
    ['{B68572C5-32C6-436A-B39B-D8DA06E33C14}']
    function GetEnumerator: IColligoEnumerator<T>;
  end;

  TColligoEnumerableBase<T> = class abstract(TInterfacedObject, IColligoEnumerableBase<T>)
  protected
    function GetEnumerator: IColligoEnumerator<T>; virtual; abstract;
  end;

  // Ordered enumerable produced by OrderBy/OrderByDescending/Order/OrderDescending.
  // Carries the ordered chain of comparison criteria so that ThenBy/ThenByDescending
  // can append a subordinate criterion (primary key stays dominant), mirroring
  // C#'s IOrderedEnumerable<T>. Kept as an ARC interface so the criteria chain lives
  // in a managed object, never in a record temporary.
  IColligoOrderedEnumerable<T> = interface(IColligoEnumerableBase<T>)
    ['{7E2C1A44-9B3D-4F6E-8A21-3C5D9E0F1B22}']
    function ThenByAppend(const AComparer: TFunc<T, T, Integer>): IColligoOrderedEnumerable<T>;
  end;

  IColligoEnumerable<T> = record
  private
    FEnumerator: IColligoEnumerableBase<T>;
    FColligoType: TColligoType;
    FComparer: IEqualityComparer<T>;
    FIsValid: Boolean;
    // Non-nil only when this record was produced by an ordering operator
    // (OrderBy/OrderByDescending/Order/OrderDescending). ThenBy/ThenByDescending
    // read it to append a subordinate criterion. Managed (ARC) field, so it
    // survives record copies/temporaries. See IColligoOrderedEnumerable<T>.
    FOrdered: IColligoOrderedEnumerable<T>;
    type
      TColligoCompare = class
      public
        class function Compare(const AEnumerator: IColligoEnumerableBase<T>;
          const AValue: T; const AComparer: IEqualityComparer<T>): Boolean; static;
      end;
    function _IsEmpty: Boolean;
  public
    constructor Create(const AEnumerator: IColligoEnumerableBase<T>;
      const AColligoType: TColligoType = ftNone; const AComparer: IEqualityComparer<T> = nil);
    function IsNotAssigned: Boolean;
    function GetEnumerator: IColligoEnumerator<T>;
    function Where(const APredicate: TFunc<T, Boolean>): IColligoEnumerable<T>;
    function Take(const ACount: Integer): IColligoEnumerable<T>;
    function Skip(const ACount: Integer): IColligoEnumerable<T>;
    function Distinct: IColligoEnumerable<T>; overload;
    function Distinct(const AComparer: IEqualityComparer<T>): IColligoEnumerable<T>; overload;
    function DistinctBy<TKey>(const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>; overload;
    function DistinctBy<TKey>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>): IColligoEnumerable<T>; overload;
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
    function Zip<TSecond, TResult>(const ASecond: IColligoEnumerable<TSecond>;
      const AResultSelector: TFunc<T, TSecond, TResult>): IColligoEnumerable<TResult>;
    function OfType<TResult>: IColligoEnumerable<TResult>;
    function Exclude(const ASecond: IColligoEnumerable<T>): IColligoEnumerable<T>; overload;
    function Exclude(const ASecond: IColligoEnumerable<T>;
      const AComparer: IEqualityComparer<T>): IColligoEnumerable<T>; overload;
    function Intersect(const ASecond: IColligoEnumerable<T>): IColligoEnumerable<T>; overload;
    function Intersect(const ASecond: IColligoEnumerable<T>;
      const AComparer: IEqualityComparer<T>): IColligoEnumerable<T>; overload;
    function Union(const ASecond: IColligoEnumerable<T>): IColligoEnumerable<T>; overload;
    function Union(const ASecond: IColligoEnumerable<T>;
      const AComparer: IEqualityComparer<T>): IColligoEnumerable<T>; overload;
    function Concat(const ASecond: IColligoEnumerable<T>): IColligoEnumerable<T>;
    function SequenceEqual(const ASecond: IColligoEnumerable<T>): Boolean;
    function Single: T; overload;
    function Single(const APredicate: TFunc<T, Boolean>): T; overload;
    function SingleOrDefault: T; overload;
    function SingleOrDefault(const APredicate: TFunc<T, Boolean>): T; overload;
    function ElementAt(const AIndex: Integer): T;
    function ElementAtOrDefault(const AIndex: Integer): T;
    function OrderBy(const AComparer: TFunc<T, T, Integer>): IColligoEnumerable<T>; overload;
    function OrderBy<TKey>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: IComparer<TKey>): IColligoEnumerable<T>; overload;
    function OrderByDesc(const AComparer: TFunc<T, T, Integer>): IColligoEnumerable<T>;
    function GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>): IGroupByEnumerable<TKey, T>; overload;
    function GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>): IGroupByEnumerable<TKey, T>; overload;
    function GroupBy<TKey, TElement>(const AKeySelector: TFunc<T, TKey>;
      const AElementSelector: TFunc<T, TElement>): IGroupByEnumerable<TKey, TElement>; overload;
    function GroupBy<TKey, TElement>(const AKeySelector: TFunc<T, TKey>;
      const AElementSelector: TFunc<T, TElement>;
      const AComparer: IEqualityComparer<TKey>): IGroupByEnumerable<TKey, TElement>; overload;
    function GroupBy<TKey, TResult>(const AKeySelector: TFunc<T, TKey>;
      const AResultSelector: TFunc<TKey, IColligoEnumerableAdapter<T>, TResult>): IColligoEnumerable<TResult>; overload;
    function GroupBy<TKey, TResult>(const AKeySelector: TFunc<T, TKey>;
      const AResultSelector: TFunc<TKey, IColligoEnumerableAdapter<T>, TResult>;
      const AComparer: IEqualityComparer<TKey>): IColligoEnumerable<TResult>; overload;
    function Join<TInner, TKey, TResult>(const AInner: IColligoEnumerable<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, TInner, TResult>): IColligoEnumerable<TResult>; overload;
    function Join<TInner, TKey, TResult>(const AInner: IColligoEnumerable<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, TInner, TResult>;
      const AComparer: IEqualityComparer<TKey>): IColligoEnumerable<TResult>; overload;
    function GroupJoin<TInner, TKey, TResult>(const AInner: IColligoEnumerable<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, IColligoEnumerableAdapter<TInner>, TResult>): IColligoEnumerable<TResult>;
    function ToHashSet: THashSet<T>;
    function ToLookup<TKey, TElement>(const AKeySelector: TFunc<T, TKey>;
      const AElementSelector: TFunc<T, TElement>): TDictionary<TKey, TList<TElement>>;
    function UnionBy<TKey>(const ASecond: IColligoEnumerable<T>;
      const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>; overload;
    function UnionBy<TKey>(const ASecond: IColligoEnumerable<T>;
      const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>): IColligoEnumerable<T>; overload;
    function Append(const AElement: T): IColligoEnumerable<T>;
    function Cast<TResult>: IColligoEnumerable<TResult>;
    function DefaultIfEmpty: IColligoEnumerable<T>; overload;
    function DefaultIfEmpty(const ADefaultValue: T): IColligoEnumerable<T>; overload;
    function ExcludeBy<TKey>(const ASecond: IColligoEnumerable<TKey>;
      const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>; overload;
    function ExcludeBy<TKey>(const ASecond: IColligoEnumerable<TKey>;
      const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>): IColligoEnumerable<T>; overload;
    function IntersectBy<TKey>(const ASecond: IColligoEnumerable<TKey>;
      const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>; overload;
    function IntersectBy<TKey>(const ASecond: IColligoEnumerable<TKey>;
      const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>): IColligoEnumerable<T>; overload;
    function Prepend(const AElement: T): IColligoEnumerable<T>;
    function Reverse: IColligoEnumerable<T>;
    function SkipLast(const ACount: Integer): IColligoEnumerable<T>;
    function TakeLast(const ACount: Integer): IColligoEnumerable<T>;
    function Average(const ASelector: TFunc<T, Double>): Double; overload;
    function Average(const ASelector: TFunc<T, Currency>): Currency; overload;
    function Average(const ASelector: TFunc<T, Int32>): Double; overload;
    function Average(const ASelector: TFunc<T, Int64>): Double; overload;
    function Average(const ASelector: TFunc<T, Single>): Double; overload;
    function Average(const ASelector: TFunc<T, NullableInt32>): NullableDouble; overload;
    function Average(const ASelector: TFunc<T, NullableInt64>): NullableDouble; overload;
    function Average(const ASelector: TFunc<T, NullableSingle>): NullableSingle; overload;
    function Average(const ASelector: TFunc<T, NullableDouble>): NullableDouble; overload;
    function Average(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency; overload;
    // Chunk splits the sequence into arrays of at most ASize elements (the last
    // may be shorter). Deferred/streaming. Returns the base interface (not the
    // IColligoEnumerable<TArray<T>> record) to avoid E2604 "recursive use of
    // generic type" — a record cannot return an instantiation of itself over a
    // type derived from its own T. Iterate the result via GetEnumerator, or wrap
    // it in IColligoEnumerable<TArray<T>>.Create(...) to chain further.
    function Chunk(const ASize: Integer): IColligoEnumerableBase<TArray<T>>;
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
    function Order: IColligoEnumerable<T>; overload;
    function Order(const AComparer: IComparer<T>): IColligoEnumerable<T>; overload;
    function OrderDescending: IColligoEnumerable<T>; overload;
    function OrderDescending(const AComparer: IComparer<T>): IColligoEnumerable<T>; overload;
    function Select<TResult>(const ASelector: TFunc<T, TResult>): IColligoEnumerable<TResult>; overload;
    function Select<TResult>(const ASelector: TFunc<T, Integer, TResult>): IColligoEnumerable<TResult>; overload;
    function SelectMany<TResult>(const ASelector: TFunc<T, TArray<TResult>>): IColligoEnumerable<TResult>; overload;
    function SelectMany<TResult>(const ASelector: TFunc<T, Integer, IColligoArray<TResult>>): IColligoEnumerable<TResult>; overload;
    function SelectMany<TCollection, TResult>(
      const ACollectionSelector: TFunc<T, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>): IColligoEnumerable<TResult>; overload;
    function SelectMany<TCollection, TResult>(
      const ACollectionSelector: TFunc<T, Integer, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>): IColligoEnumerable<TResult>; overload;
    function SkipWhile(const APredicate: TFunc<T, Boolean>): IColligoEnumerable<T>; overload;
    function SkipWhile(const APredicate: TFunc<T, Integer, Boolean>): IColligoEnumerable<T>; overload;
    function TakeWhile(const APredicate: TFunc<T, Boolean>): IColligoEnumerable<T>; overload;
    function TakeWhile(const APredicate: TFunc<T, Integer, Boolean>): IColligoEnumerable<T>; overload;
    function ToDictionary<TKey, TValue>(const AKeySelector: TFunc<T, TKey>;
      const AValueSelector: TFunc<T, TValue>): TDictionary<TKey, TValue>; overload;
    function ToDictionary<TKey, TValue>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, T>; overload;
    function ToDictionary<TKey, TValue>(const AKeySelector: TFunc<T, TKey>;
      const AValueSelector: TFunc<T, TValue>;
      const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, TValue>; overload;
    function TryGetNonEnumeratedCount(out ACount: Integer): Boolean;
    function ThenBy<TKey>(const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>;
    function ThenByDescending<TKey>(const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>;
    function ToArray: IColligoArray<T>;
    function ToList: IColligoList<T>;
  end;

  IGroupByEnumerable<TKey, T> = interface(IInterface)
    ['{A85DB3F6-E808-4E81-B386-75190087507B}']
    function GetEnumerator: IColligoEnumerator<IGrouping<TKey, T>>;
    function AsEnumerable: IColligoEnumerable<IGrouping<TKey, T>>;
  end;

  IGrouping<TKey, T> = interface(IInterface)
    ['{87B4E3F7-C092-44D1-B682-0B03C0202BF0}']
    function GetKey: TKey;
    function GetItems: IColligoEnumerable<T>;
    property Key: TKey read GetKey;
    property Items: IColligoEnumerable<T> read GetItems;
  end;

  TColligoGrouping<TKey, T> = class(TInterfacedObject, IGrouping<TKey, T>)
  private
    FKey: TKey;
    FItems: IColligoEnumerable<T>;
  public
    constructor Create(const AKey: TKey; const AItems: IColligoEnumerable<T>);
    function GetKey: TKey;
    function GetItems: IColligoEnumerable<T>;
    property Key: TKey read GetKey;
    property Items: IColligoEnumerable<T> read GetItems;
  end;

//  IColligoChunkResult<T> = interface(IInterface)
//    ['{1148CD41-1C5F-44DA-A4EF-C200AC3F2D5A}']
//    function GetEnumerator: IColligoEnumerator<TArray<T>>;
//    function AsEnumerable: IColligoEnumerable<TArray<T>>;
//  end;

  IColligoEnumerableAdapter<TResult> = interface(IInterface)
    ['{69303F43-C266-437F-A790-4038CFDA0680}']
    function AsEnumerable: IColligoEnumerable<TResult>;
  end;

  IColligoArray<T> = interface(IInterface)
    ['{E3DF6D61-1A52-466E-8B16-CF7AAC574A02}']
    function GetItem(AIndex: NativeInt): T;
    procedure SetItem(AIndex: NativeInt; const AValue: T);
    function _GetArray: TArray<T>;
    procedure SetItems(const AItems: TArray<T>);
    function AsEnumerable: IColligoEnumerable<T>;
    function GetEnumerator: IColligoEnumerator<T>;
    function Length: Integer;
    property ArrayData: TArray<T> read _GetArray;
    property Items[AIndex: NativeInt]: T read GetItem write SetItem; default;
  end;

  ICollections<T> = interface(IColligoEnumerableBase<T>)
    ['{1F1B87DA-2722-40E3-899F-5622CA9BE807}']
    function Count: NativeInt;
    function Contains(const AItem: T): Boolean;
    function Remove(const AItem: T): Boolean;
    function AsEnumerable: IColligoEnumerable<T>;
    function GetEnumerator: IColligoEnumerator<T>;
    procedure Add(const AItem: T);
    procedure CopyTo(AArray: array of T; AIndex: Integer);
    procedure Clear;
  end;

  IColligoList<T> = interface(ICollections<T>)
    ['{2749C02A-9973-4747-A4D3-29376DFD6242}']
    function GetCapacity: NativeInt;
    procedure SetCapacity(const AValue: NativeInt);
    function GetItem(AIndex: NativeInt): T;
    procedure SetItem(AIndex: NativeInt; const AValue: T);
    function GetList: IColligoArray<T>;
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
    function Expand: IColligoList<T>;
    function IndexOf(const AValue: T): NativeInt;
    function IndexOfItem(const AValue: T; Direction: TDirection): NativeInt;
    function LastIndexOf(const AValue: T): NativeInt;
    function BinarySearch(const AItem: T; out FoundIndex: NativeInt): Boolean; overload;
    function BinarySearch(const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>): Boolean; overload;
    function BinarySearch(const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>; AIndex, Count: NativeInt): Boolean; overload;
    function IsEmpty: Boolean;
    function ToArray: IColligoArray<T>;
    property Capacity: NativeInt read GetCapacity write SetCapacity;
    property Items[AIndex: NativeInt]: T read GetItem write SetItem; default;
    property List: IColligoArray<T> read GetList;
    property Comparer: IComparer<T> read GetComparer;
    property OnNotify: TCollectionNotifyEvent<T> read GetOnNotify write SetOnNotify;
  end;

  IColligoDictionary<K, V> = interface(ICollections<TPair<K, V>>)
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
    function ToArray: IColligoArray<TPair<K, V>>;
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

  // Static entry points for the LINQ generators (Enumerable.Range/Repeat/Empty).
  // These start a pipeline from nothing (no source collection). All deferred.
  TColligo = class
  public
    // ACount consecutive integers from AStart (AStart..AStart+ACount-1).
    // ACount=0 -> empty. Raises EArgumentOutOfRangeException if ACount < 0 or
    // AStart+ACount-1 overflows Integer. Note: the 2nd argument is a COUNT, not
    // an end value (Range(1,5) = 1,2,3,4,5).
    class function Range(const AStart, ACount: Integer): IColligoEnumerable<Integer>; static;
    // The same element ACount times. ACount=0 -> empty. Raises if ACount < 0.
    // (Repeat is a reserved word, hence the & escape.)
    class function &Repeat<T>(const AElement: T; const ACount: Integer): IColligoEnumerable<T>; static;
    // An empty sequence of T.
    class function Empty<T>: IColligoEnumerable<T>; static;
  end;

implementation

uses
  Colligo.Collections,
  Colligo.Adapters,
  Colligo.SkipWhile,
  Colligo.Where,
  Colligo.Select,
  Colligo.Take,
  Colligo.OrderBy,
  Colligo.Skip,
  Colligo.Distinct,
  Colligo.TakeWhile,
  Colligo.GroupBy,
  Colligo.GroupJoin,
  Colligo.OfType,
  Colligo.SelectMany,
  Colligo.Zip,
  Colligo.Join,
  Colligo.Exclude,
  Colligo.Union,
  Colligo.Intersect,
  Colligo.Concat,
  Colligo.Append,
  Colligo.Prepend,
  Colligo.DefaultIfEmpty,
  Colligo.DistinctBy,
  Colligo.UnionBy,
  Colligo.ExcludeBy,
  Colligo.IntersectBy,
  Colligo.Reverse,
  Colligo.SkipLast,
  Colligo.TakeLast,
  Colligo.Generators,
  Colligo.Chunk,
  Colligo.Cast,
  Colligo.SkipWhileIndexed,
  Colligo.SelectIndexed,
  Colligo.TakeWhileIndexed,
  Colligo.SelectManyCollection,
  Colligo.SelectManyIndexed,
  Colligo.SelectManyCollectionIndexed;

{ IColligoEnumerable<T> }

constructor IColligoEnumerable<T>.Create(const AEnumerator: IColligoEnumerableBase<T>;
  const AColligoType: TColligoType; const AComparer: IEqualityComparer<T>);
begin
  FEnumerator := AEnumerator;
  FColligoType := AColligoType;
  FComparer := AComparer;
  if FComparer = nil then
    FComparer := TEqualityComparer<T>.Default;
  FIsValid := True;
  FOrdered := nil;
end;

function IColligoEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := FEnumerator.GetEnumerator;
end;

function IColligoEnumerable<T>.Where(const APredicate: TFunc<T, Boolean>): IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(
    TColligoWhereEnumerable<T>.Create(FEnumerator, APredicate),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.Take(const ACount: Integer): IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(
    TColligoTakeEnumerable<T>.Create(FEnumerator, ACount),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.Skip(const ACount: Integer): IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(
    TColligoSkipEnumerable<T>.Create(FEnumerator, ACount),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.OrderBy(const AComparer: TFunc<T, T, Integer>): IColligoEnumerable<T>;
var
  LOrdered: IColligoOrderedEnumerable<T>;
begin
  LOrdered := TColligoOrderByEnumerable<T>.Create(FEnumerator, AComparer);
  Result := IColligoEnumerable<T>.Create(LOrdered, FColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function IColligoEnumerable<T>.OrderBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: IComparer<TKey>): IColligoEnumerable<T>;
var
  LOrdered: IColligoOrderedEnumerable<T>;
  LFunc: TFunc<T, T, Integer>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AComparer) then
    raise EArgumentNilException.Create('Comparer cannot be nil');
  LFunc :=
    function(A, B: T): Integer
    begin
      Result := AComparer.Compare(AKeySelector(A), AKeySelector(B));
    end;
  LOrdered := TColligoOrderByEnumerable<T>.Create(FEnumerator, LFunc);
  Result := IColligoEnumerable<T>.Create(LOrdered, FColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function IColligoEnumerable<T>.OrderByDesc(const AComparer: TFunc<T, T, Integer>): IColligoEnumerable<T>;
var
  LOrdered: IColligoOrderedEnumerable<T>;
  LFunc: TFunc<T, T, Integer>;
begin
  LFunc :=
    function(A, B: T): Integer
    begin
      Result := -AComparer(A, B);
    end;
  LOrdered := TColligoOrderByEnumerable<T>.Create(FEnumerator, LFunc);
  Result := IColligoEnumerable<T>.Create(LOrdered, FColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function IColligoEnumerable<T>.OrderDescending(const AComparer: IComparer<T>): IColligoEnumerable<T>;
var
  LOrdered: IColligoOrderedEnumerable<T>;
  LFunc: TFunc<T, T, Integer>;
begin
  LFunc :=
    function(A, B: T): Integer
    begin
      if AComparer = nil then
        Result := -TComparer<T>.Default.Compare(A, B)
      else
        Result := -AComparer.Compare(A, B);
    end;
  LOrdered := TColligoOrderByEnumerable<T>.Create(FEnumerator, LFunc);
  Result := IColligoEnumerable<T>.Create(LOrdered, FColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function IColligoEnumerable<T>.OrderDescending: IColligoEnumerable<T>;
begin
  Result := OrderDescending(nil);
end;

function IColligoEnumerable<T>.Distinct: IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(
    TColligoDistinctEnumerable<T>.Create(FEnumerator, FComparer),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.Distinct(const AComparer: IEqualityComparer<T>): IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(
    TColligoDistinctEnumerable<T>.Create(FEnumerator, AComparer),
    FColligoType,
    AComparer
  );
end;

function IColligoEnumerable<T>.Select<TResult>(const ASelector: TFunc<T, TResult>): IColligoEnumerable<TResult>;
begin
  Result := IColligoEnumerable<TResult>.Create(
    TColligoSelectEnumerable<T, TResult>.Create(FEnumerator, ASelector),
    FColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function IColligoEnumerable<T>.Aggregate(const AReducer: TFunc<T, T, T>): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Aggregate<TAcc>(const AInitialValue: TAcc;
  const AAccumulator: TFunc<TAcc, T, TAcc>): TAcc;
var
  LEnum: IColligoEnumerator<T>;
  LResult: TAcc;
begin
  LEnum := GetEnumerator;
  LResult := AInitialValue;
  while LEnum.MoveNext do
    LResult := AAccumulator(LResult, LEnum.Current);
  Result := LResult;
end;

function IColligoEnumerable<T>.Aggregate<TAccumulate, TResult>(
  const AInitialValue: TAccumulate;
  const AAccumulator: TFunc<TAccumulate, T, TAccumulate>;
  const AResultSelector: TFunc<TAccumulate, TResult>): TResult;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.AggregateBy<TKey, TAccumulate>(
  const AKeySelector: TFunc<T, TKey>;
  const ASeedFactory: TFunc<TKey, TAccumulate>;
  const AAccumulator: TFunc<TAccumulate, T, TAccumulate>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, TAccumulate>;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.AggregateBy<TKey, TAccumulate>(
  const AKeySelector: TFunc<T, TKey>;
  const ASeed: TAccumulate;
  const AAccumulator: TFunc<TAccumulate, T, TAccumulate>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, TAccumulate>;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Sum(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Sum(const ASelector: TFunc<T, Integer>): Integer;
var
  LEnum: IColligoEnumerator<T>;
  LSum: Int64;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  // Accumulate in Int64 and detect overflow of the Integer running total per
  // step (matches C# checked int Sum), instead of silently wrapping a 32-bit
  // accumulator (the source has no {$Q+}).
  LSum := 0;
  while LEnum.MoveNext do
  begin
    LSum := LSum + ASelector(LEnum.Current);
    if (LSum > High(Integer)) or (LSum < Low(Integer)) then
      raise EIntOverflow.Create('Arithmetic overflow: Sum exceeds Integer range');
  end;
  Result := Integer(LSum);
end;

function IColligoEnumerable<T>.SumCurrency(const ASelector: TFunc<T, Currency>): Currency;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.SumInt32(const ASelector: TFunc<T, Int32>): Int32;
var
  LEnum: IColligoEnumerator<T>;
  LSum: Int64;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
  begin
    LSum := LSum + ASelector(LEnum.Current);
    if (LSum > High(Int32)) or (LSum < Low(Int32)) then
      raise EIntOverflow.Create('Arithmetic overflow: Sum exceeds Int32 range');
  end;
  Result := Int32(LSum);
end;

function IColligoEnumerable<T>.Sum(const ASelector: TFunc<T, Int64>): Int64;
var
  LEnum: IColligoEnumerator<T>;
  LSum, LValue, LNew: Int64;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
  begin
    LValue := ASelector(LEnum.Current);
    LNew := LSum + LValue;
    // Signed-overflow detection (no {$Q+}): the sum overflows Int64 when adding
    // a positive value decreases the total, or adding a negative one increases it.
    if ((LValue > 0) and (LNew < LSum)) or ((LValue < 0) and (LNew > LSum)) then
      raise EIntOverflow.Create('Arithmetic overflow: Sum exceeds Int64 range');
    LSum := LNew;
  end;
  Result := LSum;
end;

function IColligoEnumerable<T>.Sum(const ASelector: TFunc<T, Single>): Single;
var
  LEnum: IColligoEnumerator<T>;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  Result := 0;
  while LEnum.MoveNext do
    Result := Result + ASelector(LEnum.Current);
end;

function IColligoEnumerable<T>.Sum(const ASelector: TFunc<T, NullableInt32>): NullableInt32;
var
  LEnum: IColligoEnumerator<T>;
  LSum: Int64;
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
      if (LSum > High(Int32)) or (LSum < Low(Int32)) then
        raise EIntOverflow.Create('Arithmetic overflow: Sum exceeds Int32 range');
      Inc(LCount);
    end;
  end;
  // LINQ: nullable Sum of an empty / all-null sequence is 0 (never null, never raises).
  Result := NullableInt32.Create(Int32(LSum));
end;

function IColligoEnumerable<T>.Sum(const ASelector: TFunc<T, NullableInt64>): NullableInt64;
var
  LEnum: IColligoEnumerator<T>;
  LSum, LNew: Int64;
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
      LNew := LSum + LValue.Value;
      if ((LValue.Value > 0) and (LNew < LSum)) or ((LValue.Value < 0) and (LNew > LSum)) then
        raise EIntOverflow.Create('Arithmetic overflow: Sum exceeds Int64 range');
      LSum := LNew;
      Inc(LCount);
    end;
  end;
  // LINQ: nullable Sum of an empty / all-null sequence is 0 (never null, never raises).
  Result := NullableInt64.Create(LSum);
end;

function IColligoEnumerable<T>.Sum(const ASelector: TFunc<T, NullableSingle>): NullableSingle;
var
  LEnum: IColligoEnumerator<T>;
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
  // LINQ: nullable Sum of an empty / all-null sequence is 0 (Result stays 0 here),
  // never null and never raises.
end;

function IColligoEnumerable<T>.Sum(const ASelector: TFunc<T, NullableDouble>): NullableDouble;
var
  LEnum: IColligoEnumerator<T>;
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
  // LINQ: nullable Sum of an empty / all-null sequence is 0 (never null, never raises).
  Result := NullableDouble.Create(LSum);
end;

function IColligoEnumerable<T>.Average(const ASelector: TFunc<T, Currency>): Currency;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Average(const ASelector: TFunc<T, Int32>): Double;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Average(const ASelector: TFunc<T, Int64>): Double;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Average(const ASelector: TFunc<T, Single>): Double;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Average(const ASelector: TFunc<T, NullableInt32>): NullableDouble;
var
  LEnum: IColligoEnumerator<T>;
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
  // LINQ: nullable Average of an empty / all-null sequence is null (never raises).
  if LCount = 0 then
    Result := NullableDouble.CreateEmpty
  else
    Result := NullableDouble.Create(LSum / LCount);
end;

function IColligoEnumerable<T>.Average(const ASelector: TFunc<T, NullableInt64>): NullableDouble;
var
  LEnum: IColligoEnumerator<T>;
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
  // LINQ: nullable Average of an empty / all-null sequence is null (never raises).
  if LCount = 0 then
    Result := NullableDouble.CreateEmpty
  else
    Result := NullableDouble.Create(LSum / LCount);
end;

function IColligoEnumerable<T>.Average(const ASelector: TFunc<T, NullableSingle>): NullableSingle;
var
  LEnum: IColligoEnumerator<T>;
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
  // LINQ: nullable Average of an empty / all-null sequence is null (never raises).
  if LCount = 0 then
    Result := NullableSingle.CreateEmpty
  else
    Result := NullableSingle.Create(LSum / LCount);
end;

function IColligoEnumerable<T>.Average(const ASelector: TFunc<T, NullableDouble>): NullableDouble;
var
  LEnum: IColligoEnumerator<T>;
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
  // LINQ: nullable Average of an empty / all-null sequence is null (never raises).
  if LCount = 0 then
    Result := NullableDouble.CreateEmpty
  else
    Result := NullableDouble.Create(LSum / LCount);
end;

function IColligoEnumerable<T>.Average(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency;
var
  LEnum: IColligoEnumerator<T>;
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
  // LINQ: nullable Average of an empty / all-null sequence is null (never raises).
  if LCount = 0 then
    Result := NullableCurrency.CreateEmpty
  else
    Result := NullableCurrency.Create(LSum / LCount);
end;

function IColligoEnumerable<T>.Average(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Min: T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Max: T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
var
  LEnum: IColligoEnumerator<T>;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    if not Assigned(APredicate) or APredicate(LEnum.Current) then
      Exit(True);
  end;
  Result := False;
end;

function IColligoEnumerable<T>.Any: Boolean;
begin
  Result := GetEnumerator.MoveNext;
end;

function IColligoEnumerable<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Contains(const AValue: T): Boolean;
begin
  Result := TColligoCompare.Compare(FEnumerator, AValue, FComparer);
end;

function IColligoEnumerable<T>.Contains(const AValue: T;
  const AComparer: IEqualityComparer<T>): Boolean;
var
  LEnum: IColligoEnumerator<T>;
begin
  if not Assigned(AComparer) then
    raise EArgumentNilException.Create('Comparer cannot be nil');
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    if AComparer.Equals(LEnum.Current, AValue) then
      Exit(True);
  Result := False;
end;

function IColligoEnumerable<T>.First: T;
begin
  Result := First(nil);
end;

function IColligoEnumerable<T>.First(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.FirstOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IColligoEnumerator<T>;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    if not Assigned(APredicate) or APredicate(LEnum.Current) then
      Exit(LEnum.Current);
  end;
  Result := Default(T);
end;

function IColligoEnumerable<T>.FirstOrDefault: T;
begin
  Result := FirstOrDefault(nil);
end;

function IColligoEnumerable<T>.Last(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Last: T;
begin
  Result := Last(nil);
end;

function IColligoEnumerable<T>.LastOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.LastOrDefault: T;
begin
  Result := LastOrDefault(nil);
end;

function IColligoEnumerable<T>.Count(const APredicate: TFunc<T, Boolean>): Integer;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.CountBy<TKey>(
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, Integer>;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Count: Integer;
begin
  Result := Count(nil);
end;

function IColligoEnumerable<T>.LongCount(const APredicate: TFunc<T, Boolean>): Int64;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.LongCount: Int64;
begin
  Result := LongCount(nil);
end;

function IColligoEnumerable<T>.TakeWhile(const APredicate: TFunc<T, Boolean>): IColligoEnumerable<T>;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate cannot be nil');
  Result := IColligoEnumerable<T>.Create(
    TColligoTakeWhileEnumerable<T>.Create(FEnumerator, APredicate),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.SkipWhile(const APredicate: TFunc<T, Boolean>): IColligoEnumerable<T>;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate cannot be nil');
  Result := IColligoEnumerable<T>.Create(
    TColligoSkipWhileEnumerable<T>.Create(FEnumerator, APredicate),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.ToArray: IColligoArray<T>;
var
  LEnum: IColligoEnumerator<T>;
  LList: IColligoList<T>;
begin
  LList := TColligoList<T>.Create;
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      LList.Add(LEnum.Current);
    Result := LList.ToArray;
  finally
    LList := nil;
  end;
end;

function IColligoEnumerable<T>.ToDictionary<TKey, TValue>(
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, T>;
begin
  Result := ToDictionary<TKey, T>(AKeySelector, function(x: T): T begin Result := x end, AComparer);
end;

function IColligoEnumerable<T>.ToDictionary<TKey, TValue>(
  const AKeySelector: TFunc<T, TKey>;
  const AValueSelector: TFunc<T, TValue>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, TValue>;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.ToList: IColligoList<T>;
var
  LList: IColligoList<T>;
  LEnum: IColligoEnumerator<T>;
begin
  LList := TColligoList<T>.Create;
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    LList.Add(LEnum.Current);
  Result := LList;
end;

function IColligoEnumerable<T>.ToDictionary<TKey, TValue>(
  const AKeySelector: TFunc<T, TKey>;
  const AValueSelector: TFunc<T, TValue>): TDictionary<TKey, TValue>;
begin
  Result := ToDictionary<TKey, TValue>(AKeySelector, AValueSelector, nil);
end;

function IColligoEnumerable<T>.GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>): IGroupByEnumerable<TKey, T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  Result := TColligoGroupByEnumerable<TKey, T>.Create(FEnumerator, AKeySelector);
end;

function IColligoEnumerable<T>.GroupBy<TKey, TElement>(
  const AKeySelector: TFunc<T, TKey>;
  const AElementSelector: TFunc<T, TElement>): IGroupByEnumerable<TKey, TElement>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AElementSelector) then
    raise EArgumentNilException.Create('Element selector cannot be nil');
  Result := TColligoGroupByEnumerable<TKey, TElement, T>.Create(
    FEnumerator,
    AKeySelector,
    AElementSelector);
end;

function IColligoEnumerable<T>.GroupBy<TKey, TResult>(
  const AKeySelector: TFunc<T, TKey>;
  const AResultSelector: TFunc<TKey, IColligoEnumerableAdapter<T>, TResult>): IColligoEnumerable<TResult>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := IColligoEnumerable<TResult>.Create(
    TColligoGroupByResultEnumerable<TKey, T, TResult>.Create(
      FEnumerator, AKeySelector, AResultSelector),
    FColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function IColligoEnumerable<T>.GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): IGroupByEnumerable<TKey, T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  Result := TColligoGroupByEnumerable<TKey, T>.Create(FEnumerator, AKeySelector, AComparer);
end;

function IColligoEnumerable<T>.GroupBy<TKey, TElement>(
  const AKeySelector: TFunc<T, TKey>;
  const AElementSelector: TFunc<T, TElement>;
  const AComparer: IEqualityComparer<TKey>): IGroupByEnumerable<TKey, TElement>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AElementSelector) then
    raise EArgumentNilException.Create('Element selector cannot be nil');
  Result := TColligoGroupByEnumerable<TKey, TElement, T>.Create(
    FEnumerator,
    AKeySelector,
    AElementSelector,
    AComparer);
end;

function IColligoEnumerable<T>.GroupBy<TKey, TResult>(
  const AKeySelector: TFunc<T, TKey>;
  const AResultSelector: TFunc<TKey, IColligoEnumerableAdapter<T>, TResult>;
  const AComparer: IEqualityComparer<TKey>): IColligoEnumerable<TResult>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := IColligoEnumerable<TResult>.Create(
    TColligoGroupByResultEnumerable<TKey, T, TResult>.Create(
      FEnumerator, AKeySelector, AResultSelector, AComparer),
    FColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function IColligoEnumerable<T>.Zip<TSecond, TResult>(const ASecond: IColligoEnumerable<TSecond>;
  const AResultSelector: TFunc<T, TSecond, TResult>): IColligoEnumerable<TResult>;
begin
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := IColligoEnumerable<TResult>.Create(
    TColligoZipEnumerable<T, TSecond, TResult>.Create(FEnumerator, ASecond.FEnumerator, AResultSelector),
    FColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function IColligoEnumerable<T>.OfType<TResult>: IColligoEnumerable<TResult>;
begin
  Result := IColligoEnumerable<TResult>.Create(
    TColligoOfTypeEnumerable<T, TResult>.Create(FEnumerator),
    FColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function IColligoEnumerable<T>.Exclude(const ASecond: IColligoEnumerable<T>): IColligoEnumerable<T>;
begin
  Result := Exclude(ASecond, FComparer);
end;

function IColligoEnumerable<T>.Exclude(const ASecond: IColligoEnumerable<T>;
  const AComparer: IEqualityComparer<T>): IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(
    TColligoExcludeEnumerable<T>.Create(FEnumerator, ASecond.FEnumerator, AComparer),
    FColligoType,
    AComparer
  );
end;

function IColligoEnumerable<T>.Intersect(const ASecond: IColligoEnumerable<T>): IColligoEnumerable<T>;
begin
  Result := Intersect(ASecond, FComparer);
end;

function IColligoEnumerable<T>.Intersect(const ASecond: IColligoEnumerable<T>;
  const AComparer: IEqualityComparer<T>): IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(
    TColligoIntersectEnumerable<T>.Create(FEnumerator, ASecond.FEnumerator, AComparer),
    FColligoType,
    AComparer
  );
end;

function IColligoEnumerable<T>.Union(const ASecond: IColligoEnumerable<T>): IColligoEnumerable<T>;
begin
  Result := Union(ASecond, FComparer);
end;

function IColligoEnumerable<T>.Union(const ASecond: IColligoEnumerable<T>;
  const AComparer: IEqualityComparer<T>): IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(
    TColligoUnionEnumerable<T>.Create(FEnumerator, ASecond.FEnumerator, AComparer),
    FColligoType,
    AComparer
  );
end;

function IColligoEnumerable<T>.Concat(const ASecond: IColligoEnumerable<T>): IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(
    TColligoConcatEnumerable<T>.Create(FEnumerator, ASecond.FEnumerator),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.SequenceEqual(const ASecond: IColligoEnumerable<T>): Boolean;
var
  LEnum1, LEnum2: IColligoEnumerator<T>;
begin
  LEnum1 := GetEnumerator;
  LEnum2 := ASecond.GetEnumerator;
  while LEnum1.MoveNext and LEnum2.MoveNext do
    if not FComparer.Equals(LEnum1.Current, LEnum2.Current) then
      Exit(False);
  Result := not (LEnum1.MoveNext or LEnum2.MoveNext);
end;

function IColligoEnumerable<T>.Single(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Single: T;
begin
  Result := Single(nil);
end;

function IColligoEnumerable<T>.SingleOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.SingleOrDefault: T;
begin
  Result := SingleOrDefault(nil);
end;

function IColligoEnumerable<T>.ElementAt(const AIndex: Integer): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.ElementAtOrDefault(const AIndex: Integer): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.DistinctBy<TKey>(const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>;
begin
  Result := DistinctBy<TKey>(AKeySelector, nil);
end;

function IColligoEnumerable<T>.DistinctBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): IColligoEnumerable<T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  // Deferred/streaming: nothing is enumerated until the result is iterated.
  Result := IColligoEnumerable<T>.Create(
    TColligoDistinctByEnumerable<T, TKey>.Create(FEnumerator, AKeySelector, AComparer),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.Min(const AComparer: TFunc<T, T, Integer>): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Max(const AComparer: TFunc<T, T, Integer>): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.GroupJoin<TInner, TKey, TResult>(const AInner: IColligoEnumerable<TInner>;
  const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
  const AResultSelector: TFunc<T, IColligoEnumerableAdapter<TInner>, TResult>): IColligoEnumerable<TResult>;
begin
  if not Assigned(AOuterKeySelector) then
    raise EArgumentNilException.Create('Outer key selector cannot be nil');
  if not Assigned(AInnerKeySelector) then
    raise EArgumentNilException.Create('Inner key selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := IColligoEnumerable<TResult>.Create(
    TColligoGroupJoinEnumerable<T, TInner, TKey, TResult>.Create(FEnumerator, AInner.FEnumerator, AOuterKeySelector, AInnerKeySelector, AResultSelector),
    FColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function IColligoEnumerable<T>.Join<TInner, TKey, TResult>(const AInner: IColligoEnumerable<TInner>;
  const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
  const AResultSelector: TFunc<T, TInner, TResult>): IColligoEnumerable<TResult>;
begin
  Result := Join<TInner, TKey, TResult>(AInner, AOuterKeySelector, AInnerKeySelector,
    AResultSelector, nil);
end;

function IColligoEnumerable<T>.Join<TInner, TKey, TResult>(const AInner: IColligoEnumerable<TInner>;
  const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
  const AResultSelector: TFunc<T, TInner, TResult>;
  const AComparer: IEqualityComparer<TKey>): IColligoEnumerable<TResult>;
begin
  if not Assigned(AOuterKeySelector) then
    raise EArgumentNilException.Create('Outer key selector cannot be nil');
  if not Assigned(AInnerKeySelector) then
    raise EArgumentNilException.Create('Inner key selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := IColligoEnumerable<TResult>.Create(
    TColligoJoinEnumerable<T, TInner, TKey, TResult>.Create(FEnumerator, AInner.FEnumerator,
      AOuterKeySelector, AInnerKeySelector, AResultSelector, AComparer),
    FColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function IColligoEnumerable<T>.MinBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: TFunc<TKey, TKey, Integer>): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Max(const ASelector: TFunc<T, Single>): Single;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Max(const ASelector: TFunc<T, Int64>): Int64;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Max(const ASelector: TFunc<T, Int32>): Int32;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Max(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Max(const ASelector: TFunc<T, Currency>): Currency;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Max(const ASelector: TFunc<T, NullableSingle>): NullableSingle;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Max(const ASelector: TFunc<T, NullableInt64>): NullableInt64;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Max(const ASelector: TFunc<T, NullableInt32>): NullableInt32;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Max(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Max(const ASelector: TFunc<T, NullableDouble>): NullableDouble;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.MaxBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: TFunc<TKey, TKey, Integer>): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>._IsEmpty: Boolean;
begin
  Result := not FIsValid;
end;

function IColligoEnumerable<T>.ToHashSet: THashSet<T>;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.ToLookup<TKey, TElement>(const AKeySelector: TFunc<T, TKey>;
  const AElementSelector: TFunc<T, TElement>): TDictionary<TKey, TList<TElement>>;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.TryGetNonEnumeratedCount(out ACount: Integer): Boolean;
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

function IColligoEnumerable<T>.ThenBy<TKey>(const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>;
var
  LOrdered: IColligoOrderedEnumerable<T>;
  LFunc: TFunc<T, T, Integer>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if FOrdered = nil then
    raise EInvalidOperation.Create('ThenBy must be called directly after OrderBy, OrderByDescending, Order or OrderDescending');
  LFunc :=
    function(A, B: T): Integer
    begin
      Result := TComparer<TKey>.Default.Compare(AKeySelector(A), AKeySelector(B));
    end;
  LOrdered := FOrdered.ThenByAppend(LFunc);
  Result := IColligoEnumerable<T>.Create(LOrdered, FColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function IColligoEnumerable<T>.ThenByDescending<TKey>(const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>;
var
  LOrdered: IColligoOrderedEnumerable<T>;
  LFunc: TFunc<T, T, Integer>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if FOrdered = nil then
    raise EInvalidOperation.Create('ThenByDescending must be called directly after OrderBy, OrderByDescending, Order or OrderDescending');
  LFunc :=
    function(A, B: T): Integer
    begin
      Result := -TComparer<TKey>.Default.Compare(AKeySelector(A), AKeySelector(B));
    end;
  LOrdered := FOrdered.ThenByAppend(LFunc);
  Result := IColligoEnumerable<T>.Create(LOrdered, FColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function IColligoEnumerable<T>.UnionBy<TKey>(const ASecond: IColligoEnumerable<T>;
  const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>;
begin
  Result := UnionBy<TKey>(ASecond, AKeySelector, nil);
end;

function IColligoEnumerable<T>.UnionBy<TKey>(const ASecond: IColligoEnumerable<T>;
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): IColligoEnumerable<T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  // Deferred/streaming: nothing is enumerated until the result is iterated.
  Result := IColligoEnumerable<T>.Create(
    TColligoUnionByEnumerable<T, TKey>.Create(FEnumerator, ASecond.FEnumerator, AKeySelector, AComparer),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.Append(const AElement: T): IColligoEnumerable<T>;
begin
  // Deferred/streaming: nothing is enumerated until the result is iterated.
  Result := IColligoEnumerable<T>.Create(
    TColligoAppendEnumerable<T>.Create(FEnumerator, AElement),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.Cast<TResult>: IColligoEnumerable<TResult>;
begin
  // Deferred/streaming: nothing is converted until enumeration; a non-matching
  // element raises EInvalidCast at the point it is reached (see Colligo.Cast).
  Result := IColligoEnumerable<TResult>.Create(
    TColligoCastEnumerable<T, TResult>.Create(FEnumerator),
    FColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function IColligoEnumerable<T>.Chunk(const ASize: Integer): IColligoEnumerableBase<TArray<T>>;
begin
  if ASize < 1 then
    raise EArgumentOutOfRangeException.Create('Chunk size must be at least 1');
  // Deferred/streaming over the already-working chunk enumerable.
  Result := TColligoChunkEnumerable<T>.Create(FEnumerator, ASize);
end;

function IColligoEnumerable<T>.DefaultIfEmpty: IColligoEnumerable<T>;
begin
  Result := DefaultIfEmpty(Default(T));
end;

function IColligoEnumerable<T>.DefaultIfEmpty(const ADefaultValue: T): IColligoEnumerable<T>;
begin
  // Deferred/streaming: nothing is enumerated until the result is iterated.
  Result := IColligoEnumerable<T>.Create(
    TColligoDefaultIfEmptyEnumerable<T>.Create(FEnumerator, ADefaultValue),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.ExcludeBy<TKey>(const ASecond: IColligoEnumerable<TKey>;
  const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>;
begin
  Result := ExcludeBy<TKey>(ASecond, AKeySelector, nil);
end;

function IColligoEnumerable<T>.ExcludeBy<TKey>(const ASecond: IColligoEnumerable<TKey>;
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): IColligoEnumerable<T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  // Deferred: the second (keys) is buffered when enumeration starts; the source
  // is streamed and yields DISTINCT non-excluded elements.
  Result := IColligoEnumerable<T>.Create(
    TColligoExcludeByEnumerable<T, TKey>.Create(FEnumerator, ASecond.FEnumerator, AKeySelector, AComparer),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.IntersectBy<TKey>(const ASecond: IColligoEnumerable<TKey>;
  const AKeySelector: TFunc<T, TKey>): IColligoEnumerable<T>;
begin
  Result := IntersectBy<TKey>(ASecond, AKeySelector, nil);
end;

function IColligoEnumerable<T>.IntersectBy<TKey>(const ASecond: IColligoEnumerable<TKey>;
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): IColligoEnumerable<T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  // Deferred: the second (keys) is buffered when enumeration starts; the source
  // is streamed and yields DISTINCT matching elements.
  Result := IColligoEnumerable<T>.Create(
    TColligoIntersectByEnumerable<T, TKey>.Create(FEnumerator, ASecond.FEnumerator, AKeySelector, AComparer),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.IsNotAssigned: Boolean;
begin
  Result := not TEqualityComparer<IColligoEnumerable<T>>.Default.Equals(Self, Default(IColligoEnumerable<T>));
end;

function IColligoEnumerable<T>.Prepend(const AElement: T): IColligoEnumerable<T>;
begin
  // Deferred/streaming: nothing is enumerated until the result is iterated.
  Result := IColligoEnumerable<T>.Create(
    TColligoPrependEnumerable<T>.Create(FEnumerator, AElement),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.Reverse: IColligoEnumerable<T>;
begin
  // Deferred, non-streaming: buffers only on the first MoveNext, not here.
  Result := IColligoEnumerable<T>.Create(
    TColligoReverseEnumerable<T>.Create(FEnumerator),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.SkipLast(const ACount: Integer): IColligoEnumerable<T>;
begin
  // Deferred, non-streaming: buffers only on the first MoveNext. ACount <= 0
  // yields the whole source (handled inside the enumerator).
  Result := IColligoEnumerable<T>.Create(
    TColligoSkipLastEnumerable<T>.Create(FEnumerator, ACount),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.SkipWhile(
  const APredicate: TFunc<T, Integer, Boolean>): IColligoEnumerable<T>;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate cannot be nil');
  Result := IColligoEnumerable<T>.Create(
    TColligoSkipWhileIndexedEnumerable<T>.Create(FEnumerator, APredicate),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.TakeLast(const ACount: Integer): IColligoEnumerable<T>;
begin
  // Deferred, non-streaming: buffers only on the first MoveNext. ACount <= 0
  // yields nothing (handled inside the enumerator).
  Result := IColligoEnumerable<T>.Create(
    TColligoTakeLastEnumerable<T>.Create(FEnumerator, ACount),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.TakeWhile(
  const APredicate: TFunc<T, Integer, Boolean>): IColligoEnumerable<T>;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate cannot be nil');
  Result := IColligoEnumerable<T>.Create(
    TColligoTakeWhileIndexedEnumerable<T>.Create(FEnumerator, APredicate),
    FColligoType,
    FComparer
  );
end;

function IColligoEnumerable<T>.Max<TResult>(const ASelector: TFunc<T, TResult>): TResult;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Max(const AComparer: IComparer<T>): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Min(const ASelector: TFunc<T, Single>): Single;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Min(const ASelector: TFunc<T, Int64>): Int64;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Min(const ASelector: TFunc<T, Int32>): Int32;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Min(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Min(const ASelector: TFunc<T, Currency>): Currency;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Min(const ASelector: TFunc<T, NullableSingle>): NullableSingle;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Min(const ASelector: TFunc<T, NullableInt64>): NullableInt64;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Min(const ASelector: TFunc<T, NullableInt32>): NullableInt32;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Min(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Min(const ASelector: TFunc<T, NullableDouble>): NullableDouble;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Min<TResult>(const ASelector: TFunc<T, TResult>): TResult;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.Min(const AComparer: IComparer<T>): T;
var
  LEnum: IColligoEnumerator<T>;
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

function IColligoEnumerable<T>.SelectMany<TCollection, TResult>(
  const ACollectionSelector: TFunc<T, Integer, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>): IColligoEnumerable<TResult>;
begin
  if not Assigned(ACollectionSelector) then
    raise EArgumentNilException.Create('Collection selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := IColligoEnumerable<TResult>.Create(
    TColligoSelectManyCollectionIndexedEnumerable<T, TCollection, TResult>.Create(
      FEnumerator, ACollectionSelector, AResultSelector),
    FColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function IColligoEnumerable<T>.SelectMany<TCollection, TResult>(
  const ACollectionSelector: TFunc<T, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>): IColligoEnumerable<TResult>;
begin
  if not Assigned(ACollectionSelector) then
    raise EArgumentNilException.Create('Collection selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := IColligoEnumerable<TResult>.Create(
    TColligoSelectManyCollectionEnumerable<T, TCollection, TResult>.Create(
      FEnumerator, ACollectionSelector, AResultSelector),
    FColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function IColligoEnumerable<T>.SelectMany<TResult>(
  const ASelector: TFunc<T, Integer, IColligoArray<TResult>>): IColligoEnumerable<TResult>;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  Result := IColligoEnumerable<TResult>.Create(
    TColligoSelectManyIndexedEnumerable<T, TResult>.Create(FEnumerator, ASelector),
    FColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function IColligoEnumerable<T>.SelectMany<TResult>(const ASelector: TFunc<T, TArray<TResult>>): IColligoEnumerable<TResult>;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  Result := IColligoEnumerable<TResult>.Create(
    TColligoSelectManyEnumerable<T, TResult>.Create(FEnumerator, ASelector),
    FColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function IColligoEnumerable<T>.Select<TResult>(
  const ASelector: TFunc<T, Integer, TResult>): IColligoEnumerable<TResult>;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  Result := IColligoEnumerable<TResult>.Create(
    TColligoSelectIndexedEnumerable<T, TResult>.Create(FEnumerator, ASelector),
    FColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function IColligoEnumerable<T>.Order(const AComparer: IComparer<T>): IColligoEnumerable<T>;
var
  LOrdered: IColligoOrderedEnumerable<T>;
  LFunc: TFunc<T, T, Integer>;
begin
  LFunc :=
    function(A, B: T): Integer
    begin
      if AComparer = nil then
        Result := TComparer<T>.Default.Compare(A, B)
      else
        Result := AComparer.Compare(A, B);
    end;
  LOrdered := TColligoOrderByEnumerable<T>.Create(FEnumerator, LFunc);
  Result := IColligoEnumerable<T>.Create(LOrdered, FColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function IColligoEnumerable<T>.Order: IColligoEnumerable<T>;
begin
  Result := Order(nil);
end;

function IColligoEnumerable<T>.Sum(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency;
var
  LEnum: IColligoEnumerator<T>;
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
  // LINQ: nullable Sum of an empty / all-null sequence is 0 (never null, never raises).
  Result := NullableCurrency.Create(LSum);
end;

{ IColligoEnumerable<T>.TColligoCompare }

class function IColligoEnumerable<T>.TColligoCompare.Compare(
  const AEnumerator: IColligoEnumerableBase<T>; const AValue: T;
  const AComparer: IEqualityComparer<T>): Boolean;
var
  LEnum: IColligoEnumerator<T>;
begin
  LEnum := AEnumerator.GetEnumerator;
  while LEnum.MoveNext do
    if AComparer.Equals(LEnum.Current, AValue) then
      Exit(True);
  Result := False;
end;

{ TColligoGrouping<TKey, T> }

constructor TColligoGrouping<TKey, T>.Create(const AKey: TKey; const AItems: IColligoEnumerable<T>);
begin
  FKey := AKey;
  FItems := AItems;
end;

function TColligoGrouping<TKey, T>.GetKey: TKey;
begin
  Result := FKey;
end;

function TColligoGrouping<TKey, T>.GetItems: IColligoEnumerable<T>;
begin
  Result := FItems;
end;

{ TColligo }

class function TColligo.Range(const AStart, ACount: Integer): IColligoEnumerable<Integer>;
begin
  if ACount < 0 then
    raise EArgumentOutOfRangeException.Create('Count must be non-negative');
  // Int64 math so the overflow check itself cannot overflow.
  if Int64(AStart) + Int64(ACount) - 1 > High(Integer) then
    raise EArgumentOutOfRangeException.Create('Range end exceeds Integer range');
  Result := IColligoEnumerable<Integer>.Create(TColligoRangeEnumerable.Create(AStart, ACount));
end;

class function TColligo.&Repeat<T>(const AElement: T; const ACount: Integer): IColligoEnumerable<T>;
begin
  if ACount < 0 then
    raise EArgumentOutOfRangeException.Create('Count must be non-negative');
  Result := IColligoEnumerable<T>.Create(TColligoRepeatEnumerable<T>.Create(AElement, ACount));
end;

class function TColligo.Empty<T>: IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(TColligoEmptyEnumerable<T>.Create);
end;

end.


