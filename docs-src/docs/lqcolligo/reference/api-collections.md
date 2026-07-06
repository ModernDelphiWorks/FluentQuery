---
title: Collections API
sidebar_position: 3
---

# Collections API — TLQColligoList, TLQColligoArray, TFluentDictionary

LQ-Colligo ships three concrete collection classes in `LQColligo.Collections` that implement their interface counterparts and integrate natively with `ILQColligoEnumerable<T>`.

## TLQColligoList&lt;T&gt;

Implements `IFluentList<T>`. Wraps a `TList<T>` and optionally owns it.

### Constructors

```delphi
constructor Create(const AOwnerships: Boolean = False); overload;
constructor Create(const AComparer: IComparer<T>; const AOwnerships: Boolean = False); overload;
constructor Create(const ACollection: TEnumerable<T>; ...); overload;
constructor Create(const ACollection: IEnumerable<T>; ...); overload;
constructor Create(const AValues: array of T; ...); overload;
constructor Create(const AList: TList<T>; const AOwnsList: Boolean = False; ...); overload;
```

When `AOwnerships = True` and `T` is a class, `TLQColligoList<T>` frees owned objects on removal/destruction.

### Key methods

```delphi
procedure Add(const AValue: T);
procedure AddRange(const AValues: array of T); overload;
procedure AddRange(const ACollection: IEnumerable<T>); overload;
procedure Insert(const AIndex: NativeInt; const AValue: T);
procedure Delete(const AIndex: NativeInt);
procedure DeleteRange(const AIndex, ACount: NativeInt);
procedure Sort; overload;
procedure Sort(const AComparer: IComparer<T>); overload;
function Remove(const AValue: T): Boolean;
function Extract(const AValue: T): T;
function BinarySearch(const AItem: T; out FoundIndex: NativeInt): Boolean;
function IndexOf(const AValue: T): NativeInt;
function Count: NativeInt;
function IsEmpty: Boolean;
function AsEnumerable: ILQColligoEnumerable<T>;
function ToArray: IFluentArray<T>;
```

### Factory class methods

```delphi
class function From(const AList: TList<T>): ILQColligoEnumerable<T>;
class function From(const AArray: TArray<T>): ILQColligoEnumerable<T>;
```

## TLQColligoArray&lt;T&gt;

Implements `IFluentArray<T>`. Wraps a `TArray<T>`.

### Key members

```delphi
constructor Create(const AArray: TArray<T>; AOwnsArray: Boolean = False);
function Length: Integer;
function AsEnumerable: ILQColligoEnumerable<T>;
function GetEnumerator: IFluentEnumerator<T>;
property Items[AIndex: NativeInt]: T read GetItem write SetItem; default;
property ArrayData: TArray<T> read _GetArray;
```

### Factory class methods

```delphi
class function From(const AArray: TArray<T>): ILQColligoEnumerable<T>; overload;
class function From(const AList: TList<T>): ILQColligoEnumerable<T>; overload;
```

## TLQColligoArray (non-generic utility record)

Static utility methods mirroring `System.Generics.Collections.TArray`:

```delphi
class procedure Sort<T>(var AValues: array of T [, AComparer, AIndex, Count]);
class function BinarySearch<T>(const AValues: array of T; const AItem: T; out FoundIndex: NativeInt [, ...]): Boolean;
class procedure Copy<T>(const Source: array of T; var Destination: array of T; ...);
class function Concat<T>(const Args: array of TArray<T>): IFluentArray<T>;
class function IndexOf<T>(const AValues: array of T; const AItem: T [, ...]): NativeInt;
class function LastIndexOf<T>(...): NativeInt;
class function Contains<T>(const AValues: array of T; const AItem: T [, AComparer]): Boolean;
class function ToString<T>(const AValues: array of T; const ASeparator: string = ','): string;
class procedure FreeValues<T>(const AValues: array of T);
class function From<T>(const AArray: array of T): ILQColligoEnumerable<T>;
```

## TFluentDictionary&lt;K, V&gt;

Implements `IFluentDictionary<K, V>`. Wraps `TDictionary<K, V>` (or `TObjectDictionary` when ownerships are specified).

### Constructors

```delphi
constructor Create(const AOwnerships: TDictionaryOwnerships = []);
constructor Create(const ACapacity: NativeInt; ...);
constructor Create(const AComparer: IEqualityComparer<K>; ...);
constructor Create(const ACollection: TEnumerable<TPair<K, V>>);
constructor Create(const AItems: array of TPair<K, V> [, AComparer]);
```

### Key methods

```delphi
procedure Add(const AKey: K; const AValue: V);
procedure AddOrSetValue(const AKey: K; const AValue: V);
function Remove(const AKey: K): Boolean;
function TryGetValue(const AKey: K; var AValue: V): Boolean;
function TryAdd(const AKey: K; const AValue: V): Boolean;
function ContainsKey(const AKey: K): Boolean;
function ContainsValue(const AValue: V): Boolean;
function Count: NativeInt;
function IsEmpty: Boolean;
function AsEnumerable: ILQColligoEnumerable<TPair<K, V>>;
function ToArray: IFluentArray<TPair<K, V>>;
property Items[const AKey: K]: V read GetItem write SetItem; default;
property Keys: TDictionary<K, V>.TKeyCollection;
property Values: TDictionary<K, V>.TValueCollection;
```

### Iterating a dictionary as a pipeline

```delphi
var LDict: IFluentDictionary<string, Integer>;
// ...

var LResult := LDict.AsEnumerable
  .Where(function(const P: TPair<string, Integer>): Boolean
    begin Result := P.Value > 10 end)
  .Select<string>(function(const P: TPair<string, Integer>): string
    begin Result := P.Key end)
  .ToArray;
```
