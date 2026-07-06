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

unit LQColligo.Generators;

interface

uses
  SysUtils,
  LQColligo;

type
  // LINQ Enumerable.Range: deferred/streaming — yields ACount consecutive
  // integers starting at AStart (AStart .. AStart+ACount-1). ACount=0 -> empty.
  TLQColligoRangeEnumerable = class(TLQColligoEnumerableBase<Integer>)
  private
    FStart: Integer;
    FCount: Integer;
  public
    constructor Create(const AStart, ACount: Integer);
    function GetEnumerator: ILQColligoEnumerator<Integer>; override;
  end;

  TLQColligoRangeEnumerator = class(TInterfacedObject, ILQColligoEnumerator<Integer>)
  private
    FStart: Integer;
    FCount: Integer;
    FIndex: Integer;
    FCurrent: Integer;
  public
    constructor Create(const AStart, ACount: Integer);
    function GetCurrent: Integer;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: Integer read GetCurrent;
  end;

  // LINQ Enumerable.Repeat: deferred/streaming — yields the same element ACount
  // times. ACount=0 -> empty.
  TLQColligoRepeatEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FElement: T;
    FCount: Integer;
  public
    constructor Create(const AElement: T; const ACount: Integer);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoRepeatEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FElement: T;
    FCount: Integer;
    FIndex: Integer;
    FCurrent: T;
  public
    constructor Create(const AElement: T; const ACount: Integer);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

  // LINQ Enumerable.Empty: an empty sequence.
  TLQColligoEmptyEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  public
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoEmptyEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FCurrent: T;
  public
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TLQColligoRangeEnumerable }

constructor TLQColligoRangeEnumerable.Create(const AStart, ACount: Integer);
begin
  FStart := AStart;
  FCount := ACount;
end;

function TLQColligoRangeEnumerable.GetEnumerator: ILQColligoEnumerator<Integer>;
begin
  Result := TLQColligoRangeEnumerator.Create(FStart, FCount);
end;

{ TLQColligoRangeEnumerator }

constructor TLQColligoRangeEnumerator.Create(const AStart, ACount: Integer);
begin
  FStart := AStart;
  FCount := ACount;
  FIndex := -1;
end;

function TLQColligoRangeEnumerator.GetCurrent: Integer;
begin
  Result := FCurrent;
end;

function TLQColligoRangeEnumerator.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FCount;
  if Result then
    FCurrent := FStart + FIndex; // in range: validated by TLQColligo.Range
end;

procedure TLQColligoRangeEnumerator.Reset;
begin
  FIndex := -1;
end;

{ TLQColligoRepeatEnumerable<T> }

constructor TLQColligoRepeatEnumerable<T>.Create(const AElement: T; const ACount: Integer);
begin
  FElement := AElement;
  FCount := ACount;
end;

function TLQColligoRepeatEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoRepeatEnumerator<T>.Create(FElement, FCount);
end;

{ TLQColligoRepeatEnumerator<T> }

constructor TLQColligoRepeatEnumerator<T>.Create(const AElement: T; const ACount: Integer);
begin
  FElement := AElement;
  FCount := ACount;
  FIndex := -1;
end;

function TLQColligoRepeatEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoRepeatEnumerator<T>.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FCount;
  if Result then
    FCurrent := FElement;
end;

procedure TLQColligoRepeatEnumerator<T>.Reset;
begin
  FIndex := -1;
end;

{ TLQColligoEmptyEnumerable<T> }

function TLQColligoEmptyEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoEmptyEnumerator<T>.Create;
end;

{ TLQColligoEmptyEnumerator<T> }

function TLQColligoEmptyEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoEmptyEnumerator<T>.MoveNext: Boolean;
begin
  Result := False;
end;

procedure TLQColligoEmptyEnumerator<T>.Reset;
begin
  // nothing to reset
end;

end.
