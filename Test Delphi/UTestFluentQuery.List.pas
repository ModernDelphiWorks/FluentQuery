unit UTestFluentQuery.List;

interface

uses
  Classes,
  SysUtils,
  Variants,
  DUnitX.TestFramework,
  Generics.Collections,
  FluentQuery,
  FluentQuery.Collections;

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
    procedure TestListLongCount;
    [Test]
    procedure TestListMap;
    [Test]
    procedure TestListGroupBy;
    [Test]
    procedure TestListZip;
    [Test]
    procedure TestListJoin;
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
    procedure TestListExclude;
    [Test]
    procedure TestListIntersect;
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
  Writeln('Map chamado, mas ainda não iterado');
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
  Writeln('OrderBy chamado, mas ainda não iterado');
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
  Writeln('Distinct chamado, mas ainda não iterado');
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
  Writeln('Zip chamado, mas ainda não iterado');
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
  Writeln('Join chamado, mas ainda não iterado');
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
  LFiltered := LList.AsEnumerable.OfType<Integer>(
    function(Value: Variant): Boolean
    begin
      Result := VarIsNumeric(Value);
    end,
    function(Value: Variant): Integer
    begin
      Result := Integer(Value);
    end);
  LArray := LFiltered.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Filtered list should have 3 integers');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(3, LArray[1], 'Second element should be 3');
  Assert.AreEqual(5, LArray[2], 'Third element should be 5');
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

initialization
  TDUnitX.RegisterTestFixture(TListTest);

end.
