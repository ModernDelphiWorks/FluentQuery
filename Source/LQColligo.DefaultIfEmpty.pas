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

unit LQColligo.DefaultIfEmpty;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  LQColligo;

type
  // LINQ DefaultIfEmpty: deferred/streaming — yields the source unchanged, or a
  // single default value if the source is empty. Nothing runs until enumeration
  // (no materialization at construction).
  TFluentDefaultIfEmptyEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FDefault: T;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const ADefault: T);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentDefaultIfEmptyEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FDefault: T;
    FCurrent: T;
    FYieldedAny: Boolean;
    FDefaultYielded: Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const ADefault: T);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentDefaultIfEmptyEnumerable<T> }

constructor TFluentDefaultIfEmptyEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; const ADefault: T);
begin
  FSource := ASource;
  FDefault := ADefault;
end;

function TFluentDefaultIfEmptyEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentDefaultIfEmptyEnumerator<T>.Create(FSource.GetEnumerator, FDefault);
end;

{ TFluentDefaultIfEmptyEnumerator<T> }

constructor TFluentDefaultIfEmptyEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; const ADefault: T);
begin
  FSource := ASource;
  FDefault := ADefault;
  FYieldedAny := False;
  FDefaultYielded := False;
end;

function TFluentDefaultIfEmptyEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentDefaultIfEmptyEnumerator<T>.MoveNext: Boolean;
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

procedure TFluentDefaultIfEmptyEnumerator<T>.Reset;
begin
  FSource.Reset;
  FYieldedAny := False;
  FDefaultYielded := False;
end;

end.
