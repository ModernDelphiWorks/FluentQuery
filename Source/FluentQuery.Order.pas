{
  ------------------------------------------------------------------------------
  FluentQuery
  LINQ-inspired fluent query API for Delphi.

  SPDX-License-Identifier: Apache-2.0
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ./FluentQuery.inc}

unit FluentQuery.Order;

interface

uses
  SysUtils,
  Generics.Collections,
  Generics.Defaults,
  FluentQuery;

type
  TFluentOrderEnumerable<T> = class(TFluentEnumerableBase<T>)
  private
    FSource: IFluentEnumerableBase<T>;
    FComparer: IComparer<T>;
  public
    constructor Create(const ASource: IFluentEnumerableBase<T>; const AComparer: IComparer<T>);
    function GetEnumerator: IFluentEnumerator<T>; override;
  end;

implementation

uses
  FluentQuery.OrderBy;

{ TFluentOrderEnumerable<T> }

constructor TFluentOrderEnumerable<T>.Create(const ASource: IFluentEnumerableBase<T>; const AComparer: IComparer<T>);
begin
  FSource := ASource;
  FComparer := AComparer;
  if FComparer = nil then
    FComparer := TComparer<T>.Default;
end;

function TFluentOrderEnumerable<T>.GetEnumerator: IFluentEnumerator<T>;
begin
  Result := TFluentOrderByEnumerator<T>.Create(FSource.GetEnumerator,
    function(A, B: T): Integer
    begin
      Result := FComparer.Compare(A, B);
    end);
end;

end.



