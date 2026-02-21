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

unit Fluent.Collections;

interface

uses
  Types,
  TypInfo,
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  Fluent,
  Fluent.Core;

type
  TFluentArray<T> = class(TInterfacedObject, IFluentArray<T>)
  private
    FArray: TArray<T>;
    FOwnsArray: Boolean;
    function GetItem(AIndex: NativeInt): T;
    procedure SetItem(AIndex: NativeInt; const AValue: T);
    function GetEnumerable: IFluentEnumerable<T>;
    function _GetArray: TArray<T>;
  public
    constructor Create(const AArray: TArray<T>; AOwnsArray: Boolean = False);
    destructor Destroy; override;
    class function From(const AArray: TArray<T>): IFluentEnumerable<T>; overload; static;
    class function From(const AList: TList<T>): IFluentEnumerable<T>; overload; static;
    procedure SetItems(const AItems: TArray<T>);
    function AsEnumerable: IFluentEnumerable<T>;
    function GetEnumerator: IFluentEnumerator<T>;
    function Length: Integer;
  end;

  TFluentArray = record
  public
    class procedure FreeValues<T>(const AValues: array of T); overload; static;
    class procedure FreeValues<T>(var AValues: TArray<T>); overload; static;
    class procedure Sort<T>(var AValues: array of T); overload; static;
    class procedure Sort<T>(var AValues: array of T; const AComparer: IComparer<T>); overload; static;
    class procedure Sort<T>(var AValues: array of T; const AComparer: IComparer<T>; AIndex, Count: NativeInt); overload; static;
    class function From<T>(const AArray: array of T): IFluentEnumerable<T>; static;
    class function BinarySearch<T>(const AValues: array of T; const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>; AIndex, Count: NativeInt): Boolean; overload; static;
    class function BinarySearch<T>(const AValues: array of T; const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>): Boolean; overload; static;
    class function BinarySearch<T>(const AValues: array of T; const AItem: T; out FoundIndex: NativeInt): Boolean; overload; static;
    class procedure Copy<T>(const Source: array of T; var Destination: array of T; SourceIndex, DestIndex, Count: NativeInt); overload; static;
    class procedure Copy<T>(const Source: array of T; var Destination: array of T; Count: NativeInt); overload; static;
    class function Concat<T>(const Args: array of TArray<T>): IFluentArray<T>; static;
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

  TFluentList<T> = class(TInterfacedObject, IFluentList<T>)
  private
    FList: TList<T>;
    FOwnsList: Boolean;
    FOwnerships: Boolean;
    FIsValueObject: Boolean;
    FOnNotify: TCollectionNotifyEvent<T>;
    function GetEnumerable: IFluentEnumerable<T>;
    function GetCapacity: NativeInt;
    procedure SetCapacity(const AValue: NativeInt);
    function GetItem(AIndex: NativeInt): T;
    procedure SetItem(AIndex: NativeInt; const AValue: T);
    function GetList: IFluentArray<T>;
    function GetComparer: IComparer<T>;
    procedure SetOnNotify(const AValue: TCollectionNotifyEvent<T>);
    function GetOnNotify: TCollectionNotifyEvent<T>;
    procedure _FreeItem(const AItem: T);
  public
    type
      TEmptyFunc = reference to function (const L, R: T): Boolean;
  public
    class function From(const AList: TList<T>): IFluentEnumerable<T>; overload; static;
    class function From(const AArray: TArray<T>): IFluentEnumerable<T>; overload; static;
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
    function Expand: IFluentList<T>;
    function IndexOf(const AValue: T): NativeInt;
    function IndexOfItem(const AValue: T; Direction: TDirection): NativeInt;
    function LastIndexOf(const AValue: T): NativeInt;
    function BinarySearch(const AItem: T; out FoundIndex: NativeInt): Boolean; overload;
    function BinarySearch(const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>): Boolean; overload;
    function BinarySearch(const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>; AIndex, Count: NativeInt): Boolean; overload;
    function IsEmpty: Boolean;
    function ToArray: IFluentArray<T>;
    function AsEnumerable: IFluentEnumerable<T>;
    function GetEnumerator: IFluentEnumerator<T>;
  end;

  TFluentDictionary<K, V> = class(TInterfacedObject, IFluentDictionary<K, V>)
  private
    FDict: TDictionary<K, V>;
    FOnKeyNotify: TCollectionNotifyEvent<K>;
    FOnValueNotify: TCollectionNotifyEvent<V>;
    function GetEnumerable: IFluentEnumerable<TPair<K, V>>;
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
    function ToArray: IFluentArray<TPair<K, V>>;
    function IsEmpty: Boolean;
    function AsEnumerable: IFluentEnumerable<TPair<K, V>>;
    function GetEnumerator: IFluentEnumerator<TPair<K, V>>;
  end;

