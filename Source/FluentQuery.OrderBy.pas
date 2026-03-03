{
  ------------------------------------------------------------------------------
  FluentQuery
  LINQ-inspired fluent query API for Delphi.

  SPDX-License-Identifier: Apache-2.0
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ./FluentQuery.inc}

unit FluentQuery.OrderBy;

interface

uses
  SysUtils,
  FluentQuery,
  FluentQuery.Collections;

type
  TFluentOrderByEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FComparer: TFunc<T, T, Integer>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>;
      const AComparer: TFunc<T, T, Integer>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentOrderByEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FItems: TArray<T>;
    FIndex: Integer;
  public
    constructor Create(const ASource: IFluentEnumerator<T>;
      const AComparer: TFunc<T, T, Integer>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

uses
  Generics.Collections,
  Generics.Defaults;

{ TFluentOrderByEnumerable<T> }

constructor TFluentOrderByEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>;
  const AComparer: TFunc<T, T, Integer>);
begin
  FSource := ASource;
  FComparer := AComparer;
end;

function TFluentOrderByEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentOrderByEnumerator<T>.Create(FSource.GetEnumerator, FComparer);
end;

{ TFluentOrderByEnumerator<T> }

//constructor TFluentOrderByEnumerator<T>.Create(const ASource: IFluentEnumerator<T>;
//  const AComparer: TFunc<T, T, Integer>);
//var
//  LList: IFluentList<T>;
//begin
//  LList := TFluentList<T>.Create;
//  while ASource.MoveNext do
//    LList.Add(ASource.Current);
//  FItems := LList.ToArray.ArrayData;
//  TArray.Sort<T>(FItems, TComparer<T>.Construct(
//    function(const Left, Right: T): Integer
//    begin
//      Result := AComparer(Left, Right);
//    end));
//  FIndex := -1;
//end;

constructor TFluentOrderByEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; const AComparer: TFunc<T, T, Integer>);
var
  LList: IFluentList<T>;
begin
  LList := TFluentList<T>.Create;
  while ASource.MoveNext do
  begin
    if not TEqualityComparer<T>.Default.Equals(ASource.Current, Default(T)) then
      LList.Add(ASource.Current);
  end;
  FItems := LList.ToArray.ArrayData;
  TArray.Sort<T>(FItems, TComparer<T>.Construct(
    function(const Left, Right: T): Integer
    begin
      Result := AComparer(Left, Right);
    end));
  FIndex := -1;
end;

function TFluentOrderByEnumerator<T>.GetCurrent: T;
begin
  Result := FItems[FIndex];
end;

function TFluentOrderByEnumerator<T>.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < Length(FItems);
end;

procedure TFluentOrderByEnumerator<T>.Reset;
begin
  FIndex := -1;
end;

end.



