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

unit Colligo.DefaultIfEmpty;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Colligo;

type
  // LINQ DefaultIfEmpty: deferred/streaming — yields the source unchanged, or a
  // single default value if the source is empty. Nothing runs until enumeration
  // (no materialization at construction).
  TColligoDefaultIfEmptyEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FDefault: T;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const ADefault: T);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoDefaultIfEmptyEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FDefault: T;
    FCurrent: T;
    FYieldedAny: Boolean;
    FDefaultYielded: Boolean;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const ADefault: T);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoDefaultIfEmptyEnumerable<T> }

constructor TColligoDefaultIfEmptyEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>; const ADefault: T);
begin
  FSource := ASource;
  FDefault := ADefault;
end;

function TColligoDefaultIfEmptyEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoDefaultIfEmptyEnumerator<T>.Create(FSource.GetEnumerator, FDefault);
end;

{ TColligoDefaultIfEmptyEnumerator<T> }

constructor TColligoDefaultIfEmptyEnumerator<T>.Create(const ASource: IColligoEnumerator<T>; const ADefault: T);
begin
  FSource := ASource;
  FDefault := ADefault;
  FYieldedAny := False;
  FDefaultYielded := False;
end;

function TColligoDefaultIfEmptyEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoDefaultIfEmptyEnumerator<T>.MoveNext: Boolean;
begin
  if FSource.MoveNext then
  begin
    FCurrent := FSource.Current;
    FYieldedAny := True;
    Result := True;
    Exit;
  end;
  // Source exhausted: emit the default exactly once, and only if the source
  // never produced any element.
  if (not FYieldedAny) and (not FDefaultYielded) then
  begin
    FDefaultYielded := True;
    FCurrent := FDefault;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure TColligoDefaultIfEmptyEnumerator<T>.Reset;
begin
  FSource.Reset;
  FYieldedAny := False;
  FDefaultYielded := False;
end;

end.
