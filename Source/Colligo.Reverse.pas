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

unit Colligo.Reverse;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Generics.Collections,
  Colligo;

type
  // LINQ Reverse: deferred, non-streaming — buffers the whole source on the
  // FIRST MoveNext (not at construction), then yields the elements in reverse.
  TColligoReverseEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoReverseEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FBuffer: TList<T>;
    FIndex: Integer;
    FBuffered: Boolean;
    FCurrent: T;
    procedure EnsureBuffered;
  public
    constructor Create(const ASource: IColligoEnumerator<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoReverseEnumerable<T> }

constructor TColligoReverseEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>);
begin
  FSource := ASource;
end;

function TColligoReverseEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoReverseEnumerator<T>.Create(FSource.GetEnumerator);
end;

{ TColligoReverseEnumerator<T> }

constructor TColligoReverseEnumerator<T>.Create(const ASource: IColligoEnumerator<T>);
begin
  FSource := ASource;
  FBuffer := TList<T>.Create;
  FBuffered := False;
end;

destructor TColligoReverseEnumerator<T>.Destroy;
begin
  FBuffer.Free;
  inherited;
end;

procedure TColligoReverseEnumerator<T>.EnsureBuffered;
begin
  if FBuffered then
    Exit;
  while FSource.MoveNext do
    FBuffer.Add(FSource.Current);
  FIndex := FBuffer.Count; // will step down toward 0
  FBuffered := True;
end;

function TColligoReverseEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoReverseEnumerator<T>.MoveNext: Boolean;
begin
  EnsureBuffered;
  Dec(FIndex);
  Result := FIndex >= 0;
  if Result then
    FCurrent := FBuffer[FIndex];
end;

procedure TColligoReverseEnumerator<T>.Reset;
begin
  FSource.Reset;
  FBuffer.Clear;
  FBuffered := False;
end;

end.
