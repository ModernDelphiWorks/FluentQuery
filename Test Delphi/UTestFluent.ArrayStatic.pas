unit UTestFluent.ArrayStatic;

interface

uses
  Classes,
  SysUtils,
  Variants,
  DUnitX.TestFramework,
  Generics.Collections,
  Generics.Defaults,
  Fluent,
  Fluent.Collections;

type
  TArrayStaticTest = class
  private
    class function CreateComparer<T>: IComparer<T>;
  public
    [Test]
    procedure TestFreeValuesArray;
    [Test]
    procedure TestFreeValuesTArray;
    [Test]
    procedure TestFrom;
    [Test]
    procedure TestSortSimple;
    [Test]
    procedure TestSortWithComparer;
    [Test]
    procedure TestSortWithComparerRange;
    [Test]
    procedure TestBinarySearchFull;
    [Test]
    procedure TestBinarySearchComparer;
    [Test]
    procedure TestBinarySearchSimple;
{$IF Defined(CPU64BITS)}
    [Test]
    procedure TestBinarySearchFull32;
    [Test]
    procedure TestBinarySearchComparer32;
    [Test]
    procedure TestBinarySearchSimple32;
{$ENDIF CPU64BITS}
    [Test]
    procedure TestCopyFull;
    [Test]
    procedure TestCopySimple;
    [Test]
    procedure TestConcat;
    [Test]
    procedure TestIndexOfSimple;
    [Test]
    procedure TestIndexOfStart;
    [Test]
    procedure TestIndexOfComparer;
    [Test]
    procedure TestLastIndexOfSimple;
    [Test]
    procedure TestLastIndexOfStart;
    [Test]
    procedure TestLastIndexOfComparer;
    [Test]
    procedure TestContainsSimple;
    [Test]
    procedure TestContainsComparer;
    [Test]
    procedure TestToStringSimple;
    [Test]
    procedure TestToStringWithFormat;

    // Testes Lazy reutilizados do TFluenIFluentArray<T>
    [Test]
    procedure TestLazyToArray;
    [Test]
    procedure TestLazyToList;
    [Test]
    procedure TestLazyCount;
    [Test]
    procedure TestLazyAny;
    [Test]
    procedure TestLazyFirstOrDefault;
    [Test]
    procedure TestLazyLastOrDefault;
    [Test]
    procedure TestLazyMin;
    [Test]
    procedure TestLazyMax;
    [Test]
    procedure TestLazySum;
    [Test]
    procedure TestLazyReduce;
    [Test]
    procedure TestLazyDistinct;
    [Test]
    procedure TestLazyFilter;
    [Test]
    procedure TestLazyTake;
    [Test]
    procedure TestLazySkip;
    [Test]
    procedure TestLazyOrderBy;
    [Test]
    procedure TestLazyLongCount;
    [Test]
    procedure TestLazyMap;
    [Test]
    procedure TestLazyGroupBy;
    [Test]
    procedure TestLazyZip;
    [Test]
    procedure TestLazyJoin;
    [Test]
    procedure TestLazyMapLazy;
    [Test]
    procedure TestLazyOrderByLazy;
    [Test]
    procedure TestLazyDistinctLazy;
    [Test]
    procedure TestLazyZipLazy;
    [Test]
    procedure TestLazyJoinLazy;
  end;

implementation

{ TArrayStaticTest }

class function TArrayStaticTest.CreateComparer<T>: IComparer<T>;
begin
  Result := TComparer<T>.Construct(
    function(const A, B: T): Integer
    begin
      Result := TComparer<T>.Default.Compare(A, B);
    end);
end;

procedure TArrayStaticTest.TestFreeValuesArray;
var
  LArray: array of TObject;
  LObj1, LObj2: TObject;
begin
  SetLength(LArray, 2);
  LObj1 := TObject.Create;
  LObj2 := TObject.Create;
  LArray[0] := LObj1;
  LArray[1] := LObj2;
  TFluentArray.FreeValues<TObject>(LArray);
  Assert.IsTrue(LArray[0] = nil, 'First element should be nil after free');
  Assert.IsTrue(LArray[1] = nil, 'Second element should be nil after free');
end;

procedure TArrayStaticTest.TestFreeValuesTArray;
var
  LArray: TArray<TObject>;
  LObj1, LObj2: TObject;
