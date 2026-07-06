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

unit LQColligo.TakeLast;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  LQColligo;

type
  // LINQ TakeLast(n): deferred, non-streaming — buffers the whole source on the
  // FIRST MoveNext (not at construction), then yields the last n elements in
  // order. n <= 0 yields nothing.
  TFluentTakeLastEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const ACount: Integer);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentTakeLastEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FCount: Integer;
    FBuffer: TList<T>;
    FIndex: Integer;
    FBuffered: Boolean;
    FCurrent: T;
    procedure EnsureBuffered;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ACount: Integer);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentTakeLastEnumerable<T> }

constructor TFluentTakeLastEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

function TFluentTakeLastEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentTakeLastEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TFluentTakeLastEnumerator<T> }

constructor TFluentTakeLastEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FBuffer := TList<T>.Create;
  FBuffered := False;
end;

destructor TFluentTakeLastEnumerator<T>.Destroy;
begin
  FBuffer.Free;
  inherited;
end;

procedure TFluentTakeLastEnumerator<T>.EnsureBuffered;
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

function TFluentTakeLastEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentTakeLastEnumerator<T>.MoveNext: Boolean;
begin
  EnsureBuffered;
  Result := FIndex < FBuffer.Count;
  if Result then
  begin
    FCurrent := FBuffer[FIndex];
    Inc(FIndex);
  end;
end;

procedure TFluentTakeLastEnumerator<T>.Reset;
begin
  FSource.Reset;
  FBuffer.Clear;
  FBuffered := False;
end;

end.
