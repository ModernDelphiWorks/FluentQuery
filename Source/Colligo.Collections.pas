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

unit Colligo.Collections;

interface

uses
  Types,
  TypInfo,
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  Colligo,
  Colligo.Core;

type
  TColligoArray<T> = class(TInterfacedObject, IColligoArray<T>)
  private
    FArray: TArray<T>;
    FOwnsArray: Boolean;
    function GetItem(AIndex: NativeInt): T;
    procedure SetItem(AIndex: NativeInt; const AValue: T);
    function GetEnumerable: IColligoEnumerable<T>;
    function _GetArray: TArray<T>;
  public
    constructor Create(const AArray: TArray<T>; AOwnsArray: Boolean = False);
    destructor Destroy; override;
    class function From(const AArray: TArray<T>): IColligoEnumerable<T>; overload; static;
    class function From(const AList: TList<T>): IColligoEnumerable<T>; overload; static;
    procedure SetItems(const AItems: TArray<T>);
    function AsEnumerable: IColligoEnumerable<T>;
    function GetEnumerator: IColligoEnumerator<T>;
    function Length: Integer;
  end;

  TColligoArray = record
  public
    class procedure FreeValues<T>(const AValues: array of T); overload; static;
    class procedure FreeValues<T>(var AValues: TArray<T>); overload; static;
    class procedure Sort<T>(var AValues: array of T); overload; static;
    class procedure Sort<T>(var AValues: array of T; const AComparer: IComparer<T>); overload; static;
    class procedure Sort<T>(var AValues: array of T; const AComparer: IComparer<T>; AIndex, Count: NativeInt); overload; static;
    class function From<T>(const AArray: array of T): IColligoEnumerable<T>; static;
    class function BinarySearch<T>(const AValues: array of T; const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>; AIndex, Count: NativeInt): Boolean; overload; static;
    class function BinarySearch<T>(const AValues: array of T; const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>): Boolean; overload; static;
    class function BinarySearch<T>(const AValues: array of T; const AItem: T; out FoundIndex: NativeInt): Boolean; overload; static;
    class procedure Copy<T>(const Source: array of T; var Destination: array of T; SourceIndex, DestIndex, Count: NativeInt); overload; static;
    class procedure Copy<T>(const Source: array of T; var Destination: array of T; Count: NativeInt); overload; static;
    class function Concat<T>(const Args: array of TArray<T>): IColligoArray<T>; static;
    class function IndexOf<T>(const AValues: array of T; const AItem: T): NativeInt; overload; static;
    class function IndexOf<T>(const AValues: array of T; const AItem: T; AIndex: NativeInt): NativeInt; overload; static;
    class function IndexOf<T>(const AValues: array of T; const AItem: T; const AComparer: IComparer<T>; AIndex, Count: NativeInt): NativeInt; overload; static;
    class function LastIndexOf<T>(const AValues: array of T; const AItem: T): NativeInt; overload; static;
    class function LastIndexOf<T>(const AValues: array of T; const AItem: T; AIndex: NativeInt): NativeInt; overload; static;
    class function LastIndexOf<T>(const AValues: array of T; const AItem: T; const AComparer: IComparer<T>; AIndex, Count: NativeInt): NativeInt; overload; static;
    class function Contains<T>(const AValues: array of T; const AItem: T): Boolean; overload; static;
    class function Contains<T>(const AValues: array of T; const AItem: T; const AComparer: IComparer<T>): Boolean; overload; static;
    class function ToString<T>(const AValues: array of T; const AFormatSettings: TFormatSettings; const ASeparator: string = ','; const ADelim1: string = ''; const ADelim2: string = ''): string; reintroduce; overload; static;
    class function ToString<T>(const AValues: array of T; const ASeparator: string = ','; const ADelim1: string = ''; const ADelim2: string = ''): string; reintroduce; overload; static;
  end;

  TColligoList<T> = class(TInterfacedObject, IColligoList<T>)
  private
    FList: TList<T>;
    FOwnsList: Boolean;
    FOwnerships: Boolean;
    FIsValueObject: Boolean;
    FOnNotify: TCollectionNotifyEvent<T>;
    function GetEnumerable: IColligoEnumerable<T>;
    function GetCapacity: NativeInt;
    procedure SetCapacity(const AValue: NativeInt);
    function GetItem(AIndex: NativeInt): T;
    procedure SetItem(AIndex: NativeInt; const AValue: T);
    function GetList: IColligoArray<T>;
    function GetComparer: IComparer<T>;
    procedure SetOnNotify(const AValue: TCollectionNotifyEvent<T>);
    function GetOnNotify: TCollectionNotifyEvent<T>;
    procedure _FreeItem(const AItem: T);
  public
    type
      TEmptyFunc = reference to function (const L, R: T): Boolean;
  public
    class function From(const AList: TList<T>): IColligoEnumerable<T>; overload; static;
    class function From(const AArray: TArray<T>): IColligoEnumerable<T>; overload; static;
    class procedure Error(const AMsg: string; Data: NativeInt); overload; virtual;
    {$IFNDEF NEXTGEN}
    class procedure Error(const AMsg: PResStringRec; const Data: NativeInt); overload;
    {$ENDIF}
    constructor Create(const AOwnerships: Boolean = False); overload;
    constructor Create(const AComparer: IComparer<T>; const AOwnerships: Boolean = False); overload;
    constructor Create(const ACollection: TEnumerable<T>; const AOwnerships: Boolean = False); overload;
    constructor Create(const ACollection: IEnumerable<T>; const AOwnerships: Boolean = False); overload;
    constructor Create(const AValues: array of T; const AOwnerships: Boolean = False); overload;
    constructor Create(const AList: TList<T>; const AOwnsList: Boolean = False; const AOwnerships: Boolean = False); overload;
    destructor Destroy; override;
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
    procedure Sort(const AComparer: IComparer<T>; AIndex, Count: NativeInt); overload;
    procedure TrimExcess;
    procedure Clear;
    procedure Add(const AValue: T);
    procedure CopyTo(AArray: array of T; AIndex: Integer);
    function Remove(const AValue: T): Boolean;
    function Contains(const AValue: T): Boolean;
    function Count: NativeInt;
    function RemoveItem(const AValue: T; Direction: TDirection): NativeInt;
    function ExtractItem(const AValue: T; Direction: TDirection): T;
    function Extract(const AValue: T): T;
    function ExtractAt(AIndex: NativeInt): T;
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
    function AsEnumerable: IColligoEnumerable<T>;
    function GetEnumerator: IColligoEnumerator<T>;
  end;

  TColligoDictionary<K, V> = class(TInterfacedObject, IColligoDictionary<K, V>)
  private
    FDict: TDictionary<K, V>;
    FOnKeyNotify: TCollectionNotifyEvent<K>;
    FOnValueNotify: TCollectionNotifyEvent<V>;
    function GetEnumerable: IColligoEnumerable<TPair<K, V>>;
    function GetCapacity: NativeInt;
    function GetItem(const AKey: K): V;
    function GetGrowThreshold: NativeInt;
    function GetCollisions: NativeInt;
    function GetKeys: TDictionary<K, V>.TKeyCollection;
    function GetValues: TDictionary<K, V>.TValueCollection;
    function GetComparer: IEqualityComparer<K>;
    function GetOnKeyNotify: TCollectionNotifyEvent<K>;
    function GetOnValueNotify: TCollectionNotifyEvent<V>;
    procedure SetCapacity(const AValue: NativeInt);
    procedure SetItem(const AKey: K; const AValue: V);
    procedure SetOnKeyNotify(const AValue: TCollectionNotifyEvent<K>);
    procedure SetOnValueNotify(const AValue: TCollectionNotifyEvent<V>);
  public
    constructor Create(const AOwnerships: TDictionaryOwnerships = []); overload;
    constructor Create(const ACapacity: NativeInt; const AOwnerships: TDictionaryOwnerships = []); overload;
    constructor Create(const AComparer: IEqualityComparer<K>; const AOwnerships: TDictionaryOwnerships = []); overload;
    constructor Create(const ACapacity: NativeInt; const AComparer: IEqualityComparer<K>; const AOwnerships: TDictionaryOwnerships = []); overload;
    constructor Create(const ACollection: TEnumerable<TPair<K, V>>); overload;
    constructor Create(const ACollection: TEnumerable<TPair<K, V>>; const AComparer: IEqualityComparer<K>; const AOwnerships: TDictionaryOwnerships = []); overload;
    constructor Create(const AItems: array of TPair<K, V>); overload;
    constructor Create(const AItems: array of TPair<K, V>; const AComparer: IEqualityComparer<K>); overload;
    destructor Destroy; override;
    procedure TrimExcess;
    procedure AddRange(const Dictionary: TDictionary<K, V>); overload;
    procedure AddRange(const AItems: TEnumerable<TPair<K, V>>); overload;
    procedure AddOrSetValue(const AKey: K; const AValue: V);
    procedure Clear;
    procedure Add(const AKey: K; const AValue: V); overload;
    procedure Add(const AItem: TPair<K, V>); overload;
    procedure CopyTo(AArray: array of TPair<K, V>; AIndex: Integer);
    function Remove(const AKey: K): Boolean; overload;
    function Remove(const AItem: TPair<K, V>): Boolean; overload;
    function Contains(const AValue: TPair<K, V>): Boolean;
    function Count: NativeInt;
    function ExtractPair(const AKey: K): TPair<K, V>;
    function TryGetValue(const AKey: K; var AValue: V): Boolean;
    function TryAdd(const AKey: K; const AValue: V): Boolean;
    function ContainsKey(const AKey: K): Boolean;
    function ContainsValue(const AValue: V): Boolean;
    function ToArray: IColligoArray<TPair<K, V>>;
    function IsEmpty: Boolean;
    function AsEnumerable: IColligoEnumerable<TPair<K, V>>;
    function GetEnumerator: IColligoEnumerator<TPair<K, V>>;
  end;

