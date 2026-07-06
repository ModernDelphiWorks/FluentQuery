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

unit LQColligo.Prepend;

interface

uses
  {$IFDEF QUERYABLE}
  LQColligo.Queryable,
  {$ENDIF}
  SysUtils,
  LQColligo;

type
  // LINQ Prepend: deferred/streaming — yields one extra element, then the
  // source. Nothing runs until enumeration (no materialization at construction).
  TLQColligoPrependEnumerable<T> = class(TLQColligoEnumerableBase<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FElement: T;
  public
    constructor Create(const ASource: ILQColligoEnumerableBase<T>; const AElement: T);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
  end;

  TLQColligoPrependEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private
    FSource: ILQColligoEnumerator<T>;
    FElement: T;
    FCurrent: T;
    FElementYielded: Boolean;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>; const AElement: T);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TLQColligoPrependEnumerable<T> }

constructor TLQColligoPrependEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>; const AElement: T);
begin
  FSource := ASource;
  FElement := AElement;
end;

function TLQColligoPrependEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoPrependEnumerator<T>.Create(FSource.GetEnumerator, FElement);
end;

{ TLQColligoPrependEnumerator<T> }

constructor TLQColligoPrependEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>; const AElement: T);
begin
  FSource := ASource;
  FElement := AElement;
  FElementYielded := False;
end;

function TLQColligoPrependEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TLQColligoPrependEnumerator<T>.MoveNext: Boolean;
begin
  if not FElementYielded then
  begin
    FElementYielded := True;
    FCurrent := FElement;
    Result := True;
    Exit;
  end;
  if FSource.MoveNext then
  begin
    FCurrent := FSource.Current;
    Result := True;
    Exit;
  end;
  Result := False;
end;

procedure TLQColligoPrependEnumerator<T>.Reset;
begin
  FSource.Reset;
  FElementYielded := False;
end;

end.
