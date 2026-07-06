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

unit LQColligo.Append;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  LQColligo;

type
  // LINQ Append: deferred/streaming — yields the source, then one extra element.
  // Nothing runs until enumeration (no materialization at construction).
  TLQColligoAppendEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FElement: T;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const AElement: T);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoAppendEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FElement: T;
    FCurrent: T;
    FSourceDone: Boolean;
    FElementYielded: Boolean;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const AElement: T);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TLQColligoAppendEnumerable<T> }

constructor TLQColligoAppendEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>; const AElement: T);
begin
  FSource := ASource;
  FElement := AElement;
end;

function TLQColligoAppendEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoAppendEnumerator<T>.Create(FSource.GetEnumerator, FElement);
end;

{ TLQColligoAppendEnumerator<T> }

constructor TLQColligoAppendEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>; const AElement: T);
begin
  FSource := ASource;
  FElement := AElement;
  FSourceDone := False;
  FElementYielded := False;
end;

function TLQColligoAppendEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoAppendEnumerator<T>.MoveNext: Boolean;
begin
  if not FSourceDone then
  begin
    if FSource.MoveNext then
    begin
      FCurrent := FSource.Current;
      Result := True;
      Exit;
    end;
    FSourceDone := True;
  end;
  if not FElementYielded then
  begin
    FElementYielded := True;
    FCurrent := FElement;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure TLQColligoAppendEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSourceDone := False;
  FElementYielded := False;
end;

end.
