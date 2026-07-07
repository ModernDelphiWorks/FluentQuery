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

unit Colligo.Prepend;

interface

uses
  {$IFDEF QUERYABLE}
  Colligo.Queryable,
  {$ENDIF}
  SysUtils,
  Colligo;

type
  // LINQ Prepend: deferred/streaming — yields one extra element, then the
  // source. Nothing runs until enumeration (no materialization at construction).
  TColligoPrependEnumerable<T> = class(TColligoEnumerableBase<T>)
  private
    FSource: IColligoEnumerableBase<T>;
    FElement: T;
  public
    constructor Create(const ASource: IColligoEnumerableBase<T>; const AElement: T);
    function GetEnumerator: IColligoEnumerator<T>; override;
  end;

  TColligoPrependEnumerator<T> = class(TInterfacedObject, IColligoEnumerator<T>)
  private
    FSource: IColligoEnumerator<T>;
    FElement: T;
    FCurrent: T;
    FElementYielded: Boolean;
  public
    constructor Create(const ASource: IColligoEnumerator<T>; const AElement: T);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TColligoPrependEnumerable<T> }

constructor TColligoPrependEnumerable<T>.Create(const ASource: IColligoEnumerableBase<T>; const AElement: T);
begin
  FSource := ASource;
  FElement := AElement;
end;

function TColligoPrependEnumerable<T>.GetEnumerator: IColligoEnumerator<T>;
begin
  Result := TColligoPrependEnumerator<T>.Create(FSource.GetEnumerator, FElement);
end;

{ TColligoPrependEnumerator<T> }

constructor TColligoPrependEnumerator<T>.Create(const ASource: IColligoEnumerator<T>; const AElement: T);
begin
  FSource := ASource;
  FElement := AElement;
  FElementYielded := False;
end;

function TColligoPrependEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TColligoPrependEnumerator<T>.MoveNext: Boolean;
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

procedure TColligoPrependEnumerator<T>.Reset;
begin
  FSource.Reset;
  FElementYielded := False;
end;

end.