implementation

uses
  Fluent.Adapters;

{ TFluentArray<T> }

function TFluentArray<T>.AsEnumerable: IFluentEnumerable<T>;
begin
  Result := GetEnumerable;
end;

constructor TFluentArray<T>.Create(const AArray: TArray<T>; AOwnsArray: Boolean);
begin
  FArray := AArray;
  FOwnsArray := AOwnsArray;
end;

destructor TFluentArray<T>.Destroy;
begin
  if FOwnsArray then
    SetLength(FArray, 0);
  inherited;
end;

function TFluentArray<T>.GetEnumerable: IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(TArrayAdapter<T>.Create(FArray));
end;

function TFluentArray<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := AsEnumerable.GetEnumerator;
end;

function TFluentArray<T>.GetItem(AIndex: NativeInt): T;
begin
  Result := FArray[AIndex];
end;

function TFluentArray<T>.Length: Integer;
begin
  Result := System.Length(FArray);
end;

procedure TFluentArray<T>.SetItem(AIndex: NativeInt; const AValue: T);
begin
  FArray[AIndex] := AValue;
end;

procedure TFluentArray<T>.SetItems(const AItems: TArray<T>);
begin
  FArray := Copy(AItems, 0, System.Length(AItems));
end;

function TFluentArray<T>._GetArray: TArray<T>;
begin
  Result := FArray;
end;

class function TFluentArray<T>.From(const AArray: TArray<T>): IFluentEnumerable<T>;
begin
  Result := TFluentArray<T>.Create(AArray).GetEnumerable;
end;

class function TFluentArray<T>.From(const AList: TList<T>): IFluentEnumerable<T>;
var
  LArray: TArray<T>;
begin
  if AList = nil then
    raise EArgumentNilException.Create('AList cannot be nil');
  LArray := AList.ToArray;
  Result := TFluentArray<T>.Create(LArray, True).GetEnumerable;
end;

class function TFluentArray.From<T>(const AArray: array of T): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(TNonGenericArrayAdapter<T>.Create(AArray));
end;

class procedure TFluentArray.Sort<T>(var AValues: array of T);
begin
  TArray.Sort<T>(AValues);
end;

class procedure TFluentArray.Sort<T>(var AValues: array of T; const AComparer: IComparer<T>);
begin
  TArray.Sort<T>(AValues, AComparer);
end;

class procedure TFluentArray.Sort<T>(var AValues: array of T; const AComparer: IComparer<T>; AIndex, Count: NativeInt);
begin
  TArray.Sort<T>(AValues, AComparer, AIndex, Count);
end;

class function TFluentArray.BinarySearch<T>(const AValues: array of T; const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>; AIndex, Count: NativeInt): Boolean;
begin
  Result := TArray.BinarySearch<T>(AValues, AItem, FoundIndex, AComparer, AIndex, Count);
end;

class function TFluentArray.BinarySearch<T>(const AValues: array of T; const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>): Boolean;
begin
  Result := TArray.BinarySearch<T>(AValues, AItem, FoundIndex, AComparer);
end;

class function TFluentArray.BinarySearch<T>(const AValues: array of T; const AItem: T; out FoundIndex: NativeInt): Boolean;
begin
  Result := TArray.BinarySearch<T>(AValues, AItem, FoundIndex);
end;

class procedure TFluentArray.Copy<T>(const Source: array of T; var Destination: array of T; SourceIndex, DestIndex, Count: NativeInt);
begin
  TArray.Copy<T>(Source, Destination, SourceIndex, DestIndex, Count);
end;

