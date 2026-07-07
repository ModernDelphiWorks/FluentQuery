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

unit Colligo.SelectIndexed;

interface

uses
  SysUtils,
  Colligo;

type
  TColligoSelectIndexedEnumerable<T, TResult> = class(TColligoEnumerableBase<TResult>)
  private
    FSource: IColligoEnumerableBase<T>;
    FSelector: TFunc<T, Integer, TResult>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const ASelector: TFunc<T, Integer, TResult>);
    function GetEnumerator: IColligoEnumerator<TResult>; override;
  end;

  TColligoSelectIndexedEnumerator<T, TResult> = class(TInterfacedObject, IColligoEnumerator<TResult>)
  private
    FSource: IColligoEnumerator<T>;
    FSelector: TFunc<T, Integer, TResult>;
    FIndex: Integer;
    FCurrent: TResult;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ASelector: TFunc<T, Integer, TResult>);
    function GetCurrent: TResult;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TResult read GetCurrent;
  end;

implementation

{ TColligoSelectIndexedEnumerable<T, TResult> }

constructor TColligoSelectIndexedEnumerable<T, TResult>.Create(
  const ASource: IColligoEnumerableBase<T>; const ASelector: TFunc<T, Integer, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
end;

function TColligoSelectIndexedEnumerable<T, TResult>.GetEnumerator: IColligoEnumerator<TResult>;
begin
  Result := TColligoSelectIndexedEnumerator<T, TResult>.Create(FSource.GetEnumerator, FSelector);
end;

{ TColligoSelectIndexedEnumerator<T, TResult> }

constructor TColligoSelectIndexedEnumerator<T, TResult>.Create(
  const ASource: IColligoEnumerator<T>; const ASelector: TFunc<T, Integer, TResult>);
begin
  FSource := ASource;
  FSelector := ASelector;
  FIndex := -1;
end;

function TColligoSelectIndexedEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result := FCurrent;
end;

function TColligoSelectIndexedEnumerator<T, TResult>.MoveNext: Boolean;
begin
  if FSource.MoveNext then
  begin
    Inc(FIndex);
    FCurrent := FSelector(FSource.Current, FIndex);
    Result := True;
  end
  else
    Result := False;
end;

procedure TColligoSelectIndexedEnumerator<T, TResult>.Reset;
begin
  FSource.Reset;
  FIndex := -1;
end;

end.



