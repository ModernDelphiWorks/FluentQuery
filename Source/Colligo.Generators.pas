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

unit Colligo.Generators;

interface

uses
  SysUtils,
  Colligo;

type
  // LINQ Enumerable.Range: deferred/streaming — yields ACount consecutive
  // integers starting at AStart (AStart .. AStart+ACount-1). ACount=0 -> empty.
  TColligoRangeEnumerable = class(TColligoEnumerableBase<Integer>)
  private
    FStart: Integer;
    FCount: Integer;
  public
    constructor Create(const AStart, ACount: Integer);
    function GetEnumerator: IColligoEnumerator<Integer>; override;
  end;

  TColligoRangeEnumerator = class(TInterfacedObject, IColligoEnumerator<Integer>)
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
  TColligoRepeatEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FElement: T;
    FCount: Integer;
  public
    constructor Create(const AElement: T; const ACount: Integer);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoRepeatEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
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
  TColligoEmptyEnumerable<T> = class(TColligoEnumerableBase<T>)
  public
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoEmptyEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FCurrent: T;
  public
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoRangeEnumerable }

constructor TColligoRangeEnumerable.Create(const AStart, ACount: Integer);
begin
  FStart := AStart;
  FCount := ACount;
end;

function TColligoRangeEnumerable.GetEnumerator: IColligoEnumerator<Integer>;
begin
  Result := TColligoRangeEnumerator.Create(FStart, FCount);
end;

{ TColligoRangeEnumerator }

constructor TColligoRangeEnumerator.Create(const AStart, ACount: Integer);
begin
  FStart := AStart;
  FCount := ACount;
  FIndex := -1;
end;

function TColligoRangeEnumerator.GetCurrent: Integer;
begin
  Result := FCurrent;
end;

function TColligoRangeEnumerator.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FCount;
  if Result then
    FCurrent := FStart + FIndex; // in range: validated by TColligo.Range
end;

procedure TColligoRangeEnumerator.Reset;
begin
  FIndex := -1;
end;

{ TColligoRepeatEnumerable<T> }

constructor TColligoRepeatEnumerable<T>.Create(const AElement: T; const ACount: Integer);
begin
  FElement := AElement;
  FCount := ACount;
end;

function TColligoRepeatEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoRepeatEnumerator<T>.Create(FElement, FCount);
end;

{ TColligoRepeatEnumerator<T> }

constructor TColligoRepeatEnumerator<T>.Create(const AElement: T; const ACount: Integer);
begin
  FElement := AElement;
  FCount := ACount;
  FIndex := -1;
end;

function TColligoRepeatEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoRepeatEnumerator<T>.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FCount;
  if Result then
    FCurrent := FElement;
end;

procedure TColligoRepeatEnumerator<T>.Reset;
begin
  FIndex := -1;
end;

{ TColligoEmptyEnumerable<T> }

function TColligoEmptyEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoEmptyEnumerator<T>.Create;
end;

{ TColligoEmptyEnumerator<T> }

function TColligoEmptyEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoEmptyEnumerator<T>.MoveNext: Boolean;
begin
  Result := False;
end;

procedure TColligoEmptyEnumerator<T>.Reset;
begin
  // nothing to reset
end;

end.
