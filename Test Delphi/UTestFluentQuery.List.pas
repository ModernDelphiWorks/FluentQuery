unit UTestFluentQuery.List;

interface

uses
  Classes,
  SysUtils,
  Variants,
  DUnitX.TestFramework,
  Generics.Collections,
  Generics.Defaults,
  LQColligo,
  LQColligo.Core,
  LQColligo.Collections;

type
  TProduct = class
  private
    FName: String;
    FPrice: Double;
    FDescount: Double;
  public
    constructor Create(AName: String; APrice: Double; ADescount: Double);
    function Price: Double;
    function Descount: Double;
  end;

  TOrderRec = record
    K1: Integer;
    K2: Integer;
    Seq: Integer;
  end;

  TListTest = class
  private
    FList: IFluentList<Integer>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestListToArray;
    [Test]
    procedure TestListToArrayNonDestructive;
    [Test]
    procedure TestListFromDoesNotLeak;
    [Test]
    procedure TestListToList;
    [Test]
    procedure TestListCount;
    [Test]
    procedure TestListAny;
    [Test]
    procedure TestListFirstOrDefault;
    [Test]
    procedure TestListLastOrDefault;
    [Test]
    procedure TestListMin;
    [Test]
    procedure TestListMax;
    [Test]
    procedure TestListSum;
    [Test]
    procedure TestListReduce;
    [Test]
    procedure TestListDistinct;
    [Test]
    procedure TestListFilter;
    [Test]
    procedure TestListTake;
    [Test]
    procedure TestListSkip;
    [Test]
    procedure TestListOrderBy;
    [Test]
    procedure TestListOrderByThenBy;
    [Test]
    procedure TestListOrderByThenByDescending;
    [Test]
    procedure TestListThenByWithoutOrderByRaises;
    [Test]
    procedure TestListLongCount;
    [Test]
    procedure TestListMap;
    [Test]
    procedure TestListGroupBy;
    [Test]
    procedure TestListGroupByFirstAppearanceOrder;
    [Test]
    procedure TestListGroupByComparer;
    [Test]
    procedure TestListGroupByReEnumerable;
    [Test]
    procedure TestListGroupByMaterializedSurvives;
    [Test]
    procedure TestListZip;
    [Test]
    procedure TestListJoin;
    [Test]
    procedure TestListJoinMultipleMatches;
    [Test]
    procedure TestListSumIntegerOverflowRaises;
    [Test]
    procedure TestListSumInt64NoWrap;
    [Test]
    procedure TestListMapLazy;
    [Test]
    procedure TestListOrderByLazy;
    [Test]
    procedure TestListDistinctLazy;
    [Test]
    procedure TestListZipLazy;
    [Test]
    procedure TestListJoinLazy;
    [Test]
    procedure TestListOfType;
    [Test]
    procedure TestListCastSuccess;
    [Test]
    procedure TestListCastDeferredRaises;
    [Test]
    procedure TestListCastStreamsBeforeRaise;
    [Test]
    procedure TestListMinBy;
    [Test]
    procedure TestListMaxBy;
    [Test]
    procedure TestListLast;
    [Test]
    procedure TestListSumDouble;
    [Test]
    procedure TestListMinWithComparer;
    [Test]
    procedure TestListReduceNoInitial;
    [Test]
    procedure TestListSelectMany;
    [Test]
    procedure TestListGroupJoin;
    [Test]
    procedure TestListTakeWhile;
    [Test]
    procedure TestListSkipWhile;
    [Test]
    procedure TestListAverage;
    [Test]
    procedure TestListSumNullableAllNullIsZero;
    [Test]
    procedure TestListSumNullableIgnoresNulls;
    [Test]
    procedure TestListAverageNullableAllNullIsNull;
    [Test]
    procedure TestListAverageNullableIgnoresNulls;
    [Test]
    procedure TestListAverageEmptyRaises;
    [Test]
    procedure TestListSumNullableEmptyIsZero;
    [Test]
    procedure TestListAverageNullableCurrencyAllNull;
    [Test]
    procedure TestListAverageNullableCurrencyValues;
    [Test]
    procedure TestListExclude;
    [Test]
    procedure TestListExcludeDistinct;
    [Test]
    procedure TestListExcludeReEnumerable;
    [Test]
    procedure TestListExcludeAllExcludedIsEmpty;
    [Test]
    procedure TestListExcludeWithComparer;
    [Test]
    procedure TestListIntersectWithComparer;
    [Test]
    procedure TestListUnionWithComparer;
    [Test]
    procedure TestListJoinWithComparer;
    [Test]
    procedure TestListAppendDeferred;
    [Test]
    procedure TestListPrependDeferred;
    [Test]
    procedure TestListDefaultIfEmptyDeferred;
    [Test]
    procedure TestListDefaultIfEmptyEmptyYieldsDefault;
    [Test]
    procedure TestListAppendPrependEmptySource;
    [Test]
    procedure TestListDefaultIfEmptyNoArgEmpty;
    [Test]
    procedure TestListAppendReEnumerable;
    [Test]
    procedure TestListDistinctByDeferred;
    [Test]
    procedure TestListUnionByDeferred;
    [Test]
    procedure TestListExcludeByDistinctDeferred;
    [Test]
    procedure TestListIntersectByDistinctDeferred;
    [Test]
    procedure TestListExcludeByReEnumerable;
    [Test]
    procedure TestListReverseDeferred;
    [Test]
    procedure TestListTakeLastDeferred;
    [Test]
    procedure TestListSkipLastDeferred;
    [Test]
    procedure TestListTakeLastSkipLastEdges;
    [Test]
    procedure TestListReverseEmptyAndReEnumerable;
    [Test]
    procedure TestListDistinctByWithComparer;
    [Test]
    procedure TestListUnionByWithComparer;
    [Test]
    procedure TestListExcludeByWithComparer;
    [Test]
    procedure TestListIntersectByWithComparer;
    [Test]
    procedure TestFluentQueryRange;
    [Test]
    procedure TestFluentQueryRepeat;
    [Test]
    procedure TestFluentQueryEmpty;
    [Test]
    procedure TestFluentQueryGeneratorValidation;
    [Test]
    procedure TestListChunk;
    [Test]
    procedure TestListChunkEdges;
    [Test]
    procedure TestListGetListNonDestructive;
    [Test]
    procedure TestListIntersect;
    [Test]
    procedure TestListIntersectDistinct;
    [Test]
    procedure TestListIntersectSecondWithDuplicates;
    [Test]
    procedure TestListUnion;
    [Test]
    procedure TestListConcat;
    [Test]
    procedure TestListAll;
    [Test]
    procedure TestListContains;
    [Test]
    procedure TestListSequenceEqual;
    [Test]
    procedure TestListSequenceEqualNegative;
    [Test]
    procedure TestListAllNegative;
    [Test]
    procedure TestListSingle;
    [Test]
    procedure TestListSingleMultipleElements;
    [Test]
    procedure TestListSingleOrDefault;
    [Test]
    procedure TestListElementAt;
    [Test]
    procedure TestListElementAtOrDefault;
    [Test]
    procedure TestListElementAtOutOfRange;
    [Test]
    procedure TestListOrderByDescending;
    [Test]
    procedure TestList_SelectMany;
    [Test]
    procedure TestList_SelectManyAutoManaged;
    [Test]
    procedure TestListReduceGeneric;
    [Test]
    procedure TestListToDictionary;
  end;

implementation

{ TProduct }

constructor TProduct.Create(AName: String; APrice, ADescount: Double);
begin
  FName := AName;
  FPrice := APrice;
  FDescount := ADescount;
end;

function TProduct.Descount: Double;
begin
  Result := FDescount;
end;

function TProduct.Price: Double;
begin
  Result := FPrice;
end;

{ TListTest }

procedure TListTest.Setup;
begin
  FList := TFluentList<Integer>.Create;
end;

procedure TListTest.TearDown;
begin

end;

procedure TListTest.TestListToArray;
var
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LArray := FList.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Array length should be 5');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(5, LArray[4], 'Last element should be 5');
end;

procedure TListTest.TestListToList;
var
  LResult: IFluentList<Integer>;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LResult := FList.AsEnumerable.ToList;
  Assert.AreEqual(5, LResult.Count, 'List count should be 5');
  Assert.AreEqual(1, LResult[0], 'First element should be 1');
  Assert.AreEqual(5, LResult[4], 'Last element should be 5');
end;

procedure TListTest.TestListCount;
var
  LCount: Integer;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LCount := FList.AsEnumerable.Count(
    function(Value: Integer): Boolean
    begin
      Result := Value > 2;
    end);
  Assert.AreEqual(3, LCount, 'Count of elements > 2 should be 3');
end;

procedure TListTest.TestListAny;
var
  LHasEven: Boolean;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LHasEven := FList.AsEnumerable.Any(
    function(Value: Integer): Boolean
    begin
      Result := Value mod 2 = 0;
    end);
  Assert.IsTrue(LHasEven, 'List should contain at least one even number');
end;

procedure TListTest.TestListFirstOrDefault;
var
  LFirstEven: Integer;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LFirstEven := FList.AsEnumerable.FirstOrDefault(
    function(Value: Integer): Boolean
    begin
      Result := Value mod 2 = 0;
    end);
  Assert.AreEqual(2, LFirstEven, 'First even number should be 2');
end;

procedure TListTest.TestListLastOrDefault;
var
  LLastEven: Integer;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LLastEven := FList.AsEnumerable.LastOrDefault(
    function(Value: Integer): Boolean
    begin
      Result := Value mod 2 = 0;
    end);
  Assert.AreEqual(4, LLastEven, 'Last even number should be 4');
end;

procedure TListTest.TestListMin;
var
  LMin: Integer;
begin
  FList.AddRange([3, 1, 4, 1, 5]);
  LMin := FList.AsEnumerable.Min;
  Assert.AreEqual(1, LMin, 'Minimum value should be 1');
end;

procedure TListTest.TestListMax;
var
  LMax: Integer;
begin
  FList.AddRange([3, 1, 4, 1, 5]);
  LMax := FList.AsEnumerable.Max;
  Assert.AreEqual(5, LMax, 'Maximum value should be 5');
end;

procedure TListTest.TestListSum;
var
  LSum: Integer;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LSum := FList.AsEnumerable.Sum(
    function(Value: Integer): Integer
    begin
      Result := Value;
    end);
  Assert.AreEqual(15, LSum, 'Sum of elements should be 15');
end;

procedure TListTest.TestListReduce;
var
  LSum: Integer;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LSum := FList.AsEnumerable.Aggregate(
    function(Acc, Value: Integer): Integer
    begin
      Result := Acc + Value;
    end);
  Assert.AreEqual(15, LSum, 'Reduced sum of elements should be 15');
end;

