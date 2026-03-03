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

unit FluentQuery.ThenBy;

interface

uses
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  FluentQuery;

type
  TFluentThenByEnumerable<TKey, TSource> = class(TFluentEnumerableBase<TSource>, IFluentEnumerableBase<TSource>)
  private
    FSource: IFluentEnumerableBase<TSource>;
    FKeySelector: TFunc<TSource, TKey>;
    FDescending: Boolean;
    FComparer: IComparer<TKey>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      ADescending: Boolean;
      const AComparer: IComparer<TKey> = nil);
    destructor Destroy; override;
    function GetEnumerator: IFluentEnumerator<TSource>; override;
  end;

  TFluentThenByEnumerator<TKey, TSource> = class(TInterfacedObject, IFluentEnumerator<TSource>)
  private
    FItems: TArray<TSource>;
    FIndex: Integer;
    FCurrent: TSource;
  public
    constructor Create(const ASource: IFluentEnumerableBase<TSource>;
      const AKeySelector: TFunc<TSource, TKey>;
      ADescending: Boolean;
      const AComparer: IComparer<TKey>);
    function GetCurrent: TSource;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TSource read GetCurrent;
  end;

implementation

{ TFluentThenByEnumerable<TKey, TSource> }

constructor TFluentThenByEnumerable<TKey, TSource>.Create(
  const ASource: IFluentEnumerableBase<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  ADescending: Boolean;
  const AComparer: IComparer<TKey>);
begin
  FSource := ASource;
  FKeySelector := AKeySelector;
  FDescending := ADescending;
  if AComparer = nil then
    FComparer := TComparer<TKey>.Default
  else
    FComparer := AComparer;
end;

destructor TFluentThenByEnumerable<TKey, TSource>.Destroy;
begin
  FSource := nil;
  inherited;
end;

function TFluentThenByEnumerable<TKey, TSource>.GetEnumerator: IFluentEnumerator<TSource>;
begin
  Result := TFluentThenByEnumerator<TKey, TSource>.Create(FSource, FKeySelector, FDescending, FComparer);
end;

{ TFluentThenByEnumerator<TKey, TSource> }

constructor TFluentThenByEnumerator<TKey, TSource>.Create(
  const ASource: IFluentEnumerableBase<TSource>;
  const AKeySelector: TFunc<TSource, TKey>;
  ADescending: Boolean;
  const AComparer: IComparer<TKey>);
var
  LEnum: IFluentEnumerator<TSource>;
  LList: TList<TSource>;
begin
  if not Assigned(AKeySelector) then
    raise EArgumentNilException.Create('Key selector cannot be nil');
  if not Assigned(AComparer) then
    raise EArgumentNilException.Create('Comparer cannot be nil');
  LList := TList<TSource>.Create;
  try
    LEnum := ASource.GetEnumerator;
    while LEnum.MoveNext do
      LList.Add(LEnum.Current);
    LList.Sort(TComparer<TSource>.Construct(
      function(const Left, Right: TSource): Integer
      begin
        Result := AComparer.Compare(AKeySelector(Left), AKeySelector(Right));
        if ADescending then
          Result := -Result;
      end));
    FItems := LList.ToArray;
  finally
    LList.Free;
  end;
  FIndex := -1;
end;

function TFluentThenByEnumerator<TKey, TSource>.GetCurrent: TSource;
begin
  Result := FCurrent;
end;

function TFluentThenByEnumerator<TKey, TSource>.MoveNext: Boolean;
begin
  Inc(FIndex);
  if FIndex < Length(FItems) then
  begin
    FCurrent := FItems[FIndex];
    Result := True;
  end
  else
    Result := False;
end;

procedure TFluentThenByEnumerator<TKey, TSource>.Reset;
begin
  FIndex := -1;
  FCurrent := Default(TSource);
end;

end.
