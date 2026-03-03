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

unit FluentQuery.Exclude;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  FluentQuery;

type
  TFluentExcludeEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FSecond: IFluentEnumerableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const ASecond: IFluentEnumerableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentExcludeEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FSecond: TDictionary<T, Boolean>;
    FCurrent: T;
    FComparer: IEqualityComparer<T>;
    function ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASecond: IFluentEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TFluentExcludeQueryable<T> = class(TFluentQueryableBase<T>)
  private
    FSource: IFluentQueryableBase<T>;
    FSecond: IFluentQueryableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IFluentQueryableBase<T>; const ASecond: IFluentQueryableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TFluentExcludeQueryableEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FSecond: TDictionary<T, Boolean>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    function _ContainsValue(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASecond: IFluentEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TFluentExcludeEnumerable<T> }

constructor TFluentExcludeEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>;
  const ASecond: IFluentEnumerableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TFluentExcludeEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentExcludeEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

{ TFluentExcludeEnumerator<T> }

constructor TFluentExcludeEnumerator<T>.Create(const ASource: IFluentEnumerator<T>;
  const ASecond: IFluentEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSecond := TDictionary<T, Boolean>.Create(FComparer);
  while ASecond.MoveNext do
    FSecond.Add(ASecond.Current, True);
end;

destructor TFluentExcludeEnumerator<T>.Destroy;
begin
  FSecond.Free;
  inherited;
end;

function TFluentExcludeEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentExcludeEnumerator<T>.ContainsValue(const AValue: T): Boolean;
var
  LKey: T;
begin
  for LKey in FSecond.Keys do
    if FComparer.Equals(LKey, AValue) then
      Exit(True);
  Result := False;
end;

function TFluentExcludeEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if not ContainsValue(FCurrent) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TFluentExcludeEnumerator<T>.Reset;
begin
  FSource.Reset;
end;

{$IFDEF QUERYABLE}
{ TFluentExcludeQueryable<T> }

constructor TFluentExcludeQueryable<T>.Create(const ASource: IFluentQueryableBase<T>;
  const ASecond: IFluentQueryableBase<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FSecond := ASecond;
  FComparer := AComparer;
end;

function TFluentExcludeQueryable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentExcludeQueryableEnumerator<T>.Create(FSource.GetEnumerator, FSecond.GetEnumerator, FComparer);
end;

function TFluentExcludeQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Exclude pra SQL (ex.: LEFT JOIN com WHERE NULL)
  Result := FSource.BuildQuery + ' EXCEPT ' + FSecond.BuildQuery;
  // Exemplo fictício: 'SELECT * FROM Table1 EXCEPT SELECT * FROM Table2'
end;

{ TFluentExcludeQueryableEnumerator<T> }

constructor TFluentExcludeQueryableEnumerator<T>.Create(const ASource: IFluentEnumerator<T>;
  const ASecond: IFluentEnumerator<T>; const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSecond := TDictionary<T, Boolean>.Create(FComparer);
  while ASecond.MoveNext do
    FSecond.Add(ASecond.Current, True);
end;

destructor TFluentExcludeQueryableEnumerator<T>.Destroy;
begin
  FSecond.Free;
  inherited;
end;

function TFluentExcludeQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentExcludeQueryableEnumerator<T>._ContainsValue(const AValue: T): Boolean;
var
  LKey: T;
begin
  for LKey in FSecond.Keys do
    if FComparer.Equals(LKey, AValue) then
      Exit(True);
  Result := False;
end;

function TFluentExcludeQueryableEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if not _ContainsValue(FCurrent) then
    begin
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TFluentExcludeQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
end;
{$ENDIF}

end.
