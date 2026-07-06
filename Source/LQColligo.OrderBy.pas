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

unit LQColligo.OrderBy;

interface

uses
  SysUtils,
  LQColligo;

type
  // Ordered enumerable carrying the full chain of comparison criteria (primary
  // first). Implements ILQColligoOrderedEnumerable<T> so ThenBy can append a
  // subordinate criterion producing a new ordered enumerable over the SAME
  // source. Serves OrderBy/OrderByDescending/Order/OrderDescending.
  TLQColligoOrderByEnumerable<T> = class(TLQColligoEnumerableBase<T>, ILQColligoOrderedEnumerable<T>)
  private
    FSource: ILQColligoEnumerableBase<T>;
    FComparers: TArray<TFunc<T, T, Integer>>;
    constructor CreateChain(const ASource: ILQColligoEnumerableBase<T>;
      const AComparers: TArray<TFunc<T, T, Integer>>);
  public
    // Primary ordering: a single comparison criterion. ThenByAppend extends the chain.
    constructor Create(const ASource: ILQColligoEnumerableBase<T>;
      const AComparer: TFunc<T, T, Integer>);
    function GetEnumerator: ILQColligoEnumerator<T>; override;
    function ThenByAppend(const AComparer: TFunc<T, T, Integer>): ILQColligoOrderedEnumerable<T>;
  end;

  TLQColligoOrderByEnumerator<T> = class(TInterfacedObject, ILQColligoEnumerator<T>)
  private type
    TIndexedItem = record
      Value: T;
      Index: Integer;
    end;
  private
    FItems: TArray<T>;
    FIndex: Integer;
  public
    constructor Create(const ASource: ILQColligoEnumerator<T>;
      const AComparers: TArray<TFunc<T, T, Integer>>);
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;
    property Current: T read GetCurrent;
  end;

implementation

uses
  Generics.Collections,
  Generics.Defaults;

{ TLQColligoOrderByEnumerable<T> }

constructor TLQColligoOrderByEnumerable<T>.Create(const ASource: ILQColligoEnumerableBase<T>;
  const AComparer: TFunc<T, T, Integer>);
begin
  FSource := ASource;
  SetLength(FComparers, 1);
  FComparers[0] := AComparer;
end;

constructor TLQColligoOrderByEnumerable<T>.CreateChain(const ASource: ILQColligoEnumerableBase<T>;
  const AComparers: TArray<TFunc<T, T, Integer>>);
begin
  FSource := ASource;
  FComparers := AComparers;
end;

function TLQColligoOrderByEnumerable<T>.GetEnumerator: ILQColligoEnumerator<T>;
begin
  Result := TLQColligoOrderByEnumerator<T>.Create(FSource.GetEnumerator, FComparers);
end;

function TLQColligoOrderByEnumerable<T>.ThenByAppend(
  const AComparer: TFunc<T, T, Integer>): ILQColligoOrderedEnumerable<T>;
var
  LNew: TArray<TFunc<T, T, Integer>>;
  LFor: Integer;
begin
  SetLength(LNew, Length(FComparers) + 1);
  for LFor := 0 to High(FComparers) do
    LNew[LFor] := FComparers[LFor];
  LNew[High(LNew)] := AComparer;
  Result := TLQColligoOrderByEnumerable<T>.CreateChain(FSource, LNew);
end;

{ TLQColligoOrderByEnumerator<T> }

constructor TLQColligoOrderByEnumerator<T>.Create(const ASource: ILQColligoEnumerator<T>;
  const AComparers: TArray<TFunc<T, T, Integer>>);
var
  LList: TList<TIndexedItem>;
  LIndexed: TArray<TIndexedItem>;
  LRec: TIndexedItem;
  LFor: Integer;
begin
  // Buffer the whole source, tagging each element with its original position so
  // the sort can be made STABLE (LINQ's OrderBy/ThenBy guarantee stability, but
  // the RTL sort is introsort — not stable). Every element is preserved,
  // including Default(T) values.
  LList := TList<TIndexedItem>.Create;
  try
    while ASource.MoveNext do
    begin
      LRec.Value := ASource.Current;
      LRec.Index := LList.Count;
      LList.Add(LRec);
    end;
    LIndexed := LList.ToArray;
  finally
    LList.Free;
  end;

  // Composite comparator: apply each criterion in order (primary dominant); the
  // first non-zero result wins. On a full tie, fall back to the original index
  // so equal elements keep their input order (stability).
  TArray.Sort<TIndexedItem>(LIndexed, TComparer<TIndexedItem>.Construct(
    function(const Left, Right: TIndexedItem): Integer
    var
      LCrit: Integer;
    begin
      Result := 0;
      for LCrit := 0 to High(AComparers) do
      begin
        Result := AComparers[LCrit](Left.Value, Right.Value);
        if Result <> 0 then
          Exit;
      end;
      Result := Left.Index - Right.Index;
    end));

  SetLength(FItems, Length(LIndexed));
  for LFor := 0 to High(LIndexed) do
    FItems[LFor] := LIndexed[LFor].Value;
  FIndex := -1;
end;

function TLQColligoOrderByEnumerator<T>.GetCurrent: T;
begin
  Result := FItems[FIndex];
end;

function TLQColligoOrderByEnumerator<T>.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result := FIndex < Length(FItems);
end;

procedure TLQColligoOrderByEnumerator<T>.Reset;
begin
  FIndex := -1;
end;

end.
