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

unit Fluent.Skip;

interface

uses
  {$IFDEF QUERYABLE}
  Fluent.Queryable,
  {$ENDIF}
  SysUtils,
  Fluent;

type
  TFluentSkipEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; ACount: Integer);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentSkipEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FCount: Integer;
    FSkipped: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; ACount: Integer);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TFluentSkipQueryable<T> = class(TFluentQueryableBase<T>)
  private
    FSource: IFluentQueryableBase<T>;
    FCount: Integer;
    FProvider: IFluentQueryProvider<T>;
  public
    constructor Create(const ASource: IFluentQueryableBase<T>; const ACount: Integer;
      const AProvider: IFluentQueryProvider<T> = nil);
    function GetEnumerator: IFluentEnumerator<T>; override;
    function BuildQuery: string; override;
  end;

  TFluentSkipQueryableEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FCount: Integer;
    FSkipped: Integer;
    FCurrent: T;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ACount: Integer);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;
  {$ENDIF}

implementation

{ TFluentSkipEnumerable<T> }

constructor TFluentSkipEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

function TFluentSkipEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentSkipEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TFluentSkipEnumerator<T> }

constructor TFluentSkipEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FSkipped := 0;
end;

function TFluentSkipEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentSkipEnumerator<T>.MoveNext: Boolean;
begin
  while FSkipped < FCount do
  begin
    if FSource.MoveNext then
      Inc(FSkipped)
    else
      Exit(False);
  end;
  Result := FSource.MoveNext;
  if Result then
    FCurrent := FSource.Current;
end;

procedure TFluentSkipEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := 0;
end;

{$IFDEF QUERYABLE}
{ TFluentSkipQueryable<T> }

constructor TFluentSkipQueryable<T>.Create(const ASource: IFluentQueryableBase<T>;
  const ACount: Integer; const AProvider: IFluentQueryProvider<T>);
begin
  FSource := ASource;
  FCount := ACount;
  FProvider := AProvider;
end;

function TFluentSkipQueryable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentSkipQueryableEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

function TFluentSkipQueryable<T>.BuildQuery: string;
begin
  // Placeholder: traduzir Skip pra SQL (ex.: OFFSET)
  Result := FSource.BuildQuery + ' OFFSET ' + IntToStr(FCount) + ' ROWS';
  // Exemplo fictício: 'SELECT * FROM Table OFFSET 10 ROWS'
  // Nota: Alguns bancos (ex.: SQL Server < 2012) não suportam OFFSET nativo, pode precisar de ajustes via FProvider
end;

{ TFluentSkipQueryableEnumerator<T> }

constructor TFluentSkipQueryableEnumerator<T>.Create(const ASource: IFluentEnumerator<T>;
  const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FSkipped := 0;
end;

function TFluentSkipQueryableEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentSkipQueryableEnumerator<T>.MoveNext: Boolean;
begin
  while FSkipped < FCount do
  begin
    if FSource.MoveNext then
      Inc(FSkipped)
    else
      Exit(False);
  end;
  Result := FSource.MoveNext;
  if Result then
    FCurrent := FSource.Current;
end;

procedure TFluentSkipQueryableEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSkipped := 0;
end;
{$ENDIF}

end.