procedure TListTest.TestListDistinct;
var
  LDistinct: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 2, 3, 3, 4, 5, 5]);
  LDistinct := FList.AsEnumerable.Distinct;
  LArray := LDistinct.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Distinct list should have 5 unique elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(5, LArray[4], 'Last element should be 5');
end;

procedure TListTest.TestListFilter;
var
  LFiltered: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LFiltered := FList.AsEnumerable.Where(
    function(Value: Integer): Boolean
    begin
      Result := Value > 3;
    end);
  LArray := LFiltered.ToArray;
  Assert.AreEqual(2, LArray.Length, 'Filtered list should have 2 elements');
  Assert.AreEqual(4, LArray[0], 'First element should be 4');
  Assert.AreEqual(5, LArray[1], 'Last element should be 5');
end;

procedure TListTest.TestListTake;
var
  LTaken: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LTaken := FList.AsEnumerable.Take(3);
  LArray := LTaken.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Taken list should have 3 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(3, LArray[2], 'Last element should be 3');
end;

procedure TListTest.TestListSkip;
var
  LSkipped: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LSkipped := FList.AsEnumerable.Skip(2);
  LArray := LSkipped.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Skipped list should have 3 elements');
  Assert.AreEqual(3, LArray[0], 'First element should be 3');
  Assert.AreEqual(5, LArray[2], 'Last element should be 5');
end;

procedure TListTest.TestListOrderBy;
var
  LOrdered: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([5, 2, 4, 1, 3]);
  LOrdered := FList.AsEnumerable.OrderBy(
    function(A, B: Integer): Integer
    begin
      Result := A - B;
    end);
  LArray := LOrdered.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Ordered list should have 5 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(5, LArray[4], 'Last element should be 5');
end;

procedure TListTest.TestListLongCount;
var
  LCount: Int64;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LCount := FList.AsEnumerable.LongCount(
    function(Value: Integer): Boolean
    begin
      Result := Value > 2;
    end);
  Assert.AreEqual(Int64(3), LCount, 'Count of elements > 2 should be 3');
end;

procedure TListTest.TestListMap;
var
  LMapped: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LMapped := FList.AsEnumerable.Select<Integer>(
    function(Value: Integer): Integer
    begin
      Result := Value * 2;
    end);
  LArray := LMapped.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Mapped list should have 5 elements');
  Assert.AreEqual(2, LArray[0], 'First element should be 2');
  Assert.AreEqual(10, LArray[4], 'Last element should be 10');
end;

procedure TListTest.TestListGroupBy;
var
  LGroups: IGroupByEnumerable<Integer, Integer>;
  LEnum: IFluentEnumerator<IGrouping<Integer, Integer>>;
  LGroup: IGrouping<Integer, Integer>;
  LArray: IFluentArray<Integer>;
  LCount: Integer;
begin
  FList.AddRange([1, 2, 3, 4, 5, 6]);
  LGroups := FList.AsEnumerable.GroupBy<Integer>(
    function(Value: Integer): Integer
    begin
      Result := Value mod 2;
    end);
  LEnum := LGroups.GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    Inc(LCount);
    LGroup := LEnum.Current;
    if LGroup.Key = 0 then
    begin
      LArray := LGroup.Items.ToArray;
      Assert.AreEqual(3, LArray.Length, 'Group of evens should have 3 elements');
      Assert.AreEqual(2, LArray[0], 'First even should be 2');
      Assert.AreEqual(6, LArray[2], 'Last even should be 6');
    end
    else if LGroup.Key = 1 then
    begin
      LArray := LGroup.Items.ToArray;
      Assert.AreEqual(3, LArray.Length, 'Group of odds should have 3 elements');
      Assert.AreEqual(1, LArray[0], 'First odd should be 1');
      Assert.AreEqual(5, LArray[2], 'Last odd should be 5');
    end;
  end;
  Assert.AreEqual(2, LCount, 'Should have 2 groups');
end;

procedure TListTest.TestListGroupByFirstAppearanceOrder;
var
  LGroups: IGroupByEnumerable<Integer, Integer>;
  LEnum: IFluentEnumerator<IGrouping<Integer, Integer>>;
  LKeys: TList<Integer>;
begin
  // Odd key (1) appears before even key (0); group order must follow
  // first appearance of the key, not TDictionary hash order.
  FList.AddRange([3, 1, 2, 4]);
  LGroups := FList.AsEnumerable.GroupBy<Integer>(
    function(Value: Integer): Integer
    begin
      Result := Value mod 2;
    end);
  LKeys := TList<Integer>.Create;
  try
    LEnum := LGroups.GetEnumerator;
    while LEnum.MoveNext do
      LKeys.Add(LEnum.Current.Key);
    Assert.AreEqual(2, LKeys.Count, 'Should have 2 groups');
    Assert.AreEqual(1, LKeys[0], 'First group must be the odd key (first appearance)');
    Assert.AreEqual(0, LKeys[1], 'Second group must be the even key');
  finally
    LKeys.Free;
  end;
end;

procedure TListTest.TestListGroupByComparer;
var
  LWords: IFluentList<string>;
  LGroups: IGroupByEnumerable<string, string>;
  LEnum: IFluentEnumerator<IGrouping<string, string>>;
  LCount: Integer;
begin
  // Case-insensitive comparer: 'a'/'A'/'a' collapse into one group.
  LWords := TFluentList<string>.Create;
  LWords.AddRange(['a', 'A', 'b', 'a']);
  LGroups := LWords.AsEnumerable.GroupBy<string>(
    function(Value: string): string
    begin
      Result := Value;
    end,
    TIStringComparer.Ordinal);
  LEnum := LGroups.GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    Inc(LCount);
    if SameText(LEnum.Current.Key, 'a') then
      Assert.AreEqual(3, LEnum.Current.Items.ToArray.Length,
        'Case-insensitive group "a" should have 3 elements');
  end;
  Assert.AreEqual(2, LCount, 'Case-insensitive grouping should yield 2 groups');
end;

procedure TListTest.TestListGroupByReEnumerable;
var
  LGroups: IGroupByEnumerable<Integer, Integer>;
  LEnum: IFluentEnumerator<IGrouping<Integer, Integer>>;
  LFirst, LSecond: Integer;
begin
  // Re-enumerating (via Reset) must reproduce the same groups; the old
  // implementation mutated the dictionary during MoveNext, breaking this.
  FList.AddRange([1, 2, 3, 4, 5, 6]);
  LGroups := FList.AsEnumerable.GroupBy<Integer>(
    function(Value: Integer): Integer
    begin
      Result := Value mod 2;
    end);
  LEnum := LGroups.GetEnumerator;

  LFirst := 0;
  while LEnum.MoveNext do
    Inc(LFirst);
  Assert.AreEqual(2, LFirst, 'First pass should yield 2 groups');

  LEnum.Reset;
  LSecond := 0;
  while LEnum.MoveNext do
    Inc(LSecond);
  Assert.AreEqual(2, LSecond, 'Second pass after Reset should yield 2 groups');
end;

procedure TListTest.TestListGroupByMaterializedSurvives;
var
  LGroups: IFluentList<IGrouping<Integer, Integer>>;
  LGroup: IGrouping<Integer, Integer>;
  LTotal: Integer;
begin
  // Materialize the groups first, then read Items AFTER the underlying
  // GroupBy enumerator has been released. Each grouping owns its own copy,
  // so this must not be a use-after-free.
  FList.AddRange([1, 2, 3, 4, 5, 6]);
  LGroups := FList.AsEnumerable.GroupBy<Integer>(
    function(Value: Integer): Integer
    begin
      Result := Value mod 2;
    end).AsEnumerable.ToList;

  Assert.AreEqual(2, LGroups.Count, 'Should have 2 materialized groups');
  LTotal := 0;
  for LGroup in LGroups do
    LTotal := LTotal + LGroup.Items.ToArray.Length;
  Assert.AreEqual(6, LTotal, 'Materialized groups should still expose all 6 elements');
end;

procedure TListTest.TestListGroupJoin;
var
  LInner: IFluentList<string>;
  LJoined: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  FList.AddRange([1, 2, 3]);
  LInner := TFluentList<string>.Create;
  LInner.AddRange(['A1', 'B1', 'C2']);
  LJoined := FList.AsEnumerable.GroupJoin<string, Integer, string>(
    LInner.AsEnumerable,
    function(Num: Integer): Integer
    begin
      Result := Num;
    end,
    function(Str: string): Integer
    begin
      Result := StrToInt(Str[2]);
    end,
    function(Num: Integer; Matches: IFluentEnumerableAdapter<string>): string
    begin
      Result := Num.ToString + ': ' + string.Join(', ', Matches.AsEnumerable.ToArray.ArrayData);
    end);
  LArray := LJoined.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Joined list should have 3 elements');
  Assert.AreEqual('1: A1, B1', LArray[0], 'First element should be "1: A1, B1"');
  Assert.AreEqual('2: C2', LArray[1], 'Second element should be "2: C2"');
  Assert.AreEqual('3: ', LArray[2], 'Third element should be "3: "');
end;

procedure TListTest.TestListZip;
var
  LList2: IFluentList<string>;
  LZipped: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  FList.AddRange([1, 2, 3]);
  LList2 := TFluentList<string>.Create;
  LList2.AddRange(['A', 'B', 'C']);
  LZipped := FList.AsEnumerable.Zip<string, string>(
    LList2.AsEnumerable,
    function(Num: Integer; Letter: string): string
    begin
      Result := Num.ToString + Letter;
    end);
  LArray := LZipped.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Zipped list should have 3 elements');
  Assert.AreEqual('1A', LArray[0], 'First element should be "1A"');
  Assert.AreEqual('2B', LArray[1], 'Second element should be "2B"');
  Assert.AreEqual('3C', LArray[2], 'Third element should be "3C"');
end;

procedure TListTest.TestListJoin;
var
  LInner: IFluentList<string>;
  LJoined: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  FList.AddRange([1, 2, 3]);
  LInner := TFluentList<string>.Create;
  LInner.AddRange(['A1', 'B2', 'C3']);
  LJoined := FList.AsEnumerable.Join<string, Integer, string>(
    LInner.AsEnumerable,
    function(Num: Integer): Integer
    begin
      Result := Num;
    end,
    function(Str: string): Integer
    begin
      Result := StrToInt(Str[2]);
    end,
    function(Num: Integer; Str: string): string
    begin
      Result := Str + '-' + Num.ToString;
    end);
  LArray := LJoined.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Joined list should have 3 elements');
  Assert.AreEqual('A1-1', LArray[0], 'First element should be "A1-1"');
  Assert.AreEqual('B2-2', LArray[1], 'Second element should be "B2-2"');
  Assert.AreEqual('C3-3', LArray[2], 'Third element should be "C3-3"');
end;