begin
  SetLength(LArray, 2);
  LObj1 := TObject.Create;
  LObj2 := TObject.Create;
  LArray[0] := LObj1;
  LArray[1] := LObj2;
  TFluentArray.FreeValues<TObject>(LArray);
  Assert.IsTrue(LArray[0] = nil, 'First element should be nil after free');
  Assert.IsTrue(LArray[1] = nil, 'Second element should be nil after free');
end;

procedure TArrayStaticTest.TestFrom;
var
  LEnum: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  LEnum := TFluentArray.From<Integer>([1, 2, 3]);
  LArray := LEnum.ToArray;
  Assert.AreEqual(3, LArray.Length, 'From should create enumerable with 3 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(3, LArray[2], 'Last element should be 3');
end;

procedure TArrayStaticTest.TestSortSimple;
var
  LArray: array[0..4] of Integer;
begin
  LArray[0] := 5; LArray[1] := 2; LArray[2] := 4; LArray[3] := 1; LArray[4] := 3;
  TFluentArray.Sort<Integer>(LArray);
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(5, LArray[4], 'Last element should be 5');
end;

procedure TArrayStaticTest.TestSortWithComparer;
var
  LArray: array[0..4] of Integer;
  LComparer: IComparer<Integer>;
begin
  LArray[0] := 5; LArray[1] := 2; LArray[2] := 4; LArray[3] := 1; LArray[4] := 3;
  LComparer := CreateComparer<Integer>;
  TFluentArray.Sort<Integer>(LArray, LComparer);
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(5, LArray[4], 'Last element should be 5');
end;

procedure TArrayStaticTest.TestSortWithComparerRange;
var
  LArray: array[0..5] of Integer;
  LComparer: IComparer<Integer>;
begin
  LArray[0] := 0; LArray[1] := 5; LArray[2] := 2; LArray[3] := 4; LArray[4] := 1; LArray[5] := 3;
  LComparer := CreateComparer<Integer>;
  TFluentArray.Sort<Integer>(LArray, LComparer, 1, 4); // Sort from index 1 to 4
  Assert.AreEqual(0, LArray[0], 'Element at index 0 should remain unchanged');
  Assert.AreEqual(1, LArray[1], 'First sorted element should be 1');
  Assert.AreEqual(5, LArray[4], 'Last sorted element should be 5');
  Assert.AreEqual(3, LArray[5], 'Element at index 5 should remain unchanged');
end;

procedure TArrayStaticTest.TestBinarySearchFull;
var
  LArray: array[0..4] of Integer;
  LFoundIndex: NativeInt;
  LComparer: IComparer<Integer>;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 4; LArray[4] := 5;
  LComparer := CreateComparer<Integer>;
  Assert.IsTrue(TFluentArray.BinarySearch<Integer>(LArray, 3, LFoundIndex, LComparer, 0, 5), 'Should find 3');
  Assert.AreEqual(NativeInt(2), LFoundIndex, 'Index of 3 should be 2');
end;

procedure TArrayStaticTest.TestBinarySearchComparer;
var
  LArray: array[0..4] of Integer;
  LFoundIndex: NativeInt;
  LComparer: IComparer<Integer>;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 4; LArray[4] := 5;
  LComparer := CreateComparer<Integer>;
  Assert.IsTrue(TFluentArray.BinarySearch<Integer>(LArray, 4, LFoundIndex, LComparer), 'Should find 4');
  Assert.AreEqual(NativeInt(3), LFoundIndex, 'Index of 4 should be 3');
end;

procedure TArrayStaticTest.TestBinarySearchSimple;
var
  LArray: array[0..4] of Integer;
  LFoundIndex: NativeInt;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 4; LArray[4] := 5;
  Assert.IsTrue(TFluentArray.BinarySearch<Integer>(LArray, 5, LFoundIndex), 'Should find 5');
  Assert.AreEqual(NativeInt(4), LFoundIndex, 'Index of 5 should be 4');
end;

{$IF Defined(CPU64BITS)}
procedure TArrayStaticTest.TestBinarySearchFull32;
var
  LArray: array[0..4] of Integer;
  LFoundIndex: Integer;
  LComparer: IComparer<Integer>;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 4; LArray[4] := 5;
  LComparer := CreateComparer<Integer>;
  Assert.IsTrue(TFluentArray.BinarySearch<Integer>(LArray, 3, LFoundIndex, LComparer, 0, 5), 'Should find 3');
  Assert.AreEqual(2, LFoundIndex, 'Index of 3 should be 2');
end;

procedure TArrayStaticTest.TestBinarySearchComparer32;
var
  LArray: array[0..4] of Integer;
  LFoundIndex: Integer;
  LComparer: IComparer<Integer>;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 4; LArray[4] := 5;
  LComparer := CreateComparer<Integer>;
  Assert.IsTrue(TFluentArray.BinarySearch<Integer>(LArray, 4, LFoundIndex, LComparer), 'Should find 4');
  Assert.AreEqual(3, LFoundIndex, 'Index of 4 should be 3');
end;

procedure TArrayStaticTest.TestBinarySearchSimple32;
var
  LArray: array[0..4] of Integer;
  LFoundIndex: Integer;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 4; LArray[4] := 5;
  Assert.IsTrue(TFluentArray.BinarySearch<Integer>(LArray, 5, LFoundIndex), 'Should find 5');
  Assert.AreEqual(4, LFoundIndex, 'Index of 5 should be 4');
end;
{$ENDIF CPU64BITS}

procedure TArrayStaticTest.TestCopyFull;
var
  LSource: TArray<Integer>;
  LDest: array[0..5] of Integer;
begin
  // Demonstra uso com IFluentArray<T>, simplificando a atribuição, mas funciona.
  LSource := [1, 2, 3, 4, 5];
  LDest[0] := 0; LDest[1] := 0; LDest[2] := 0; LDest[3] := 0; LDest[4] := 0; LDest[5] := 0;
  TFluentArray.Copy<Integer>(LSource, LDest, 1, 2, 3);
  Assert.AreEqual(0, LDest[0], 'Index 0 should remain 0');
  Assert.AreEqual(0, LDest[1], 'Index 1 should remain 0');
  Assert.AreEqual(2, LDest[2], 'Index 2 should be 2');
  Assert.AreEqual(3, LDest[3], 'Index 3 should be 3');
  Assert.AreEqual(4, LDest[4], 'Index 4 should be 4');
  Assert.AreEqual(0, LDest[5], 'Index 5 should remain 0');
end;

procedure TArrayStaticTest.TestCopySimple;
var
  LSource: array[0..2] of Integer;
  LDest: array[0..2] of Integer;
begin
  LSource[0] := 1; LSource[1] := 2; LSource[2] := 3;
  LDest[0] := 0; LDest[1] := 0; LDest[2] := 0;
  TFluentArray.Copy<Integer>(LSource, LDest, 3);
  Assert.AreEqual(1, LDest[0], 'Index 0 should be 1');
  Assert.AreEqual(2, LDest[1], 'Index 1 should be 2');
  Assert.AreEqual(3, LDest[2], 'Index 2 should be 3');
end;

procedure TArrayStaticTest.TestConcat;
var
  LResult: IFluentArray<Integer>;
begin
  LResult := TFluentArray.Concat<Integer>([TArray<Integer>.Create(1, 2),
                                           TArray<Integer>.Create(3, 4)]);
  Assert.AreEqual(4, LResult.Length, 'Concat should have 4 elements');
  Assert.AreEqual(1, LResult[0], 'First element should be 1');
  Assert.AreEqual(4, LResult[3], 'Last element should be 4');
end;

procedure TArrayStaticTest.TestIndexOfSimple;
var
  LArray: array[0..4] of Integer;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 4; LArray[4] := 5;
  Assert.AreEqual(NativeInt(2), TFluentArray.IndexOf<Integer>(LArray, 3), 'Index of 3 should be 2');
  Assert.AreEqual(NativeInt(-1), TFluentArray.IndexOf<Integer>(LArray, 6), 'Index of 6 should be -1');
end;

procedure TArrayStaticTest.TestIndexOfStart;
var
  LArray: array[0..4] of Integer;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 2; LArray[4] := 5;
  Assert.AreEqual(NativeInt(3), TFluentArray.IndexOf<Integer>(LArray, 2, 2), 'Index of 2 starting at 2 should be 3');
end;

procedure TArrayStaticTest.TestIndexOfComparer;
var
  LArray: array[0..4] of Integer;
  LComparer: IComparer<Integer>;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 4; LArray[4] := 5;
  LComparer := CreateComparer<Integer>;
  Assert.AreEqual(NativeInt(4), TFluentArray.IndexOf<Integer>(LArray, 5, LComparer, 0, 5), 'Index of 5 should be 4');
end;

procedure TArrayStaticTest.TestLastIndexOfSimple;
var
  LArray: array[0..4] of Integer;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 2; LArray[4] := 5;
  Assert.AreEqual(NativeInt(3), TFluentArray.LastIndexOf<Integer>(LArray, 2), 'Last index of 2 should be 3');
end;

procedure TArrayStaticTest.TestLastIndexOfStart;
var
  LArray: array[0..4] of Integer;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 2; LArray[4] := 5;
  Assert.AreEqual(NativeInt(1), TFluentArray.LastIndexOf<Integer>(LArray, 2, 2), 'Last index of 2 up to index 2 should be 1');
end;

procedure TArrayStaticTest.TestLastIndexOfComparer;
var
  LArray: array[0..4] of Integer;
  LComparer: IComparer<Integer>;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 2; LArray[4] := 5;
  LComparer := CreateComparer<Integer>;
  Assert.AreEqual(NativeInt(3), TFluentArray.LastIndexOf<Integer>(LArray, 2, LComparer, 4, 5), 'Last index of 2 should be 3');
end;

procedure TArrayStaticTest.TestContainsSimple;
var
  LArray: array[0..4] of Integer;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 4; LArray[4] := 5;
  Assert.IsTrue(TFluentArray.Contains<Integer>(LArray, 3), 'Should contain 3');
  Assert.IsFalse(TFluentArray.Contains<Integer>(LArray, 6), 'Should not contain 6');
end;

procedure TArrayStaticTest.TestContainsComparer;
var
  LArray: array[0..4] of Integer;
  LComparer: IComparer<Integer>;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3; LArray[3] := 4; LArray[4] := 5;
  LComparer := CreateComparer<Integer>;
  Assert.IsTrue(TFluentArray.Contains<Integer>(LArray, 4, LComparer), 'Should contain 4');
end;

procedure TArrayStaticTest.TestToStringSimple;
var
  LArray: array[0..2] of Integer;
begin
  LArray[0] := 1; LArray[1] := 2; LArray[2] := 3;
  Assert.AreEqual('1,2,3', TFluentArray.ToString<Integer>(LArray), 'ToString should be "1,2,3"');
  Assert.AreEqual('[1] [2] [3]', TFluentArray.ToString<Integer>(LArray, ' ', '[', ']'), 'ToString with delimiters should be "[1] [2] [3]"');
end;

procedure TArrayStaticTest.TestToStringWithFormat;
var
  LArray: array[0..2] of Double;
  LFmt: TFormatSettings;
begin
  LFmt := TFormatSettings.Create;
  LFmt.DecimalSeparator := ',';
  LArray[0] := 1.5; LArray[1] := 2.5; LArray[2] := 3.5;
  Assert.AreEqual('1,5;2,5;3,5', TFluentArray.ToString<Double>(LArray, LFmt, ';'), 'ToString with format should be "1,5;2,5;3,5"');
end;

// Testes Lazy
procedure TArrayStaticTest.TestLazyToArray;
var
  LArray: IFluentArray<Integer>;
begin
  LArray := TFluentArray.From<Integer>([1, 2, 3, 4, 5]).ToArray;
  Assert.AreEqual(5, LArray.Length, 'Array length should be 5');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(5, LArray[4], 'Last element should be 5');
end;

procedure TArrayStaticTest.TestLazyToList;
var
  LResult: IFluentList<Integer>;
begin
  LResult := TFluentArray.From<Integer>([1, 2, 3, 4, 5]).ToList;
  Assert.AreEqual(5, LResult.Count, 'List count should be 5');
  Assert.AreEqual(1, LResult[0], 'First element should be 1');
  Assert.AreEqual(5, LResult[4], 'Last element should be 5');
end;

procedure TArrayStaticTest.TestLazyCount;
var
  LCount: Integer;
begin
  LCount := TFluentArray.From<Integer>([1, 2, 3, 4, 5]).Count(
    function(Value: Integer): Boolean
    begin
      Result := Value > 2;
    end);
  Assert.AreEqual(3, LCount, 'Count of elements > 2 should be 3');
end;

procedure TArrayStaticTest.TestLazyAny;
var
  LHasEven: Boolean;
begin
  LHasEven := TFluentArray.From<Integer>([1, 2, 3, 4, 5]).Any(
    function(Value: Integer): Boolean
    begin
      Result := Value mod 2 = 0;
    end);
  Assert.IsTrue(LHasEven, 'Array should contain at least one even number');
end;

procedure TArrayStaticTest.TestLazyFirstOrDefault;
var
  LFirstEven: Integer;
begin
  LFirstEven := TFluentArray.From<Integer>([1, 2, 3, 4, 5]).FirstOrDefault(
    function(Value: Integer): Boolean
    begin
      Result := Value mod 2 = 0;
    end);
  Assert.AreEqual(2, LFirstEven, 'First even number should be 2');
end;

procedure TArrayStaticTest.TestLazyLastOrDefault;
var
  LLastEven: Integer;
begin
  LLastEven := TFluentArray.From<Integer>([1, 2, 3, 4, 5]).LastOrDefault(
    function(Value: Integer): Boolean
    begin
      Result := Value mod 2 = 0;
    end);
  Assert.AreEqual(4, LLastEven, 'Last even number should be 4');
end;

procedure TArrayStaticTest.TestLazyMin;
var
  LMin: Integer;
begin
  LMin := TFluentArray.From<Integer>([3, 1, 4, 1, 5]).Min;
  Assert.AreEqual(1, LMin, 'Minimum value should be 1');
end;

procedure TArrayStaticTest.TestLazyMax;
var
  LMax: Integer;
begin
  LMax := TFluentArray.From<Integer>([3, 1, 4, 1, 5]).Max;
  Assert.AreEqual(5, LMax, 'Maximum value should be 5');
end;

procedure TArrayStaticTest.TestLazySum;
var
  LSum: Integer;
begin
  LSum := TFluentArray.From<Integer>([1, 2, 3, 4, 5]).Sum(
    function(Value: Integer): Integer
    begin
      Result := Value;
    end);
  Assert.AreEqual(15, LSum, 'Sum of elements should be 15');
end;

procedure TArrayStaticTest.TestLazyReduce;
var
  LSum: Integer;
begin
  LSum := TFluentArray.From<Integer>([1, 2, 3, 4, 5]).Aggregate(
    function(Acc, Value: Integer): Integer
    begin
      Result := Acc + Value;
    end);
  Assert.AreEqual(15, LSum, 'Reduced sum of elements should be 15');
end;

procedure TArrayStaticTest.TestLazyDistinct;
var
  LDistinct: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  LDistinct := TFluentArray.From<Integer>([1, 2, 2, 3, 3, 4, 5, 5]).Distinct;
  LArray := LDistinct.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Distinct array should have 5 unique elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(5, LArray[4], 'Last element should be 5');
end;

procedure TArrayStaticTest.TestLazyFilter;
var
  LFiltered: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  LFiltered := TFluentArray.From<Integer>([1, 2, 3, 4, 5]).Where(
    function(Value: Integer): Boolean
    begin
      Result := Value > 3;
    end);
  LArray := LFiltered.ToArray;
  Assert.AreEqual(2, LArray.Length, 'Filtered array should have 2 elements');
  Assert.AreEqual(4, LArray[0], 'First element should be 4');
  Assert.AreEqual(5, LArray[1], 'Last element should be 5');
end;

procedure TArrayStaticTest.TestLazyTake;
var
  LTaken: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  LTaken := TFluentArray.From<Integer>([1, 2, 3, 4, 5]).Take(3);
  LArray := LTaken.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Taken array should have 3 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(3, LArray[2], 'Last element should be 3');
end;

procedure TArrayStaticTest.TestLazySkip;
var
  LSkipped: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  LSkipped := TFluentArray.From<Integer>([1, 2, 3, 4, 5]).Skip(2);
  LArray := LSkipped.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Skipped array should have 3 elements');
  Assert.AreEqual(3, LArray[0], 'First element should be 3');
  Assert.AreEqual(5, LArray[2], 'Last element should be 5');
end;

procedure TArrayStaticTest.TestLazyOrderBy;
var
  LOrdered: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  LOrdered := TFluentArray.From<Integer>([5, 2, 4, 1, 3]).OrderBy(
    function(A, B: Integer): Integer
    begin
      Result := A - B;
    end);
  LArray := LOrdered.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Ordered array should have 5 elements');
  Assert.AreEqual(1, LArray[0], 'First element should be 1');
  Assert.AreEqual(5, LArray[4], 'Last element should be 5');
end;

procedure TArrayStaticTest.TestLazyLongCount;
var
  LCount: Int64;
begin
  LCount := TFluentArray.From<Integer>([1, 2, 3, 4, 5]).LongCount(
    function(Value: Integer): Boolean
    begin
      Result := Value > 2;
    end);
  Assert.AreEqual(Int64(3), LCount, 'Count of elements > 2 should be 3');
end;

procedure TArrayStaticTest.TestLazyMap;
var
  LMapped: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  LMapped := TFluentArray.From<Integer>([1, 2, 3, 4, 5]).Select<Integer>(
    function(Value: Integer): Integer
    begin
      Result := Value * 2;
    end);
  LArray := LMapped.ToArray;
  Assert.AreEqual(5, LArray.Length, 'Mapped array should have 5 elements');
  Assert.AreEqual(2, LArray[0], 'First element should be 2');
  Assert.AreEqual(10, LArray[4], 'Last element should be 10');
end;

procedure TArrayStaticTest.TestLazyGroupBy;
var
  LGroups: IGroupByEnumerable<Integer, Integer>;
  LEnum: IFluentEnumerator<IGrouping<Integer, Integer>>;
  LGroup: IGrouping<Integer, Integer>;
  LArray: IFluentArray<Integer>;
  LCount: Integer;
begin
  LGroups := TFluentArray.From<Integer>([1, 2, 3, 4, 5, 6]).GroupBy<Integer>(
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

procedure TArrayStaticTest.TestLazyZip;
var
  LZipped: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  LZipped := TFluentArray.From<Integer>([1, 2, 3]).Zip<string, string>(
    TFluentArray.From<string>(['A', 'B', 'C']),
    function(Num: Integer; Letter: string): string
    begin
      Result := Num.ToString + Letter;
    end);
  LArray := LZipped.ToArray;
  Assert.AreEqual(3, LArray.Length, 'Zipped array should have 3 elements');
  Assert.AreEqual('1A', LArray[0], 'First element should be "1A"');
  Assert.AreEqual('2B', LArray[1], 'Second element should be "2B"');
  Assert.AreEqual('3C', LArray[2], 'Third element should be "3C"');
end;

procedure TArrayStaticTest.TestLazyJoin;
var
  LJoined: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  LJoined := TFluentArray.From<Integer>([1, 2, 3]).Join<string, Integer, string>(
    TFluentArray.From<string>(['A1', 'B2', 'C3']),
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

procedure TArrayStaticTest.TestLazyMapLazy;
var
  LMapped: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  LMapped := TFluentArray.From<Integer>([1, 2, 3]).Select<string>(
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

procedure TArrayStaticTest.TestLazyOrderByLazy;
var
  LOrdered: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  LOrdered := TFluentArray.From<Integer>([3, 1, 4, 1, 5]).Where(
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

procedure TArrayStaticTest.TestLazyDistinctLazy;
var
  LDistinct: IFluentEnumerable<Integer>;
  LArray: IFluentArray<Integer>;
begin
  LDistinct := TFluentArray.From<Integer>([3, 1, 4, 1, 5, 3]).Where(
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

procedure TArrayStaticTest.TestLazyZipLazy;
var
  LZipped: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  LZipped := TFluentArray.From<Integer>([1, 2, 3]).Zip<string, string>(
    TFluentArray.From<string>(['A', 'B', 'C']),
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

procedure TArrayStaticTest.TestLazyJoinLazy;
var
  LJoined: IFluentEnumerable<string>;
  LArray: IFluentArray<string>;
begin
  LJoined := TFluentArray.From<Integer>([1, 2, 3]).Join<string, Integer, string>(
    TFluentArray.From<string>(['A1', 'B2', 'C3']),
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

initialization
  TDUnitX.RegisterTestFixture(TArrayStaticTest);

end.
