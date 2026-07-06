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

unit LQColligo.Reverse;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  LQColligo;

type
  // LINQ Reverse: deferred, non-streaming — buffers the whole source on the
  // FIRST MoveNext (not at construction), then yields the elements in reverse.
  TLQColligoReverseEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoReverseEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FBuffer: TList<T>;
    FIndex: Integer;
    FBuffered: Boolean;
    FCurrent: T;
    procedure EnsureBuffered;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TLQColligoReverseEnumerable<T> }

constructor TLQColligoReverseEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>);
begin
  FSource := ASource;
end;

function TLQColligoReverseEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoReverseEnumerator<T>.Create(FSource.GetEnumerator);
end;

{ TLQColligoReverseEnumerator<T> }

constructor TLQColligoReverseEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>);
begin
  FSource := ASource;
  FBuffer := TList<T>.Create;
  FBuffered := False;
end;

destructor TLQColligoReverseEnumerator<T>.Destroy;
begin
  FBuffer.Free;
  inherited;
end;

procedure TLQColligoReverseEnumerator<T>.EnsureBuffered;
begin
  if FBuffered then
    Exit;
  while FSource.MoveNext do
    FBuffer.Add(FSource.Current);
  FIndex := FBuffer.Count; // will step down toward 0
  FBuffered := True;
end;

function TLQColligoReverseEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoReverseEnumerator<T>.MoveNext: Boolean;
begin
  EnsureBuffered;
  Dec(FIndex);
  Result := FIndex >= 0;
  if Result then
    FCurrent := FBuffer[FIndex];
end;

procedure TLQColligoReverseEnumerator<T>.Reset;
begin
  FSource.Reset;
  FBuffer.Clear;
  FBuffered := False;
end;

end.