procedure TListTest.TestListJoinMultipleMatches;
var
  LInner: IFluentList<string>;
  LJoined: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  // Outer key 1 matches two inner rows; the hash join must emit BOTH, in inner
  // order, and preserve outer order (1 before 2).
  FList.AddRange([1, 2]);
  LInner := TFluentList<string>.Create;
  LInner.AddRange(['A1', 'B1', 'C2']);
  LJoined := FList.AsEnumerable.Join<string, Integer, string>(
    LInner.AsEnumerable,
    function(Num: Integer): Integer
    begin
      Result := Num;
    end,
    function(Str: string): Integer
    begin
      Result := StrToInt(Str[2]);
    end,
    function(Num: Integer; Str: string): string
    begin
      Result := Num.ToString + ':' + Str;
    end);
  LArray := LJoined.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Should emit one row per matching pair');
  Assert.AreEqual('1:A1', LArray[0], 'Outer 1, first inner match');
  Assert.AreEqual('1:B1', LArray[1], 'Outer 1, second inner match (inner order)');
  Assert.AreEqual('2:C2', LArray[2], 'Outer 2 match after outer 1');
end;

procedure TListTest.TestListSumIntegerOverflowRaises;
begin
  // C#-parity: overflowing an Integer Sum must raise, not silently wrap.
  FList.AddRange([High(Integer), 1]);
  Assert.WillRaise(
    procedure
    begin
      FList.AsEnumerable.Sum(
        function(Value: Integer): Integer
        begin
          Result := Value;
        end);
    end,
    EIntOverflow);
end;

procedure TListTest.TestListSumInt64NoWrap;
var
  LSum: Int64;
begin
  // Three values that each fit in Integer but whose total exceeds Integer range;
  // the Int64 Sum overload must return the exact total without wrapping.
  FList.AddRange([1, 2, 3]);
  LSum := FList.AsEnumerable.Sum(
    function(Value: Integer): Int64
    begin
      Result := Int64(High(Integer));
    end);
  Assert.AreEqual(Int64(3) * High(Integer), LSum, 'Int64 Sum must not wrap at 32 bits');
end;

procedure TListTest.TestListMapLazy;
var
  LMapped: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  FList.AddRange([1, 2, 3]);
  LMapped := FList.AsEnumerable.Select<string>(
    function(Value: Integer): string
    begin
      Writeln('Mapping: ' + IntToStr(Value));
      Result := Value.ToString + 'x';
    end);
  Writeln('Map chamado, mas ainda n�o iterado');
  LArray := LMapped.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Mapped list should have 3 elements');
  Assert.AreEqual('1x', LArray[0], 'First element should be "1x"');
  Assert.AreEqual('2x', LArray[1], 'Second element should be "2x"');
  Assert.AreEqual('3x', LArray[2], 'Third element should be "3x"');
end;

procedure TListTest.TestListOrderByLazy;
var
  LOrdered: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([3, 1, 4, 1, 5]);
  LOrdered := FList.AsEnumerable.Where(
    function(Value: Integer): Boolean
    begin
      Writeln('Filtering: ' + IntToStr(Value));
      Result := Value > 2;
    end).OrderBy(
    function(A, B: Integer): Integer
    begin
      Writeln('Ordering: ' + IntToStr(A) + ' vs ' + IntToStr(B));
      Result := A - B;
    end);
  Writeln('OrderBy chamado, mas ainda n�o iterado');
  LArray := LOrdered.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Ordered list should have 3 elements');
  Assert.AreEqual(3, LArray[0], 'First element should be 3');
  Assert.AreEqual(4, LArray[1], 'Second element should be 4');
  Assert.AreEqual(5, LArray[2], 'Third element should be 5');
end;

procedure TListTest.TestListDistinctLazy;
var
  LDistinct: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([3, 1, 4, 1, 5, 3]);
  LDistinct := FList.AsEnumerable.Where(
    function(Value: Integer): Boolean
    begin
      Writeln('Filtering: ' + IntToStr(Value));
      Result := Value > 2;
    end).Distinct;
  Writeln('Distinct chamado, mas ainda n�o iterado');
  LArray := LDistinct.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Distinct list should have 3 elements');
  Assert.AreEqual(3, LArray[0], 'First element should be 3');
  Assert.AreEqual(4, LArray[1], 'Second element should be 4');
  Assert.AreEqual(5, LArray[2], 'Third element should be 5');
end;

procedure TListTest.TestListZipLazy;
var
  LList2: IFluentList<string>;
  LZipped: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  FList.AddRange([1, 2, 3]);
  LList2 := TFluentList<string>.Create;
  LList2.AddRange(['A', 'B', 'C']);
  LZipped := FList.AsEnumerable.Zip<string, string>(
    LList2.AsEnumerable,
    function(Num: Integer; Letter: string): string
    begin
      Writeln('Zipping: ' + IntToStr(Num) + ' with ' + Letter);
      Result := Num.ToString + Letter;
    end);
  Writeln('Zip chamado, mas ainda n�o iterado');
  LArray := LZipped.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Zipped list should have 3 elements');
  Assert.AreEqual('1A', LArray[0], 'First element should be "1A"');
  Assert.AreEqual('2B', LArray[1], 'Second element should be "2B"');
  Assert.AreEqual('3C', LArray[2], 'Third element should be "3C"');
end;

procedure TListTest.TestListJoinLazy;
var
  LInner: IFluentList<string>;
  LJoined: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  FList.AddRange([1, 2, 3]);
  LInner := TFluentList<string>.Create;
  LInner.AddRange(['A1', 'B2', 'C3']);
  LJoined := FList.AsEnumerable.Join<string, Integer, string>(
    LInner.AsEnumerable,
    function(Num: Integer): Integer
    begin
      Result := Num;
    end,
    function(Str: string): Integer
    begin
      Result := StrToInt(Str[2]);
    end,
    function(Num: Integer; Str: string): string
    begin
      Writeln('Joining: ' + IntToStr(Num) + ' with ' + Str);
      Result := Str + '-' + Num.ToString;
    end);
  Writeln('Join chamado, mas ainda n�o iterado');
  LArray := LJoined.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Joined list should have 3 elements');
  Assert.AreEqual('A1-1', LArray[0], 'First element should be "A1-1"');
  Assert.AreEqual('B2-2', LArray[1], 'Second element should be "B2-2"');
  Assert.AreEqual('C3-3', LArray[2], 'Third element should be "C3-3"');
end;

procedure TListTest.TestListOfType;
var
  LList: IFluentList<Variant>;
  LFiltered: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  LList := TFluentList<Variant>.Create;
  LList.AddRange([1, 'two', 3, 'four', 5]);
  // OfType<Integer>() with no arguments: filters by runtime type, keeping the
  // integer variants and silently dropping the strings.
  LFiltered := LList.AsEnumerable.OfType<Integer>;
  LArray := LFiltered.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Filtered list should have 3 integers');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(3, LArray[1], 'Second element should be 3');
  Assert.AreEqual(5, LArray[2], 'Third element should be 5');
end;

procedure TListTest.TestListCastSuccess;
var
  LList: IFluentList<Variant>;
  LArray: IFluentArray<Integer>;
begin
  // Every element is convertible: Cast<Integer> converts them all.
  LList := TFluentList<Variant>.Create;
  LList.AddRange([10, 20, 30]);
  LArray := LList.AsEnumerable.Cast<Integer>.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Cast should convert every element');
  Assert.AreEqual(10, LArray[0], 'First cast element');
  Assert.AreEqual(30, LArray[2], 'Last cast element');
end;

procedure TListTest.TestListCastDeferredRaises;
var
  LList: IFluentList<Variant>;
  LCast: IFluentEnumerable<Integer>;
  LRaised: Boolean;
begin
  LList := TFluentList<Variant>.Create;
  LList.AddRange([1, 'two', 3]);
  // Deferred: building the Cast pipeline must NOT raise here (an eager
  // implementation would throw on this line and fail the test before the try).
  LCast := LList.AsEnumerable.Cast<Integer>;
  // The incompatible 'two' raises EInvalidCast only when enumeration reaches it.
  LRaised := False;
  try
    LCast.ToArray;
  except
    on E: EInvalidCast do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'Cast must raise EInvalidCast per element during enumeration');
end;

procedure TListTest.TestListCastStreamsBeforeRaise;
var
  LList: IFluentList<Variant>;
  LEnum: IFluentEnumerator<Integer>;
  LRaised: Boolean;
begin
  // Streaming, not all-or-nothing: the first valid element is yielded before
  // the incompatible one is reached and raises.
  LList := TFluentList<Variant>.Create;
  LList.AddRange([1, 'two', 3]);
  LEnum := LList.AsEnumerable.Cast<Integer>.GetEnumerator;
  Assert.IsTrue(LEnum.MoveNext, 'first element should be available');
  Assert.AreEqual(1, LEnum.Current, 'valid element yielded before the bad one');
  LRaised := False;
  try
    LEnum.MoveNext; // reaches 'two'
  except
    on E: EInvalidCast do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'the incompatible element raises when reached');
end;

procedure TListTest.TestListMinBy;
var
  LMin: Integer;
begin
  FList.AddRange([3, 1, 4, 1, 5]);
  LMin := FList.AsEnumerable.MinBy<Integer>(
    function(Value: Integer): Integer
    begin
      Result := Value;
    end,
    function(A, B: Integer): Integer
    begin
      Result := A - B;
    end);
  Assert.AreEqual(1, LMin, 'MinBy should return 1');
end;

procedure TListTest.TestListMaxBy;
var
  LMax: Integer;
begin
  FList.AddRange([3, 1, 4, 1, 5]);
  LMax := FList.AsEnumerable.MaxBy<Integer>(
    function(Value: Integer): Integer
    begin
      Result := Value;
    end,
    function(A, B: Integer): Integer
    begin
      Result := A - B;
    end);
  Assert.AreEqual(5, LMax, 'MaxBy should return 5');
end;

procedure TListTest.TestListLast;
var
  LLast: Integer;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LLast := FList.AsEnumerable.Last(
    function(Value: Integer): Boolean
    begin
      Result := Value > 3;
    end);
  Assert.AreEqual(5, LLast, 'Last should return 5');
end;

procedure TListTest.TestListSumDouble;
var
  LList: IFluentList<Double>;
  LSum: Double;
begin
  LList := TFluentList<Double>.Create;
  LList.AddRange([1.5, 2.5, 3.5]);
  LSum := LList.AsEnumerable.Sum(
    function(Value: Double): Double
    begin
      Result := Value;
    end);
  Assert.AreEqual(Double(7.5), LSum, 'Sum should be 7.5');
end;

procedure TListTest.TestListMinWithComparer;
var
  LMin: Integer;
begin
  FList.AddRange([3, 1, 4, 1, 5]);
  LMin := FList.AsEnumerable.Min(
    function(A, B: Integer): Integer
    begin
      Result := A - B;
    end);
  Assert.AreEqual(1, LMin, 'Min should be 1');
end;

procedure TListTest.TestListReduceNoInitial;
var
  LResult: Integer;
