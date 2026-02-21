program PTestFluentCQL;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}
{$STRONGLINKTYPES ON}
uses
  FastMM4,
  DUnitX.MemoryLeakMonitor.FastMM4,
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ELSE}
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  {$ENDIF }
  DUnitX.TestFramework,
  UTestFluent4D.CQL in 'UTestFluent4D.CQL.pas',
  Fluent.Adapters in '..\Source\Fluent.Adapters.pas',
  Fluent.Collections in '..\Source\Fluent.Collections.pas',
  Fluent.Core in '..\Source\Fluent.Core.pas',
  Fluent in '..\Source\Fluent.pas',
  Fluent.Query.Provider in '..\Source\Fluent.Query.Provider.pas',
  Fluent.SkipWhile in '..\Source\Fluent.SkipWhile.pas',
  Fluent.Where in '..\Source\Fluent.Where.pas',
  Fluent.Select in '..\Source\Fluent.Select.pas',
  Fluent.Take in '..\Source\Fluent.Take.pas',
  Fluent.Skip in '..\Source\Fluent.Skip.pas',
  Fluent.OrderBy in '..\Source\Fluent.OrderBy.pas',
  Fluent.Distinct in '..\Source\Fluent.Distinct.pas',
  Fluent.GroupBy in '..\Source\Fluent.GroupBy.pas',
  Fluent.TakeWhile in '..\Source\Fluent.TakeWhile.pas',
  Fluent.Zip in '..\Source\Fluent.Zip.pas',
  Fluent.Join in '..\Source\Fluent.Join.pas',
  Fluent.OfType in '..\Source\Fluent.OfType.pas',
  Fluent.SelectMany in '..\Source\Fluent.SelectMany.pas',
  Fluent.GroupJoin in '..\Source\Fluent.GroupJoin.pas',
  Fluent.Exclude in '..\Source\Fluent.Exclude.pas',
  Fluent.Intersect in '..\Source\Fluent.Intersect.pas',
  Fluent.Union in '..\Source\Fluent.Union.pas',
  Fluent.Concat in '..\Source\Fluent.Concat.pas',
  Fluent.Order in '..\Source\Fluent.Order.pas',
  Fluent.SelectIndexed in '..\Source\Fluent.SelectIndexed.pas',
  Fluent.SelectManyIndexed in '..\Source\Fluent.SelectManyIndexed.pas',
  Fluent.SelectManyCollection in '..\Source\Fluent.SelectManyCollection.pas',
  Fluent.SelectManyCollectionIndexed in '..\Source\Fluent.SelectManyCollectionIndexed.pas',
  Fluent.SkipWhileIndexed in '..\Source\Fluent.SkipWhileIndexed.pas',
  Fluent.TakeWhileIndexed in '..\Source\Fluent.TakeWhileIndexed.pas',
  Fluent.Chunk in '..\Source\Fluent.Chunk.pas',
  Fluent.ThenBy in '..\Source\Fluent.ThenBy.pas',
  Fluent.Cast in '..\Source\Fluent.Cast.pas',
  Fluent.Queryable in '..\Source\Fluent.Queryable.pas',
  Fluent.Xml in '..\Source\Fluent.Xml.pas',
  Fluent.Json in '..\Source\Fluent.Json.pas',
  Fluent.Xml.Provider in '..\Source\Fluent.Xml.Provider.pas',
  Fluent.Json.Provider in '..\Source\Fluent.Json.Provider.pas',
  Fluent.Helpers in '..\Source\Fluent.Helpers.pas',
  Fluent.Parse in '..\Source\Fluent.Parse.pas',
  Fluent.Expression in '..\Source\Fluent.Expression.pas',
  Evolution.Tuple in '..\..\Evolution4D\Source\Evolution.Tuple.pas';

{ keep comment here to protect the following conditional from being removed by the IDE when adding a unit }
{$IFNDEF TESTINSIGHT}
var
  runner: ITestRunner;
  results: IRunResults;
  logger: ITestLogger;
  nunitLogger : ITestLogger;
{$ENDIF}
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
{$ELSE}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //When true, Assertions must be made during tests;
    runner.FailsOnNoAsserts := False;

    //tell the runner how we will log things
    //Log to the console window if desired
    if TDUnitX.Options.ConsoleMode <> TDunitXConsoleMode.Off then
    begin
      logger := TDUnitXConsoleLogger.Create(TDUnitX.Options.ConsoleMode = TDunitXConsoleMode.Quiet);
      runner.AddLogger(logger);
    end;
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

    {$IFNDEF CI}
    //We don't want this happening when running under CI.
    TDUnitX.Options.ExitBehavior := TDUnitXExitBehavior.Pause;
    if TDUnitX.Options.ExitBehavior = TDUnitXExitBehavior.Pause then
    begin
      System.Write('Done.. press <Enter> key to quit.');
      System.Readln;
    end;
    {$ENDIF}
  except
    on E: Exception do
      System.Writeln(E.ClassName, ': ', E.Message);
  end;
{$ENDIF}
end.