class procedure TFluentArray.Copy<T>(const Source: array of T; var Destination: array of T; Count: NativeInt);
begin
  TArray.Copy<T>(Source, Destination, Count);
end;

class function TFluentArray.Concat<T>(const Args: array of TArray<T>): IFluentArray<T>;
var
  LArray: TArray<T>;
begin
  LArray := TArray.Concat<T>(Args);
  Result := TFluentArray<T>.Create(LArray);
end;

class function TFluentArray.IndexOf<T>(const AValues: array of T; const AItem: T): NativeInt;
begin
  Result := TArray.IndexOf<T>(AValues, AItem);
end;

class function TFluentArray.IndexOf<T>(const AValues: array of T; const AItem: T; AIndex: NativeInt): NativeInt;
begin
  Result := TArray.IndexOf<T>(AValues, AItem, AIndex);
end;

class function TFluentArray.IndexOf<T>(const AValues: array of T; const AItem: T; const AComparer: IComparer<T>; AIndex, Count: NativeInt): NativeInt;
begin
  Result := TArray.IndexOf<T>(AValues, AItem, AComparer, AIndex, Count);
end;

class function TFluentArray.LastIndexOf<T>(const AValues: array of T; const AItem: T): NativeInt;
begin
  Result := TArray.LastIndexOf<T>(AValues, AItem);
end;

class function TFluentArray.LastIndexOf<T>(const AValues: array of T; const AItem: T; AIndex: NativeInt): NativeInt;
begin
  Result := TArray.LastIndexOf<T>(AValues, AItem, AIndex);
end;

class function TFluentArray.LastIndexOf<T>(const AValues: array of T; const AItem: T; const AComparer: IComparer<T>; AIndex, Count: NativeInt): NativeInt;
begin
  Result := TArray.LastIndexOf<T>(AValues, AItem, AComparer, AIndex, Count);
end;

class function TFluentArray.Contains<T>(const AValues: array of T; const AItem: T): Boolean;
begin
  Result := TArray.Contains<T>(AValues, AItem);
end;

class function TFluentArray.Contains<T>(const AValues: array of T; const AItem: T; const AComparer: IComparer<T>): Boolean;
begin
  Result := TArray.Contains<T>(AValues, AItem, AComparer);
end;

class procedure TFluentArray.FreeValues<T>(const AValues: array of T);
begin
  TArray.FreeValues<T>(AValues);
end;

class procedure TFluentArray.FreeValues<T>(var AValues: TArray<T>);
begin
  TArray.FreeValues<T>(AValues);
end;

class function TFluentArray.ToString<T>(const AValues: array of T; const AFormatSettings: TFormatSettings; const ASeparator: string = ','; const ADelim1: string = ''; const ADelim2: string = ''): string;
begin
  Result := TArray.ToString<T>(AValues, AFormatSettings, ASeparator, ADelim1, ADelim2);
end;

class function TFluentArray.ToString<T>(const AValues: array of T; const ASeparator: string = ','; const ADelim1: string = ''; const ADelim2: string = ''): string;
begin
  Result := TArray.ToString<T>(AValues, ASeparator, ADelim1, ADelim2);
end;

{ TFluentList<T> }

constructor TFluentList<T>.Create(const AOwnerships: Boolean);
begin
  FList := TList<T>.Create;
  FOwnsList := True;
  FOwnerships := AOwnerships;
  FIsValueObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
end;

constructor TFluentList<T>.Create(const AComparer: IComparer<T>; const AOwnerships: Boolean);
begin
  FList := TList<T>.Create(AComparer);
  FOwnsList := True;
  FOwnerships := AOwnerships;
  FIsValueObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
end;

constructor TFluentList<T>.Create(const ACollection: TEnumerable<T>; const AOwnerships: Boolean);
begin
  FList := TList<T>.Create(ACollection);
  FOwnsList := True;
  FOwnerships := AOwnerships;
  FIsValueObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
end;

constructor TFluentList<T>.Create(const ACollection: IEnumerable<T>; const AOwnerships: Boolean);
begin
  FList := TList<T>.Create(ACollection);
  FOwnsList := True;
  FOwnerships := AOwnerships;
  FIsValueObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
end;