begin
  FList.AddRange([1, 2, 3]);
  LResult := FList.AsEnumerable.Aggregate(
    function(A, B: Integer): Integer
    begin
      Result := A + B;
    end);
  Assert.AreEqual(6, LResult, 'Reduce should be 6');
end;

procedure TListTest.TestListTakeWhile;
var
  LTaken: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3, 0, 4]);
  LTaken := FList.AsEnumerable.TakeWhile(
    function(Value: Integer): Boolean
    begin
      Result := Value > 0;
    end);
  LArray := LTaken.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Taken list should have 3 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(3, LArray[2], 'Third element should be 3');
end;

procedure TListTest.TestListSkipWhile;
var
  LSkipped: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3, 0, 4]);
  LSkipped := FList.AsEnumerable.SkipWhile(
    function(Value: Integer): Boolean
    begin
      Result := Value > 0;
    end);
  LArray := LSkipped.ToArray;
  Assert.AreEqual(2, LArray.Length, 'Skipped list should have 2 elements');
  Assert.AreEqual(0, LArray[0], 'First element should be 0');
  Assert.AreEqual(4, LArray[1], 'Second element should be 4');
end;

procedure TListTest.TestListAverage;
var
  LAverage: Double;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LAverage := FList.AsEnumerable.Average(
    function(Value: Integer): Double
    begin
      Result := Value;
    end);
  Assert.AreEqual(Double(3.0), LAverage, 'Average should be 3.0');
end;

procedure TListTest.TestListSumNullableAllNullIsZero;
var
  LResult: NullableInt32;
begin
  // LINQ: nullable Sum of an all-null sequence is 0, never null, never raises.
  FList.AddRange([1, 2, 3]);
  LResult := FList.AsEnumerable.Sum(
    function(Value: Integer): NullableInt32
    begin
      Result := NullableInt32.CreateEmpty;
    end);
  Assert.IsTrue(LResult.HasValue, 'nullable Sum must return a value (0), not null');
  Assert.AreEqual(0, LResult.Value, 'all-null nullable Sum must be 0');
end;

procedure TListTest.TestListSumNullableIgnoresNulls;
var
  LResult: NullableInt32;
begin
  // Nulls are skipped; the rest are summed.
  FList.AddRange([1, 2, 3, 4]);
  LResult := FList.AsEnumerable.Sum(
    function(Value: Integer): NullableInt32
    begin
      if Odd(Value) then
        Result := NullableInt32.Create(Value)
      else
        Result := NullableInt32.CreateEmpty;
    end);
  Assert.IsTrue(LResult.HasValue, 'nullable Sum should have a value');
  Assert.AreEqual(4, LResult.Value, 'sum of 1+3 with even values null');
end;

procedure TListTest.TestListAverageNullableAllNullIsNull;
var
  LResult: NullableDouble;
begin
  // LINQ: nullable Average of an all-null sequence is null (not 0, no raise).
  FList.AddRange([1, 2, 3]);
  LResult := FList.AsEnumerable.Average(
    function(Value: Integer): NullableInt32
    begin
      Result := NullableInt32.CreateEmpty;
    end);
  Assert.IsFalse(LResult.HasValue, 'all-null nullable Average must be null');
end;

procedure TListTest.TestListAverageNullableIgnoresNulls;
var
  LResult: NullableDouble;
begin
  // Average over the non-null values only: (2+4+6)/3 = 4.
  FList.AddRange([2, 4, 6, 7]);
  LResult := FList.AsEnumerable.Average(
    function(Value: Integer): NullableInt32
    begin
      if Value mod 2 = 0 then
        Result := NullableInt32.Create(Value)
      else
        Result := NullableInt32.CreateEmpty;
    end);
  Assert.IsTrue(LResult.HasValue, 'nullable Average should have a value');
  Assert.AreEqual(Double(4.0), LResult.Value, 'average of the non-null values');
end;

procedure TListTest.TestListAverageEmptyRaises;
var
  LRaised: Boolean;
begin
  // Non-nullable Average of an empty sequence must raise (contrast: nullable = null).
  LRaised := False;
  try
    FList.AsEnumerable.Average(
      function(Value: Integer): Double
      begin
        Result := Value;
      end);
  except
    on E: EInvalidOperation do
      LRaised := True;
  end;
  Assert.IsTrue(LRaised, 'non-nullable Average of empty must raise EInvalidOperation');
end;

procedure TListTest.TestListSumNullableEmptyIsZero;
var
  LResult: NullableInt64;
begin
  // True EMPTY sequence (not just all-null), Int64 overload: Sum must be 0.
  LResult := FList.AsEnumerable.Sum(
    function(Value: Integer): NullableInt64
    begin
      Result := NullableInt64.Create(Value);
    end);
  Assert.IsTrue(LResult.HasValue, 'nullable Sum of empty must be 0, not null');
  Assert.AreEqual(Int64(0), LResult.Value, 'nullable Sum of empty must be 0');
end;

procedure TListTest.TestListAverageNullableCurrencyAllNull;
var
  LResult: NullableCurrency;
begin
  // Currency overload, all-null: Average must be null.
  FList.AddRange([1, 2, 3]);
  LResult := FList.AsEnumerable.Average(
    function(Value: Integer): NullableCurrency
    begin
      Result := NullableCurrency.CreateEmpty;
    end);
  Assert.IsFalse(LResult.HasValue, 'all-null nullable Currency Average must be null');
end;

procedure TListTest.TestListAverageNullableCurrencyValues;
var
  LResult: NullableCurrency;
begin
  // Currency overload with values: (10+20+30)/3 = 20.
  FList.AddRange([10, 20, 30]);
  LResult := FList.AsEnumerable.Average(
    function(Value: Integer): NullableCurrency
    begin
      Result := NullableCurrency.Create(Value);
    end);
  Assert.IsTrue(LResult.HasValue, 'nullable Currency Average should have a value');
  Assert.AreEqual(Double(20.0), Double(LResult.Value), 'Currency average of 10,20,30');
end;

procedure TListTest.TestListExclude;
var
  LSecond: IFluentList<Integer>;
  LExclude: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3, 4]);
  LSecond := TFluentList<Integer>.Create;
  LSecond.AddRange([2, 4]);
  LExclude := FList.AsEnumerable.Exclude(LSecond.AsEnumerable);
  LArray := LExclude.ToArray;
  Assert.AreEqual(2, LArray.Length, 'Exclude list should have 2 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(3, LArray[1], 'Second element should be 3');
end;

procedure TListTest.TestListExcludeDistinct;
var
  LSecond: IFluentList<Integer>;
  LArray: IFluentArray<Integer>;
begin
  // LINQ Except returns DISTINCT elements: duplicates in the source that are not
  // excluded must appear at most once, in first-appearance order.
  FList.AddRange([1, 1, 2, 3, 3, 4]);
  LSecond := TFluentList<Integer>.Create;
  LSecond.AddRange([4]);
  LArray := FList.AsEnumerable.Exclude(LSecond.AsEnumerable).ToArray;
  Assert.AreEqual(3, LArray.Length, 'Except must dedupe the output');
  Assert.AreEqual(1, LArray[0], 'First distinct element');
  Assert.AreEqual(2, LArray[1], 'Second distinct element');
  Assert.AreEqual(3, LArray[2], 'Third distinct element');
end;

procedure TListTest.TestListExcludeReEnumerable;
var
  LSecond: IFluentList<Integer>;
  LExcluded: IFluentEnumerable<Integer>;
  LFirst, LSecondPass: IFluentArray<Integer>;
begin
  // Each enumeration builds a fresh emitted-set, so re-enumerating the same
  // query (a new GetEnumerator per ToArray) reproduces the identical distinct
  // result rather than leaking dedupe state across enumerations.
  FList.AddRange([1, 1, 2, 3]);
  LSecond := TFluentList<Integer>.Create;
  LSecond.AddRange([2]);
  LExcluded := FList.AsEnumerable.Exclude(LSecond.AsEnumerable);

  LFirst := LExcluded.ToArray;
  LSecondPass := LExcluded.ToArray;

  Assert.AreEqual(2, LFirst.Length, 'First enumeration should yield distinct [1,3]');
  Assert.AreEqual(2, LSecondPass.Length, 'Second enumeration should reproduce [1,3]');
  Assert.AreEqual(1, LSecondPass[0], 'First element on re-enumeration');
  Assert.AreEqual(3, LSecondPass[1], 'Second element on re-enumeration');
end;

procedure TListTest.TestListExcludeAllExcludedIsEmpty;
var
  LSecond: IFluentList<Integer>;
  LArray: IFluentArray<Integer>;
begin
  // Every (distinct) source value is in the second set -> empty result.
  FList.AddRange([1, 1, 2, 2]);
  LSecond := TFluentList<Integer>.Create;
  LSecond.AddRange([1, 2]);
  LArray := FList.AsEnumerable.Exclude(LSecond.AsEnumerable).ToArray;
  Assert.AreEqual(0, LArray.Length, 'All values excluded -> empty sequence');
end;

procedure TListTest.TestListExcludeWithComparer;
var
  LFirst, LSecond: IFluentList<string>;
  LArray: IFluentArray<string>;
begin
  // Case-insensitive comparer: 'A' and 'C' are excluded by 'a'/'c'.
  // With the default (case-sensitive) comparer nothing would match -> 3 elements.
  LFirst := TFluentList<string>.Create;
  LFirst.AddRange(['A', 'b', 'C']);
  LSecond := TFluentList<string>.Create;
  LSecond.AddRange(['a', 'c']);
  LArray := LFirst.AsEnumerable.Exclude(LSecond.AsEnumerable, TIStringComparer.Ordinal).ToArray;
  Assert.AreEqual(1, LArray.Length, 'case-insensitive Exclude keeps only "b"');
  Assert.AreEqual('b', LArray[0], 'remaining element is b');
end;

procedure TListTest.TestListIntersectWithComparer;
var
  LFirst, LSecond: IFluentList<string>;
  LArray: IFluentArray<string>;
begin
  // Case-insensitive: 'A' intersects 'a'. Default comparer -> empty.
  LFirst := TFluentList<string>.Create;
  LFirst.AddRange(['A', 'b', 'C']);
  LSecond := TFluentList<string>.Create;
  LSecond.AddRange(['a', 'x']);
  LArray := LFirst.AsEnumerable.Intersect(LSecond.AsEnumerable, TIStringComparer.Ordinal).ToArray;
  Assert.AreEqual(1, LArray.Length, 'case-insensitive Intersect finds "A"~"a"');
  Assert.AreEqual('A', LArray[0], 'intersected element keeps first-sequence casing');
end;

procedure TListTest.TestListUnionWithComparer;
var
  LFirst, LSecond: IFluentList<string>;
  LArray: IFluentArray<string>;
begin
  // Case-insensitive: 'a' in the second sequence is a duplicate of 'A' -> deduped.
  // Default comparer would keep both -> 4 elements.
  LFirst := TFluentList<string>.Create;
  LFirst.AddRange(['A', 'b']);
  LSecond := TFluentList<string>.Create;
  LSecond.AddRange(['a', 'C']);
  LArray := LFirst.AsEnumerable.Union(LSecond.AsEnumerable, TIStringComparer.Ordinal).ToArray;
  Assert.AreEqual(3, LArray.Length, 'case-insensitive Union dedupes "a" against "A"');
  Assert.AreEqual('A', LArray[0], 'first element');
  Assert.AreEqual('b', LArray[1], 'second element');
  Assert.AreEqual('C', LArray[2], 'third element (new from second sequence)');
end;

procedure TListTest.TestListJoinWithComparer;
var
  LOuter, LInner: IFluentList<string>;
  LArray: IFluentArray<string>;
begin
  // Case-insensitive key comparer: outer 'A' matches inner 'a'.
  // With the default comparer there would be no match -> 0 results.
  LOuter := TFluentList<string>.Create;
  LOuter.AddRange(['A']);
  LInner := TFluentList<string>.Create;
  LInner.AddRange(['a']);
  LArray := LOuter.AsEnumerable.Join<string, string, string>(
    LInner.AsEnumerable,
    function(O: string): string
    begin
      Result := O;
    end,
    function(I: string): string
    begin
      Result := I;
    end,
    function(O, I: string): string
    begin
      Result := O + '-' + I;
    end,
    TIStringComparer.Ordinal).ToArray;
  Assert.AreEqual(1, LArray.Length, 'case-insensitive Join matches "A" with "a"');
  Assert.AreEqual('A-a', LArray[0], 'joined pair preserves original casing');
end;

procedure TListTest.TestListAppendDeferred;
var
  LCount: Integer;
  LDeferred: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  // Append must be deferred: building the pipeline must NOT enumerate the
  // source (an eager Append would run the Select side-effect immediately).
  FList.AddRange([1, 2, 3]);
  LCount := 0;
  LDeferred := FList.AsEnumerable.Select<Integer>(
    function(Value: Integer): Integer
    begin
      Inc(LCount);
      Result := Value;
    end).Append(99);
  Assert.AreEqual(0, LCount, 'Append must not enumerate the source at construction');

  LArray := LDeferred.ToArray;
  Assert.IsTrue(LCount > 0, 'source is enumerated only when the result is iterated');
  Assert.AreEqual(4, LArray.Length, 'source + appended element');
  Assert.AreEqual(1, LArray[0], 'first is the source head');
  Assert.AreEqual(99, LArray[3], 'appended element comes last');
end;

procedure TListTest.TestListPrependDeferred;
var
  LCount: Integer;
  LDeferred: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3]);
  LCount := 0;
  LDeferred := FList.AsEnumerable.Select<Integer>(
    function(Value: Integer): Integer
    begin
      Inc(LCount);
      Result := Value;
    end).Prepend(99);
  Assert.AreEqual(0, LCount, 'Prepend must not enumerate the source at construction');

  LArray := LDeferred.ToArray;
  Assert.AreEqual(4, LArray.Length, 'prepended element + source');
  Assert.AreEqual(99, LArray[0], 'prepended element comes first');
  Assert.AreEqual(3, LArray[3], 'source tail last');
