unit UTestFluent.StringHelper;

interface

uses
  Classes,
  SysUtils,
  DUnitX.TestFramework,
  Generics.Collections,
  Fluent,
  Fluent.Helpers;

type
  TFluentStringTest = class
  public
    [Test]
    procedure TestPartition;
    [Test]
    procedure TestWhere;
    [Test]
    procedure TestCollect;
    [Test]
    procedure TestSelect;
    [Test]
    procedure TestSelectMany;
    [Test]
    procedure TestSum;
    [Test]
    procedure TestFirst;
    [Test]
    procedure TestLast;
    [Test]
    procedure TestReduce;
    [Test]
    procedure TestExists;
    [Test]
    procedure TestAll;
    [Test]
    procedure TestAny;
    [Test]
    procedure TestSort;
    [Test]
    procedure TestTake;
    [Test]
    procedure TestSkip;
    [Test]
    procedure TestGroupBy;
    [Test]
    procedure TestReverse;
    [Test]
    procedure TestCountWhere;
  end;

implementation

{ TFluentStringTest }

procedure TFluentStringTest.TestPartition;
var
  LString, LLeft, LRight: string;
begin
  LString := 'Hello123';
  LString.Partition(
    function(C: Char): Boolean
    begin
      Result := CharInSet(C, ['0'..'9']);
    end, LLeft, LRight);
  Assert.AreEqual('123', LLeft, 'Left should contain digits');
  Assert.AreEqual('Hello', LRight, 'Right should contain letters');
end;

procedure TFluentStringTest.TestWhere;
var
  LString: string;
  LFiltered: IFluentArray<Char>;
begin
  LString := 'Hello123';
  LFiltered := LString.Where(
    function(C: Char): Boolean
    begin
      Result := CharInSet(C, ['0'..'9']);
    end).ToArray;
  Assert.AreEqual(3, LFiltered.Length, 'Filtered should have 3 digits');
  Assert.AreEqual('1', LFiltered[0], 'First digit should be 1');
  Assert.AreEqual('3', LFiltered[2], 'Last digit should be 3');
end;

procedure TFluentStringTest.TestCollect;
var
  LString: string;
  LWords: IFluentArray<string>;
begin
  LString := 'Hello World';
  LWords := LString.Collect.ToArray;
  Assert.AreEqual(2, LWords.Length, 'Should have 2 words');
  Assert.AreEqual('Hello', LWords[0], 'First word should be Hello');
  Assert.AreEqual('World', LWords[1], 'Second word should be World');
end;

procedure TFluentStringTest.TestSelect;
var
  LString: string;
  LMapped: IFluentArray<Integer>;
begin
  LString := 'abc';
  LMapped := LString.Select<Integer>(
    function(C: Char): Integer
    begin
      Result := Ord(C);
    end).ToArray;
  Assert.AreEqual(3, LMapped.Length, 'Mapped should have 3 elements');
  Assert.AreEqual(97, LMapped[0], 'First should be ASCII of a');
  Assert.AreEqual(99, LMapped[2], 'Last should be ASCII of c');
end;

procedure TFluentStringTest.TestSelectMany;
var
  LString: string;
  LFlatMapped: TArray<Char>;
begin
  LString := 'ab';
  LFlatMapped := LString.SelectMany<Char>(
    function(C: Char): TArray<Char>
    begin
      Result := [C, C];
    end).ToArray.ArrayData;
  Assert.AreEqual(4, Length(LFlatMapped), 'FlatMapped should have 4 chars');
  Assert.AreEqual('a', LFlatMapped[0], 'First should be a');
  Assert.AreEqual('b', LFlatMapped[2], 'Third should be b');
end;

procedure TFluentStringTest.TestSum;
var
  LString: string;
begin
  LString := 'abc';
  Assert.AreEqual(294, LString.Sum, 'Sum should be ASCII sum of abc (97+98+99)');
end;

procedure TFluentStringTest.TestFirst;
var
  LString: string;