implementation

uses
  Colligo.Adapters;

{ TColligoArray<T> }

function TColligoArray<T>.AsEnumerable: IColligoEnumerable<T>;
begin
  Result := GetEnumerable;
end;

constructor TColligoArray<T>.Create(const AArray: TArray<T>; AOwnsArray: Boolean);
begin
  FArray := AArray;
  FOwnsArray := AOwnsArray;
end;

destructor TColligoArray<T>.Destroy;
begin
  if FOwnsArray then
    SetLength(FArray, 0);
  inherited;
end;

function TColligoArray<T>.GetEnumerable: IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(TArrayAdapter<T>.Create(FArray));
end;

function TColligoArray<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := AsEnumerable.GetEnumerator;
end;

function TColligoArray<T>.GetItem(AIndex: NativeInt): T;
begin
  Result := FArray[AIndex];
end;

function TColligoArray<T>.Length: Integer;
begin
  Result := System.Length(FArray);
end;

procedure TColligoArray<T>.SetItem(AIndex: NativeInt; const AValue: T);
begin
  FArray[AIndex] := AValue;
end;

procedure TColligoArray<T>.SetItems(const AItems: TArray<T>);
begin
  FArray := Copy(AItems, 0, System.Length(AItems));
end;

function TColligoArray<T>._GetArray: TArray<T>;
begin
  Result := FArray;