constructor TFluentList<T>.Create(const AValues: array of T; const AOwnerships: Boolean);
begin
  FList := TList<T>.Create;
  FOwnsList := True;
  FOwnerships := AOwnerships;
  FIsValueObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
  AddRange(AValues);
end;

constructor TFluentList<T>.Create(const AList: TList<T>; const AOwnsList: Boolean; const AOwnerships: Boolean);
begin
  if AList = nil then
    raise EArgumentNilException.Create('AList cannot be nil');
  FList := AList;
  FOwnsList := AOwnsList;
  FOwnerships := AOwnerships;
  FIsValueObject := PTypeInfo(TypeInfo(T))^.Kind = tkClass;
end;

destructor TFluentList<T>.Destroy;
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

class procedure TFluentList<T>.Error(const AMsg: string; Data: NativeInt);
begin
  TList<T>.Error(AMsg, Data);
end;

{$IFNDEF NEXTGEN}
class procedure TFluentList<T>.Error(const AMsg: PResStringRec; const Data: NativeInt);
begin
  TList<T>.Error(AMsg, Data);
end;
{$ENDIF}

procedure TFluentList<T>.Add(const AValue: T);
begin
  FList.Add(AValue);
end;

procedure TFluentList<T>.AddRange(const AValues: array of T);
begin
  FList.AddRange(AValues);
end;

procedure TFluentList<T>.AddRange(const ACollection: IEnumerable<T>);
begin
  FList.AddRange(ACollection);
end;

procedure TFluentList<T>.AddRange(const ACollection: TEnumerable<T>);
begin
  FList.AddRange(ACollection);
end;

procedure TFluentList<T>.Insert(const AIndex: NativeInt; const AValue: T);
begin
  FList.Insert(AIndex, AValue);
end;

procedure TFluentList<T>.InsertRange(const AIndex: NativeInt; const AValues: array of T; ACount: NativeInt);
begin
  FList.InsertRange(AIndex, AValues, ACount);
end;

procedure TFluentList<T>.InsertRange(const AIndex: NativeInt; const AValues: array of T);
begin
  FList.InsertRange(AIndex, AValues);
end;

procedure TFluentList<T>.InsertRange(const AIndex: NativeInt; const ACollection: IEnumerable<T>);
begin
  FList.InsertRange(AIndex, ACollection);
end;

procedure TFluentList<T>.InsertRange(const AIndex: NativeInt; const ACollection: TEnumerable<T>);
begin
  FList.InsertRange(AIndex, ACollection);
end;

function TFluentList<T>.IsEmpty: Boolean;
begin
  Result := FList.IsEmpty;
end;

procedure TFluentList<T>.Pack;
begin
  FList.Pack;
end;

function TFluentList<T>.Remove(const AValue: T): Boolean;
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

function TFluentList<T>.RemoveItem(const AValue: T; Direction: TDirection): NativeInt;
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

procedure TFluentList<T>.Delete(const AIndex: NativeInt);
begin
  if (AIndex >= 0) and (AIndex < FList.Count) then
  begin
    _FreeItem(FList[AIndex]);
    FList.Delete(AIndex);
  end
  else
    raise EArgumentOutOfRangeException.Create('Index out of range');
end;

procedure TFluentList<T>.DeleteRange(const AIndex, ACount: NativeInt);
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

function TFluentList<T>.ExtractItem(const AValue: T; Direction: TDirection): T;
begin
  Result := FList.ExtractItem(AValue, Direction);
end;

function TFluentList<T>.Extract(const AValue: T): T;
begin
  Result := FList.Extract(AValue);
end;

function TFluentList<T>.ExtractAt(AIndex: NativeInt): T;
begin
  Result := FList.ExtractAt(AIndex);
end;

procedure TFluentList<T>.Exchange(const AIndex1, AIndex2: NativeInt);
begin
  FList.Exchange(AIndex1, AIndex2);
end;

procedure TFluentList<T>.Move(const ACurIndex, ANewIndex: NativeInt);
begin
  FList.Move(ACurIndex, ANewIndex);
end;

function TFluentList<T>.First: T;
begin
  Result := FList.First;
end;

function TFluentList<T>.Last: T;
begin
  Result := FList.Last;
end;

procedure TFluentList<T>.Clear;
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

