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
  TFluentAppendEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FElement: T;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const AElement: T);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentAppendEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FElement: T;
    FCurrent: T;
    FSourceDone: Boolean;
    FElementYielded: Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const AElement: T);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentAppendEnumerable<T> }

constructor TFluentAppendEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; const AElement: T);
begin
  FSource := ASource;
  FElement := AElement;
end;

function TFluentAppendEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentAppendEnumerator<T>.Create(FSource.GetEnumerator, FElement);
end;

{ TFluentAppendEnumerator<T> }

constructor TFluentAppendEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; const AElement: T);
begin
  FSource := ASource;
  FElement := AElement;
  FSourceDone := False;
  FElementYielded := False;
end;

function TFluentAppendEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentAppendEnumerator<T>.MoveNext: Boolean;
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

procedure TFluentAppendEnumerator<T>.Reset;
begin
  FSource.Reset;
  FSourceDone := False;
  FElementYielded := False;
end;

end.