end;

class function TColligoArray<T>.From(const AArray: TArray<T>): IColligoEnumerable<T>;
var
  LWrapper: IColligoArray<T>;
begin
  // Hold the wrapper in an interface variable so ARC frees it. Without this the
  // TColligoArray instance is never assigned to an interface (refcount 0) and
  // leaks. GetEnumerable's adapter keeps its own copy of the data, so the
  // returned enumerable stays valid after the wrapper is released.
  LWrapper := TColligoArray<T>.Create(AArray);
  Result := LWrapper.AsEnumerable;
end;

class function TColligoArray<T>.From(const AList: TList<T>): IColligoEnumerable<T>;
var
  LArray: TArray<T>;
  LWrapper: IColligoArray<T>;
begin
  if AList = nil then
    raise EArgumentNilException.Create('AList cannot be nil');
  LArray := AList.ToArray;
  LWrapper := TColligoArray<T>.Create(LArray, True);
  Result := LWrapper.AsEnumerable;
end;

class function TColligoArray.From<T>(const AArray: array of T): IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(TNonGenericArrayAdapter<T>.Create(AArray));
end;

class procedure TColligoArray.Sort<T>(var AValues: array of T);
begin
  TArray.Sort<T>(AValues);
end;

class procedure TColligoArray.Sort<T>(var AValues: array of T; const AComparer: IComparer<T>);
begin
  TArray.Sort<T>(AValues, AComparer);
end;

class procedure TColligoArray.Sort<T>(var AValues: array of T; const AComparer: IComparer<T>; AIndex, Count: NativeInt);
begin
  TArray.Sort<T>(AValues, AComparer, AIndex, Count);
end;

class function TColligoArray.BinarySearch<T>(const AValues: array of T; const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>; AIndex, Count: NativeInt): Boolean;
begin
  Result := TArray.BinarySearch<T>(AValues, AItem, FoundIndex, AComparer, AIndex, Count);
end;

class function TColligoArray.BinarySearch<T>(const AValues: array of T; const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>): Boolean;
begin
  Result := TArray.BinarySearch<T>(AValues, AItem, FoundIndex, AComparer);
end;

class function TColligoArray.BinarySearch<T>(const AValues: array of T; const AItem: T; out FoundIndex: NativeInt): Boolean;
begin
  Result := TArray.BinarySearch<T>(AValues, AItem, FoundIndex);
end;

class procedure TColligoArray.Copy<T>(const Source: array of T; var Destination: array of T; SourceIndex, DestIndex, Count: NativeInt);
begin
  TArray.Copy<T>(Source, Destination, SourceIndex, DestIndex, Count);
end;

class procedure TColligoArray.Copy<T>(const Source: array of T; var Destination: array of T; Count: NativeInt);
begin
  TArray.Copy<T>(Source, Destination, Count);
end;

class function TColligoArray.Concat<T>(const Args: array of TArray<T>): IColligoArray<T>;
var
  LArray: TArray<T>;
begin
  LArray := TArray.Concat<T>(Args);
  Result := TColligoArray<T>.Create(LArray);
end;

class function TColligoArray.IndexOf<T>(const AValues: array of T; const AItem: T): NativeInt;
begin
  Result := TArray.IndexOf<T>(AValues, AItem);
end;

class function TColligoArray.IndexOf<T>(const AValues: array of T; const AItem: T; AIndex: NativeInt): NativeInt;
begin
  Result := TArray.IndexOf<T>(AValues, AItem, AIndex);
