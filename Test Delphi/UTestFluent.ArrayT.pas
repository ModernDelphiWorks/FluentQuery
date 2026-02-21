unit UTestFluent.ArrayT;

interface

uses
  Classes,
  SysUtils,
  Variants,
  DUnitX.TestFramework,
  Generics.Collections,
  Fluent,
  Fluent.Collections;

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

  TArrayTest = class
  private
    FArray: IFluentArray<Integer>;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestArrayToArray;
    [Test]
    procedure TestArrayToList;
    [Test]
    procedure TestArrayCount;
    [Test]
    procedure TestArrayAny;
    [Test]
    procedure TestArrayFirstOrDefault;
    [Test]
    procedure TestArrayLastOrDefault;
    [Test]
    procedure TestArrayMin;
    [Test]
    procedure TestArrayMax;
    [Test]
    procedure TestArraySum;
    [Test]
    procedure TestArrayReduce;
    [Test]
    procedure TestArrayDistinct;
    [Test]
    procedure TestArrayFilter;
    [Test]
    procedure TestArrayTake;
    [Test]
    procedure TestArraySkip;
    [Test]
    procedure TestArrayOrderBy;
    [Test]
    procedure TestArrayLongCount;
    [Test]
    procedure TestArrayMap;
    [Test]
    procedure TestArrayGroupBy;
    [Test]
    procedure TestArrayZip;
    [Test]
    procedure TestArrayJoin;
    [Test]
    procedure TestArrayMapLazy;
    [Test]
    procedure TestArrayOrderByLazy;
    [Test]
    procedure TestArrayDistinctLazy;
    [Test]
    procedure TestArrayZipLazy;
    [Test]
    procedure TestArrayJoinLazy;
    [Test]
    procedure TestArrayOfType;
    [Test]
    procedure TestArrayMinBy;
    [Test]
    procedure TestArrayMaxBy;
    [Test]
    procedure TestArrayLast;
    [Test]
    procedure TestArraySumDouble;
    [Test]
    procedure TestArrayMinWithComparer;
    [Test]
    procedure TestArrayReduceNoInitial;
//    [Test]
//    procedure TestArraySelectMany;
    [Test]
    procedure TestArrayGroupJoin;
    [Test]
    procedure TestArrayTakeWhile;
    [Test]
    procedure TestArraySkipWhile;
    [Test]
    procedure TestArrayAverage;
    [Test]
    procedure TestArrayExclude;
    [Test]
    procedure TestArrayIntersect;
    [Test]
    procedure TestArrayUnion;
    [Test]
    procedure TestArrayConcat;
    [Test]
    procedure TestArrayAll;
    [Test]
    procedure TestArrayContains;
    [Test]
    procedure TestArraySequenceEqual;
    [Test]
    procedure TestArraySequenceEqualNegative;
    [Test]
    procedure TestArrayAllNegative;
    [Test]
    procedure TestArraySingle;
    [Test]
    procedure TestArraySingleMultipleElements;
    [Test]
    procedure TestArraySingleOrDefault;
    [Test]
    procedure TestArrayElementAt;
    [Test]
    procedure TestArrayElementAtOrDefault;
    [Test]
    procedure TestArrayElementAtOutOfRange;
    [Test]
    procedure TestArrayOrderByDescending;
    [Test]
    procedure TestArrayFlatMap;
    [Test]
    procedure TestArrayFlatMapAutoManaged;
    [Test]
    procedure TestArrayReduceGeneric;
    [Test]
    procedure TestArrayToDictionary;
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

{ TArrayTest }

procedure TArrayTest.Setup;
begin
  FArray := TFluentArray<Integer>.Create([]);
end;

procedure TArrayTest.TearDown;
begin

end;

procedure TArrayTest.TestArrayToArray;
var
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LArray := FArray.AsEnumerable.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Array length should be 5');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(5, LArray[4], 'Last element should be 5');
end;

procedure TArrayTest.TestArrayToList;
var
  LResult: IFluentList<Integer>;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LResult := FArray.AsEnumerable.ToList;
  Assert.AreEqual(5, LResult.Count, 'List count should be 5');
  Assert.AreEqual(1, LResult[0], 'First element should be 1');
  Assert.AreEqual(5, LResult[4], 'Last element should be 5');
