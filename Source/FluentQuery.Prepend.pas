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

unit FluentQuery.Prepend;

interface

uses
  {$IFDEF QUERYABLE}
  FluentQuery.Queryable,
  {$ENDIF}
  SysUtils,
  FluentQuery;

type
  // LINQ Prepend: deferred/streaming — yields one extra element, then the
  // source. Nothing runs until enumeration (no materialization at construction).
  TFluentPrependEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FElement: T;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const AElement: T);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

  TFluentPrependEnumerator<T> = class(TInterfacedObject, IFluentEnumerator<T>)
  private
    FSource: IFluentEnumerator<T>;
    FElement: T;
    FCurrent: T;
    FElementYielded: Boolean;
  public
    constructor Create(const ASource: IFluentEnumerator<T>; const AElement: T);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

{ TFluentPrependEnumerable<T> }

constructor TFluentPrependEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; const AElement: T);
begin
  FSource := ASource;
  FElement := AElement;
end;

function TFluentPrependEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentPrependEnumerator<T>.Create(FSource.GetEnumerator, FElement);
end;

{ TFluentPrependEnumerator<T> }

constructor TFluentPrependEnumerator<T>.Create(const ASource: IFluentEnumerator<T>; const AElement: T);
begin
  FSource := ASource;
  FElement := AElement;
  FElementYielded := False;
end;

function TFluentPrependEnumerator<T>.GetCurrent: T;
begin
  Result := FCurrent;
end;

function TFluentPrependEnumerator<T>.MoveNext: Boolean;
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

procedure TFluentPrependEnumerator<T>.Reset;
begin
  FSource.Reset;
  FElementYielded := False;
end;

end.