end;

class function TColligoArray.IndexOf<T>(const AValues: array of T; const AItem: T; const AComparer: IComparer<T>; AIndex, Count: NativeInt): NativeInt;
begin
  Result := TArray.IndexOf<T>(AValues, AItem, AComparer, AIndex, Count);
end;

class function TColligoArray.LastIndexOf<T>(const AValues: array of T; const AItem: T): NativeInt;
begin
  Result := TArray.LastIndexOf<T>(AValues, AItem);
end;

class function TColligoArray.LastIndexOf<T>(const AValues: array of T; const AItem: T; AIndex: NativeInt): NativeInt;
begin
  Result := TArray.LastIndexOf<T>(AValues, AItem, AIndex);
end;

class function TColligoArray.LastIndexOf<T>(const AValues: array of T; const AItem: T; const AComparer: IComparer<T>; AIndex, Count: NativeInt): NativeInt;
begin
  Result := TArray.LastIndexOf<T>(AValues, AItem, AComparer, AIndex, Count);
end;

class function TColligoArray.Contains<T>(const AValues: array of T; const AItem: T): Boolean;
begin
  Result := TArray.Contains<T>(AValues, AItem);
end;

class function TColligoArray.Contains<T>(const AValues: array of T; const AItem: T; const AComparer: IComparer<T>): Boolean;
begin
  Result := TArray.Contains<T>(AValues, AItem, AComparer);
end;

class procedure TColligoArray.FreeValues<T>(const AValues: array of T);
begin
  TArray.FreeValues<T>(AValues);
end;

class procedure TColligoArray.FreeValues<T>(var AValues: TArray<T>);
begin
  TArray.FreeValues<T>(AValues);
end;

class function TColligoArray.ToString<T>(const AValues: array of T; const AFormatSettings: TFormatSettings; const ASeparator: string = ','; const ADelim1: string = ''; const ADelim2: string = ''): string;
begin
  Result := TArray.ToString<T>(AValues, AFormatSettings, ASeparator, ADelim1, ADelim2);
end;

class function TColligoArray.ToString<T>(const AValues: array of T; const ASeparator: string = ','; const ADelim1: string = ''; const ADelim2: string = ''): string;
begin
  Result := TArray.ToString<T>(AValues, ASeparator, ADelim1, ADelim2);
end;

{ TColligoList<T> }

constructor TColligoList<T>.Create(const AOwnerships: Boolean);
begin
  FList := TList<T>.Create;
  FOwnsList := True;
  FOwnerships := AOwnerships;
  FIsValueObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
end;

constructor TColligoList<T>.Create(const AComparer: IComparer<T>; const AOwnerships: Boolean);
begin
  FList := TList<T>.Create(AComparer);
  FOwnsList := True;
  FOwnerships := AOwnerships;
  FIsValueObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
end;

constructor TColligoList<T>.Create(const ACollection: TEnumerable<T>; const AOwnerships: Boolean);
begin
  FList := TList<T>.Create(ACollection);
  FOwnsList := True;
  FOwnerships := AOwnerships;
  FIsValueObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
end;

constructor TColligoList<T>.Create(const ACollection: IEnumerable<T>; const AOwnerships: Boolean);
begin
  FList := TList<T>.Create(ACollection);
  FOwnsList := True;
  FOwnerships := AOwnerships;
  FIsValueObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
end;

constructor TColligoList<T>.Create(const AValues: array of T; const AOwnerships: Boolean);
begin
  FList := TList<T>.Create;
  FOwnsList := True;
  FOwnerships := AOwnerships;
  FIsValueObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
  AddRange(AValues);
end;

constructor TColligoList<T>.Create(const AList: TList<T>; const AOwnsList: Boolean; const AOwnerships: Boolean);
begin
  if AList = nil then
    raise EArgumentNilException.Create('AList cannot be nil');
  FList := AList;
  FOwnsList := AOwnsList;
  FOwnerships := AOwnerships;
  FIsValueObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
end;

destructor TColligoList<T>.Destroy;
var
  LValue: T;
begin
  if FOwnsList then
  begin
    if FOwnerships and FIsValueObject then
    begin
      for LValue in FList do
        _FreeItem(LValue);
    end;
    FList.Free;
  end;
  inherited;
end;

class procedure TColligoList<T>.Error(const AMsg: string; Data: NativeInt);
begin
  TList<T>.Error(AMsg, Data);
end;

{$IFNDEF NEXTGEN}
class procedure TColligoList<T>.Error(const AMsg: PResStringRec; const Data: NativeInt);
begin
  TList<T>.Error(AMsg, Data);
end;
{$ENDIF}

procedure TColligoList<T>.Add(const AValue: T);
begin
  FList.Add(AValue);
end;

procedure TColligoList<T>.AddRange(const AValues: array of T);
begin
  FList.AddRange(AValues);
end;

