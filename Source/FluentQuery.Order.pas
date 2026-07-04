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
var
  LComparers: TArray<TFunc<T, T, Integer>>;
begin
  SetLength(LComparers, 1);
  LComparers[0] :=
    function(A, B: T): Integer
    begin
      Result := FComparer.Compare(A, B);
    end;
  Result := TFluentOrderByEnumerator<T>.Create(FSource.GetEnumerator, LComparers);
end;

end.



