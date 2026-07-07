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

unit Colligo.Select;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Colligo;

type
  TColligoSelectEnumerable<T, TResult> = class(TColligoEnumerableBase<TResult>)
  private
    FSource: IColligoEnumerableBase<T>;
    FSelector: TFunc<T, TResult>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>;
      const ASelector: TFunc<T, TResult>);
    function GetEnumerator: IColligoEnumerator<TResult>; override;
  end;

  TColligoSelectEnumerator<T, TResult> = class(TInterfacedObject, IColligoEnumerator<TResult>)
  private
    FSource: IColligoEnumerator<T>;
    FSelector: TFunc<T, TResult>;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ASelector: TFunc<T, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TColligoSelectQueryable<T, TResult> = class(TColligoQueryableBase<TResult>)
  private
    FSource: IColligoQueryableBase<T>;
    FSelector: TFunc<T, TResult>;
  public
    constructor Create(const ASource: IColligoQueryableBase<T>; const ASelector: TFunc<T, TResult>);
    function GetEnumerator: IColligoEnumerator<TResult>; override;
    function BuildQuery: string; override;
  end;
  {$ENDIF}

implementation

{ TColligoMapEnumerable<T, TResult> }

constructor TColligoSelectEnumerable<T, TResult>.Create(const ASource: IColligoEnumerableBase<T>; const ASelector: TFunc<T, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TColligoSelectEnumerable<T, TResult>.GetEnumerator: IColligoEnumerator<TResult>;
begin
  Result := TColligoSelectEnumerator<T, TResult>.Create(FSource.GetEnumerator, FSelector);
end;

{ TColligoMapEnumerator<T, TResult> }

constructor TColligoSelectEnumerator<T, TResult>.Create(const ASource: IColligoEnumerator<T>; const ASelector: TFunc<T, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TColligoSelectEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TColligoSelectEnumerator<T, TResult>.MoveNext: Boolean;
begin
  if FSource.MoveNext then
  begin
    FCurrent := FSelector(FSource.Current);
    Result := True;
  end
  else
    Result := False;
end;

procedure TColligoSelectEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
end;

{$IFDEF QUERYABLE}
{ TColligoSelectQueryable}

constructor TColligoSelectQueryable<T, TResult>.Create(const ASource: IColligoQueryableBase<T>;
  const ASelector: TFunc<T, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TColligoSelectQueryable<T, TResult>.GetEnumerator: IColligoEnumerator<TResult>;
begin
  // Placeholder: Implementar iteração com FSelector
  Result := FSource.GetEnumerator as IColligoEnumerator<TResult>; // Ajustar depois
end;

function TColligoSelectQueryable<T, TResult>.BuildQuery: string;
begin
  // Placeholder: Converter FSelector pra SELECT via FluentSQL
  Result := FSource.BuildQuery; // + ' SELECT ColumnName'
  // Exemplo real: Result := FSource.Select('ColumnName').AsString;
end;
{$ENDIF}

end.



