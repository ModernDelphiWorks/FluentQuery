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

unit Colligo.Chunk;

interface

uses
  Math,
  Classes,
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  Colligo,
  Colligo.Core,
  Colligo.Adapters;

type
  TColligoChunkEnumerable<T> = class(TColligoEnumerableBase<TArray<T>>)
  private
    FSource: IColligoEnumerableBase<T>;
    FSize: Integer;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const ASize: Integer);
    function GetEnumerator: IColligoEnumerator<TArray<T>>; override;
  end;

  TColligoChunkEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<TArray<T>>)
  private
    FSource: IColligoEnumerator<T>;
    FSize: Integer;
    FCurrent: TArray<T>;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ASize: Integer);
    function GetCurrent: TArray<T>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TArray<T> read GetCurrent;
  end;

//  TColligoChunkResult<T> = class(TInterfacedObject, IColligoChunkResult<T>)
//  private
//    FEnumerable: TColligoChunkEnumerable<T>;
//  public
//    constructor Create(const ASource: IColligoEnumerableBase<T>; ASize: Integer);
//    destructor Destroy; override;
//    function GetEnumerator: IColligoEnumerator<TArray<T>>;
//    function AsEnumerable: IColligoEnumerable<TArray<T>>;
//  end;

implementation

{ TColligoChunkResult<T> }

//constructor TColligoChunkResult<T>.Create(const ASource: IColligoEnumerableBase<T>; ASize: Integer);
//begin
//  FEnumerable := TColligoChunkEnumerable<T>.Create(ASource, ASize);
//end;

//destructor TColligoChunkResult<T>.Destroy;
//begin
//  FEnumerable.Free;
//  inherited;
//end;

//function TColligoChunkResult<T>.GetEnumerator: IColligoEnumerator<TArray<T>>;
//begin
//  Result := FEnumerable.GetEnumerator;
//end;

//function TColligoChunkResult<T>.AsEnumerable: IColligoEnumerable<TArray<T>>;
//begin
//  Result := IColligoEnumerable<TArray<T>>.Create(
//    FEnumerable,
//    ftNone,
//    TEqualityComparer<TArray<T>>.Default
//  );
//end;

{ TColligoChunkEnumerable<T> }

constructor TColligoChunkEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>; const ASize: Integer);
begin
  FSource := ASource;
  FSize := ASize;
end;

function TColligoChunkEnumerable<T>.GetEnumerator: IColligoEnumerator<TArray<T>>;
begin
  Result := TColligoChunkEnumerator<T>.Create(FSource.GetEnumerator, FSize);
end;

{ TColligoChunkEnumerator<T> }

constructor TColligoChunkEnumerator<T>.Create(const ASource: IColligoEnumerator<T>; const ASize: Integer);
begin
  FSource := ASource;
  FSize := Max(1, ASize);
end;

function TColligoChunkEnumerator<T>.GetCurrent: TArray<T>;
begin
  Result := FCurrent;
end;

function TColligoChunkEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoChunkEnumerator<T>.Reset;
begin
  FSource.Reset;
end;

end.