function TFluentList<T>.Expand: IFluentList<T>;
begin
  FList.Expand;
  Result := Self;
end;

function TFluentList<T>.Contains(const AValue: T): Boolean;
begin
  Result := FList.Contains(AValue);
end;

procedure TFluentList<T>.CopyTo(AArray: array of T; AIndex: Integer);
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

function TFluentList<T>.Count: NativeInt;
begin
  Result := FList.Count;
end;

function TFluentList<T>.IndexOf(const AValue: T): NativeInt;
begin
  Result := FList.IndexOf(AValue);
end;

function TFluentList<T>.IndexOfItem(const AValue: T; Direction: TDirection): NativeInt;
begin
  Result := FList.IndexOfItem(AValue, Direction);
end;

function TFluentList<T>.LastIndexOf(const AValue: T): NativeInt;
begin
  Result := FList.LastIndexOf(AValue);
end;

procedure TFluentList<T>.Reverse;
begin
  FList.Reverse;
end;

procedure TFluentList<T>.Sort;
begin
  FList.Sort;
end;

procedure TFluentList<T>.Sort(const AComparer: IComparer<T>);
begin
  FList.Sort(AComparer);
end;

procedure TFluentList<T>.Sort(const AComparer: IComparer<T>; AIndex, Count: NativeInt);
begin
  FList.Sort(AComparer, AIndex, Count);
end;

function TFluentList<T>.BinarySearch(const AItem: T; out FoundIndex: NativeInt): Boolean;
begin
  Result := FList.BinarySearch(AItem, FoundIndex);
end;

function TFluentList<T>.BinarySearch(const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>): Boolean;
begin
  Result := FList.BinarySearch(AItem, FoundIndex, AComparer);
end;

function TFluentList<T>.BinarySearch(const AItem: T; out FoundIndex: NativeInt; const AComparer: IComparer<T>; AIndex, Count: NativeInt): Boolean;
begin
  Result := FList.BinarySearch(AItem, FoundIndex, AComparer, AIndex, Count);
end;

procedure TFluentList<T>.TrimExcess;
begin
  FList.TrimExcess;
end;

procedure TFluentList<T>._FreeItem(const AItem: T);
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

function TFluentList<T>.ToArray: IFluentArray<T>;
var
  LArray: TArray<T>;
begin
  LArray := Copy(FList.List, 0, FList.Count);
  Result := TFluentArray<T>.Create(LArray, True);
  FList.Clear;
end;

function TFluentList<T>.AsEnumerable: IFluentEnumerable<T>;
begin
  Result := GetEnumerable;
end;

function TFluentList<T>.GetEnumerable: IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(
    TListAdapter<T>.Create(FList, False),
    ftList,
    TEqualityComparer<T>.Default
  );
end;

function TFluentList<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TListAdapterEnumerator<T>.Create(FList.GetEnumerator);
end;

class function TFluentList<T>.From(const AList: TList<T>): IFluentEnumerable<T>;
begin
  Result := TFluentList<T>.Create(AList).GetEnumerable;
end;

class function TFluentList<T>.From(const AArray: TArray<T>): IFluentEnumerable<T>;
begin
  Result := IFluentEnumerable<T>.Create(TArrayAdapter<T>.Create(AArray));
end;

function TFluentList<T>.GetCapacity: NativeInt;
begin
  Result := FList.Capacity;
end;

procedure TFluentList<T>.SetCapacity(const AValue: NativeInt);
begin
  FList.Capacity := AValue;
end;

function TFluentList<T>.GetItem(AIndex: NativeInt): T;
begin
  Result := FList.Items[AIndex];
end;

procedure TFluentList<T>.SetItem(AIndex: NativeInt; const AValue: T);
begin
  FList.Items[AIndex] := AValue;
end;

function TFluentList<T>.GetList: IFluentArray<T>;
begin
  Result := TFluentArray<T>.Create(FList.List);
  FList.Clear;
end;

function TFluentList<T>.GetOnNotify: TCollectionNotifyEvent<T>;
begin
  Result := FOnNotify;
end;

function TFluentList<T>.GetComparer: IComparer<T>;
begin
  Result := FList.Comparer;
end;

