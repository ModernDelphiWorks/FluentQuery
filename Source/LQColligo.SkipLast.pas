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

unit LQColligo.SkipLast;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  LQColligo;

type
  // LINQ SkipLast(n): deferred, non-streaming — buffers the whole source on the
  // FIRST MoveNext (not at construction), then yields all but the last n
  // elements. n <= 0 yields the whole source.
  TLQColligoSkipLastEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const ACount: Integer);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoSkipLastEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FCount: Integer;
    FBuffer: TList<T>;
    FIndex: Integer;
    FLimit: Integer;
    FBuffered: Boolean;
    FCurrent: T;
    procedure EnsureBuffered;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const ACount: Integer);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TLQColligoSkipLastEnumerable<T> }

constructor TLQColligoSkipLastEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

function TLQColligoSkipLastEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoSkipLastEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TLQColligoSkipLastEnumerator<T> }

constructor TLQColligoSkipLastEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FBuffer := TList<T>.Create;
  FBuffered := False;
end;

destructor TLQColligoSkipLastEnumerator<T>.Destroy;
begin
  FBuffer.Free;
  inherited;
end;

procedure TLQColligoSkipLastEnumerator<T>.EnsureBuffered;
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

function TLQColligoSkipLastEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoSkipLastEnumerator<T>.MoveNext: Boolean;
begin
  EnsureBuffered;
  Result := FIndex < FLimit;
  if Result then
  begin
    FCurrent := FBuffer[FIndex];
    Inc(FIndex);
  end;
end;

procedure TLQColligoSkipLastEnumerator<T>.Reset;
begin
  FSource.Reset;
  FBuffer.Clear;
  FBuffered := False;
end;

end.