procedure TColligoList<T>.AddRange(const ACollection: IEnumerable<T>);
begin
  FList.AddRange(ACollection);
end;

procedure TColligoList<T>.AddRange(const ACollection: TEnumerable<T>);
begin
  FList.AddRange(ACollection);
end;

procedure TColligoList<T>.Insert(const AIndex: NativeInt; const AValue: T);
begin
  FList.Insert(AIndex, AValue);
end;

procedure TColligoList<T>.InsertRange(const AIndex: NativeInt; const AValues: array of T; ACount: NativeInt);
begin
  FList.InsertRange(AIndex, AValues, ACount);
end;

procedure TColligoList<T>.InsertRange(const AIndex: NativeInt; const AValues: array of T);
begin
  FList.InsertRange(AIndex, AValues);
end;

procedure TColligoList<T>.InsertRange(const AIndex: NativeInt; const ACollection: IEnumerable<T>);
begin
  FList.InsertRange(AIndex, ACollection);
end;

procedure TColligoList<T>.InsertRange(const AIndex: NativeInt; const ACollection: TEnumerable<T>);
begin
  FList.InsertRange(AIndex, ACollection);
end;

function TColligoList<T>.IsEmpty: Boolean;
begin
  Result := FList.IsEmpty;
end;

procedure TColligoList<T>.Pack;
begin
  FList.Pack;
end;

function TColligoList<T>.Remove(const AValue: T): Boolean;
var
  LIndex: NativeInt;
begin
  LIndex := FList.IndexOf(AValue);
  if LIndex >= 0 then
  begin
    _FreeItem(FList[LIndex]);
    FList.Delete(LIndex);
    Result := True;
  end
  else
    Result := False;
end;

function TColligoList<T>.RemoveItem(const AValue: T; Direction: TDirection): NativeInt;
var
  LIndex: NativeInt;
begin
  LIndex := FList.IndexOfItem(AValue, Direction);
  if LIndex >= 0 then
  begin
    _FreeItem(FList[LIndex]);
    FList.Delete(LIndex);
  end;
  Result := LIndex;
end;

procedure TColligoList<T>.Delete(const AIndex: NativeInt);
begin
  if (AIndex >= 0) and (AIndex < FList.Count) then
  begin
    _FreeItem(FList[AIndex]);
    FList.Delete(AIndex);
  end
  else
    raise EArgumentOutOfRangeException.Create('Index out of range');
end;

procedure TColligoList<T>.DeleteRange(const AIndex, ACount: NativeInt);
var
  LFor: NativeInt;
begin
  if FOwnerships and FIsValueObject then
  begin
    for LFor := AIndex to AIndex + ACount - 1 do
      _FreeItem(FList[LFor]);
  end;
  FList.DeleteRange(AIndex, ACount);
end;

function TColligoList<T>.ExtractItem(const AValue: T; Direction: TDirection): T;
begin
  Result := FList.ExtractItem(AValue, Direction);
end;

function TColligoList<T>.Extract(const AValue: T): T;
begin
  Result := FList.Extract(AValue);
end;

function TColligoList<T>.ExtractAt(AIndex: NativeInt): T;
begin
  Result := FList.ExtractAt(AIndex);
end;

procedure TColligoList<T>.Exchange(const AIndex1, AIndex2: NativeInt);
begin
  FList.Exchange(AIndex1, AIndex2);
end;

procedure TColligoList<T>.Move(const ACurIndex, ANewIndex: NativeInt);
begin
  FList.Move(ACurIndex, ANewIndex);
end;

function TColligoList<T>.First: T;
begin
  Result := FList.First;
end;

function TColligoList<T>.Last: T;
begin
  Result := FList.Last;
end;

procedure TColligoList<T>.Clear;
var
  LValue: T;
begin
  if FOwnerships and FIsValueObject then
  begin
    for LValue in FList do
      _FreeItem(LValue);
  end;
  FList.Clear;
end;

function TColligoList<T>.Expand: IColligoList<T>;
begin
  FList.Expand;
  Result := Self;
end;

function TColligoList<T>.Contains(const AValue: T): Boolean;
begin
  Result := FList.Contains(AValue);
end;

procedure TColligoList<T>.CopyTo(AArray: array of T; AIndex: Integer);
var
  LFor: Integer;
begin
  if Length(AArray) = 0 then
    raise EArgumentNilException.Create('Array cannot be empty');
  if (AIndex < 0) or (AIndex >= Length(AArray)) then
    raise EArgumentOutOfRangeException.Create('Index out of range');
  if AIndex + FList.Count > Length(AArray) then
    raise EArgumentException.Create('Array too small to accommodate all elements');

  for LFor := 0 to FList.Count - 1 do
    AArray[AIndex + LFor] := FList[LFor];
end;

function TColligoList<T>.Count: NativeInt;
begin
  Result := FList.Count;
end;

function TColligoList<T>.IndexOf(const AValue: T): NativeInt;
begin
  Result := FList.IndexOf(AValue);
