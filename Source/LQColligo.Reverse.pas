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
  TFluentReverseEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentReverseEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FBuffer: TList<T>;
    FIndex: Integer;
    FBuffered: Boolean;
    FCurrent: T;
    procedure EnsureBuffered;
  public
    constructor Create(const ASource: IFluentEnumerator<T>);
    destructor Destroy; override;
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentReverseEnumerable<T> }

constructor TFluentReverseEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>);
begin
  FSource := ASource;
end;

function TFluentReverseEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentReverseEnumerator<T>.Create(FSource.GetEnumerator);
end;

{ TFluentReverseEnumerator<T> }

constructor TFluentReverseEnumerator<T>.Create(const ASource: IFluentEnumerator<T>);
begin
  FSource := ASource;
  FBuffer := TList<T>.Create;
  FBuffered := False;
end;

destructor TFluentReverseEnumerator<T>.Destroy;
begin
  FBuffer.Free;
  inherited;
end;

procedure TFluentReverseEnumerator<T>.EnsureBuffered;
begin
  if FBuffered then
    Exit;
  while FSource.MoveNext do
    FBuffer.Add(FSource.Current);
  FIndex := FBuffer.Count; // will step down toward 0
  FBuffered := True;
end;

function TFluentReverseEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentReverseEnumerator<T>.MoveNext: Boolean;
begin
  EnsureBuffered;
  Dec(FIndex);
  Result := FIndex >= 0;
  if Result then
    FCurrent := FBuffer[FIndex];
end;

procedure TFluentReverseEnumerator<T>.Reset;
begin
  FSource.Reset;
  FBuffer.Clear;
  FBuffered := False;
end;

end.
