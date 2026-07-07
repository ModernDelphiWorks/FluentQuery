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

unit Colligo.SkipLast;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Colligo;

type
  // LINQ SkipLast(n): deferred, non-streaming — buffers the whole source on the
  // FIRST MoveNext (not at construction), then yields all but the last n
  // elements. n <= 0 yields the whole source.
  TColligoSkipLastEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const ACount: Integer);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoSkipLastEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FCount: Integer;
    FBuffer: TList<T>;
    FIndex: Integer;
    FLimit: Integer;
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

{ TColligoSkipLastEnumerable<T> }

constructor TColligoSkipLastEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

function TColligoSkipLastEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoSkipLastEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TColligoSkipLastEnumerator<T> }

constructor TColligoSkipLastEnumerator<T>.Create(const ASource: IColligoEnumerator<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FBuffer := TList<T>.Create;
  FBuffered := False;
end;

destructor TColligoSkipLastEnumerator<T>.Destroy;
begin
  FBuffer.Free;
  inherited;
end;

procedure TColligoSkipLastEnumerator<T>.EnsureBuffered;
begin
  if FBuffered then
    Exit;
  while FSource.MoveNext do
    FBuffer.Add(FSource.Current);
  if FCount <= 0 then
    FLimit := FBuffer.Count
  else
  begin
    FLimit := FBuffer.Count - FCount;
    if FLimit < 0 then
      FLimit := 0;
  end;
  FIndex := 0;
  FBuffered := True;
end;

function TColligoSkipLastEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoSkipLastEnumerator<T>.MoveNext: Boolean;
begin
  EnsureBuffered;
  Result := FIndex < FLimit;
  if Result then
  begin
    FCurrent := FBuffer[FIndex];
    Inc(FIndex);
  end;
end;

procedure TColligoSkipLastEnumerator<T>.Reset;
begin
  FSource.Reset;
  FBuffer.Clear;
  FBuffered := False;
end;

end.
