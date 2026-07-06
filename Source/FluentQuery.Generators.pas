{
  ------------------------------------------------------------------------------
  FluentQuery
  Lazy Data Manipulation and LINQ-like collection querying library for Delphi and Lazarus.

  SPDX-License-Identifier: MIT
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the MIT License.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ./FluentQuery.inc}

unit FluentQuery.Generators;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  {$ENDIF}
  SysUtils,
  FluentQuery;

type
  // LINQ Enumerable.Range: deferred/streaming — yields ACount consecutive
  // integers starting at AStart (AStart .. AStart+ACount-1). ACount=0 -> empty.
  TFluentRangeEnumerable = class(TFluentEnumerableBase<Integer>)
  private
    FStart: Integer;
    FCount: Integer;
  public
    constructor Create(const AStart, ACount: Integer);
    function GetEnumerator: IFluentEnumerator<Integer>; override;
  end;

  TFluentRangeEnumerator = class(TInterfacedObject, IFluentEnumerator<Integer>)
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
  TFluentRepeatEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FElement: T;
    FCount: Integer;
  public
    constructor Create(const AElement: T; const ACount: Integer);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentRepeatEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
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
  TFluentEmptyEnumerable<T> = class(TFluentEnumerableBase<T>)
  public
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentEmptyEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FCurrent: T;
  public
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentRangeEnumerable }

constructor TFluentRangeEnumerable.Create(const AStart, ACount: Integer);
begin
  FStart := AStart;
  FCount := ACount;
end;

function TFluentRangeEnumerable.GetEnumerator: IFluentEnumerator<Integer>;
begin
  Result := TFluentRangeEnumerator.Create(FStart, FCount);
end;

{ TFluentRangeEnumerator }

constructor TFluentRangeEnumerator.Create(const AStart, ACount: Integer);
begin
  FStart := AStart;
  FCount := ACount;
  FIndex := -1;
end;

function TFluentRangeEnumerator.GetCurrent: Integer;
begin
  Result := FCurrent;
end;

function TFluentRangeEnumerator.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FCount;
  if Result then
    FCurrent := FStart + FIndex; // in range: validated by TFluentQuery.Range
end;

procedure TFluentRangeEnumerator.Reset;
begin
  FIndex := -1;
end;

{ TFluentRepeatEnumerable<T> }

constructor TFluentRepeatEnumerable<T>.Create(const AElement: T; const ACount: Integer);
begin
  FElement := AElement;
  FCount := ACount;
end;

function TFluentRepeatEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentRepeatEnumerator<T>.Create(FElement, FCount);
end;

{ TFluentRepeatEnumerator<T> }

constructor TFluentRepeatEnumerator<T>.Create(const AElement: T; const ACount: Integer);
begin
  FElement := AElement;
  FCount := ACount;
  FIndex := -1;
end;

function TFluentRepeatEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentRepeatEnumerator<T>.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < FCount;
  if Result then
    FCurrent := FElement;
end;

procedure TFluentRepeatEnumerator<T>.Reset;
begin
  FIndex := -1;
end;

{ TFluentEmptyEnumerable<T> }

function TFluentEmptyEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentEmptyEnumerator<T>.Create;
end;

{ TFluentEmptyEnumerator<T> }

function TFluentEmptyEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentEmptyEnumerator<T>.MoveNext: Boolean;
begin
  Result := False;
end;

procedure TFluentEmptyEnumerator<T>.Reset;
begin
  // nothing to reset
end;

end.