end;

procedure TListTest.TestListDefaultIfEmptyDeferred;
var
  LCount: Integer;
  LDeferred: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3]);
  LCount := 0;
  LDeferred := FList.AsEnumerable.Select<Integer>(
    function(Value: Integer): Integer
    begin
      Inc(LCount);
      Result := Value;
    end).DefaultIfEmpty(0);
  Assert.AreEqual(0, LCount, 'DefaultIfEmpty must not enumerate the source at construction');

  LArray := LDeferred.ToArray;
  Assert.AreEqual(3, LArray.Length, 'non-empty source passes through unchanged');
  Assert.AreEqual(1, LArray[0], 'first source element');
end;

procedure TListTest.TestListDefaultIfEmptyEmptyYieldsDefault;
var
  LArray: IFluentArray<Integer>;
begin
  // Empty source -> a single default value.
  LArray := FList.AsEnumerable.DefaultIfEmpty(42).ToArray;
  Assert.AreEqual(1, LArray.Length, 'empty source yields one default');
  Assert.AreEqual(42, LArray[0], 'the supplied default value');
end;

procedure TListTest.TestListAppendPrependEmptySource;
var
  LAppended, LPrepended: IFluentArray<Integer>;
begin
  // Over an empty source, Append/Prepend yield just the single element.
  LAppended := FList.AsEnumerable.Append(7).ToArray;
  Assert.AreEqual(1, LAppended.Length, 'Append over empty -> [element]');
  Assert.AreEqual(7, LAppended[0], 'appended element');

  LPrepended := FList.AsEnumerable.Prepend(7).ToArray;
  Assert.AreEqual(1, LPrepended.Length, 'Prepend over empty -> [element]');
  Assert.AreEqual(7, LPrepended[0], 'prepended element');
end;

procedure TListTest.TestListDefaultIfEmptyNoArgEmpty;
var
  LArray: IFluentArray<Integer>;
begin
  // No-arg DefaultIfEmpty over an empty source yields Default(T) (0 for Integer).
  LArray := FList.AsEnumerable.DefaultIfEmpty.ToArray;
  Assert.AreEqual(1, LArray.Length, 'empty source yields one default');
  Assert.AreEqual(0, LArray[0], 'Default(Integer) is 0');
end;

procedure TListTest.TestListAppendReEnumerable;
var
  LDeferred: IFluentEnumerable<Integer>;
  LFirst, LSecond: IFluentArray<Integer>;
begin
  // Each GetEnumerator reprocesses the source: two ToArray calls on the same
  // deferred result reproduce the identical output.
  FList.AddRange([1, 2]);
  LDeferred := FList.AsEnumerable.Append(9);
  LFirst := LDeferred.ToArray;
  LSecond := LDeferred.ToArray;
  Assert.AreEqual(3, LFirst.Length, 'first enumeration');
  Assert.AreEqual(3, LSecond.Length, 'second enumeration reproduces the result');
  Assert.AreEqual(9, LSecond[2], 'appended element present on re-enumeration');
end;

procedure TListTest.TestListDistinctByDeferred;
var
  LCount: Integer;
  LDeferred: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  // Deferred + distinct-by-key (first occurrence, source order).
  FList.AddRange([1, 1, 2, 3, 3]);
  LCount := 0;
  LDeferred := FList.AsEnumerable.Select<Integer>(
    function(Value: Integer): Integer
    begin
      Inc(LCount);
      Result := Value;
    end).DistinctBy<Integer>(
    function(Value: Integer): Integer
    begin
      Result := Value;
    end);
  Assert.AreEqual(0, LCount, 'DistinctBy must not enumerate the source at construction');

  LArray := LDeferred.ToArray;
  Assert.AreEqual(3, LArray.Length, 'distinct keys 1,2,3');
  Assert.AreEqual(1, LArray[0], 'first');
  Assert.AreEqual(2, LArray[1], 'second');
  Assert.AreEqual(3, LArray[2], 'third');
end;

procedure TListTest.TestListUnionByDeferred;
var
  LCount: Integer;
  LSecond: IFluentList<Integer>;
  LDeferred: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  // Deferred + union-by-key across both sequences (first occurrence).
  FList.AddRange([1, 2]);
  LSecond := TFluentList<Integer>.Create;
  LSecond.AddRange([2, 3]);
  LCount := 0;
  LDeferred := FList.AsEnumerable.Select<Integer>(
    function(Value: Integer): Integer
    begin
      Inc(LCount);
      Result := Value;
    end).UnionBy<Integer>(LSecond.AsEnumerable,
    function(Value: Integer): Integer
    begin
      Result := Value;
    end);
  Assert.AreEqual(0, LCount, 'UnionBy must not enumerate the source at construction');

  LArray := LDeferred.ToArray;
  Assert.AreEqual(3, LArray.Length, 'union by key -> 1,2,3');
  Assert.AreEqual(1, LArray[0], 'first');
  Assert.AreEqual(3, LArray[2], 'new key from second sequence');
end;

procedure TListTest.TestListExcludeByDistinctDeferred;
var
  LCount: Integer;
  LSecondKeys: IFluentList<Integer>;
  LDeferred: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  // ExcludeBy: deferred over the source, and the output is DISTINCT (a source
  // with duplicate keys must not repeat).
  FList.AddRange([1, 1, 2, 3, 3, 4]);
  LSecondKeys := TFluentList<Integer>.Create;
  LSecondKeys.AddRange([4]);
  LCount := 0;
  LDeferred := FList.AsEnumerable.Select<Integer>(
    function(Value: Integer): Integer
    begin
      Inc(LCount);
      Result := Value;
    end).ExcludeBy<Integer>(LSecondKeys.AsEnumerable,
    function(Value: Integer): Integer
    begin
      Result := Value;
    end);
  Assert.AreEqual(0, LCount, 'ExcludeBy must not enumerate the source at construction');

  LArray := LDeferred.ToArray;
  Assert.AreEqual(3, LArray.Length, 'distinct, key 4 excluded -> [1,2,3]');
  Assert.AreEqual(1, LArray[0], 'first');
  Assert.AreEqual(2, LArray[1], 'second');
  Assert.AreEqual(3, LArray[2], 'third');
end;

procedure TListTest.TestListIntersectByDistinctDeferred;
var
  LCount: Integer;
  LSecondKeys: IFluentList<Integer>;
  LDeferred: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  // IntersectBy: deferred over the source, output DISTINCT.
  FList.AddRange([1, 1, 2, 3]);
  LSecondKeys := TFluentList<Integer>.Create;
  LSecondKeys.AddRange([1, 3]);
  LCount := 0;
  LDeferred := FList.AsEnumerable.Select<Integer>(
    function(Value: Integer): Integer
    begin
      Inc(LCount);
      Result := Value;
    end).IntersectBy<Integer>(LSecondKeys.AsEnumerable,
    function(Value: Integer): Integer
    begin
      Result := Value;
    end);
  Assert.AreEqual(0, LCount, 'IntersectBy must not enumerate the source at construction');

  LArray := LDeferred.ToArray;
  Assert.AreEqual(2, LArray.Length, 'distinct intersection on keys 1,3 -> [1,3]');
  Assert.AreEqual(1, LArray[0], 'first');
  Assert.AreEqual(3, LArray[1], 'second');
end;

procedure TListTest.TestListExcludeByReEnumerable;
var
  LSecondKeys: IFluentList<Integer>;
  LDeferred: IFluentEnumerable<Integer>;
  LFirst, LSecond: IFluentArray<Integer>;
