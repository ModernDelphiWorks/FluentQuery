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

unit LQColligo;

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
  LQColligo.Core;

type
  ILQColligoEnumerableAdapter<TResult> = interface;
  IGroupByEnumerable<TKey, T> = interface;
  IGrouping<TKey, T> = interface;
  ILQColligoArray<T> = interface;
  ILQColligoList<T> = interface;
//  ILQColligoChunkResult<T> = interface;

  ILQColligoEnumerator<T> = interface(IInterface)
    ['{E2DEBD49-1094-41A5-A817-48FB81A6F6F2}']
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  ILQColligoEnumerableBase<T> = interface(IInterface)
    ['{B68572C5-32C6-436A-B39B-D8DA06E33C14}']
    function GetEnumerator: ILQColligoEnumerator<T>;
  end;

  TLQColligoEnumerableBase<T> = class abstract(TInterfacedObject, ILQColligoEnumerableBase<T>)
  protected
    function GetEnumerator: ILQColligoEnumerator<T>; virtual; abstract;
  end;

  // Ordered enumerable produced by OrderBy/OrderByDescending/Order/OrderDescending.
  // Carries the ordered chain of comparison criteria so that ThenBy/ThenByDescending
  // can append a subordinate criterion (primary key stays dominant), mirroring
  // C#'s IOrderedEnumerable<T>. Kept as an ARC interface so the criteria chain lives
  // in a managed object, never in a record temporary.
  ILQColligoOrderedEnumerable<T> = interface(ILQColligoEnumerableBase<T>)
    ['{7E2C1A44-9B3D-4F6E-8A21-3C5D9E0F1B22}']
    function ThenByAppend(const AComparer: TFunc<T, T, Integer>): ILQColligoOrderedEnumerable<T>;
  end;

  ILQColligoEnumerable<T> = record
  private
    FEnumerator: ILQColligoEnumerableBase<T>;
    FLQColligoType: TLQColligoType;
    FComparer: IEqualityComparer<T>;
    FIsValid: Boolean;
    // Non-nil only when this record was produced by an ordering operator
    // (OrderBy/OrderByDescending/Order/OrderDescending). ThenBy/ThenByDescending
    // read it to append a subordinate criterion. Managed (ARC) field, so it
    // survives record copies/temporaries. See ILQColligoOrderedEnumerable<T>.
    FOrdered: ILQColligoOrderedEnumerable<T>;
    type
      TLQColligoCompare = class
      public
        class function Compare(const AEnumerator: ILQColligoEnumerableBase<T>;
          const AValue: T; const AComparer: IEqualityComparer<T>): Boolean; static;
      end;
    function _IsEmpty: Boolean;
  public
    constructor Create(const AEnumerator: ILQColligoEnumerableBase<T>;
      const ALQColligoType: TLQColligoType = ftNone; const AComparer: IEqualityComparer<T> = nil);
    function IsNotAssigned: Boolean;
    function GetEnumerator: ILQColligoEnumerator<T>;
    function Where(const APredicate: TFunc<T, Boolean>): ILQColligoEnumerable<T>;
    function Take(const ACount: Integer): ILQColligoEnumerable<T>;
    function Skip(const ACount: Integer): ILQColligoEnumerable<T>;
    function Distinct: ILQColligoEnumerable<T>; overload;
    function Distinct(const AComparer: IEqualityComparer<T>): ILQColligoEnumerable<T>; overload;
    function DistinctBy<TKey>(const AKeySelector: TFunc<T, TKey>): ILQColligoEnumerable<T>; overload;
    function DistinctBy<TKey>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>): ILQColligoEnumerable<T>; overload;
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
    function Zip<TSecond, TResult>(const ASecond: ILQColligoEnumerable<TSecond>;
      const AResultSelector: TFunc<T, TSecond, TResult>): ILQColligoEnumerable<TResult>;
    function OfType<TResult>: ILQColligoEnumerable<TResult>;
    function Exclude(const ASecond: ILQColligoEnumerable<T>): ILQColligoEnumerable<T>; overload;
    function Exclude(const ASecond: ILQColligoEnumerable<T>;
      const AComparer: IEqualityComparer<T>): ILQColligoEnumerable<T>; overload;
    function Intersect(const ASecond: ILQColligoEnumerable<T>): ILQColligoEnumerable<T>; overload;
    function Intersect(const ASecond: ILQColligoEnumerable<T>;
      const AComparer: IEqualityComparer<T>): ILQColligoEnumerable<T>; overload;
    function Union(const ASecond: ILQColligoEnumerable<T>): ILQColligoEnumerable<T>; overload;
    function Union(const ASecond: ILQColligoEnumerable<T>;
      const AComparer: IEqualityComparer<T>): ILQColligoEnumerable<T>; overload;
    function Concat(const ASecond: ILQColligoEnumerable<T>): ILQColligoEnumerable<T>;
    function SequenceEqual(const ASecond: ILQColligoEnumerable<T>): Boolean;
    function Single: T; overload;
    function Single(const APredicate: TFunc<T, Boolean>): T; overload;
    function SingleOrDefault: T; overload;
    function SingleOrDefault(const APredicate: TFunc<T, Boolean>): T; overload;
    function ElementAt(const AIndex: Integer): T;
    function ElementAtOrDefault(const AIndex: Integer): T;
    function OrderBy(const AComparer: TFunc<T, T, Integer>): ILQColligoEnumerable<T>; overload;
    function OrderBy<TKey>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: IComparer<TKey>): ILQColligoEnumerable<T>; overload;
    function OrderByDesc(const AComparer: TFunc<T, T, Integer>): ILQColligoEnumerable<T>;
    function GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>): IGroupByEnumerable<TKey, T>; overload;
    function GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>): IGroupByEnumerable<TKey, T>; overload;
    function GroupBy<TKey, TElement>(const AKeySelector: TFunc<T, TKey>;
      const AElementSelector: TFunc<T, TElement>): IGroupByEnumerable<TKey, TElement>; overload;
    function GroupBy<TKey, TElement>(const AKeySelector: TFunc<T, TKey>;
      const AElementSelector: TFunc<T, TElement>;
      const AComparer: IEqualityComparer<TKey>): IGroupByEnumerable<TKey, TElement>; overload;
    function GroupBy<TKey, TResult>(const AKeySelector: TFunc<T, TKey>;
      const AResultSelector: TFunc<TKey, ILQColligoEnumerableAdapter<T>, TResult>): ILQColligoEnumerable<TResult>; overload;
    function GroupBy<TKey, TResult>(const AKeySelector: TFunc<T, TKey>;
      const AResultSelector: TFunc<TKey, ILQColligoEnumerableAdapter<T>, TResult>;
      const AComparer: IEqualityComparer<TKey>): ILQColligoEnumerable<TResult>; overload;
    function Join<TInner, TKey, TResult>(const AInner: ILQColligoEnumerable<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, TInner, TResult>): ILQColligoEnumerable<TResult>; overload;
    function Join<TInner, TKey, TResult>(const AInner: ILQColligoEnumerable<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, TInner, TResult>;
      const AComparer: IEqualityComparer<TKey>): ILQColligoEnumerable<TResult>; overload;
    function GroupJoin<TInner, TKey, TResult>(const AInner: ILQColligoEnumerable<TInner>;
      const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
      const AResultSelector: TFunc<T, ILQColligoEnumerableAdapter<TInner>, TResult>): ILQColligoEnumerable<TResult>;
    function ToHashSet: THashSet<T>;
    function ToLookup<TKey, TElement>(const AKeySelector: TFunc<T, TKey>;
      const AElementSelector: TFunc<T, TElement>): TDictionary<TKey, TList<TElement>>;
    function UnionBy<TKey>(const ASecond: ILQColligoEnumerable<T>;
      const AKeySelector: TFunc<T, TKey>): ILQColligoEnumerable<T>; overload;
    function UnionBy<TKey>(const ASecond: ILQColligoEnumerable<T>;
      const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>): ILQColligoEnumerable<T>; overload;
    function Append(const AElement: T): ILQColligoEnumerable<T>;
    function Cast<TResult>: ILQColligoEnumerable<TResult>;
    function DefaultIfEmpty: ILQColligoEnumerable<T>; overload;
    function DefaultIfEmpty(const ADefaultValue: T): ILQColligoEnumerable<T>; overload;
    function ExcludeBy<TKey>(const ASecond: ILQColligoEnumerable<TKey>;
      const AKeySelector: TFunc<T, TKey>): ILQColligoEnumerable<T>; overload;
    function ExcludeBy<TKey>(const ASecond: ILQColligoEnumerable<TKey>;
      const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>): ILQColligoEnumerable<T>; overload;
    function IntersectBy<TKey>(const ASecond: ILQColligoEnumerable<TKey>;
      const AKeySelector: TFunc<T, TKey>): ILQColligoEnumerable<T>; overload;
    function IntersectBy<TKey>(const ASecond: ILQColligoEnumerable<TKey>;
      const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>): ILQColligoEnumerable<T>; overload;
    function Prepend(const AElement: T): ILQColligoEnumerable<T>;
    function Reverse: ILQColligoEnumerable<T>;
    function SkipLast(const ACount: Integer): ILQColligoEnumerable<T>;
    function TakeLast(const ACount: Integer): ILQColligoEnumerable<T>;
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
    // ILQColligoEnumerable<TArray<T>> record) to avoid E2604 "recursive use of
    // generic type" — a record cannot return an instantiation of itself over a
    // type derived from its own T. Iterate the result via GetEnumerator, or wrap
    // it in ILQColligoEnumerable<TArray<T>>.Create(...) to chain further.
    function Chunk(const ASize: Integer): ILQColligoEnumerableBase<TArray<T>>;
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
    function Order: ILQColligoEnumerable<T>; overload;
    function Order(const AComparer: IComparer<T>): ILQColligoEnumerable<T>; overload;
    function OrderDescending: ILQColligoEnumerable<T>; overload;
    function OrderDescending(const AComparer: IComparer<T>): ILQColligoEnumerable<T>; overload;
    function Select<TResult>(const ASelector: TFunc<T, TResult>): ILQColligoEnumerable<TResult>; overload;
    function Select<TResult>(const ASelector: TFunc<T, Integer, TResult>): ILQColligoEnumerable<TResult>; overload;
    function SelectMany<TResult>(const ASelector: TFunc<T, TArray<TResult>>): ILQColligoEnumerable<TResult>; overload;
    function SelectMany<TResult>(const ASelector: TFunc<T, Integer, ILQColligoArray<TResult>>): ILQColligoEnumerable<TResult>; overload;
    function SelectMany<TCollection, TResult>(
      const ACollectionSelector: TFunc<T, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>): ILQColligoEnumerable<TResult>; overload;
    function SelectMany<TCollection, TResult>(
      const ACollectionSelector: TFunc<T, Integer, TArray<TCollection>>;
      const AResultSelector: TFunc<T, TCollection, TResult>): ILQColligoEnumerable<TResult>; overload;
    function SkipWhile(const APredicate: TFunc<T, Boolean>): ILQColligoEnumerable<T>; overload;
    function SkipWhile(const APredicate: TFunc<T, Integer, Boolean>): ILQColligoEnumerable<T>; overload;
    function TakeWhile(const APredicate: TFunc<T, Boolean>): ILQColligoEnumerable<T>; overload;
    function TakeWhile(const APredicate: TFunc<T, Integer, Boolean>): ILQColligoEnumerable<T>; overload;
    function ToDictionary<TKey, TValue>(const AKeySelector: TFunc<T, TKey>;
      const AValueSelector: TFunc<T, TValue>): TDictionary<TKey, TValue>; overload;
    function ToDictionary<TKey, TValue>(const AKeySelector: TFunc<T, TKey>;
      const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, T>; overload;
    function ToDictionary<TKey, TValue>(const AKeySelector: TFunc<T, TKey>;
      const AValueSelector: TFunc<T, TValue>;
      const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, TValue>; overload;
    function TryGetNonEnumeratedCount(out ACount: Integer): Boolean;
    function ThenBy<TKey>(const AKeySelector: TFunc<T, TKey>): ILQColligoEnumerable<T>;
    function ThenByDescending<TKey>(const AKeySelector: TFunc<T, TKey>): ILQColligoEnumerable<T>;
    function ToArray: ILQColligoArray<T>;
    function ToList: ILQColligoList<T>;
  end;

  IGroupByEnumerable<TKey, T> = interface(IInterface)
    ['{A85DB3F6-E808-4E81-B386-75190087507B}']
    function GetEnumerator: ILQColligoEnumerator<IGrouping<TKey, T>>;
    function AsEnumerable: ILQColligoEnumerable<IGrouping<TKey, T>>;
  end;

  IGrouping<TKey, T> = interface(IInterface)
    ['{87B4E3F7-C092-44D1-B682-0B03C0202BF0}']
    function GetKey: TKey;
    function GetItems: ILQColligoEnumerable<T>;
    property Key: TKey read GetKey;
    property Items: ILQColligoEnumerable<T> read GetItems;
  end;

  TLQColligoGrouping<TKey, T> = class(TInterfacedObject, IGrouping<TKey, T>)
  private
    FKey: TKey;
    FItems: ILQColligoEnumerable<T>;
  public
    constructor Create(const AKey: TKey; const AItems: ILQColligoEnumerable<T>);
    function GetKey: TKey;
    function GetItems: ILQColligoEnumerable<T>;
    property Key: TKey read GetKey;
    property Items: ILQColligoEnumerable<T> read GetItems;
  end;

//  ILQColligoChunkResult<T> = interface(IInterface)
//    ['{1148CD41-1C5F-44DA-A4EF-C200AC3F2D5A}']
//    function GetEnumerator: ILQColligoEnumerator<TArray<T>>;
//    function AsEnumerable: ILQColligoEnumerable<TArray<T>>;
//  end;

  ILQColligoEnumerableAdapter<TResult> = interface(IInterface)
    ['{69303F43-C266-437F-A790-4038CFDA0680}']
    function AsEnumerable: ILQColligoEnumerable<TResult>;
  end;

  ILQColligoArray<T> = interface(IInterface)
    ['{E3DF6D61-1A52-466E-8B16-CF7AAC574A02}']
    function GetItem(AIndex: NativeInt): T;
    procedure SetItem(AIndex: NativeInt; const AValue: T);
    function _GetArray: TArray<T>;
    procedure SetItems(const AItems: TArray<T>);
    function AsEnumerable: ILQColligoEnumerable<T>;
    function GetEnumerator: ILQColligoEnumerator<T>;
    function Length: Integer;
    property ArrayData: TArray<T> read _GetArray;
    property Items[AIndex: NativeInt]: T read GetItem write SetItem; default;
  end;

  ICollections<T> = interface(ILQColligoEnumerableBase<T>)
    ['{1F1B87DA-2722-40E3-899F-5622CA9BE807}']
    function Count: NativeInt;
    function Contains(const AItem: T): Boolean;
    function Remove(const AItem: T): Boolean;
    function AsEnumerable: ILQColligoEnumerable<T>;
    function GetEnumerator: ILQColligoEnumerator<T>;
    procedure Add(const AItem: T);
    procedure CopyTo(AArray: array of T; AIndex: Integer);
    procedure Clear;
  end;

  ILQColligoList<T> = interface(ICollections<T>)
    ['{2749C02A-9973-4747-A4D3-29376DFD6242}']
    function GetCapacity: NativeInt;
    procedure SetCapacity(const AValue: NativeInt);
    function GetItem(AIndex: NativeInt): T;
    procedure SetItem(AIndex: NativeInt; const AValue: T);
    function GetList: ILQColligoArray<T>;
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
    function Expand: ILQColligoList<T>;
    function IndexOf(const AValue: T): NativeInt;
    function IndexOfItem(const AValue: T; Direction: TDirection): NativeInt;
    function LastIndexOf(const AValue: T): NativeInt;
    function BinarySearch(const AItem: T; out FoundIndex: NativeInt): Boolean; overload;
    function BinarySearch(const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>): Boolean; overload;
    function BinarySearch(const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>; AIndex, Count: NativeInt): Boolean; overload;
    function IsEmpty: Boolean;
    function ToArray: ILQColligoArray<T>;
    property Capacity: NativeInt read GetCapacity write SetCapacity;
    property Items[AIndex: NativeInt]: T read GetItem write SetItem; default;
    property List: ILQColligoArray<T> read GetList;
    property Comparer: IComparer<T> read GetComparer;
    property OnNotify: TCollectionNotifyEvent<T> read GetOnNotify write SetOnNotify;
  end;

  ILQColligoDictionary<K, V> = interface(ICollections<TPair<K, V>>)
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
    function ToArray: ILQColligoArray<TPair<K, V>>;
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
  TLQColligo = class
  public
    // ACount consecutive integers from AStart (AStart..AStart+ACount-1).
    // ACount=0 -> empty. Raises EArgumentOutOfRangeException if ACount < 0 or
    // AStart+ACount-1 overflows Integer. Note: the 2nd argument is a COUNT, not
    // an end value (Range(1,5) = 1,2,3,4,5).
    class function Range(const AStart, ACount: Integer): ILQColligoEnumerable<Integer>; static;
    // The same element ACount times. ACount=0 -> empty. Raises if ACount < 0.
    // (Repeat is a reserved word, hence the & escape.)
    class function &Repeat<T>(const AElement: T; const ACount: Integer): ILQColligoEnumerable<T>; static;
    // An empty sequence of T.
    class function Empty<T>: ILQColligoEnumerable<T>; static;
  end;

implementation

uses
  LQColligo.Collections,
  LQColligo.Adapters,
  LQColligo.SkipWhile,
  LQColligo.Where,
  LQColligo.Select,
  LQColligo.Take,
  LQColligo.OrderBy,
  LQColligo.Skip,
  LQColligo.Distinct,
  LQColligo.TakeWhile,
  LQColligo.GroupBy,
  LQColligo.GroupJoin,
  LQColligo.OfType,
  LQColligo.SelectMany,
  LQColligo.Zip,
  LQColligo.Join,
  LQColligo.Exclude,
  LQColligo.Union,
  LQColligo.Intersect,
  LQColligo.Concat,
  LQColligo.Append,
  LQColligo.Prepend,
  LQColligo.DefaultIfEmpty,
  LQColligo.DistinctBy,
  LQColligo.UnionBy,
  LQColligo.ExcludeBy,
  LQColligo.IntersectBy,
  LQColligo.Reverse,
  LQColligo.SkipLast,
  LQColligo.TakeLast,
  LQColligo.Generators,
  LQColligo.Chunk,
  LQColligo.Cast,
  LQColligo.SkipWhileIndexed,
  LQColligo.SelectIndexed,
  LQColligo.TakeWhileIndexed,
  LQColligo.SelectManyCollection,
  LQColligo.SelectManyIndexed,
  LQColligo.SelectManyCollectionIndexed;

{ ILQColligoEnumerable<T> }

constructor ILQColligoEnumerable<T>.Create(const AEnumerator: ILQColligoEnumerableBase<T>;
  const ALQColligoType: TLQColligoType; const AComparer: IEqualityComparer<T>);
begin
  FEnumerator := AEnumerator;
  FLQColligoType := ALQColligoType;
  FComparer := AComparer;
  if FComparer = nil then
    FComparer := TEqualityComparer<T>.Default;
  FIsValid := True;
  FOrdered := nil;
end;

function ILQColligoEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := FEnumerator.GetEnumerator;
end;

function ILQColligoEnumerable<T>.Where(const APredicate: TFunc<T, Boolean>): ILQColligoEnumerable<T>;
begin
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoWhereEnumerable<T>.Create(FEnumerator, APredicate),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.Take(const ACount: Integer): ILQColligoEnumerable<T>;
begin
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoTakeEnumerable<T>.Create(FEnumerator, ACount),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.Skip(const ACount: Integer): ILQColligoEnumerable<T>;
begin
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoSkipEnumerable<T>.Create(FEnumerator, ACount),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.OrderBy(const AComparer: TFunc<T, T, Integer>): ILQColligoEnumerable<T>;
var
  LOrdered: ILQColligoOrderedEnumerable<T>;
begin
  LOrdered := TLQColligoOrderByEnumerable<T>.Create(FEnumerator, AComparer);
  Result := ILQColligoEnumerable<T>.Create(LOrdered, FLQColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function ILQColligoEnumerable<T>.OrderBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: IComparer<TKey>): ILQColligoEnumerable<T>;
var
  LOrdered: ILQColligoOrderedEnumerable<T>;
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
  LOrdered := TLQColligoOrderByEnumerable<T>.Create(FEnumerator, LFunc);
  Result := ILQColligoEnumerable<T>.Create(LOrdered, FLQColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function ILQColligoEnumerable<T>.OrderByDesc(const AComparer: TFunc<T, T, Integer>): ILQColligoEnumerable<T>;
var
  LOrdered: ILQColligoOrderedEnumerable<T>;
  LFunc: TFunc<T, T, Integer>;
begin
  LFunc :=
    function(A, B: T): Integer
    begin
      Result := -AComparer(A, B);
    end;
  LOrdered := TLQColligoOrderByEnumerable<T>.Create(FEnumerator, LFunc);
  Result := ILQColligoEnumerable<T>.Create(LOrdered, FLQColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function ILQColligoEnumerable<T>.OrderDescending(const AComparer: IComparer<T>): ILQColligoEnumerable<T>;
var
  LOrdered: ILQColligoOrderedEnumerable<T>;
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
  LOrdered := TLQColligoOrderByEnumerable<T>.Create(FEnumerator, LFunc);
  Result := ILQColligoEnumerable<T>.Create(LOrdered, FLQColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function ILQColligoEnumerable<T>.OrderDescending: ILQColligoEnumerable<T>;
begin
  Result := OrderDescending(nil);
end;

function ILQColligoEnumerable<T>.Distinct: ILQColligoEnumerable<T>;
begin
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoDistinctEnumerable<T>.Create(FEnumerator, FComparer),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.Distinct(const AComparer: IEqualityComparer<T>): ILQColligoEnumerable<T>;
begin
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoDistinctEnumerable<T>.Create(FEnumerator, AComparer),
    FLQColligoType,
    AComparer
  );
end;

function ILQColligoEnumerable<T>.Select<TResult>(const ASelector: TFunc<T, TResult>): ILQColligoEnumerable<TResult>;
begin
  Result := ILQColligoEnumerable<TResult>.Create(
    TLQColligoSelectEnumerable<T, TResult>.Create(FEnumerator, ASelector),
    FLQColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function ILQColligoEnumerable<T>.Aggregate(const AReducer: TFunc<T, T, T>): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Aggregate<TAcc>(const AInitialValue: TAcc;
  const AAccumulator: TFunc<TAcc, T, TAcc>): TAcc;
var
  LEnum: ILQColligoEnumerator<T>;
  LResult: TAcc;
begin
  LEnum := GetEnumerator;
  LResult := AInitialValue;
  while LEnum.MoveNext do
    LResult := AAccumulator(LResult, LEnum.Current);
  Result := LResult;
end;

function ILQColligoEnumerable<T>.Aggregate<TAccumulate, TResult>(
  const AInitialValue: TAccumulate;
  const AAccumulator: TFunc<TAccumulate, T, TAccumulate>;
  const AResultSelector: TFunc<TAccumulate, TResult>): TResult;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.AggregateBy<TKey, TAccumulate>(
  const AKeySelector: TFunc<T, TKey>;
  const ASeedFactory: TFunc<TKey, TAccumulate>;
  const AAccumulator: TFunc<TAccumulate, T, TAccumulate>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, TAccumulate>;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.AggregateBy<TKey, TAccumulate>(
  const AKeySelector: TFunc<T, TKey>;
  const ASeed: TAccumulate;
  const AAccumulator: TFunc<TAccumulate, T, TAccumulate>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, TAccumulate>;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Sum(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Sum(const ASelector: TFunc<T, Integer>): Integer;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.SumCurrency(const ASelector: TFunc<T, Currency>): Currency;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.SumInt32(const ASelector: TFunc<T, Int32>): Int32;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Sum(const ASelector: TFunc<T, Int64>): Int64;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Sum(const ASelector: TFunc<T, Single>): Single;
var
  LEnum: ILQColligoEnumerator<T>;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  LEnum := GetEnumerator;
  Result := 0;
  while LEnum.MoveNext do
    Result := Result + ASelector(LEnum.Current);
end;

function ILQColligoEnumerable<T>.Sum(const ASelector: TFunc<T, NullableInt32>): NullableInt32;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Sum(const ASelector: TFunc<T, NullableInt64>): NullableInt64;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Sum(const ASelector: TFunc<T, NullableSingle>): NullableSingle;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Sum(const ASelector: TFunc<T, NullableDouble>): NullableDouble;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Average(const ASelector: TFunc<T, Currency>): Currency;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Average(const ASelector: TFunc<T, Int32>): Double;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Average(const ASelector: TFunc<T, Int64>): Double;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Average(const ASelector: TFunc<T, Single>): Double;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Average(const ASelector: TFunc<T, NullableInt32>): NullableDouble;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Average(const ASelector: TFunc<T, NullableInt64>): NullableDouble;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Average(const ASelector: TFunc<T, NullableSingle>): NullableSingle;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Average(const ASelector: TFunc<T, NullableDouble>): NullableDouble;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Average(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Average(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Min: T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Max: T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Any(const APredicate: TFunc<T, Boolean>): Boolean;
var
  LEnum: ILQColligoEnumerator<T>;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    if not Assigned(APredicate) or APredicate(LEnum.Current) then
      Exit(True);
  end;
  Result := False;
end;

function ILQColligoEnumerable<T>.Any: Boolean;
begin
  Result := GetEnumerator.MoveNext;
end;

function ILQColligoEnumerable<T>.All(const APredicate: TFunc<T, Boolean>): Boolean;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Contains(const AValue: T): Boolean;
begin
  Result := TLQColligoCompare.Compare(FEnumerator, AValue, FComparer);
end;

function ILQColligoEnumerable<T>.Contains(const AValue: T;
  const AComparer: IEqualityComparer<T>): Boolean;
var
  LEnum: ILQColligoEnumerator<T>;
begin
  if not Assigned(AComparer) then
    raise EArgumentNilException.Create('Comparer cannot be nil');
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    if AComparer.Equals(LEnum.Current, AValue) then
      Exit(True);
  Result := False;
end;

function ILQColligoEnumerable<T>.First: T;
begin
  Result := First(nil);
end;

function ILQColligoEnumerable<T>.First(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.FirstOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: ILQColligoEnumerator<T>;
begin
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
  begin
    if not Assigned(APredicate) or APredicate(LEnum.Current) then
      Exit(LEnum.Current);
  end;
  Result := Default(T);
end;

function ILQColligoEnumerable<T>.FirstOrDefault: T;
begin
  Result := FirstOrDefault(nil);
end;

function ILQColligoEnumerable<T>.Last(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Last: T;
begin
  Result := Last(nil);
end;

function ILQColligoEnumerable<T>.LastOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.LastOrDefault: T;
begin
  Result := LastOrDefault(nil);
end;

function ILQColligoEnumerable<T>.Count(const APredicate: TFunc<T, Boolean>): Integer;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.CountBy<TKey>(
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, Integer>;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Count: Integer;
begin
  Result := Count(nil);
end;

function ILQColligoEnumerable<T>.LongCount(const APredicate: TFunc<T, Boolean>): Int64;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.LongCount: Int64;
begin
  Result := LongCount(nil);
end;

function ILQColligoEnumerable<T>.TakeWhile(const APredicate: TFunc<T, Boolean>): ILQColligoEnumerable<T>;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate cannot be nil');
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoTakeWhileEnumerable<T>.Create(FEnumerator, APredicate),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.SkipWhile(const APredicate: TFunc<T, Boolean>): ILQColligoEnumerable<T>;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate cannot be nil');
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoSkipWhileEnumerable<T>.Create(FEnumerator, APredicate),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.ToArray: ILQColligoArray<T>;
var
  LEnum: ILQColligoEnumerator<T>;
  LList: ILQColligoList<T>;
begin
  LList := TLQColligoList<T>.Create;
  try
    LEnum := GetEnumerator;
    while LEnum.MoveNext do
      LList.Add(LEnum.Current);
    Result := LList.ToArray;
  finally
    LList := nil;
  end;
end;

function ILQColligoEnumerable<T>.ToDictionary<TKey, TValue>(
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, T>;
begin
  Result := ToDictionary<TKey, T>(AKeySelector, function(x: T): T begin Result := x end, AComparer);
end;

function ILQColligoEnumerable<T>.ToDictionary<TKey, TValue>(
  const AKeySelector: TFunc<T, TKey>;
  const AValueSelector: TFunc<T, TValue>;
  const AComparer: IEqualityComparer<TKey>): TDictionary<TKey, TValue>;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.ToList: ILQColligoList<T>;
var
  LList: ILQColligoList<T>;
  LEnum: ILQColligoEnumerator<T>;
begin
  LList := TLQColligoList<T>.Create;
  LEnum := GetEnumerator;
  while LEnum.MoveNext do
    LList.Add(LEnum.Current);
  Result := LList;
end;

function ILQColligoEnumerable<T>.ToDictionary<TKey, TValue>(
  const AKeySelector: TFunc<T, TKey>;
  const AValueSelector: TFunc<T, TValue>): TDictionary<TKey, TValue>;
begin
  Result := ToDictionary<TKey, TValue>(AKeySelector, AValueSelector, nil);
end;

function ILQColligoEnumerable<T>.GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>): IGroupByEnumerable<TKey, T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  Result := TLQColligoGroupByEnumerable<TKey, T>.Create(FEnumerator, AKeySelector);
end;

function ILQColligoEnumerable<T>.GroupBy<TKey, TElement>(
  const AKeySelector: TFunc<T, TKey>;
  const AElementSelector: TFunc<T, TElement>): IGroupByEnumerable<TKey, TElement>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AElementSelector) then
    raise EArgumentNilException.Create('Element selector cannot be nil');
  Result := TLQColligoGroupByEnumerable<TKey, TElement, T>.Create(
    FEnumerator,
    AKeySelector,
    AElementSelector);
end;

function ILQColligoEnumerable<T>.GroupBy<TKey, TResult>(
  const AKeySelector: TFunc<T, TKey>;
  const AResultSelector: TFunc<TKey, ILQColligoEnumerableAdapter<T>, TResult>): ILQColligoEnumerable<TResult>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := ILQColligoEnumerable<TResult>.Create(
    TLQColligoGroupByResultEnumerable<TKey, T, TResult>.Create(
      FEnumerator, AKeySelector, AResultSelector),
    FLQColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function ILQColligoEnumerable<T>.GroupBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): IGroupByEnumerable<TKey, T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  Result := TLQColligoGroupByEnumerable<TKey, T>.Create(FEnumerator, AKeySelector, AComparer);
end;

function ILQColligoEnumerable<T>.GroupBy<TKey, TElement>(
  const AKeySelector: TFunc<T, TKey>;
  const AElementSelector: TFunc<T, TElement>;
  const AComparer: IEqualityComparer<TKey>): IGroupByEnumerable<TKey, TElement>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AElementSelector) then
    raise EArgumentNilException.Create('Element selector cannot be nil');
  Result := TLQColligoGroupByEnumerable<TKey, TElement, T>.Create(
    FEnumerator,
    AKeySelector,
    AElementSelector,
    AComparer);
end;

function ILQColligoEnumerable<T>.GroupBy<TKey, TResult>(
  const AKeySelector: TFunc<T, TKey>;
  const AResultSelector: TFunc<TKey, ILQColligoEnumerableAdapter<T>, TResult>;
  const AComparer: IEqualityComparer<TKey>): ILQColligoEnumerable<TResult>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := ILQColligoEnumerable<TResult>.Create(
    TLQColligoGroupByResultEnumerable<TKey, T, TResult>.Create(
      FEnumerator, AKeySelector, AResultSelector, AComparer),
    FLQColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function ILQColligoEnumerable<T>.Zip<TSecond, TResult>(const ASecond: ILQColligoEnumerable<TSecond>;
  const AResultSelector: TFunc<T, TSecond, TResult>): ILQColligoEnumerable<TResult>;
begin
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := ILQColligoEnumerable<TResult>.Create(
    TLQColligoZipEnumerable<T, TSecond, TResult>.Create(FEnumerator, ASecond.FEnumerator, AResultSelector),
    FLQColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function ILQColligoEnumerable<T>.OfType<TResult>: ILQColligoEnumerable<TResult>;
begin
  Result := ILQColligoEnumerable<TResult>.Create(
    TLQColligoOfTypeEnumerable<T, TResult>.Create(FEnumerator),
    FLQColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function ILQColligoEnumerable<T>.Exclude(const ASecond: ILQColligoEnumerable<T>): ILQColligoEnumerable<T>;
begin
  Result := Exclude(ASecond, FComparer);
end;

function ILQColligoEnumerable<T>.Exclude(const ASecond: ILQColligoEnumerable<T>;
  const AComparer: IEqualityComparer<T>): ILQColligoEnumerable<T>;
begin
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoExcludeEnumerable<T>.Create(FEnumerator, ASecond.FEnumerator, AComparer),
    FLQColligoType,
    AComparer
  );
end;

function ILQColligoEnumerable<T>.Intersect(const ASecond: ILQColligoEnumerable<T>): ILQColligoEnumerable<T>;
begin
  Result := Intersect(ASecond, FComparer);
end;

function ILQColligoEnumerable<T>.Intersect(const ASecond: ILQColligoEnumerable<T>;
  const AComparer: IEqualityComparer<T>): ILQColligoEnumerable<T>;
begin
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoIntersectEnumerable<T>.Create(FEnumerator, ASecond.FEnumerator, AComparer),
    FLQColligoType,
    AComparer
  );
end;

function ILQColligoEnumerable<T>.Union(const ASecond: ILQColligoEnumerable<T>): ILQColligoEnumerable<T>;
begin
  Result := Union(ASecond, FComparer);
end;

function ILQColligoEnumerable<T>.Union(const ASecond: ILQColligoEnumerable<T>;
  const AComparer: IEqualityComparer<T>): ILQColligoEnumerable<T>;
begin
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoUnionEnumerable<T>.Create(FEnumerator, ASecond.FEnumerator, AComparer),
    FLQColligoType,
    AComparer
  );
end;

function ILQColligoEnumerable<T>.Concat(const ASecond: ILQColligoEnumerable<T>): ILQColligoEnumerable<T>;
begin
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoConcatEnumerable<T>.Create(FEnumerator, ASecond.FEnumerator),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.SequenceEqual(const ASecond: ILQColligoEnumerable<T>): Boolean;
var
  LEnum1, LEnum2: ILQColligoEnumerator<T>;
begin
  LEnum1 := GetEnumerator;
  LEnum2 := ASecond.GetEnumerator;
  while LEnum1.MoveNext and LEnum2.MoveNext do
    if not FComparer.Equals(LEnum1.Current, LEnum2.Current) then
      Exit(False);
  Result := not (LEnum1.MoveNext or LEnum2.MoveNext);
end;

function ILQColligoEnumerable<T>.Single(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Single: T;
begin
  Result := Single(nil);
end;

function ILQColligoEnumerable<T>.SingleOrDefault(const APredicate: TFunc<T, Boolean>): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.SingleOrDefault: T;
begin
  Result := SingleOrDefault(nil);
end;

function ILQColligoEnumerable<T>.ElementAt(const AIndex: Integer): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.ElementAtOrDefault(const AIndex: Integer): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.DistinctBy<TKey>(const AKeySelector: TFunc<T, TKey>): ILQColligoEnumerable<T>;
begin
  Result := DistinctBy<TKey>(AKeySelector, nil);
end;

function ILQColligoEnumerable<T>.DistinctBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): ILQColligoEnumerable<T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  // Deferred/streaming: nothing is enumerated until the result is iterated.
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoDistinctByEnumerable<T, TKey>.Create(FEnumerator, AKeySelector, AComparer),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.Min(const AComparer: TFunc<T, T, Integer>): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Max(const AComparer: TFunc<T, T, Integer>): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.GroupJoin<TInner, TKey, TResult>(const AInner: ILQColligoEnumerable<TInner>;
  const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
  const AResultSelector: TFunc<T, ILQColligoEnumerableAdapter<TInner>, TResult>): ILQColligoEnumerable<TResult>;
begin
  if not Assigned(AOuterKeySelector) then
    raise EArgumentNilException.Create('Outer key selector cannot be nil');
  if not Assigned(AInnerKeySelector) then
    raise EArgumentNilException.Create('Inner key selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := ILQColligoEnumerable<TResult>.Create(
    TLQColligoGroupJoinEnumerable<T, TInner, TKey, TResult>.Create(FEnumerator, AInner.FEnumerator, AOuterKeySelector, AInnerKeySelector, AResultSelector),
    FLQColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function ILQColligoEnumerable<T>.Join<TInner, TKey, TResult>(const AInner: ILQColligoEnumerable<TInner>;
  const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
  const AResultSelector: TFunc<T, TInner, TResult>): ILQColligoEnumerable<TResult>;
begin
  Result := Join<TInner, TKey, TResult>(AInner, AOuterKeySelector, AInnerKeySelector,
    AResultSelector, nil);
end;

function ILQColligoEnumerable<T>.Join<TInner, TKey, TResult>(const AInner: ILQColligoEnumerable<TInner>;
  const AOuterKeySelector: TFunc<T, TKey>; const AInnerKeySelector: TFunc<TInner, TKey>;
  const AResultSelector: TFunc<T, TInner, TResult>;
  const AComparer: IEqualityComparer<TKey>): ILQColligoEnumerable<TResult>;
begin
  if not Assigned(AOuterKeySelector) then
    raise EArgumentNilException.Create('Outer key selector cannot be nil');
  if not Assigned(AInnerKeySelector) then
    raise EArgumentNilException.Create('Inner key selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := ILQColligoEnumerable<TResult>.Create(
    TLQColligoJoinEnumerable<T, TInner, TKey, TResult>.Create(FEnumerator, AInner.FEnumerator,
      AOuterKeySelector, AInnerKeySelector, AResultSelector, AComparer),
    FLQColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function ILQColligoEnumerable<T>.MinBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: TFunc<TKey, TKey, Integer>): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Max(const ASelector: TFunc<T, Single>): Single;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Max(const ASelector: TFunc<T, Int64>): Int64;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Max(const ASelector: TFunc<T, Int32>): Int32;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Max(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Max(const ASelector: TFunc<T, Currency>): Currency;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Max(const ASelector: TFunc<T, NullableSingle>): NullableSingle;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Max(const ASelector: TFunc<T, NullableInt64>): NullableInt64;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Max(const ASelector: TFunc<T, NullableInt32>): NullableInt32;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Max(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Max(const ASelector: TFunc<T, NullableDouble>): NullableDouble;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.MaxBy<TKey>(const AKeySelector: TFunc<T, TKey>;
  const AComparer: TFunc<TKey, TKey, Integer>): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>._IsEmpty: Boolean;
begin
  Result := not FIsValid;
end;

function ILQColligoEnumerable<T>.ToHashSet: THashSet<T>;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.ToLookup<TKey, TElement>(const AKeySelector: TFunc<T, TKey>;
  const AElementSelector: TFunc<T, TElement>): TDictionary<TKey, TList<TElement>>;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.TryGetNonEnumeratedCount(out ACount: Integer): Boolean;
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

function ILQColligoEnumerable<T>.ThenBy<TKey>(const AKeySelector: TFunc<T, TKey>): ILQColligoEnumerable<T>;
var
  LOrdered: ILQColligoOrderedEnumerable<T>;
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
  Result := ILQColligoEnumerable<T>.Create(LOrdered, FLQColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function ILQColligoEnumerable<T>.ThenByDescending<TKey>(const AKeySelector: TFunc<T, TKey>): ILQColligoEnumerable<T>;
var
  LOrdered: ILQColligoOrderedEnumerable<T>;
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
  Result := ILQColligoEnumerable<T>.Create(LOrdered, FLQColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function ILQColligoEnumerable<T>.UnionBy<TKey>(const ASecond: ILQColligoEnumerable<T>;
  const AKeySelector: TFunc<T, TKey>): ILQColligoEnumerable<T>;
begin
  Result := UnionBy<TKey>(ASecond, AKeySelector, nil);
end;

function ILQColligoEnumerable<T>.UnionBy<TKey>(const ASecond: ILQColligoEnumerable<T>;
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): ILQColligoEnumerable<T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  // Deferred/streaming: nothing is enumerated until the result is iterated.
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoUnionByEnumerable<T, TKey>.Create(FEnumerator, ASecond.FEnumerator, AKeySelector, AComparer),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.Append(const AElement: T): ILQColligoEnumerable<T>;
begin
  // Deferred/streaming: nothing is enumerated until the result is iterated.
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoAppendEnumerable<T>.Create(FEnumerator, AElement),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.Cast<TResult>: ILQColligoEnumerable<TResult>;
begin
  // Deferred/streaming: nothing is converted until enumeration; a non-matching
  // element raises EInvalidCast at the point it is reached (see LQColligo.Cast).
  Result := ILQColligoEnumerable<TResult>.Create(
    TLQColligoCastEnumerable<T, TResult>.Create(FEnumerator),
    FLQColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function ILQColligoEnumerable<T>.Chunk(const ASize: Integer): ILQColligoEnumerableBase<TArray<T>>;
begin
  if ASize < 1 then
    raise EArgumentOutOfRangeException.Create('Chunk size must be at least 1');
  // Deferred/streaming over the already-working chunk enumerable.
  Result := TLQColligoChunkEnumerable<T>.Create(FEnumerator, ASize);
end;

function ILQColligoEnumerable<T>.DefaultIfEmpty: ILQColligoEnumerable<T>;
begin
  Result := DefaultIfEmpty(Default(T));
end;

function ILQColligoEnumerable<T>.DefaultIfEmpty(const ADefaultValue: T): ILQColligoEnumerable<T>;
begin
  // Deferred/streaming: nothing is enumerated until the result is iterated.
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoDefaultIfEmptyEnumerable<T>.Create(FEnumerator, ADefaultValue),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.ExcludeBy<TKey>(const ASecond: ILQColligoEnumerable<TKey>;
  const AKeySelector: TFunc<T, TKey>): ILQColligoEnumerable<T>;
begin
  Result := ExcludeBy<TKey>(ASecond, AKeySelector, nil);
end;

function ILQColligoEnumerable<T>.ExcludeBy<TKey>(const ASecond: ILQColligoEnumerable<TKey>;
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): ILQColligoEnumerable<T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  // Deferred: the second (keys) is buffered when enumeration starts; the source
  // is streamed and yields DISTINCT non-excluded elements.
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoExcludeByEnumerable<T, TKey>.Create(FEnumerator, ASecond.FEnumerator, AKeySelector, AComparer),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.IntersectBy<TKey>(const ASecond: ILQColligoEnumerable<TKey>;
  const AKeySelector: TFunc<T, TKey>): ILQColligoEnumerable<T>;
begin
  Result := IntersectBy<TKey>(ASecond, AKeySelector, nil);
end;

function ILQColligoEnumerable<T>.IntersectBy<TKey>(const ASecond: ILQColligoEnumerable<TKey>;
  const AKeySelector: TFunc<T, TKey>;
  const AComparer: IEqualityComparer<TKey>): ILQColligoEnumerable<T>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  // Deferred: the second (keys) is buffered when enumeration starts; the source
  // is streamed and yields DISTINCT matching elements.
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoIntersectByEnumerable<T, TKey>.Create(FEnumerator, ASecond.FEnumerator, AKeySelector, AComparer),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.IsNotAssigned: Boolean;
begin
  Result := not TEqualityComparer<ILQColligoEnumerable<T>>.Default.Equals(Self, Default(ILQColligoEnumerable<T>));
end;

function ILQColligoEnumerable<T>.Prepend(const AElement: T): ILQColligoEnumerable<T>;
begin
  // Deferred/streaming: nothing is enumerated until the result is iterated.
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoPrependEnumerable<T>.Create(FEnumerator, AElement),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.Reverse: ILQColligoEnumerable<T>;
begin
  // Deferred, non-streaming: buffers only on the first MoveNext, not here.
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoReverseEnumerable<T>.Create(FEnumerator),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.SkipLast(const ACount: Integer): ILQColligoEnumerable<T>;
begin
  // Deferred, non-streaming: buffers only on the first MoveNext. ACount <= 0
  // yields the whole source (handled inside the enumerator).
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoSkipLastEnumerable<T>.Create(FEnumerator, ACount),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.SkipWhile(
  const APredicate: TFunc<T, Integer, Boolean>): ILQColligoEnumerable<T>;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate cannot be nil');
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoSkipWhileIndexedEnumerable<T>.Create(FEnumerator, APredicate),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.TakeLast(const ACount: Integer): ILQColligoEnumerable<T>;
begin
  // Deferred, non-streaming: buffers only on the first MoveNext. ACount <= 0
  // yields nothing (handled inside the enumerator).
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoTakeLastEnumerable<T>.Create(FEnumerator, ACount),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.TakeWhile(
  const APredicate: TFunc<T, Integer, Boolean>): ILQColligoEnumerable<T>;
begin
  if not Assigned(APredicate) then
    raise EArgumentNilException.Create('Predicate cannot be nil');
  Result := ILQColligoEnumerable<T>.Create(
    TLQColligoTakeWhileIndexedEnumerable<T>.Create(FEnumerator, APredicate),
    FLQColligoType,
    FComparer
  );
end;

function ILQColligoEnumerable<T>.Max<TResult>(const ASelector: TFunc<T, TResult>): TResult;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Max(const AComparer: IComparer<T>): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Min(const ASelector: TFunc<T, Single>): Single;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Min(const ASelector: TFunc<T, Int64>): Int64;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Min(const ASelector: TFunc<T, Int32>): Int32;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Min(const ASelector: TFunc<T, Double>): Double;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Min(const ASelector: TFunc<T, Currency>): Currency;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Min(const ASelector: TFunc<T, NullableSingle>): NullableSingle;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Min(const ASelector: TFunc<T, NullableInt64>): NullableInt64;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Min(const ASelector: TFunc<T, NullableInt32>): NullableInt32;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Min(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Min(const ASelector: TFunc<T, NullableDouble>): NullableDouble;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Min<TResult>(const ASelector: TFunc<T, TResult>): TResult;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.Min(const AComparer: IComparer<T>): T;
var
  LEnum: ILQColligoEnumerator<T>;
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

function ILQColligoEnumerable<T>.SelectMany<TCollection, TResult>(
  const ACollectionSelector: TFunc<T, Integer, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>): ILQColligoEnumerable<TResult>;
begin
  if not Assigned(ACollectionSelector) then
    raise EArgumentNilException.Create('Collection selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := ILQColligoEnumerable<TResult>.Create(
    TLQColligoSelectManyCollectionIndexedEnumerable<T, TCollection, TResult>.Create(
      FEnumerator, ACollectionSelector, AResultSelector),
    FLQColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function ILQColligoEnumerable<T>.SelectMany<TCollection, TResult>(
  const ACollectionSelector: TFunc<T, TArray<TCollection>>;
  const AResultSelector: TFunc<T, TCollection, TResult>): ILQColligoEnumerable<TResult>;
begin
  if not Assigned(ACollectionSelector) then
    raise EArgumentNilException.Create('Collection selector cannot be nil');
  if not Assigned(AResultSelector) then
    raise EArgumentNilException.Create('Result selector cannot be nil');
  Result := ILQColligoEnumerable<TResult>.Create(
    TLQColligoSelectManyCollectionEnumerable<T, TCollection, TResult>.Create(
      FEnumerator, ACollectionSelector, AResultSelector),
    FLQColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function ILQColligoEnumerable<T>.SelectMany<TResult>(
  const ASelector: TFunc<T, Integer, ILQColligoArray<TResult>>): ILQColligoEnumerable<TResult>;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  Result := ILQColligoEnumerable<TResult>.Create(
    TLQColligoSelectManyIndexedEnumerable<T, TResult>.Create(FEnumerator, ASelector),
    FLQColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function ILQColligoEnumerable<T>.SelectMany<TResult>(const ASelector: TFunc<T, TArray<TResult>>): ILQColligoEnumerable<TResult>;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  Result := ILQColligoEnumerable<TResult>.Create(
    TLQColligoSelectManyEnumerable<T, TResult>.Create(FEnumerator, ASelector),
    FLQColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function ILQColligoEnumerable<T>.Select<TResult>(
  const ASelector: TFunc<T, Integer, TResult>): ILQColligoEnumerable<TResult>;
begin
  if not Assigned(ASelector) then
    raise EArgumentNilException.Create('Selector cannot be nil');
  Result := ILQColligoEnumerable<TResult>.Create(
    TLQColligoSelectIndexedEnumerable<T, TResult>.Create(FEnumerator, ASelector),
    FLQColligoType,
    TEqualityComparer<TResult>.Default
  );
end;

function ILQColligoEnumerable<T>.Order(const AComparer: IComparer<T>): ILQColligoEnumerable<T>;
var
  LOrdered: ILQColligoOrderedEnumerable<T>;
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
  LOrdered := TLQColligoOrderByEnumerable<T>.Create(FEnumerator, LFunc);
  Result := ILQColligoEnumerable<T>.Create(LOrdered, FLQColligoType, FComparer);
  Result.FOrdered := LOrdered;
end;

function ILQColligoEnumerable<T>.Order: ILQColligoEnumerable<T>;
begin
  Result := Order(nil);
end;

function ILQColligoEnumerable<T>.Sum(const ASelector: TFunc<T, NullableCurrency>): NullableCurrency;
var
  LEnum: ILQColligoEnumerator<T>;
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

{ ILQColligoEnumerable<T>.TLQColligoCompare }

class function ILQColligoEnumerable<T>.TLQColligoCompare.Compare(
  const AEnumerator: ILQColligoEnumerableBase<T>; const AValue: T;
  const AComparer: IEqualityComparer<T>): Boolean;
var
  LEnum: ILQColligoEnumerator<T>;
begin
  LEnum := AEnumerator.GetEnumerator;
  while LEnum.MoveNext do
    if AComparer.Equals(LEnum.Current, AValue) then
      Exit(True);
  Result := False;
end;

{ TLQColligoGrouping<TKey, T> }

constructor TLQColligoGrouping<TKey, T>.Create(const AKey: TKey; const AItems: ILQColligoEnumerable<T>);
begin
  FKey := AKey;
  FItems := AItems;
end;

function TLQColligoGrouping<TKey, T>.GetKey: TKey;
begin
  Result := FKey;
end;

function TLQColligoGrouping<TKey, T>.GetItems: ILQColligoEnumerable<T>;
begin
  Result := FItems;
end;

{ TLQColligo }

class function TLQColligo.Range(const AStart, ACount: Integer): ILQColligoEnumerable<Integer>;
begin
  if ACount < 0 then
    raise EArgumentOutOfRangeException.Create('Count must be non-negative');
  // Int64 math so the overflow check itself cannot overflow.
  if Int64(AStart) + Int64(ACount) - 1 > High(Integer) then
    raise EArgumentOutOfRangeException.Create('Range end exceeds Integer range');
  Result := ILQColligoEnumerable<Integer>.Create(TLQColligoRangeEnumerable.Create(AStart, ACount));
end;

class function TLQColligo.&Repeat<T>(const AElement: T; const ACount: Integer): ILQColligoEnumerable<T>;
begin
  if ACount < 0 then
    raise EArgumentOutOfRangeException.Create('Count must be non-negative');
  Result := ILQColligoEnumerable<T>.Create(TLQColligoRepeatEnumerable<T>.Create(AElement, ACount));
end;

class function TLQColligo.Empty<T>: ILQColligoEnumerable<T>;
begin
  Result := ILQColligoEnumerable<T>.Create(TLQColligoEmptyEnumerable<T>.Create);
end;

end.


