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

unit LQColligo.Chunk;

interface

uses
  Math,
  Classes,
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  LQColligo,
  LQColligo.Core,
  LQColligo.Adapters;

type
  TLQColligoChunkEnumerable<T> = class(TLQColligoEnumerableBase<TArray<T>>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FSize: Integer;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const ASize: Integer);
    function GetEnumerator: ILQColligoEnumerator<TArray<T>>; override;
  end;

  TLQColligoChunkEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<TArray<T>>)
  private
    FSource: ILQColligoEnumerator<T>;
    FSize: Integer;
    FCurrent: TArray<T>;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ASize: Integer);
    function GetCurrent: TArray<T>;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: TArray<T> read GetCurrent;
  end;

//  TLQColligoChunkResult<T> = class(TInterfacedObject, ILQColligoChunkResult<T>)
//  private
//    FEnumerable: TLQColligoChunkEnumerable<T>;
//  public
//    constructor Create(const ASource: ILQColligoEnumerableBase<T>; ASize: Integer);
//    destructor Destroy; override;
//    function GetEnumerator: ILQColligoEnumerator<TArray<T>>;
//    function AsEnumerable: ILQColligoEnumerable<TArray<T>>;
//  end;

implementation

{ TLQColligoChunkResult<T> }

//constructor TLQColligoChunkResult<T>.Create(const ASource: ILQColligoEnumerableBase<T>; ASize: Integer);
//begin
//  FEnumerable := TLQColligoChunkEnumerable<T>.Create(ASource, ASize);
//end;

//destructor TLQColligoChunkResult<T>.Destroy;
//begin
//  FEnumerable.Free;
//  inherited;
//end;

//function TLQColligoChunkResult<T>.GetEnumerator: ILQColligoEnumerator<TArray<T>>;
//begin
//  Result := FEnumerable.GetEnumerator;
//end;

//function TLQColligoChunkResult<T>.AsEnumerable: ILQColligoEnumerable<TArray<T>>;
//begin
//  Result := ILQColligoEnumerable<TArray<T>>.Create(
//    FEnumerable,
//    ftNone,
//    TEqualityComparer<TArray<T>>.Default
//  );
//end;

{ TLQColligoChunkEnumerable<T> }

constructor TLQColligoChunkEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>; const ASize: Integer);
begin
  FSource := ASource;
  FSize := ASize;
end;

function TLQColligoChunkEnumerable<T>.GetEnumerator: ILQColligoEnumerator<TArray<T>>;
begin
  Result := TLQColligoChunkEnumerator<T>.Create(FSource.GetEnumerator, FSize);
end;

{ TLQColligoChunkEnumerator<T> }

constructor TLQColligoChunkEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>; const ASize: Integer);
begin
  FSource := ASource;
  FSize := Max(1, ASize);
end;

function TLQColligoChunkEnumerator<T>.GetCurrent: TArray<T>;
begin
  Result := FCurrent;
end;

function TLQColligoChunkEnumerator<T>.MoveNext: Boolean;
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

procedure TLQColligoChunkEnumerator<T>.Reset;
begin
  FSource.Reset;
end;

end.