end;

function TColligoList<T>.IndexOfItem(const AValue: T; Direction: TDirection): NativeInt;
begin
  Result := FList.IndexOfItem(AValue, Direction);
end;

function TColligoList<T>.LastIndexOf(const AValue: T): NativeInt;
begin
  Result := FList.LastIndexOf(AValue);
end;

procedure TColligoList<T>.Reverse;
begin
  FList.Reverse;
end;

procedure TColligoList<T>.Sort;
begin
  FList.Sort;
end;

procedure TColligoList<T>.Sort(const AComparer: IComparer<T>);
begin
  FList.Sort(AComparer);
end;

procedure TColligoList<T>.Sort(const AComparer: IComparer<T>; AIndex, Count: NativeInt);
begin
  FList.Sort(AComparer, AIndex, Count);
end;

function TColligoList<T>.BinarySearch(const AItem: T; out FoundIndex: NativeInt): Boolean;
begin
  Result := FList.BinarySearch(AItem, FoundIndex);
end;

function TColligoList<T>.BinarySearch(const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>): Boolean;
begin
  Result := FList.BinarySearch(AItem, FoundIndex, AComparer);
end;

function TColligoList<T>.BinarySearch(const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>; AIndex, Count: NativeInt): Boolean;
begin
  Result := FList.BinarySearch(AItem, FoundIndex, AComparer, AIndex, Count);
end;

procedure TColligoList<T>.TrimExcess;
begin
  FList.TrimExcess;
end;

procedure TColligoList<T>._FreeItem(const AItem: T);
var
  LPointer: Pointer;
begin
  if FOwnerships and FIsValueObject then
  begin
    LPointer := Pointer(@AItem);
    if Assigned(LPointer) then
      TObject(LPointer^).Free;
  end;
end;

function TColligoList<T>.ToArray: IColligoArray<T>;
var
  LArray: TArray<T>;
begin
  // Non-destructive, like LINQ's ToArray: copy the elements, leave the source
  // list intact so the same list can be queried again.
  LArray := Copy(FList.List, 0, FList.Count);
  Result := TColligoArray<T>.Create(LArray, True);
end;

function TColligoList<T>.AsEnumerable: IColligoEnumerable<T>;
begin
  Result := GetEnumerable;
end;

function TColligoList<T>.GetEnumerable: IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(
    TListAdapter<T>.Create(FList, False),
    ftList,
    TEqualityComparer<T>.Default
  );
end;

function TColligoList<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TListAdapterEnumerator<T>.Create(FList.GetEnumerator);
end;

class function TColligoList<T>.From(const AList: TList<T>): IColligoEnumerable<T>;
var
  LWrapper: IColligoList<T>;
begin
  // Hold the wrapper in an interface variable so ARC frees it (otherwise the
  // TColligoList instance leaks with refcount 0). It does not own AList
  // (AOwnsList=False), so releasing the wrapper leaves the caller's list — and
  // therefore the adapter that references it — valid.
  LWrapper := TColligoList<T>.Create(AList);
  Result := LWrapper.AsEnumerable;
end;

class function TColligoList<T>.From(const AArray: TArray<T>): IColligoEnumerable<T>;
begin
  Result := IColligoEnumerable<T>.Create(TArrayAdapter<T>.Create(AArray));
end;

function TColligoList<T>.GetCapacity: NativeInt;
begin
  Result := FList.Capacity;
end;

procedure TColligoList<T>.SetCapacity(const AValue: NativeInt);
begin
  FList.Capacity := AValue;
end;

function TColligoList<T>.GetItem(AIndex: NativeInt): T;
begin
  Result := FList.Items[AIndex];
end;

procedure TColligoList<T>.SetItem(AIndex: NativeInt; const AValue: T);
begin
  FList.Items[AIndex] := AValue;
end;

function TColligoList<T>.GetList: IColligoArray<T>;
var
  LArray: TArray<T>;
begin
  // Non-destructive snapshot of exactly Count elements. Previously this returned
  // the raw internal array (FList.List — including spare capacity) and then
  // Clear'd the list, so reading GetList emptied the list and could expose
  // uninitialised capacity slots.
  LArray := Copy(FList.List, 0, FList.Count);
  Result := TColligoArray<T>.Create(LArray, True);
end;

function TColligoList<T>.GetOnNotify: TCollectionNotifyEvent<T>;
begin
  Result := FOnNotify;
end;

function TColligoList<T>.GetComparer: IComparer<T>;
begin
  Result := FList.Comparer;
end;

procedure TColligoList<T>.SetOnNotify(const AValue: TCollectionNotifyEvent<T>);
begin
  FList.OnNotify := AValue;
end;

{ TColligoDictionary<K, V> }

constructor TColligoDictionary<K, V>.Create(const AOwnerships: TDictionaryOwnerships);
begin
  if AOwnerships = [] then
    FDict := TDictionary<K, V>.Create
  else
    FDict := TObjectDictionary<K, V>.Create(AOwnerships);
