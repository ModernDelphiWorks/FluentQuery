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

unit Colligo.TakeLast;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Colligo;

type
  // LINQ TakeLast(n): deferred, non-streaming — buffers the whole source on the
  // FIRST MoveNext (not at construction), then yields the last n elements in
  // order. n <= 0 yields nothing.
  TColligoTakeLastEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const ACount: Integer);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoTakeLastEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FCount: Integer;
    FBuffer: TList<T>;
    FIndex: Integer;
    FBuffered: Boolean;
    FCurrent: T;
    procedure EnsureBuffered;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ACount: Integer);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoTakeLastEnumerable<T> }

constructor TColligoTakeLastEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

function TColligoTakeLastEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoTakeLastEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TColligoTakeLastEnumerator<T> }

constructor TColligoTakeLastEnumerator<T>.Create(const ASource: IColligoEnumerator<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FBuffer := TList<T>.Create;
  FBuffered := False;
end;

destructor TColligoTakeLastEnumerator<T>.Destroy;
begin
  FBuffer.Free;
  inherited;
end;

procedure TColligoTakeLastEnumerator<T>.EnsureBuffered;
begin
  if FBuffered then
    Exit;
  while FSource.MoveNext do
    FBuffer.Add(FSource.Current);
  if FCount <= 0 then
    FIndex := FBuffer.Count // yield nothing
  else
  begin
    FIndex := FBuffer.Count - FCount;
    if FIndex < 0 then
      FIndex := 0;
  end;
  FBuffered := True;
end;

function TColligoTakeLastEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoTakeLastEnumerator<T>.MoveNext: Boolean;
begin
  EnsureBuffered;
  Result := FIndex < FBuffer.Count;
  if Result then
  begin
    FCurrent := FBuffer[FIndex];
    Inc(FIndex);
  end;
end;

procedure TColligoTakeLastEnumerator<T>.Reset;
begin
  FSource.Reset;
  FBuffer.Clear;
  FBuffered := False;
end;

end.