end;

procedure TArrayTest.TestArrayCount;
var
  LCount: Integer;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LCount := FArray.AsEnumerable.Count(
    function(Value: Integer): Boolean
    begin
      Result := Value > 2;
    end);
  Assert.AreEqual(3, LCount, 'Count of elements > 2 should be 3');
end;

procedure TArrayTest.TestArrayAny;
var
  LHasEven: Boolean;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LHasEven := FArray.AsEnumerable.Any(
    function(Value: Integer): Boolean
    begin
      Result := Value mod 2 = 0;
    end);
  Assert.IsTrue(LHasEven, 'Array should contain at least one even number');
end;

procedure TArrayTest.TestArrayFirstOrDefault;
var
  LFirstEven: Integer;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LFirstEven := FArray.AsEnumerable.FirstOrDefault(
    function(Value: Integer): Boolean
    begin
      Result := Value mod 2 = 0;
    end);
  Assert.AreEqual(2, LFirstEven, 'First even number should be 2');
end;

procedure TArrayTest.TestArrayLastOrDefault;
var
  LLastEven: Integer;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LLastEven := FArray.AsEnumerable.LastOrDefault(
    function(Value: Integer): Boolean
    begin
      Result := Value mod 2 = 0;
    end);
  Assert.AreEqual(4, LLastEven, 'Last even number should be 4');
end;

procedure TArrayTest.TestArrayMin;
var
  LMin: Integer;
begin
  FArray.SetItems([3, 1, 4, 1, 5]);
  LMin := FArray.AsEnumerable.Min;
  Assert.AreEqual(1, LMin, 'Minimum value should be 1');
end;

procedure TArrayTest.TestArrayMax;
var
  LMax: Integer;
begin
  FArray.SetItems([3, 1, 4, 1, 5]);
  LMax := FArray.AsEnumerable.Max;
  Assert.AreEqual(5, LMax, 'Maximum value should be 5');
end;

procedure TArrayTest.TestArraySum;
var
  LSum: Integer;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LSum := FArray.AsEnumerable.Sum(
    function(Value: Integer): Integer
    begin
      Result := Value;
    end);
  Assert.AreEqual(15, LSum, 'Sum of elements should be 15');
end;

procedure TArrayTest.TestArrayReduce;
var
  LSum: Integer;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LSum := FArray.AsEnumerable.Aggregate(
    function(Acc, Value: Integer): Integer
    begin
      Result := Acc + Value;
    end);
  Assert.AreEqual(15, LSum, 'Reduced sum of elements should be 15');
end;

procedure TArrayTest.TestArrayDistinct;
var
  LDistinct: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([1, 2, 2, 3, 3, 4, 5, 5]);
  LDistinct := FArray.AsEnumerable.Distinct;
  LArray := LDistinct.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Distinct array should have 5 unique elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(5, LArray[4], 'Last element should be 5');
end;

procedure TArrayTest.TestArrayFilter;
var
  LFiltered: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LFiltered := FArray.AsEnumerable.Where(
    function(Value: Integer): Boolean
    begin
      Result := Value > 3;
    end);
  LArray := LFiltered.ToArray;
  Assert.AreEqual(2, LArray.Length, 'Filtered array should have 2 elements');
  Assert.AreEqual(4, LArray[0], 'First element should be 4');
  Assert.AreEqual(5, LArray[1], 'Last element should be 5');
end;

procedure TArrayTest.TestArrayTake;
var
  LTaken: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LTaken := FArray.AsEnumerable.Take(3);
  LArray := LTaken.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Taken array should have 3 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(3, LArray[2], 'Last element should be 3');
end;

procedure TArrayTest.TestArraySkip;
var
  LSkipped: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LSkipped := FArray.AsEnumerable.Skip(2);
  LArray := LSkipped.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Skipped array should have 3 elements');
  Assert.AreEqual(3, LArray[0], 'First element should be 3');
  Assert.AreEqual(5, LArray[2], 'Last element should be 5');
end;

procedure TArrayTest.TestArrayOrderBy;
var
  LOrdered: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([5, 2, 4, 1, 3]);
  LOrdered := FArray.AsEnumerable.OrderBy(
    function(A, B: Integer): Integer
    begin
      Result := A - B;
    end);
  LArray := LOrdered.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Ordered array should have 5 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(5, LArray[4], 'Last element should be 5');