end;

constructor TColligoDictionary<K, V>.Create(const ACapacity: NativeInt;
  const AOwnerships: TDictionaryOwnerships);
begin
  if AOwnerships = [] then
    FDict := TDictionary<K, V>.Create(ACapacity)
  else
    FDict := TObjectDictionary<K, V>.Create(AOwnerships, ACapacity);
end;

constructor TColligoDictionary<K, V>.Create(const AComparer: IEqualityComparer<K>;
  const AOwnerships: TDictionaryOwnerships);
begin
  if AOwnerships = [] then
    FDict := TDictionary<K, V>.Create(AComparer)
  else
    FDict := TObjectDictionary<K, V>.Create(AOwnerships, AComparer);
end;

constructor TColligoDictionary<K, V>.Create(const ACapacity: NativeInt;
  const AComparer: IEqualityComparer<K>; const AOwnerships: TDictionaryOwnerships);
begin
  if AOwnerships = [] then
    FDict := TDictionary<K, V>.Create(ACapacity, AComparer)
  else
    FDict := TObjectDictionary<K, V>.Create(AOwnerships, ACapacity, AComparer);
end;

constructor TColligoDictionary<K, V>.Create(const ACollection: TEnumerable<TPair<K, V>>);
begin
  FDict := TDictionary<K, V>.Create(ACollection);
end;

constructor TColligoDictionary<K, V>.Create(const ACollection: TEnumerable<TPair<K, V>>;
  const AComparer: IEqualityComparer<K>; const AOwnerships: TDictionaryOwnerships);
begin
  if AOwnerships = [] then
    FDict := TDictionary<K, V>.Create(ACollection, AComparer)
  else
    FDict := TObjectDictionary<K, V>.Create(AOwnerships, AComparer);
end;

constructor TColligoDictionary<K, V>.Create(const AItems: array of TPair<K, V>);
begin
  FDict := TDictionary<K, V>.Create(AItems);
end;

constructor TColligoDictionary<K, V>.Create(const AItems: array of TPair<K, V>;
  const AComparer: IEqualityComparer<K>);
begin
  FDict := TDictionary<K, V>.Create(AItems, AComparer);
end;

destructor TColligoDictionary<K, V>.Destroy;
begin
  FDict.Free;
  inherited;
end;

procedure TColligoDictionary<K, V>.Add(const AKey: K; const AValue: V);
begin
  FDict.Add(AKey, AValue);
end;

function TColligoDictionary<K, V>.Remove(const AKey: K): Boolean;
begin
  Result := False;
  if not FDict.ContainsKey(AKey) then
    Exit;
  FDict.Remove(AKey);
  Result := True;
end;

function TColligoDictionary<K, V>.ExtractPair(const AKey: K): TPair<K, V>;
begin
  Result := TPair<K, V>.Create(Default(K), Default(V));
  if not FDict.ContainsKey(AKey) then
    Exit;
  Result := FDict.ExtractPair(AKey);
end;

procedure TColligoDictionary<K, V>.Clear;
begin
  FDict.Clear;
end;

procedure TColligoDictionary<K, V>.TrimExcess;
begin
  FDict.TrimExcess;
end;

function TColligoDictionary<K, V>.TryGetValue(const AKey: K; var AValue: V): Boolean;
begin
  Result := FDict.TryGetValue(AKey, AValue);
end;

procedure TColligoDictionary<K, V>.Add(const AItem: TPair<K, V>);
begin
  FDict.Add(Aitem.Key, Aitem.Value);
end;

procedure TColligoDictionary<K, V>.AddOrSetValue(const AKey: K; const AValue: V);
begin
  FDict.AddOrSetValue(AKey, AValue);
end;

procedure TColligoDictionary<K, V>.AddRange(const Dictionary: TDictionary<K, V>);
var
  LPair: TPair<K, V>;
begin
  for LPair in Dictionary do
    Add(LPair.Key, LPair.Value);
end;

procedure TColligoDictionary<K, V>.AddRange(const AItems: TEnumerable<TPair<K, V>>);
var
  LPair: TPair<K, V>;
begin
  for LPair in AItems do
    Add(LPair.Key, LPair.Value);
end;

function TColligoDictionary<K, V>.TryAdd(const AKey: K; const AValue: V): Boolean;
begin
  Result := FDict.TryAdd(AKey, AValue);
end;

function TColligoDictionary<K, V>.Contains(const AValue: TPair<K, V>): Boolean;
var
  LValue: V;
begin
  if FDict.ContainsKey(AValue.Key) then
  begin
    LValue := FDict[AValue.Key];
    Result := TEqualityComparer<V>.Default.Equals(LValue, AValue.Value);
  end
  else
    Result := False;
end;

function TColligoDictionary<K, V>.ContainsKey(const AKey: K): Boolean;
begin
  Result := FDict.ContainsKey(AKey);
end;