begin
  // Each GetEnumerator rebuilds the excluded/emitted sets, so re-enumerating the
  // same query reproduces the identical distinct result.
  FList.AddRange([1, 1, 2, 3, 4]);
  LSecondKeys := TFluentList<Integer>.Create;
  LSecondKeys.AddRange([4]);
  LDeferred := FList.AsEnumerable.ExcludeBy<Integer>(LSecondKeys.AsEnumerable,
    function(Value: Integer): Integer
    begin
      Result := Value;
    end);
  LFirst := LDeferred.ToArray;
  LSecond := LDeferred.ToArray;
  Assert.AreEqual(3, LFirst.Length, 'first enumeration -> [1,2,3]');
  Assert.AreEqual(3, LSecond.Length, 'second enumeration reproduces [1,2,3]');
  Assert.AreEqual(1, LSecond[0], 'first element on re-enumeration');
  Assert.AreEqual(3, LSecond[2], 'last element on re-enumeration');
end;

procedure TListTest.TestListReverseDeferred;
var
  LCount: Integer;
  LDeferred: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  // Reverse buffers only on the first MoveNext, not at construction.
  FList.AddRange([1, 2, 3]);
  LCount := 0;
  LDeferred := FList.AsEnumerable.Select<Integer>(
    function(Value: Integer): Integer
    begin
      Inc(LCount);
      Result := Value;
    end).Reverse;
  Assert.AreEqual(0, LCount, 'Reverse must not enumerate the source at construction');

  LArray := LDeferred.ToArray;
  Assert.AreEqual(3, LArray.Length, 'all elements');
  Assert.AreEqual(3, LArray[0], 'reversed head');
  Assert.AreEqual(1, LArray[2], 'reversed tail');
end;

procedure TListTest.TestListTakeLastDeferred;
var
  LCount: Integer;
  LDeferred: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LCount := 0;
  LDeferred := FList.AsEnumerable.Select<Integer>(
    function(Value: Integer): Integer
    begin
      Inc(LCount);
      Result := Value;
    end).TakeLast(2);
  Assert.AreEqual(0, LCount, 'TakeLast must not enumerate the source at construction');

  LArray := LDeferred.ToArray;
  Assert.AreEqual(2, LArray.Length, 'last 2 elements');
  Assert.AreEqual(4, LArray[0], 'first of the last 2');
  Assert.AreEqual(5, LArray[1], 'last element');
end;

procedure TListTest.TestListSkipLastDeferred;
var
  LCount: Integer;
  LDeferred: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LCount := 0;
  LDeferred := FList.AsEnumerable.Select<Integer>(
    function(Value: Integer): Integer
    begin
      Inc(LCount);
      Result := Value;
    end).SkipLast(2);
  Assert.AreEqual(0, LCount, 'SkipLast must not enumerate the source at construction');

  LArray := LDeferred.ToArray;
  Assert.AreEqual(3, LArray.Length, 'all but the last 2');
  Assert.AreEqual(1, LArray[0], 'first element');
  Assert.AreEqual(3, LArray[2], 'last kept element');
end;

procedure TListTest.TestListTakeLastSkipLastEdges;
begin
  FList.AddRange([1, 2, 3]);
  // TakeLast(0) -> empty; SkipLast(0) -> all.
  Assert.AreEqual(0, FList.AsEnumerable.TakeLast(0).ToArray.Length, 'TakeLast(0) is empty');
  Assert.AreEqual(3, FList.AsEnumerable.SkipLast(0).ToArray.Length, 'SkipLast(0) keeps all');
  // Count larger than the sequence.
  Assert.AreEqual(3, FList.AsEnumerable.TakeLast(10).ToArray.Length, 'TakeLast(>count) keeps all');
  Assert.AreEqual(0, FList.AsEnumerable.SkipLast(10).ToArray.Length, 'SkipLast(>count) is empty');
end;

procedure TListTest.TestListReverseEmptyAndReEnumerable;
var
  LReversed: IFluentEnumerable<Integer>;
  LFirst, LSecond: IFluentArray<Integer>;
begin
  // Empty source -> empty result (buffer step-down must not under/overflow).
  Assert.AreEqual(0, FList.AsEnumerable.Reverse.ToArray.Length, 'Reverse of empty is empty');

  // Re-enumeration: each GetEnumerator re-buffers, reproducing the reversed order.
  FList.AddRange([1, 2, 3]);
  LReversed := FList.AsEnumerable.Reverse;
  LFirst := LReversed.ToArray;
  LSecond := LReversed.ToArray;
  Assert.AreEqual(3, LFirst.Length, 'first enumeration');
  Assert.AreEqual(3, LSecond.Length, 'second enumeration reproduces the result');
  Assert.AreEqual(3, LSecond[0], 'reversed head on re-enumeration');
  Assert.AreEqual(1, LSecond[2], 'reversed tail on re-enumeration');
end;

procedure TListTest.TestListDistinctByWithComparer;
var
  LWords: IFluentList<string>;
  LArray: IFluentArray<string>;
begin
  // Case-insensitive key: 'a' and 'A' collapse -> ['a','b']. Default -> 3.
  LWords := TFluentList<string>.Create;
  LWords.AddRange(['a', 'A', 'b']);
  LArray := LWords.AsEnumerable.DistinctBy<string>(
    function(V: string): string
    begin
      Result := V;
    end, TIStringComparer.Ordinal).ToArray;
  Assert.AreEqual(2, LArray.Length, 'case-insensitive DistinctBy collapses a/A');
  Assert.AreEqual('a', LArray[0], 'first occurrence kept');
  Assert.AreEqual('b', LArray[1], 'second distinct key');
end;

procedure TListTest.TestListUnionByWithComparer;
var
  LFirst, LSecond: IFluentList<string>;
  LArray: IFluentArray<string>;
begin
  // Case-insensitive: 'A' in second is a duplicate of 'a' -> ['a','b']. Default -> 3.
  LFirst := TFluentList<string>.Create;
  LFirst.AddRange(['a']);
  LSecond := TFluentList<string>.Create;
  LSecond.AddRange(['A', 'b']);
  LArray := LFirst.AsEnumerable.UnionBy<string>(LSecond.AsEnumerable,
    function(V: string): string
    begin
      Result := V;
    end, TIStringComparer.Ordinal).ToArray;
  Assert.AreEqual(2, LArray.Length, 'case-insensitive UnionBy dedupes A against a');
  Assert.AreEqual('a', LArray[0], 'first');
  Assert.AreEqual('b', LArray[1], 'new key from second');
end;

procedure TListTest.TestListExcludeByWithComparer;
var
  LSource, LKeys: IFluentList<string>;
  LArray: IFluentArray<string>;
begin
  // Case-insensitive: key 'A' excludes 'a' -> ['B']. Default -> ['a','B'].
  LSource := TFluentList<string>.Create;
  LSource.AddRange(['a', 'B']);
  LKeys := TFluentList<string>.Create;
  LKeys.AddRange(['A']);
  LArray := LSource.AsEnumerable.ExcludeBy<string>(LKeys.AsEnumerable,
    function(V: string): string
    begin
      Result := V;
    end, TIStringComparer.Ordinal).ToArray;
  Assert.AreEqual(1, LArray.Length, 'case-insensitive ExcludeBy removes a via A');
  Assert.AreEqual('B', LArray[0], 'remaining element');
end;

procedure TListTest.TestListIntersectByWithComparer;
var
  LSource, LKeys: IFluentList<string>;
  LArray: IFluentArray<string>;
begin
  // Case-insensitive: key 'A' matches 'a' -> ['a']. Default -> empty.
  LSource := TFluentList<string>.Create;
  LSource.AddRange(['a', 'B']);
  LKeys := TFluentList<string>.Create;
  LKeys.AddRange(['A']);
  LArray := LSource.AsEnumerable.IntersectBy<string>(LKeys.AsEnumerable,
    function(V: string): string
    begin
      Result := V;
    end, TIStringComparer.Ordinal).ToArray;
  Assert.AreEqual(1, LArray.Length, 'case-insensitive IntersectBy matches a via A');
  Assert.AreEqual('a', LArray[0], 'matched element keeps source casing');
end;

procedure TListTest.TestFluentQueryRange;
var
  LArray: IFluentArray<Integer>;
begin
  // Range(1,5) = 1,2,3,4,5 (the 2nd arg is a COUNT, not an end value).
  LArray := TFluentQuery.Range(1, 5).ToArray;
  Assert.AreEqual(5, LArray.Length, 'Range(1,5) has 5 elements');
  Assert.AreEqual(1, LArray[0], 'first');
  Assert.AreEqual(5, LArray[4], 'last');
  // Zero count -> empty.
  Assert.AreEqual(0, TFluentQuery.Range(10, 0).ToArray.Length, 'Range(_,0) is empty');
  // Negative start supported.
  LArray := TFluentQuery.Range(-2, 3).ToArray;
  Assert.AreEqual(3, LArray.Length, 'Range(-2,3) has 3 elements');
  Assert.AreEqual(-2, LArray[0], 'first is start');
  Assert.AreEqual(0, LArray[2], 'last is start+count-1');
  // Exact upper boundary succeeds: start+count-1 = High(Integer).
  LArray := TFluentQuery.Range(High(Integer), 1).ToArray;
  Assert.AreEqual(1, LArray.Length, 'Range(MaxInt,1) yields one element');
  Assert.AreEqual(High(Integer), LArray[0], 'the single element is MaxInt');
end;

procedure TListTest.TestFluentQueryRepeat;
var
  LArray: IFluentArray<string>;
begin
  LArray := TFluentQuery.&Repeat<string>('x', 3).ToArray;
  Assert.AreEqual(3, LArray.Length, 'Repeat yields the element count times');
  Assert.AreEqual('x', LArray[0], 'first');
  Assert.AreEqual('x', LArray[2], 'last');
  Assert.AreEqual(0, TFluentQuery.&Repeat<string>('x', 0).ToArray.Length, 'Repeat(_,0) is empty');
end;

procedure TListTest.TestFluentQueryEmpty;
begin
  Assert.AreEqual(0, TFluentQuery.Empty<Integer>.ToArray.Length, 'Empty<Integer> is empty');
  Assert.IsFalse(TFluentQuery.Empty<string>.Any, 'Empty has no elements');
end;

procedure TListTest.TestFluentQueryGeneratorValidation;
begin
  // Arguments are validated eagerly (at the call), even though generation is lazy.
  Assert.WillRaise(
    procedure
    begin
      TFluentQuery.Range(1, -1);
    end, EArgumentOutOfRangeException, 'Range with negative count raises');
  Assert.WillRaise(
    procedure
    begin
      TFluentQuery.Range(High(Integer), 2);
    end, EArgumentOutOfRangeException, 'Range that overflows Integer raises');
  Assert.WillRaise(
    procedure
    begin
      TFluentQuery.&Repeat<Integer>(7, -1);
    end, EArgumentOutOfRangeException, 'Repeat with negative count raises');
end;

procedure TListTest.TestListGetListNonDestructive;
var
  LArr: IFluentArray<Integer>;
