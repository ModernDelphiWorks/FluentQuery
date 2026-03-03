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

unit FluentQuery.Chunk;

interface

uses
  Math,
  Classes,
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  FluentQuery,
  FluentQuery.Core,
  FluentQuery.Adapters;

type
  TFluentChunkEnumerable<T> = class(TFluentEnumerableBase<TArray<T>>)
  private
    FSource: IFluentEnumerableBase<T>;
    FSize: Integer;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const ASize: Integer);
    function GetEnumerator: IFluentEnumerator<TArray<T>>; override;
  end;

  TFluentChunkEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<TArray<T>>)
  private
    FSource: IFluentEnumerator<T>;
    FSize: Integer;
    FCurrent: TArray<T>;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ASize: Integer);
    function GetCurrent: TArray<T>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TArray<T> read GetCurrent;
  end;

//  TFluentChunkResult<T> = class(TInterfacedObject, IFluentChunkResult<T>)
//  private
//    FEnumerable: TFluentChunkEnumerable<T>;
//  public
//    constructor Create(const ASource: IFluentEnumerableBase<T>; ASize: Integer);
//    destructor Destroy; override;
//    function GetEnumerator: IFluentEnumerator<TArray<T>>;
//    function AsEnumerable: IFluentEnumerable<TArray<T>>;
//  end;

implementation

{ TFluentChunkResult<T> }

//constructor TFluentChunkResult<T>.Create(const ASource: IFluentEnumerableBase<T>; ASize: Integer);
//begin
//  FEnumerable := TFluentChunkEnumerable<T>.Create(ASource, ASize);
//end;

//destructor TFluentChunkResult<T>.Destroy;
//begin
//  FEnumerable.Free;
//  inherited;
//end;

//function TFluentChunkResult<T>.GetEnumerator: IFluentEnumerator<TArray<T>>;
//begin
//  Result := FEnumerable.GetEnumerator;
//end;

//function TFluentChunkResult<T>.AsEnumerable: IFluentEnumerable<TArray<T>>;
//begin
//  Result := IFluentEnumerable<TArray<T>>.Create(
//    FEnumerable,
//    ftNone,
//    TEqualityComparer<TArray<T>>.Default
//  );
//end;

{ TFluentChunkEnumerable<T> }

constructor TFluentChunkEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; const ASize: Integer);
begin
  FSource := ASource;
  FSize := ASize;
end;

function TFluentChunkEnumerable<T>.GetEnumerator: IFluentEnumerator<TArray<T>>;
begin
  Result := TFluentChunkEnumerator<T>.Create(FSource.GetEnumerator, FSize);
end;

{ TFluentChunkEnumerator<T> }

constructor TFluentChunkEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; const ASize: Integer);
begin
  FSource := ASource;
  FSize := Max(1, ASize);
end;

function TFluentChunkEnumerator<T>.GetCurrent: TArray<T>;
begin
  Result := FCurrent;
end;

function TFluentChunkEnumerator<T>.MoveNext: Boolean;
var
  LList: TList<T>;
  LFor: Integer;
begin
  LList := TList<T>.Create;
  try
    LFor := 0;
    while (LFor < FSize) and FSource.MoveNext do
    begin
      LList.Add(FSource.Current);
      Inc(LFor);
    end;
    if LFor > 0 then
    begin
      FCurrent := LList.ToArray;
      Result := True;
    end
    else
      Result := False;
  finally
    LList.Free;
  end;
end;

procedure TFluentChunkEnumerator<T>.Reset;
begin
  FSource.Reset;
end;

end.



