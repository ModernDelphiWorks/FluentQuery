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
  TFluentSkipLastEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FCount: Integer;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const ACount: Integer);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentSkipLastEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FCount: Integer;
    FBuffer: TList<T>;
    FIndex: Integer;
    FLimit: Integer;
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

{ TFluentSkipLastEnumerable<T> }

constructor TFluentSkipLastEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
end;

function TFluentSkipLastEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentSkipLastEnumerator<T>.Create(FSource.GetEnumerator, FCount);
end;

{ TFluentSkipLastEnumerator<T> }

constructor TFluentSkipLastEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; const ACount: Integer);
begin
  FSource := ASource;
  FCount := ACount;
  FBuffer := TList<T>.Create;
  FBuffered := False;
end;

destructor TFluentSkipLastEnumerator<T>.Destroy;
begin
  FBuffer.Free;
  inherited;
end;

procedure TFluentSkipLastEnumerator<T>.EnsureBuffered;
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

function TFluentSkipLastEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentSkipLastEnumerator<T>.MoveNext: Boolean;
begin
  EnsureBuffered;
  Result := FIndex < FLimit;
  if Result then
  begin
    FCurrent := FBuffer[FIndex];
    Inc(FIndex);
  end;
end;

procedure TFluentSkipLastEnumerator<T>.Reset;
begin
  FSource.Reset;
  FBuffer.Clear;
  FBuffered := False;
end;

end.
