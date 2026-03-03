{
                          Apache License

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

unit FluentQuery.Adapters;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  {$ENDIF}
  Math,
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  FluentQuery.Core,
  FluentQuery;

type
  TEnumerableAdapter<TResult> = class(TInterfacedObject, IFluentEnumerableAdapter<TResult>)
  private
    FBase: IFluentEnumerableBase<TResult>;
    FValue: IFluentEnumerable<TResult>;
    FList: TObject;
  public
    constructor Create(const ABase: IFluentEnumerableBase<TResult>;
      const AList: TObject); overload;
    constructor Create(const AValue: IFluentEnumerable<TResult>;
      const AList: TObject); overload;
    destructor Destroy; override;
    function AsEnumerable: IFluentEnumerable<TResult>;
  end;

  TListAdapter<T> = class(TInterfacedObject, IFluentEnumerableBase<T>)
  private
    FList: TList<T>;
    FOwnsList: Boolean;
    function GetCount: Integer;
  public
    constructor Create(const AList: TList<T>; AOwnsList: Boolean = False);
    destructor Destroy; override;
    function GetEnumerator: IFluentEnumerator<T>;
    property Count: Integer read GetCount;
  end;

  TListAdapterEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FEnumerator: TList<T>.TEnumerator;
  public
    constructor Create(const AEnumerator: TList<T>.TEnumerator);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  TDictionaryAdapter<K, V> = class(TInterfacedObject, IFluentEnumerableBase<TPair<K, V>>)
  private
    FDict: TDictionary<K, V>;
    FOwnsDict: Boolean;
  public
    constructor Create(const ADict: TDictionary<K, V>; AOwnsDict: Boolean = False);
    destructor Destroy; override;
    function GetEnumerator: IFluentEnumerator<TPair<K, V>>;
  end;

  TDictionaryAdapterEnumerator<K, V> = class(TInterfacedObject, IFluentEnumerator<TPair<K, V>>)
  private
    FEnumerator: TDictionary<K, V>.TPairEnumerator;
  public
    constructor Create(const AEnumerator: TDictionary<K, V>.TPairEnumerator);
    destructor Destroy; override;
    function GetCurrent: TPair<K, V>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TPair<K, V> read GetCurrent;
  end;

  TStringAdapter = class(TInterfacedObject, IFluentEnumerableBase<Char>)
  private
    FString: string;
  public
    constructor Create(const AString: string);
    function GetEnumerator: IFluentEnumerator<Char>;
  end;

  TStringAdapterEnumerator = class(TInterfacedObject, IFluentEnumerator<Char>)
  private
    FString: string;
    FIndex: Integer;
  public
    constructor Create(const AString: string);
    function GetCurrent: Char;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: Char read GetCurrent;
  end;

  TArrayAdapter<T> = class(TInterfacedObject, IFluentEnumerableBase<T>)
  private
    FArray: TArray<T>;
    FList: TList<T>;
    function GetCount: Integer;
  public
    constructor Create(const AArray: TArray<T>);
    destructor Destroy; override;
    function GetEnumerator: IFluentEnumerator<T>;
    property Count: Integer read GetCount;
  end;

  TNonGenericArrayAdapter<T> = class(TInterfacedObject, IFluentEnumerableBase<T>)
  private
    FArray: TArray<T>;
    FList: TList<T>;
  public
    constructor Create(const AArray: array of T);
    destructor Destroy; override;
    function GetEnumerator: IFluentEnumerator<T>;
  end;

  {$IFDEF QUERYABLE}
  TQueryableToEnumerableAdapter<T> = class(TInterfacedObject, IFluentEnumerableBase<T>)
  private
    FQueryable: IFluentQueryableBase<T>;
  public
    constructor Create(const AQueryable: IFluentQueryableBase<T>);
    function GetEnumerator: IFluentEnumerator<T>;
  end;
  {$ENDIF}

implementation

{ TListAdapter<T> }

constructor TListAdapter<T>.Create(const AList: TList<T>; AOwnsList: Boolean);
begin
  FList := AList;
  FOwnsList := AOwnsList;
end;

destructor TListAdapter<T>.Destroy;
begin
  if FOwnsList then
    FList.Free;
  inherited;
end;

function TListAdapter<T>.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TListAdapter<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TListAdapterEnumerator<T>.Create(FList.GetEnumerator);
end;

{ TListEnumerator<T> }

constructor TListAdapterEnumerator<T>.Create(const AEnumerator: TList<T>.TEnumerator);
begin
  FEnumerator := AEnumerator;
end;

destructor TListAdapterEnumerator<T>.Destroy;
begin
  FEnumerator.Free;
  inherited;
end;

function TListAdapterEnumerator<T>.GetCurrent: T;
begin
  Result := FEnumerator.Current;
end;

function TListAdapterEnumerator<T>.MoveNext: Boolean;
begin
  Result := FEnumerator.MoveNext;
end;

procedure TListAdapterEnumerator<T>.Reset;
begin
  raise ENotSupportedException.Create('Reset is not supported for list enumerators');
end;

{ TDictionaryAdapter<K, V> }

constructor TDictionaryAdapter<K, V>.Create(const ADict: TDictionary<K, V>; AOwnsDict: Boolean);
begin
  FDict := ADict;
  FOwnsDict := AOwnsDict;
end;

destructor TDictionaryAdapter<K, V>.Destroy;
begin
  if FOwnsDict then
    FDict.Free;
  inherited;
end;

function TDictionaryAdapter<K, V>.GetEnumerator: IFluentEnumerator<TPair<K, V>>;
begin
  Result := TDictionaryAdapterEnumerator<K, V>.Create(FDict.GetEnumerator);
end;

{ TDictionaryEnumerator<K, V> }

constructor TDictionaryAdapterEnumerator<K, V>.Create(const AEnumerator: TDictionary<K, V>.TPairEnumerator);
begin
  FEnumerator := AEnumerator;
end;

destructor TDictionaryAdapterEnumerator<K, V>.Destroy;
begin
  FEnumerator.Free;
  inherited;
end;

function TDictionaryAdapterEnumerator<K, V>.GetCurrent: TPair<K, V>;
begin
  Result := FEnumerator.Current;
end;

function TDictionaryAdapterEnumerator<K, V>.MoveNext: Boolean;
begin
  Result := FEnumerator.MoveNext;
end;

procedure TDictionaryAdapterEnumerator<K, V>.Reset;
begin
  raise ENotSupportedException.Create('Reset is not supported for dictionary enumerators');
end;

{ TArrayAdapter<T> }

constructor TArrayAdapter<T>.Create(const AArray: TArray<T>);
begin
  FArray := AArray;
  FList := TList<T>.Create(AArray);
end;

destructor TArrayAdapter<T>.Destroy;
begin
  FList.Free;
  inherited;
end;

function TArrayAdapter<T>.GetCount: Integer;
begin
  Result := Length(FArray);
end;

function TArrayAdapter<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TListAdapterEnumerator<T>.Create(FList.GetEnumerator);
end;

{ TStringAdapter }

constructor TStringAdapter.Create(const AString: string);
begin
  FString := AString;
end;

function TStringAdapter.GetEnumerator: IFluentEnumerator<Char>;
begin
  Result := TStringAdapterEnumerator.Create(FString);
end;

{ TStringEnumerator }

constructor TStringAdapterEnumerator.Create(const AString: string);
begin
  FString := AString;
  FIndex := 0;
end;

function TStringAdapterEnumerator.GetCurrent: Char;
begin
  if (FIndex < 1) or (FIndex > Length(FString)) then
    raise ERangeError.Create('Index out of bounds');
  Result := FString[FIndex];
end;

function TStringAdapterEnumerator.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex <= Length(FString);
end;

procedure TStringAdapterEnumerator.Reset;
begin
  FIndex := 0;
end;

{ TNonGenericArrayAdapter<T> }

constructor TNonGenericArrayAdapter<T>.Create(const AArray: array of T);
var
  LFor: Integer;
begin
  SetLength(FArray, Length(AArray));
  for LFor := 0 to High(AArray) do
    FArray[LFor] := AArray[LFor];
  FList := TList<T>.Create(AArray);
end;

destructor TNonGenericArrayAdapter<T>.Destroy;
begin
  FList.Free;
  inherited;
end;

function TNonGenericArrayAdapter<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TListAdapterEnumerator<T>.Create(FList.GetEnumerator);
end;

{$IFDEF QUERYABLE}
{ TQueryableToEnumerableAdapter<T> }

constructor TQueryableToEnumerableAdapter<T>.Create(const AQueryable: IFluentQueryableBase<T>);
begin
  FQueryable := AQueryable;
end;

function TQueryableToEnumerableAdapter<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := FQueryable.GetEnumerator;
end;
{$ENDIF}

{ TFluentEnumerableAdapter<TResult> }

constructor TEnumerableAdapter<TResult>.Create(const ABase: IFluentEnumerableBase<TResult>;
  const AList: TObject);
begin
  FBase := ABase;
  FList := AList;
  FValue := IFluentEnumerable<TResult>.Create(
    FBase,
    ftNone,
    TEqualityComparer<TResult>.Default
  );
end;

constructor TEnumerableAdapter<TResult>.Create(const AValue: IFluentEnumerable<TResult>;
  const AList: TObject);
begin
  FValue := AValue;
  FList := AList;
  FBase := nil;
end;

destructor TEnumerableAdapter<TResult>.Destroy;
begin
  FList.Free;
  inherited;
end;

function TEnumerableAdapter<TResult>.AsEnumerable: IFluentEnumerable<TResult>;
begin
  Result := FValue;
end;

end.