procedure TFluentList<T>.SetOnNotify(const AValue: TCollectionNotifyEvent<T>);
begin
  FList.OnNotify := AValue;
end;

{ TFluentDictionary<K, V> }

constructor TFluentDictionary<K, V>.Create(const AOwnerships: TDictionaryOwnerships);
begin
  if AOwnerships = [] then
    FDict := TDictionary<K, V>.Create
  else
    FDict := TObjectDictionary<K, V>.Create(AOwnerships);
end;

constructor TFluentDictionary<K, V>.Create(const ACapacity: NativeInt;
  const AOwnerships: TDictionaryOwnerships);
begin
  if AOwnerships = [] then
    FDict := TDictionary<K, V>.Create(ACapacity)
  else
    FDict := TObjectDictionary<K, V>.Create(AOwnerships, ACapacity);
end;

constructor TFluentDictionary<K, V>.Create(const AComparer: IEqualityComparer<K>;
  const AOwnerships: TDictionaryOwnerships);
begin
  if AOwnerships = [] then
    FDict := TDictionary<K, V>.Create(AComparer)
  else
    FDict := TObjectDictionary<K, V>.Create(AOwnerships, AComparer);
end;

constructor TFluentDictionary<K, V>.Create(const ACapacity: NativeInt;
  const AComparer: IEqualityComparer<K>; const AOwnerships: TDictionaryOwnerships);
begin
  if AOwnerships = [] then
    FDict := TDictionary<K, V>.Create(ACapacity, AComparer)
  else
    FDict := TObjectDictionary<K, V>.Create(AOwnerships, ACapacity, AComparer);
end;

constructor TFluentDictionary<K, V>.Create(const ACollection: TEnumerable<TPair<K, V>>);
begin
  FDict := TDictionary<K, V>.Create(ACollection);
end;

constructor TFluentDictionary<K, V>.Create(const ACollection: TEnumerable<TPair<K, V>>;
  const AComparer: IEqualityComparer<K>; const AOwnerships: TDictionaryOwnerships);
begin
  if AOwnerships = [] then
    FDict := TDictionary<K, V>.Create(ACollection, AComparer)
  else
    FDict := TObjectDictionary<K, V>.Create(AOwnerships, AComparer);
end;

constructor TFluentDictionary<K, V>.Create(const AItems: array of TPair<K, V>);
begin
  FDict := TDictionary<K, V>.Create(AItems);
end;

constructor TFluentDictionary<K, V>.Create(const AItems: array of TPair<K, V>;
  const AComparer: IEqualityComparer<K>);
begin
  FDict := TDictionary<K, V>.Create(AItems, AComparer);
end;

destructor TFluentDictionary<K, V>.Destroy;
begin
  FDict.Free;
  inherited;
end;

procedure TFluentDictionary<K, V>.Add(const AKey: K; const AValue: V);
begin
  FDict.Add(AKey, AValue);
end;

function TFluentDictionary<K, V>.Remove(const AKey: K): Boolean;
begin
  Result := False;
  if not FDict.ContainsKey(AKey) then
    Exit;
  FDict.Remove(AKey);
  Result := True;
end;

function TFluentDictionary<K, V>.ExtractPair(const AKey: K): TPair<K, V>;
begin
  Result := TPair<K, V>.Create(Default(K), Default(V));
  if not FDict.ContainsKey(AKey) then
    Exit;
  Result := FDict.ExtractPair(AKey);
end;

procedure TFluentDictionary<K, V>.Clear;
begin
  FDict.Clear;
end;

procedure TFluentDictionary<K, V>.TrimExcess;
begin
  FDict.TrimExcess;
end;

function TFluentDictionary<K, V>.TryGetValue(const AKey: K; var AValue: V): Boolean;
begin
  Result := FDict.TryGetValue(AKey, AValue);
end;

procedure TFluentDictionary<K, V>.Add(const AItem: TPair<K, V>);
begin
  FDict.Add(Aitem.Key, Aitem.Value);
end;

procedure TFluentDictionary<K, V>.AddOrSetValue(const AKey: K; const AValue: V);
begin
  FDict.AddOrSetValue(AKey, AValue);
end;

