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

unit LQColligo.Select;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  LQColligo;

type
  TLQColligoSelectEnumerable<T, TResult> = class(TLQColligoEnumerableBase<TResult>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FSelector: TFunc<T, TResult>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>;
      const ASelector: TFunc<T, TResult>);
    function GetEnumerator: ILQColligoEnumerator<TResult>; override;
  end;

  TLQColligoSelectEnumerator<T, TResult> = class(TInterfacedObject, ILQColligoEnumerator<TResult>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSelector: TFunc<T, TResult>;
    FCurrent: TResult;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ASelector: TFunc<T, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

  {$IFDEF QUERYABLE}
  TLQColligoSelectQueryable<T, TResult> = class(TLQColligoQueryableBase<TResult>)
  private
    FSource: ILQColligoQueryableBase<T>;
    FSelector: TFunc<T, TResult>;
  public
    constructor Create(const ASource: ILQColligoQueryableBase<T>; const ASelector: TFunc<T, TResult>);
    function GetEnumerator: ILQColligoEnumerator<TResult>; override;
    function BuildQuery: string; override;
  end;
  {$ENDIF}

implementation

{ TLQColligoMapEnumerable<T, TResult> }

constructor TLQColligoSelectEnumerable<T, TResult>.Create(const ASource: ILQColligoEnumerableBase<T>; const ASelector: TFunc<T, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TLQColligoSelectEnumerable<T, TResult>.GetEnumerator: ILQColligoEnumerator<TResult>;
begin
  Result := TLQColligoSelectEnumerator<T, TResult>.Create(FSource.GetEnumerator, FSelector);
end;

{ TLQColligoMapEnumerator<T, TResult> }

constructor TLQColligoSelectEnumerator<T, TResult>.Create(const ASource: ILQColligoEnumerator<T>; const ASelector: TFunc<T, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TLQColligoSelectEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TLQColligoSelectEnumerator<T, TResult>.MoveNext: Boolean;
begin
  if FSource.MoveNext then
  begin
    FCurrent := FSelector(FSource.Current);
    Result := True;
  end
  else
    Result := False;
end;

procedure TLQColligoSelectEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
end;

{$IFDEF QUERYABLE}
{ TLQColligoSelectQueryable}

constructor TLQColligoSelectQueryable<T, TResult>.Create(const ASource: ILQColligoQueryableBase<T>;
  const ASelector: TFunc<T, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TLQColligoSelectQueryable<T, TResult>.GetEnumerator: ILQColligoEnumerator<TResult>;
begin
  // Placeholder: Implementar iteração com FSelector
  Result := FSource.GetEnumerator as ILQColligoEnumerator<TResult>; // Ajustar depois
end;

function TLQColligoSelectQueryable<T, TResult>.BuildQuery: string;
begin
  // Placeholder: Converter FSelector pra SELECT via FluentSQL
  Result := FSource.BuildQuery; // + ' SELECT ColumnName'
  // Exemplo real: Result := FSource.Select('ColumnName').AsString;
end;
{$ENDIF}

end.