end;

procedure TArrayTest.TestArrayLongCount;
var
  LCount: Int64;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LCount := FArray.AsEnumerable.LongCount(
    function(Value: Integer): Boolean
    begin
      Result := Value > 2;
    end);
  Assert.AreEqual(Int64(3), LCount, 'Count of elements > 2 should be 3');
end;

procedure TArrayTest.TestArrayMap;
var
  LMapped: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LMapped := FArray.AsEnumerable.Select<Integer>(
    function(Value: Integer): Integer
    begin
      Result := Value * 2;
    end);
  LArray := LMapped.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Mapped array should have 5 elements');
  Assert.AreEqual(2, LArray[0], 'First element should be 2');
  Assert.AreEqual(10, LArray[4], 'Last element should be 10');
end;

procedure TArrayTest.TestArrayGroupBy;
var
  LGroups: IGroupByEnumerable<Integer, Integer>;
  LEnum: IFluentEnumerator<IGrouping<Integer, Integer>>;
  LGroup: IGrouping<Integer, Integer>;
  LArray: IFluentArray<Integer>;
  LCount: Integer;
begin
  FArray.SetItems([1, 2, 3, 4, 5, 6]);
  LGroups := FArray.AsEnumerable.GroupBy<Integer>(
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

procedure TArrayTest.TestArrayZip;
var
  LArray2: TFluentArray<string>;
  LZipped: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  FArray.SetItems([1, 2, 3]);
  LArray2 := TFluentArray<string>.Create(['A', 'B', 'C']);
  try
    LZipped := FArray.AsEnumerable.Zip<string, string>(
      LArray2.AsEnumerable,
      function(Num: Integer; Letter: string): string
      begin
        Result := Num.ToString + Letter;
      end);
    LArray := LZipped.ToArray;
    Assert.AreEqual(3, LArray.Length, 'Zipped array should have 3 elements');
    Assert.AreEqual('1A', LArray[0], 'First element should be "1A"');
    Assert.AreEqual('2B', LArray[1], 'Second element should be "2B"');
    Assert.AreEqual('3C', LArray[2], 'Third element should be "3C"');
  finally
    LArray2.Free;
  end;
end;

procedure TArrayTest.TestArrayJoin;
var
  LInner: IFluentArray<string>;
  LJoined: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  FArray.SetItems([1, 2, 3]);
  LInner := TFluentArray<string>.Create(['A1', 'B2', 'C3']);
  LJoined := FArray.AsEnumerable.Join<string, Integer, string>(
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
  Assert.AreEqual(3, LArray.Length, 'Joined array should have 3 elements');
  Assert.AreEqual('A1-1', LArray[0], 'First element should be "A1-1"');
  Assert.AreEqual('B2-2', LArray[1], 'Second element should be "B2-2"');
  Assert.AreEqual('C3-3', LArray[2], 'Third element should be "C3-3"');
end;

procedure TArrayTest.TestArrayMapLazy;
var
  LMapped: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  FArray.SetItems([1, 2, 3]);
  LMapped := FArray.AsEnumerable.Select<string>(
    function(Value: Integer): string
    begin
      Writeln('Mapping: ' + IntToStr(Value));
      Result := Value.ToString + 'x';
    end);
  Writeln('Map chamado, mas ainda não iterado');
  LArray := LMapped.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Mapped array should have 3 elements');
  Assert.AreEqual('1x', LArray[0], 'First element should be "1x"');
  Assert.AreEqual('2x', LArray[1], 'Second element should be "2x"');
  Assert.AreEqual('3x', LArray[2], 'Third element should be "3x"');
end;

procedure TArrayTest.TestArrayOrderByLazy;
var
  LOrdered: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([3, 1, 4, 1, 5]);
  LOrdered := FArray.AsEnumerable.Where(
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
  Assert.AreEqual(3, LArray.Length, 'Ordered array should have 3 elements');
  Assert.AreEqual(3, LArray[0], 'First element should be 3');
  Assert.AreEqual(4, LArray[1], 'Second element should be 4');
  Assert.AreEqual(5, LArray[2], 'Third element should be 5');
end;

procedure TArrayTest.TestArrayDistinctLazy;
var
  LDistinct: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([3, 1, 4, 1, 5, 3]);
  LDistinct := FArray.AsEnumerable.Where(
    function(Value: Integer): Boolean
    begin
      Writeln('Filtering: ' + IntToStr(Value));
      Result := Value > 2;
    end).Distinct;
  Writeln('Distinct chamado, mas ainda não iterado');
  LArray := LDistinct.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Distinct array should have 3 elements');
  Assert.AreEqual(3, LArray[0], 'First element should be 3');
  Assert.AreEqual(4, LArray[1], 'Second element should be 4');
  Assert.AreEqual(5, LArray[2], 'Third element should be 5');
end;

procedure TArrayTest.TestArrayZipLazy;
var
  LArray2: IFluentArray<string>;
  LZipped: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  FArray.SetItems([1, 2, 3]);
  LArray2 := TFluentArray<string>.Create(['A', 'B', 'C']);
  LZipped := FArray.AsEnumerable.Zip<string, string>(
    LArray2.AsEnumerable,
    function(Num: Integer; Letter: string): string
    begin
      Writeln('Zipping: ' + IntToStr(Num) + ' with ' + Letter);
      Result := Num.ToString + Letter;
    end);
  Writeln('Zip chamado, mas ainda não iterado');
  LArray := LZipped.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Zipped array should have 3 elements');
  Assert.AreEqual('1A', LArray[0], 'First element should be "1A"');
  Assert.AreEqual('2B', LArray[1], 'Second element should be "2B"');
  Assert.AreEqual('3C', LArray[2], 'Third element should be "3C"');
end;

procedure TArrayTest.TestArrayJoinLazy;
var
  LInner: IFluentArray<string>;
  LJoined: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  FArray.SetItems([1, 2, 3]);
  LInner := TFluentArray<string>.Create(['A1', 'B2', 'C3']);
  LJoined := FArray.AsEnumerable.Join<string, Integer, string>(
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
  Assert.AreEqual(3, LArray.Length, 'Joined array should have 3 elements');
  Assert.AreEqual('A1-1', LArray[0], 'First element should be "A1-1"');
  Assert.AreEqual('B2-2', LArray[1], 'Second element should be "B2-2"');
  Assert.AreEqual('C3-3', LArray[2], 'Third element should be "C3-3"');
end;

procedure TArrayTest.TestArrayOfType;
var
  LArrayVar: IFluentArray<Variant>;
  LFiltered: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  LArrayVar := TFluentArray<Variant>.Create([1, 'two', 3, 'four', 5]);
  LFiltered := LArrayVar.AsEnumerable.OfType<Integer>(
    function(Value: Variant): Boolean
    begin
      Result := VarIsNumeric(Value);
    end,
    function(Value: Variant): Integer
    begin
      Result := Integer(Value);
    end);
  LArray := LFiltered.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Filtered array should have 3 integers');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(3, LArray[1], 'Second element should be 3');
  Assert.AreEqual(5, LArray[2], 'Third element should be 5');
end;

procedure TArrayTest.TestArrayMinBy;
var
  LMin: Integer;
begin
  FArray.SetItems([3, 1, 4, 1, 5]);
  LMin := FArray.AsEnumerable.MinBy<Integer>(
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

procedure TArrayTest.TestArrayMaxBy;
var
  LMax: Integer;
begin
  FArray.SetItems([3, 1, 4, 1, 5]);
  LMax := FArray.AsEnumerable.MaxBy<Integer>(
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

procedure TArrayTest.TestArrayLast;
var
  LLast: Integer;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LLast := FArray.AsEnumerable.Last(
    function(Value: Integer): Boolean
    begin
      Result := Value > 3;
    end);
  Assert.AreEqual(5, LLast, 'Last should return 5');
end;

procedure TArrayTest.TestArraySumDouble;
var
  LArray: TFluentArray<Double>;
  LSum: Double;
begin
  LArray := TFluentArray<Double>.Create([1.5, 2.5, 3.5]);
  try
    LSum := LArray.AsEnumerable.Sum(
      function(Value: Double): Double
      begin
        Result := Value;
      end);
    Assert.AreEqual(Double(7.5), LSum, 'Sum should be 7.5');
  finally
    LArray.Free;
  end;
end;

procedure TArrayTest.TestArrayMinWithComparer;
var
  LMin: Integer;
begin
  FArray.SetItems([3, 1, 4, 1, 5]);
  LMin := FArray.AsEnumerable.Min(
    function(A, B: Integer): Integer
    begin
      Result := A - B;
    end);
  Assert.AreEqual(1, LMin, 'Min should be 1');
end;

procedure TArrayTest.TestArrayReduceNoInitial;
var
  LResult: Integer;
begin
  FArray.SetItems([1, 2, 3]);
  LResult := FArray.AsEnumerable.Aggregate(
    function(A, B: Integer): Integer
    begin
      Result := A + B;
    end);
  Assert.AreEqual(6, LResult, 'Reduce should be 6');
end;

procedure TArrayTest.TestArrayGroupJoin;
var
  LInner: IFluentArray<string>;
  LJoined: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  FArray.SetItems([1, 2, 3]);
  LInner := TFluentArray<string>.Create(['A1', 'B1', 'C2']);
  LJoined := FArray.AsEnumerable.GroupJoin<string, Integer, string>(
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
  Assert.AreEqual(3, LArray.Length, 'Joined array should have 3 elements');
  Assert.AreEqual('1: A1, B1', LArray[0], 'First element should be "1: A1, B1"');
  Assert.AreEqual('2: C2', LArray[1], 'Second element should be "2: C2"');
  Assert.AreEqual('3: ', LArray[2], 'Third element should be "3: "');
end;

procedure TArrayTest.TestArrayTakeWhile;
var
  LTaken: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([1, 2, 3, 0, 4]);
  LTaken := FArray.AsEnumerable.TakeWhile(
    function(Value: Integer): Boolean
    begin
      Result := Value > 0;
    end);
  LArray := LTaken.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Taken array should have 3 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(3, LArray[2], 'Third element should be 3');
end;

procedure TArrayTest.TestArraySkipWhile;
var
  LSkipped: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([1, 2, 3, 0, 4]);
  LSkipped := FArray.AsEnumerable.SkipWhile(
    function(Value: Integer): Boolean
    begin
      Result := Value > 0;
    end);
  LArray := LSkipped.ToArray;
  Assert.AreEqual(2, LArray.Length, 'Skipped array should have 2 elements');
  Assert.AreEqual(0, LArray[0], 'First element should be 0');
  Assert.AreEqual(4, LArray[1], 'Second element should be 4');
end;

procedure TArrayTest.TestArrayAverage;
var
  LAverage: Double;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LAverage := FArray.AsEnumerable.Average(
    function(Value: Integer): Double
    begin
      Result := Value;
    end);
  Assert.AreEqual(Double(3.0), LAverage, 'Average should be 3.0');
end;

procedure TArrayTest.TestArrayExclude;
var
  LSecond: IFluentArray<Integer>;
  LExclude: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([1, 2, 3, 4]);
  LSecond := TFluentArray<Integer>.Create([2, 4]);
  LExclude := FArray.AsEnumerable.Exclude(LSecond.AsEnumerable);
  LArray := LExclude.ToArray;
  Assert.AreEqual(2, LArray.Length, 'Exclude array should have 2 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(3, LArray[1], 'Second element should be 3');
end;

procedure TArrayTest.TestArrayIntersect;
var
  LSecond: IFluentArray<Integer>;
  LIntersect: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([1, 2, 3, 4]);
  LSecond := TFluentArray<Integer>.Create([2, 4, 5]);
  LIntersect := FArray.AsEnumerable.Intersect(LSecond.AsEnumerable);
  LArray := LIntersect.ToArray;
  Assert.AreEqual(2, LArray.Length, 'Intersect array should have 2 elements');
  Assert.AreEqual(2, LArray[0], 'First element should be 2');
  Assert.AreEqual(4, LArray[1], 'Second element should be 4');
end;

procedure TArrayTest.TestArrayUnion;
var
  LSecond: IFluentArray<Integer>;
  LUnion: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([1, 2, 3]);
  LSecond := TFluentArray<Integer>.Create([2, 3, 4]);
  LUnion := FArray.AsEnumerable.Union(LSecond.AsEnumerable);
  LArray := LUnion.ToArray;
  Assert.AreEqual(4, LArray.Length, 'Union array should have 4 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(4, LArray[3], 'Fourth element should be 4');
end;

procedure TArrayTest.TestArrayConcat;
var
  LSecond: IFluentArray<Integer>;
  LConcat: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([1, 2, 3]);
  LSecond := TFluentArray<Integer>.Create([2, 3, 4]);
  LConcat := FArray.AsEnumerable.Concat(LSecond.AsEnumerable);
  LArray := LConcat.ToArray;
  Assert.AreEqual(6, LArray.Length, 'Concat array should have 6 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(4, LArray[5], 'Sixth element should be 4');
end;

procedure TArrayTest.TestArrayAll;
var
  LResult: Boolean;
begin
  FArray.SetItems([1, 2, 3]);
  LResult := FArray.AsEnumerable.All(
    function(Value: Integer): Boolean
    begin
      Result := Value > 0;
    end);
  Assert.IsTrue(LResult, 'All elements should be greater than 0');

  FArray.SetItems([1, 2, -3]);
  LResult := FArray.AsEnumerable.All(
    function(Value: Integer): Boolean
    begin
      Result := Value > 0;
    end);
  Assert.IsFalse(LResult, 'Not all elements are greater than 0');
end;

procedure TArrayTest.TestArrayContains;
var
  LResult: Boolean;
begin
  FArray.SetItems([1, 2, 3]);
  LResult := FArray.AsEnumerable.Contains(2);
  Assert.IsTrue(LResult, 'Array should contain 2');

  LResult := FArray.AsEnumerable.Contains(4);
  Assert.IsFalse(LResult, 'Array should not contain 4');
end;

procedure TArrayTest.TestArraySequenceEqual;
var
  LSecond: IFluentArray<Integer>;
  LResult: Boolean;
begin
  FArray.SetItems([1, 2, 3]);
  LSecond := TFluentArray<Integer>.Create([1, 2, 3]);
  LResult := FArray.AsEnumerable.SequenceEqual(LSecond.AsEnumerable);
  Assert.IsTrue(LResult, 'Sequences should be equal');

  LSecond.SetItems([1, 2, 4]);
  LResult := FArray.AsEnumerable.SequenceEqual(LSecond.AsEnumerable);
  Assert.IsFalse(LResult, 'Sequences should not be equal');
end;

procedure TArrayTest.TestArraySequenceEqualNegative;
var
  LSecond: TFluentArray<Integer>;
  LResult: Boolean;
begin
  FArray.SetItems([1, 2, 3]);
  LSecond := TFluentArray<Integer>.Create([1, 2, 4]);
  try
    LResult := FArray.AsEnumerable.SequenceEqual(LSecond.AsEnumerable);
    Assert.IsFalse(LResult, 'Sequences should not be equal');
  finally
    LSecond.Free;
  end;
end;

procedure TArrayTest.TestArrayAllNegative;
var
  LResult: Boolean;
begin
  FArray.SetItems([1, 2, -3]);
  LResult := FArray.AsEnumerable.All(
    function(Value: Integer): Boolean
    begin
      Result := Value > 0;
    end);
  Assert.IsFalse(LResult, 'Not all elements are greater than 0');
end;

procedure TArrayTest.TestArraySingle;
var
  LResult: Integer;
begin
  FArray.SetItems([1, 2, 3]);
  LResult := FArray.AsEnumerable.Single(
    function(Value: Integer): Boolean
    begin
      Result := Value = 2;
    end);
  Assert.AreEqual(2, LResult, 'Single element should be 2');
end;

procedure TArrayTest.TestArraySingleMultipleElements;
begin
  FArray.SetItems([1, 2, 2, 3]);
  Assert.WillRaise(
    procedure
    begin
      FArray.AsEnumerable.Single(
        function(Value: Integer): Boolean
        begin
          Result := Value = 2;
        end);
    end,
    EInvalidOperation,
    'Single should raise exception for multiple elements');
end;

procedure TArrayTest.TestArraySingleOrDefault;
var
  LResult: Integer;
begin
  FArray.SetItems([1, 2, 3]);
  LResult := FArray.AsEnumerable.SingleOrDefault(
    function(Value: Integer): Boolean
    begin
      Result := Value = 4;
    end);
  Assert.AreEqual(0, LResult, 'SingleOrDefault should return 0 when no element is found');

  LResult := FArray.AsEnumerable.SingleOrDefault(
    function(Value: Integer): Boolean
    begin
      Result := Value = 2;
    end);
  Assert.AreEqual(2, LResult, 'SingleOrDefault should return 2');
end;

procedure TArrayTest.TestArrayElementAt;
var
  LResult: Integer;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LResult := FArray.AsEnumerable.ElementAt(2);
  Assert.AreEqual(3, LResult, 'Element at index 2 should be 3');
end;

procedure TArrayTest.TestArrayElementAtOrDefault;
var
  LResult: Integer;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LResult := FArray.AsEnumerable.ElementAtOrDefault(2);
  Assert.AreEqual(3, LResult, 'Element at index 2 should be 3');
  LResult := FArray.AsEnumerable.ElementAtOrDefault(10);
  Assert.AreEqual(0, LResult, 'Element at index 10 should return default (0)');
end;

procedure TArrayTest.TestArrayElementAtOutOfRange;
begin
  FArray.SetItems([1, 2, 3]);
  Assert.WillRaise(
    procedure
    begin
      FArray.AsEnumerable.ElementAt(5);
    end,
    EArgumentOutOfRangeException,
    'Expected EArgumentOutOfRangeException for index out of range');
end;

procedure TArrayTest.TestArrayOrderByDescending;
var
  LOrdered: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  FArray.SetItems([3, 1, 4, 1, 5]);
  LOrdered := FArray.AsEnumerable.OrderByDesc(
    function(A, B: Integer): Integer
    begin
      Result := A - B;
    end);
  LArray := LOrdered.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Ordered array should have 5 elements');
  Assert.AreEqual(5, LArray[0], 'First element should be 5');
  Assert.AreEqual(1, LArray[4], 'Fifth element should be 1');
end;

procedure TArrayTest.TestArrayFlatMap;
var
  LArrayStr: IFluentArray<string>;
  LFiltered: IFluentEnumerable<Char>;
  LResult: IFluentArray<Char>;
begin
  LArrayStr := TFluentArray<string>.Create(['abc', 'def']);
  LFiltered := LArrayStr.AsEnumerable.SelectMany<Char>(
    function(x: string): TArray<Char>
    begin
      Result := TArray<Char>.Create(x[1], x[1]);
    end);
  LResult := LFiltered.ToArray;
  Assert.AreEqual(4, LResult.Length, 'FlatMap should return 4 characters');
  Assert.AreEqual('a', LResult[0], 'First character should be "a"');
  Assert.AreEqual('d', LResult[2], 'Third character should be "d"');
end;

procedure TArrayTest.TestArrayFlatMapAutoManaged;
var
  LArrayStr: IFluentArray<string>;
  LEnum: IFluentEnumerable<string>;
  LFiltered: IFluentEnumerable<Char>;
  LResult: IFluentArray<Char>;
begin
  LArrayStr := TFluentArray<string>.Create(['abc', 'def']);
  LEnum := LArrayStr.AsEnumerable;
  LFiltered := LEnum.SelectMany<Char>(
    function(x: string): TArray<Char>
    begin
      Result := TArray<Char>.Create(x[1], x[1]);
    end);
  LResult := LFiltered.ToArray;
  Assert.AreEqual(4, LResult.Length, 'FlatMap should return 4 characters');
  Assert.AreEqual('a', LResult[0], 'First character should be "a"');
  Assert.AreEqual('d', LResult[2], 'Third character should be "d"');
end;

procedure TArrayTest.TestArrayReduceGeneric;
var
  LResult: string;
begin
  FArray.SetItems([1, 2, 3, 4, 5]);
  LResult := FArray.AsEnumerable.Aggregate<string>(
    'Sum: ',
    function(Acc: string; Value: Integer): string
    begin
      Result := Acc + Value.ToString;
    end);
  Assert.AreEqual('Sum: 12345', LResult, 'Reduce should concatenate numbers as string');
end;

procedure TArrayTest.TestArrayToDictionary;
var
  LDict: TDictionary<Integer, string>;
begin
  FArray.SetItems([1, 2, 3]);
  LDict := FArray.AsEnumerable.ToDictionary<Integer, string>(
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
  TDUnitX.RegisterTestFixture(TArrayTest);

end.