begin
  // The List property (GetList) must be a non-destructive snapshot of exactly
  // Count elements. Previously reading it returned the raw internal array and
  // then Clear'd the list.
  FList.AddRange([1, 2, 3]);
  LArr := FList.List;
  Assert.AreEqual(3, LArr.Length, 'snapshot has exactly Count elements (no spare capacity)');
  Assert.AreEqual(1, LArr[0], 'first');
  Assert.AreEqual(3, LArr[2], 'last');
  Assert.AreEqual(3, FList.Count, 'reading List must not clear the source list');
  Assert.AreEqual(3, FList.List.Length, 'a second read still returns all elements');
end;

procedure TListTest.TestListChunk;
var
  LCount: Integer;
  LChunkSource: IFluentEnumerableBase<TArray<Integer>>;
  LEnum: IFluentEnumerator<TArray<Integer>>;
  LChunks: TList<TArray<Integer>>;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LCount := 0;
  // Chunk over a side-effecting Select: building the chunk pipeline must not
  // enumerate the source (deferred).
  LChunkSource := FList.AsEnumerable.Select<Integer>(
    function(Value: Integer): Integer
    begin
      Inc(LCount);
      Result := Value;
    end).Chunk(2);
  Assert.AreEqual(0, LCount, 'Chunk must not enumerate the source at construction');

  LChunks := TList<TArray<Integer>>.Create;
  try
    LEnum := LChunkSource.GetEnumerator;
    while LEnum.MoveNext do
      LChunks.Add(LEnum.Current);
    Assert.IsTrue(LCount > 0, 'source enumerated on iteration');
    Assert.AreEqual(3, LChunks.Count, '5 elements in chunks of 2 -> 3 chunks');
    Assert.AreEqual(2, Length(LChunks[0]), 'first chunk is full');
    Assert.AreEqual(1, LChunks[0][0], 'first element');
    Assert.AreEqual(4, LChunks[1][1], 'second chunk second element');
    Assert.AreEqual(1, Length(LChunks[2]), 'last chunk holds the remainder');
    Assert.AreEqual(5, LChunks[2][0], 'last element');
  finally
    LChunks.Free;
  end;
end;

procedure TListTest.TestListChunkEdges;
var
  LEnum: IFluentEnumerator<TArray<Integer>>;
  LCount: Integer;
begin
  // Size >= count -> a single chunk with all elements.
  FList.AddRange([1, 2, 3]);
  LEnum := FList.AsEnumerable.Chunk(10).GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    Inc(LCount);
    Assert.AreEqual(3, Length(LEnum.Current), 'single chunk holds all elements');
  end;
  Assert.AreEqual(1, LCount, 'one chunk when size >= count');

  // Empty source -> zero chunks.
  FList.Clear;
  LEnum := FList.AsEnumerable.Chunk(2).GetEnumerator;
  Assert.IsFalse(LEnum.MoveNext, 'empty source yields no chunks');

  // Exact multiple -> no spurious trailing empty chunk (classic off-by-one).
  FList.AddRange([1, 2, 3, 4]);
  LEnum := FList.AsEnumerable.Chunk(2).GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    Inc(LCount);
    Assert.AreEqual(2, Length(LEnum.Current), 'each chunk full on exact multiple');
  end;
  Assert.AreEqual(2, LCount, 'exact multiple -> exactly 2 chunks, no trailing empty');

  // Size < 1 raises (eager validation).
  Assert.WillRaise(
    procedure
    begin
      FList.AsEnumerable.Chunk(0);
    end, EArgumentOutOfRangeException, 'Chunk(0) raises');
end;

procedure TListTest.TestListIntersect;
var
  LSecond: TFluentList<Integer>;
  LIntersect: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3, 4]);
  LSecond := TFluentList<Integer>.Create;
  try
    LSecond.AddRange([2, 4, 5]);
    LIntersect := FList.AsEnumerable.Intersect(LSecond.AsEnumerable);
    LArray := LIntersect.ToArray;
    Assert.AreEqual(2, LArray.Length, 'Intersect list should have 2 elements');
    Assert.AreEqual(2, LArray[0], 'First element should be 2');
    Assert.AreEqual(4, LArray[1], 'Second element should be 4');
  finally
    LSecond.Free;
  end;
end;

procedure TListTest.TestListUnion;
var
  LSecond: TFluentList<Integer>;
  LUnion: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3]);
  LSecond := TFluentList<Integer>.Create;
  try
    LSecond.AddRange([2, 3, 4]);
    LUnion := FList.AsEnumerable.Union(LSecond.AsEnumerable);
    LArray := LUnion.ToArray;
    Assert.AreEqual(4, LArray.Length, 'Union list should have 4 elements');
    Assert.AreEqual(1, LArray[0], 'First element should be 1');
    Assert.AreEqual(4, LArray[3], 'Fourth element should be 4');
  finally
    LSecond.Free;
  end;
end;

procedure TListTest.TestListConcat;
var
  LSecond: TFluentList<Integer>;
  LConcat: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([1, 2, 3]);
  LSecond := TFluentList<Integer>.Create;
  try
    LSecond.AddRange([2, 3, 4]);
    LConcat := FList.AsEnumerable.Concat(LSecond.AsEnumerable);
    LArray := LConcat.ToArray;
    Assert.AreEqual(6, LArray.Length, 'Concat list should have 6 elements');
    Assert.AreEqual(1, LArray[0], 'First element should be 1');
    Assert.AreEqual(4, LArray[5], 'Sixth element should be 4');
  finally
    LSecond.Free;
  end;
end;

procedure TListTest.TestListAll;
var
  LResult: Boolean;
begin
  FList.AddRange([1, 2, 3]);
  LResult := FList.AsEnumerable.All(
    function(Value: Integer): Boolean
    begin
      Result := Value > 0;
    end);
  Assert.IsTrue(LResult, 'All elements should be greater than 0');

  FList.Clear;
  FList.AddRange([1, 2, -3]);
  LResult := FList.AsEnumerable.All(
    function(Value: Integer): Boolean
    begin
      Result := Value > 0;
    end);
  Assert.IsFalse(LResult, 'Not all elements are greater than 0');
end;

procedure TListTest.TestListContains;
var
  LResult: Boolean;
begin
  FList.AddRange([1, 2, 3]);
  LResult := FList.AsEnumerable.Contains(2);
  Assert.IsTrue(LResult, 'List should contain 2');

  LResult := FList.AsEnumerable.Contains(4);
  Assert.IsFalse(LResult, 'List should not contain 4');
end;

procedure TListTest.TestListSelectMany;
var
  LList: IFluentList<TArray<Integer>>;
  LSelected: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  LList := TFluentList<TArray<Integer>>.Create;
  LList.Add([1, 2]);
  LList.Add([3]);
  LList.Add([4, 5]);
  LSelected := LList.AsEnumerable.SelectMany<Integer>(
    function(Value: TArray<Integer>): TArray<Integer>
    var
      LInnerList: TFluentList<Integer>;
    begin
      LInnerList := TFluentList<Integer>.Create(Value);
      try
        Result := LInnerList.ToArray.ArrayData;
      finally
        LInnerList.Free;
      end;
    end);
  LArray := LSelected.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Selected list should have 5 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(5, LArray[4], 'Fifth element should be 5');
end;

procedure TListTest.TestListSequenceEqual;
var
  LSecond: TFluentList<Integer>;
  LResult: Boolean;
begin
  FList.AddRange([1, 2, 3]);
  LSecond := TFluentList<Integer>.Create;
  try
    LSecond.AddRange([1, 2, 3]);
    LResult := FList.AsEnumerable.SequenceEqual(LSecond.AsEnumerable);
    Assert.IsTrue(LResult, 'Sequences should be equal');

    LSecond.Clear;
    LSecond.AddRange([1, 2, 4]);
    LResult := FList.AsEnumerable.SequenceEqual(LSecond.AsEnumerable);
    Assert.IsFalse(LResult, 'Sequences should not be equal');
  finally
    LSecond.Free;
  end;
end;

procedure TListTest.TestListSequenceEqualNegative;
var
  LSecond: TFluentList<Integer>;
  LResult: Boolean;
begin
  FList.AddRange([1, 2, 3]);
  LSecond := TFluentList<Integer>.Create;
  try
    LSecond.AddRange([1, 2, 4]);
    LResult := FList.AsEnumerable.SequenceEqual(LSecond.AsEnumerable);
    Assert.IsFalse(LResult, 'Sequences should not be equal');
  finally
    LSecond.Free;
  end;
end;

procedure TListTest.TestListAllNegative;
var
  LResult: Boolean;
begin
  FList.AddRange([1, 2, -3]);
  LResult := FList.AsEnumerable.All(
    function(Value: Integer): Boolean
    begin
      Result := Value > 0;
    end);
  Assert.IsFalse(LResult, 'Not all elements are greater than 0');
end;

procedure TListTest.TestListSingle;
var
  LResult: Integer;
begin
  FList.AddRange([1, 2, 3]);
  LResult := FList.AsEnumerable.Single(
    function(Value: Integer): Boolean
    begin
      Result := Value = 2;
    end);
  Assert.AreEqual(2, LResult, 'Single element should be 2');
end;

procedure TListTest.TestListSingleMultipleElements;
begin
  FList.AddRange([1, 2, 2, 3]);
  Assert.WillRaise(
    procedure
    begin
      FList.AsEnumerable.Single(
        function(Value: Integer): Boolean
        begin
          Result := Value = 2;
        end);
    end,
    EInvalidOperation,
    'Single should raise exception for multiple elements');
end;

procedure TListTest.TestListSingleOrDefault;
var
  LResult: Integer;
begin
  FList.AddRange([1, 2, 3]);
  LResult := FList.AsEnumerable.SingleOrDefault(
    function(Value: Integer): Boolean
    begin
      Result := Value = 4;
    end);
  Assert.AreEqual(0, LResult, 'SingleOrDefault should return 0 when no element is found');

  LResult := FList.AsEnumerable.SingleOrDefault(
    function(Value: Integer): Boolean
    begin
      Result := Value = 2;
    end);
  Assert.AreEqual(2, LResult, 'SingleOrDefault should return 2');
end;

procedure TListTest.TestListElementAt;
var
  LResult: Integer;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LResult := FList.AsEnumerable.ElementAt(2);
  Assert.AreEqual(3, LResult, 'Element at index 2 should be 3');
end;

procedure TListTest.TestListElementAtOrDefault;
var
  LResult: Integer;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LResult := FList.AsEnumerable.ElementAtOrDefault(2);
  Assert.AreEqual(3, LResult, 'Element at index 2 should be 3');
  LResult := FList.AsEnumerable.ElementAtOrDefault(10);
  Assert.AreEqual(0, LResult, 'Element at index 10 should return default (0)');
end;

procedure TListTest.TestListElementAtOutOfRange;
begin
  FList.AddRange([1, 2, 3]);
  Assert.WillRaise(
    procedure
    begin
      FList.AsEnumerable.ElementAt(5);
    end,
    EArgumentOutOfRangeException,
    'Expected EArgumentOutOfRangeException for index out of range');