function TColligoDictionary<K, V>.ContainsValue(const AValue: V): Boolean;
begin
  Result := FDict.ContainsValue(AValue);
end;

procedure TColligoDictionary<K, V>.CopyTo(AArray: array of TPair<K, V>; AIndex: Integer);
var
  LArray: TArray<TPair<K, V>>;
  LFor: Integer;
begin
  if Length(AArray) = 0 then
    raise EArgumentNilException.Create('Array cannot be empty');
  if (AIndex < 0) or (AIndex >= Length(AArray)) then
    raise EArgumentOutOfRangeException.Create('Index out of range');
  if AIndex + FDict.Count > Length(AArray) then
    raise EArgumentException.Create('Array too small to accommodate all elements');

  LArray := FDict.ToArray;
  for LFor := 0 to FDict.Count - 1 do
    AArray[AIndex + LFor] := LArray[LFor];
end;

function TColligoDictionary<K, V>.ToArray: IColligoArray<TPair<K, V>>;
begin
  Result := TColligoArray<TPair<K, V>>.Create(FDict.ToArray);
end;

function TColligoDictionary<K, V>.AsEnumerable: IColligoEnumerable<TPair<K, V>>;
begin
  Result := GetEnumerable;
end;

function TColligoDictionary<K, V>.GetEnumerable: IColligoEnumerable<TPair<K, V>>;
begin
  Result := IColligoEnumerable<TPair<K, V>>.Create(
    TDictionaryAdapter<K, V>.Create(FDict),
    ftDictionary,
    TEqualityComparer<TPair<K, V>>.Construct(
      function(const Left, Right: TPair<K, V>): Boolean
      begin
        Result := (TComparer<K>.Default.Compare(Left.Key, Right.Key) = 0) and
                  (TComparer<V>.Default.Compare(Left.Value, Right.Value) = 0);
      end,
      function(const AValue: TPair<K, V>): Integer
      begin
        Result := TEqualityComparer<K>.Default.GetHashCode(AValue.Key) xor
                  TEqualityComparer<V>.Default.GetHashCode(AValue.Value);
      end)
  );
end;

function TColligoDictionary<K, V>.GetEnumerator: IColligoEnumerator<TPair<K, V>>;
begin
  Result := TDictionaryAdapterEnumerator<K, V>.Create(FDict.GetEnumerator);
end;

function TColligoDictionary<K, V>.GetCapacity: NativeInt;
begin
  Result := FDict.Capacity;
end;

procedure TColligoDictionary<K, V>.SetCapacity(const AValue: NativeInt);
begin
  FDict.Capacity := AValue;
end;

function TColligoDictionary<K, V>.GetItem(const AKey: K): V;
begin
  Result := FDict.Items[AKey];
end;

procedure TColligoDictionary<K, V>.SetItem(const AKey: K; const AValue: V);
begin
  FDict.Items[AKey] := AValue;
end;

function TColligoDictionary<K, V>.Count: NativeInt;
begin
  Result := FDict.Count;
end;

function TColligoDictionary<K, V>.IsEmpty: Boolean;
begin
  Result := FDict.IsEmpty;
end;

function TColligoDictionary<K, V>.Remove(const AItem: TPair<K, V>): Boolean;
var
  LValue: V;
begin
  Result := False;
  if FDict.ContainsKey(AItem.Key) then
  begin
    LValue := FDict[AItem.Key];
    if TEqualityComparer<V>.Default.Equals(LValue, AItem.Value) then
    begin
      FDict.Remove(AItem.Key);
      Result := True;
    end;
  end;
end;

function TColligoDictionary<K, V>.GetGrowThreshold: NativeInt;
begin
  Result := FDict.GrowThreshold;
end;

function TColligoDictionary<K, V>.GetCollisions: NativeInt;
begin
  Result := FDict.Collisions;
end;

function TColligoDictionary<K, V>.GetKeys: TDictionary<K, V>.TKeyCollection;
begin
  Result := FDict.Keys;
end;

function TColligoDictionary<K, V>.GetOnKeyNotify: TCollectionNotifyEvent<K>;
begin
  Result := FOnKeyNotify;
end;

function TColligoDictionary<K, V>.GetOnValueNotify: TCollectionNotifyEvent<V>;
begin
  Result := FOnValueNotify;
end;

function TColligoDictionary<K, V>.GetValues: TDictionary<K, V>.TValueCollection;
begin
  Result := FDict.Values;
end;

function TColligoDictionary<K, V>.GetComparer: IEqualityComparer<K>;
begin
  Result := FDict.Comparer;
end;

procedure TColligoDictionary<K, V>.SetOnKeyNotify(const AValue: TCollectionNotifyEvent<K>);
begin
  FDict.OnKeyNotify := AValue;
end;

procedure TColligoDictionary<K, V>.SetOnValueNotify(const AValue: TCollectionNotifyEvent<V>);
begin
  FDict.OnValueNotify := AValue;
end;

end.



