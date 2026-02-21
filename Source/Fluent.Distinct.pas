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

unit Fluent.Distinct;

interface

uses
  {$IFDEF QUERYABLE}
  Fluent.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  Fluent;

type
  TFluentDistinctEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentDistinctEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FSet: TList<T>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    function Contains(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TFluentDistinctQueryable<T> = class(TFluentQueryableBase<T>)
  private
    FSource: IFluentQueryableBase<T>;
    FComparer: IEqualityComparer<T>;
  public
    constructor Create(const ASource: IFluentQueryableBase<T>;
      const AComparer: IEqualityComparer<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TFluentDistinctQueryableEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FSet: TList<T>;
    FComparer: IEqualityComparer<T>;
    FCurrent: T;
    function Contains(const AValue: T): Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>;
      const AComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TFluentDistinctEnumerable<T> }

constructor TFluentDistinctEnumerable<T>.Create(
  const ASource: IFluentEnumerableBase<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  if AComparer = nil then
    FComparer := TEqualityComparer<T>.Default
  else
    FComparer := AComparer;
end;

function TFluentDistinctEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentDistinctEnumerator<T>.Create(FSource.GetEnumerator, FComparer);
end;

{ TFluentDistinctEnumerator<T> }

constructor TFluentDistinctEnumerator<T>.Create(
  const ASource: IFluentEnumerator<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSet := TList<T>.Create;
end;

destructor TFluentDistinctEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TFluentDistinctEnumerator<T>.Contains(const AValue: T): Boolean;
var
  LItem: T;
begin
  for LItem in FSet do
    if FComparer.Equals(LItem, AValue) then
      Exit(True);
  Result := False;
end;

function TFluentDistinctEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentDistinctEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if not Contains(FCurrent) then
    begin
      FSet.Add(FCurrent);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TFluentDistinctEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSet.Clear;
end;

{$IFDEF QUERYABLE}
{ TFluentDistinctQueryable<T> }

constructor TFluentDistinctQueryable<T>.Create(
  const ASource: IFluentQueryableBase<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  if AComparer = nil then
    FComparer := TEqualityComparer<T>.Default
  else
    FComparer := AComparer;
end;

function TFluentDistinctQueryable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentDistinctQueryableEnumerator<T>.Create(FSource.GetEnumerator, FComparer);
end;

function TFluentDistinctQueryable<T>.BuildQuery: string;
begin
  Result := 'SELECT DISTINCT * FROM (' + FSource.BuildQuery + ') AS Temp';
end;

{ TFluentDistinctQueryableEnumerator<T> }

constructor TFluentDistinctQueryableEnumerator<T>.Create(
  const ASource: IFluentEnumerator<T>;
  const AComparer: IEqualityComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  FSet := TList<T>.Create;
end;

destructor TFluentDistinctQueryableEnumerator<T>.Destroy;
begin
  FSet.Free;
  inherited;
end;

function TFluentDistinctQueryableEnumerator<T>.Contains(const AValue: T): Boolean;
var
  LItem: T;
begin
  for LItem in FSet do
    if FComparer.Equals(LItem, AValue) then
      Exit(True);
  Result := False;
end;

function TFluentDistinctQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentDistinctQueryableEnumerator<T>.MoveNext: Boolean;
begin
  while FSource.MoveNext do
  begin
    FCurrent := FSource.Current;
    if not Contains(FCurrent) then
    begin
      FSet.Add(FCurrent);
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

procedure TFluentDistinctQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSet.Clear;
end;
{$ENDIF}

end.