end;

procedure TListTest.TestListOrderByDescending;
var
  LOrdered: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FList.AddRange([3, 1, 4, 1, 5]);
  LOrdered := FList.AsEnumerable.OrderByDesc(
    function(A, B: Integer): Integer
    begin
      Result := A - B;
    end);
  LArray := LOrdered.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Ordered list should have 5 elements');
  Assert.AreEqual(5, LArray[0], 'First element should be 5');
  Assert.AreEqual(1, LArray[4], 'Fifth element should be 1');
end;

procedure TListTest.TestList_SelectMany;
var
  LList: IFluentList<string>;
  LFiltered: IFluentEnumerable<Char>;
  LResult: IFluentArray<Char>;
begin
  LList := TFluentList<string>.Create;
  LList.AddRange(['abc', 'def']);
  LFiltered := LList.AsEnumerable.SelectMany<Char>(
    function(x: string; i: integer): IFluentArray<Char>
    begin
      Result := TFluentArray<Char>.Create([x[1], x[1]]);
    end);
  LResult := LFiltered.ToArray;
  Assert.AreEqual(4, LResult.Length, 'FlatMap deve retornar 4 caracteres');
  Assert.AreEqual('a', LResult[0], 'Primeiro caractere deve ser "a"');
  Assert.AreEqual('d', LResult[2], 'Terceiro caractere deve ser "d"');
end;

procedure TListTest.TestList_SelectManyAutoManaged;
var
  LList: IFluentList<string>;
  LEnum: IFluentEnumerable<string>;
  LFiltered: IFluentEnumerable<Char>;
  LResult: IFluentArray<Char>;
begin
  LList := TFluentList<string>.Create(['abc', 'def']);
  LEnum := LList.AsEnumerable;
  LFiltered := LEnum.SelectMany<Char>(
    function(x: string; i: integer): IFluentArray<Char>
    begin
      Result := TFluentArray<Char>.Create([x[1], x[1]]);
    end);
  LResult := LFiltered.ToArray;
  Assert.AreEqual(4, LResult.Length, 'FlatMap deve retornar 4 caracteres');
  Assert.AreEqual('a', LResult[0], 'Primeiro caractere deve ser "a"');
  Assert.AreEqual('d', LResult[2], 'Terceiro caractere deve ser "d"');
end;

procedure TListTest.TestListReduceGeneric;
var
  LResult: string;
begin
  FList.AddRange([1, 2, 3, 4, 5]);
  LResult := FList.AsEnumerable.Aggregate<string>(
    'Sum: ',
    function(Acc: string; Value: Integer): string
    begin
      Result := Acc + Value.ToString;
    end);
  Assert.AreEqual('Sum: 12345', LResult, 'Reduce should concatenate numbers as string');
end;

procedure TListTest.TestListToDictionary;
var
  LDict: TDictionary<Integer, string>;
begin
  FList.AddRange([1, 2, 3]);
  LDict := FList.AsEnumerable.ToDictionary<Integer, string>(
    function(Value: Integer): Integer
    begin
      Result := Value;
    end,
    function(Value: Integer): string
    begin
      Result := 'Item' + Value.ToString;
    end);
  try
    Assert.AreEqual(3, LDict.Count, 'Dictionary should have 3 entries');
    Assert.AreEqual('Item1', LDict[1], 'Key 1 should map to "Item1"');
    Assert.AreEqual('Item2', LDict[2], 'Key 2 should map to "Item2"');
    Assert.AreEqual('Item3', LDict[3], 'Key 3 should map to "Item3"');
  finally
    LDict.Free;
  end;
end;

function MakeOrderRec(AK1, AK2, ASeq: Integer): TOrderRec;
begin
  Result.K1 := AK1;
  Result.K2 := AK2;
  Result.Seq := ASeq;
end;

// C2 regression: OrderBy(K1).ThenBy(K2) must sort by (K1,K2) with K1 dominant,
// K2 only breaking ties, and be STABLE (equal (K1,K2) keep input order via Seq).
// Buggy code re-sorted by K2 alone, destroying the primary order.
procedure TListTest.TestListOrderByThenBy;
var
  LList: IFluentList<TOrderRec>;
  LArr: IFluentArray<TOrderRec>;
begin
  LList := TFluentList<TOrderRec>.Create;
  LList.Add(MakeOrderRec(2, 1, 0));
  LList.Add(MakeOrderRec(1, 2, 1));
  LList.Add(MakeOrderRec(1, 1, 2));
  LList.Add(MakeOrderRec(2, 1, 3));
  LList.Add(MakeOrderRec(1, 2, 4));
  LArr := LList.AsEnumerable
    .OrderBy(
      function(A, B: TOrderRec): Integer
      begin
        Result := A.K1 - B.K1;
      end)
    .ThenBy<Integer>(
      function(X: TOrderRec): Integer
      begin
        Result := X.K2;
      end)
    .ToArray;
  Assert.AreEqual(5, LArr.Length, 'All 5 elements must be preserved');
  // Expected (K1,K2) order with stable Seq tie-break: 2,1,4,0,3
  Assert.AreEqual(2, LArr[0].Seq, 'pos0 K1=1 K2=1 seq 2');
  Assert.AreEqual(1, LArr[1].Seq, 'pos1 K1=1 K2=2 seq 1 stable before 4');
  Assert.AreEqual(4, LArr[2].Seq, 'pos2 K1=1 K2=2 seq 4');
  Assert.AreEqual(0, LArr[3].Seq, 'pos3 K1=2 K2=1 seq 0 stable before 3');
  Assert.AreEqual(3, LArr[4].Seq, 'pos4 K1=2 K2=1 seq 3');
end;

procedure TListTest.TestListOrderByThenByDescending;
var
  LList: IFluentList<TOrderRec>;
  LArr: IFluentArray<TOrderRec>;
begin
  LList := TFluentList<TOrderRec>.Create;
  LList.Add(MakeOrderRec(2, 1, 0));
  LList.Add(MakeOrderRec(1, 2, 1));
  LList.Add(MakeOrderRec(1, 1, 2));
  LList.Add(MakeOrderRec(2, 1, 3));
  LList.Add(MakeOrderRec(1, 2, 4));
  LArr := LList.AsEnumerable
    .OrderBy(
      function(A, B: TOrderRec): Integer
      begin
        Result := A.K1 - B.K1;
      end)
    .ThenByDescending<Integer>(
      function(X: TOrderRec): Integer
      begin
        Result := X.K2;
      end)
    .ToArray;
  Assert.AreEqual(5, LArr.Length, 'All 5 elements must be preserved');
  // K1 asc, K2 desc within group, stable on ties: 1,4,2,0,3
  Assert.AreEqual(1, LArr[0].Seq, 'pos0 K1=1 K2=2 seq 1');
  Assert.AreEqual(4, LArr[1].Seq, 'pos1 K1=1 K2=2 seq 4');
  Assert.AreEqual(2, LArr[2].Seq, 'pos2 K1=1 K2=1 seq 2');
  Assert.AreEqual(0, LArr[3].Seq, 'pos3 K1=2 K2=1 seq 0');
  Assert.AreEqual(3, LArr[4].Seq, 'pos4 K1=2 K2=1 seq 3');
end;

// ThenBy is only valid directly after an ordering operator (IOrderedEnumerable).
procedure TListTest.TestListThenByWithoutOrderByRaises;
var
  LList: IFluentList<TOrderRec>;
begin
  LList := TFluentList<TOrderRec>.Create;
  LList.Add(MakeOrderRec(1, 1, 0));
  Assert.WillRaise(
    procedure
    begin
      LList.AsEnumerable.ThenBy<Integer>(
        function(X: TOrderRec): Integer
        begin
          Result := X.K2;
        end).ToArray;
    end,
    EInvalidOperation);
end;

// Intersect returns DISTINCT elements present in both sequences. The enumerator
// now tracks emitted items (FEmitted) instead of draining FSecond, so duplicates
// in the source collapse to a single result and the second set stays intact.
procedure TListTest.TestListIntersectDistinct;
var
  L1, L2: IFluentList<Integer>;
  LArr: IFluentArray<Integer>;
begin
  L1 := TFluentList<Integer>.Create;
  L1.AddRange([1, 1, 2, 3, 2]);
  L2 := TFluentList<Integer>.Create;
  L2.AddRange([1, 2]);
  LArr := L1.AsEnumerable.Intersect(L2.AsEnumerable).ToArray;
  Assert.AreEqual(2, LArr.Length, 'Intersect must be distinct: {1,2}');
  Assert.AreEqual(1, LArr[0], 'First distinct element is 1');
  Assert.AreEqual(2, LArr[1], 'Second distinct element is 2');
end;

// Regression: a second sequence with duplicates must not crash the Intersect
// enumerator. Building FSecond now uses AddOrSetValue instead of Add (which
// raised EListError on a duplicate key).
procedure TListTest.TestListIntersectSecondWithDuplicates;
var
  L1, L2: IFluentList<Integer>;
  LArr: IFluentArray<Integer>;
begin
  L1 := TFluentList<Integer>.Create;
  L1.AddRange([1, 2, 3]);
  L2 := TFluentList<Integer>.Create;
  L2.AddRange([2, 2, 3, 3]);
  LArr := L1.AsEnumerable.Intersect(L2.AsEnumerable).ToArray;
  Assert.AreEqual(2, LArr.Length, 'Intersect with duplicate second: {2,3}');
  Assert.AreEqual(2, LArr[0], 'First is 2');
  Assert.AreEqual(3, LArr[1], 'Second is 3');
end;

// ToArray must be non-destructive (LINQ semantics): the source list stays intact.
procedure TListTest.TestListToArrayNonDestructive;
var
  LList: IFluentList<Integer>;
  LArr1, LArr2: IFluentArray<Integer>;
begin
  LList := TFluentList<Integer>.Create;
  LList.AddRange([1, 2, 3]);
  LArr1 := LList.ToArray;
  LArr2 := LList.ToArray;
  Assert.AreEqual(3, LArr1.Length, 'First ToArray must have 3 elements');
  Assert.AreEqual(3, LArr2.Length, 'Second ToArray must still have 3 (non-destructive)');
  Assert.AreEqual(3, LList.Count, 'Source list must be intact after ToArray');
end;

// TFluentList.From must not leak the wrapper (FastMM FullDebugMode fails on leak).
procedure TListTest.TestListFromDoesNotLeak;
var
  LSrc: TList<Integer>;
  LArr: IFluentArray<Integer>;
begin
  LSrc := TList<Integer>.Create;
  try
    LSrc.AddRange([1, 2, 3]);
    LArr := TFluentList<Integer>.From(LSrc).ToArray;
    Assert.AreEqual(3, LArr.Length, 'From must enumerate all elements');
  finally
    LSrc.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TListTest);

end.