procedure TFluentDictionary<K, V>.AddRange(const Dictionary: TDictionary<K, V>);
var
  LPair: TPair<K, V>;
begin
  for LPair in Dictionary do
    Add(LPair.Key, LPair.Value);
end;

procedure TFluentDictionary<K, V>.AddRange(const AItems: TEnumerable<TPair<K, V>>);
var
  LPair: TPair<K, V>;
begin
  for LPair in AItems do
    Add(LPair.Key, LPair.Value);
end;

function TFluentDictionary<K, V>.TryAdd(const AKey: K; const AValue: V): Boolean;
begin
  Result := FDict.TryAdd(AKey, AValue);
end;

function TFluentDictionary<K, V>.Contains(const AValue: TPair<K, V>): Boolean;
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

function TFluentDictionary<K, V>.ContainsKey(const AKey: K): Boolean;
begin
  Result := FDict.ContainsKey(AKey);
end;

function TFluentDictionary<K, V>.ContainsValue(const AValue: V): Boolean;
begin
  Result := FDict.ContainsValue(AValue);
end;

procedure TFluentDictionary<K, V>.CopyTo(AArray: array of TPair<K, V>; AIndex: Integer);
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

function TFluentDictionary<K, V>.ToArray: IFluentArray<TPair<K, V>>;
begin
  Result := TFluentArray<TPair<K, V>>.Create(FDict.ToArray);
end;

function TFluentDictionary<K, V>.AsEnumerable: IFluentEnumerable<TPair<K, V>>;
begin
  Result := GetEnumerable;
end;

function TFluentDictionary<K, V>.GetEnumerable: IFluentEnumerable<TPair<K, V>>;
begin
  Result := IFluentEnumerable<TPair<K, V>>.Create(
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

function TFluentDictionary<K, V>.GetEnumerator: IFluentEnumerator<TPair<K, V>>;
begin
  Result := TDictionaryAdapterEnumerator<K, V>.Create(FDict.GetEnumerator);
end;

function TFluentDictionary<K, V>.GetCapacity: NativeInt;
begin
  Result := FDict.Capacity;
end;

procedure TFluentDictionary<K, V>.SetCapacity(const AValue: NativeInt);
begin
  FDict.Capacity := AValue;
end;

function TFluentDictionary<K, V>.GetItem(const AKey: K): V;
begin
  Result := FDict.Items[AKey];
end;

procedure TFluentDictionary<K, V>.SetItem(const AKey: K; const AValue: V);
begin
  FDict.Items[AKey] := AValue;
end;

function TFluentDictionary<K, V>.Count: NativeInt;
begin
  Result := FDict.Count;
end;

function TFluentDictionary<K, V>.IsEmpty: Boolean;
begin
  Result := FDict.IsEmpty;
end;

function TFluentDictionary<K, V>.Remove(const AItem: TPair<K, V>): Boolean;
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

function TFluentDictionary<K, V>.GetGrowThreshold: NativeInt;
begin
  Result := FDict.GrowThreshold;
end;

function TFluentDictionary<K, V>.GetCollisions: NativeInt;
begin
  Result := FDict.Collisions;
end;

function TFluentDictionary<K, V>.GetKeys: TDictionary<K, V>.TKeyCollection;
begin
  Result := FDict.Keys;
end;

function TFluentDictionary<K, V>.GetOnKeyNotify: TCollectionNotifyEvent<K>;
begin
  Result := FOnKeyNotify;
end;

function TFluentDictionary<K, V>.GetOnValueNotify: TCollectionNotifyEvent<V>;
begin
  Result := FOnValueNotify;
end;

function TFluentDictionary<K, V>.GetValues: TDictionary<K, V>.TValueCollection;
begin
  Result := FDict.Values;
end;

function TFluentDictionary<K, V>.GetComparer: IEqualityComparer<K>;
begin
  Result := FDict.Comparer;
end;

procedure TFluentDictionary<K, V>.SetOnKeyNotify(const AValue: TCollectionNotifyEvent<K>);
begin
  FDict.OnKeyNotify := AValue;
end;

procedure TFluentDictionary<K, V>.SetOnValueNotify(const AValue: TCollectionNotifyEvent<V>);
begin
  FDict.OnValueNotify := AValue;
end;

end.
