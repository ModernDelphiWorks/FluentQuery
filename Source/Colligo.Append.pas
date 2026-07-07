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

unit Colligo.Append;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Colligo;

type
  // LINQ Append: deferred/streaming — yields the source, then one extra element.
  // Nothing runs until enumeration (no materialization at construction).
  TColligoAppendEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FElement: T;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const AElement: T);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoAppendEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FElement: T;
    FCurrent: T;
    FSourceDone: Boolean;
    FElementYielded: Boolean;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const AElement: T);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoAppendEnumerable<T> }

constructor TColligoAppendEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>; const AElement: T);
begin
  FSource := ASource;
  FElement := AElement;
end;

function TColligoAppendEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoAppendEnumerator<T>.Create(FSource.GetEnumerator, FElement);
end;

{ TColligoAppendEnumerator<T> }

constructor TColligoAppendEnumerator<T>.Create(const ASource: IColligoEnumerator<T>; const AElement: T);
begin
  FSource := ASource;
  FElement := AElement;
  FSourceDone := False;
  FElementYielded := False;
end;

function TColligoAppendEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoAppendEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoAppendEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSourceDone := False;
  FElementYielded := False;
end;

end.