begin
  LString := 'Hello';
  Assert.AreEqual('H', LString.First, 'First should be H');
  LString := '';
  Assert.AreEqual(#0, LString.First, 'First of empty should be #0');
end;

procedure TFluentStringTest.TestLast;
var
  LString: string;
begin
  LString := 'Hello';
  Assert.AreEqual('o', LString.Last, 'Last should be o');
  LString := '';
  Assert.AreEqual(#0, LString.Last, 'Last of empty should be #0');
end;

procedure TFluentStringTest.TestReduce;
var
  LString: string;
  LResult: string;
begin
  LString := 'abc';
  LResult := LString.Aggregate<string>('',
    function(Acc: string; C: Char): string
    begin
      Result := Acc + C;
    end);
  Assert.AreEqual('abc', LResult, 'Reduce should concatenate to abc');
end;

procedure TFluentStringTest.TestExists;
var
  LString: string;
begin
  LString := 'Hello';
  Assert.IsTrue(LString.Exists(
    function(C: Char): Boolean
    begin
      Result := C = 'l';
    end), 'Should exist an l');
end;

procedure TFluentStringTest.TestAll;
var
  LString: string;
begin
  LString := 'aaa';
  Assert.IsTrue(LString.All(
    function(C: Char): Boolean
    begin
      Result := C = 'a';
    end), 'All should be a');
  LString := 'aba';
  Assert.IsFalse(LString.All(
    function(C: Char): Boolean
    begin
      Result := C = 'a';
    end), 'Not all are a');
end;

procedure TFluentStringTest.TestAny;
var
  LString: string;
begin
  LString := 'Hello';
  Assert.IsTrue(LString.Any(
    function(C: Char): Boolean
    begin
      Result := C = 'e';
    end), 'Should have an e');
end;

procedure TFluentStringTest.TestSort;
var
  LString: string;
  LSorted: IFluentArray<Char>;
begin
  LString := 'cba';
  LSorted := LString.Sort.ToArray;
  Assert.AreEqual(3, LSorted.Length, 'Sorted should have 3 chars');
  Assert.AreEqual('a', LSorted[0], 'First should be a');
  Assert.AreEqual('c', LSorted[2], 'Last should be c');
end;

procedure TFluentStringTest.TestTake;
var
  LString: string;
  LTaken: IFluentArray<Char>;
begin
  LString := 'Hello';
  LTaken := LString.Take(3).ToArray;
  Assert.AreEqual(3, LTaken.Length, 'Taken should have 3 chars');
  Assert.AreEqual('H', LTaken[0], 'First should be H');
  Assert.AreEqual('l', LTaken[2], 'Last should be l');
end;

procedure TFluentStringTest.TestSkip;
var
  LString: string;
  LSkipped: IFluentArray<Char>;
begin
  LString := 'Hello';
  LSkipped := LString.Skip(2).ToArray;
  Assert.AreEqual(3, LSkipped.Length, 'Skipped should have 3 chars');
  Assert.AreEqual('l', LSkipped[0], 'First should be l');
  Assert.AreEqual('o', LSkipped[2], 'Last should be o');
end;

procedure TFluentStringTest.TestGroupBy;
var
  LString: string;
  LGroups: IGroupByEnumerable<Boolean, Char>;
  LEnum: IFluentEnumerator<IGrouping<Boolean, Char>>;
  LGroup: IGrouping<Boolean, Char>;
  LArray: IFluentArray<Char>;
  LCount: Integer;
begin
  LString := 'Hello';
  LGroups := LString.GroupBy<Boolean>(
    function(C: Char): Boolean
    begin
      Result := CharInSet(C, ['a'..'z']);
    end);
  LEnum := LGroups.GetEnumerator;
  LCount := 0;
  while LEnum.MoveNext do
  begin
    Inc(LCount);
    LGroup := LEnum.Current;
    LArray := LGroup.Items.ToArray;
    if LGroup.Key then
    begin
      Assert.AreEqual(4, LArray.Length, 'Lowercase group should have 4 chars');
      Assert.AreEqual('e', LArray[0], 'First lowercase should be e');
    end
    else
      Assert.AreEqual(1, LArray.Length, 'Uppercase group should have 1 char');
  end;
  Assert.AreEqual(2, LCount, 'Should have 2 groups');
end;

procedure TFluentStringTest.TestReverse;
var
  LString: string;
  LReversed: IFluentArray<Char>;
begin
  LString := 'Hello';
  LReversed := LString.Reverse.ToArray;
  Assert.AreEqual(5, LReversed.Length, 'Reversed should have 5 chars');
  Assert.AreEqual('o', LReversed[0], 'First should be o');
  Assert.AreEqual('H', LReversed[4], 'Last should be H');
end;

procedure TFluentStringTest.TestCountWhere;
var
  LString: string;
begin
  LString := 'Hello';
  Assert.AreEqual(2, LString.CountWhere(
    function(C: Char): Boolean
    begin
      Result := C = 'l';
    end), 'Should count 2 l''s');
end;

initialization
  TDUnitX.RegisterTestFixture(TFluentStringTest);

end.
