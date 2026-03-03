program PTestFluentQuerySQL;

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
  UTestFluentQuery.CQL in 'UTestFluentQuery.CQL.pas',
  FluentQuery.Adapters in '..\Source\FluentQuery.Adapters.pas',
  FluentQuery.Collections in '..\Source\FluentQuery.Collections.pas',
  FluentQuery.Core in '..\Source\FluentQuery.Core.pas',
  FluentQuery in '..\Source\FluentQuery.pas',
  FluentQuery.Provider in '..\Source\FluentQuery.Provider.pas',
  FluentQuery.SkipWhile in '..\Source\FluentQuery.SkipWhile.pas',
  FluentQuery.Where in '..\Source\FluentQuery.Where.pas',
  FluentQuery.Select in '..\Source\FluentQuery.Select.pas',
  FluentQuery.Take in '..\Source\FluentQuery.Take.pas',
  FluentQuery.Skip in '..\Source\FluentQuery.Skip.pas',
  FluentQuery.OrderBy in '..\Source\FluentQuery.OrderBy.pas',
  FluentQuery.Distinct in '..\Source\FluentQuery.Distinct.pas',
  FluentQuery.GroupBy in '..\Source\FluentQuery.GroupBy.pas',
  FluentQuery.TakeWhile in '..\Source\FluentQuery.TakeWhile.pas',
  FluentQuery.Zip in '..\Source\FluentQuery.Zip.pas',
  FluentQuery.Join in '..\Source\FluentQuery.Join.pas',
  FluentQuery.OfType in '..\Source\FluentQuery.OfType.pas',
  FluentQuery.SelectMany in '..\Source\FluentQuery.SelectMany.pas',
  FluentQuery.GroupJoin in '..\Source\FluentQuery.GroupJoin.pas',
  FluentQuery.Exclude in '..\Source\FluentQuery.Exclude.pas',
  FluentQuery.Intersect in '..\Source\FluentQuery.Intersect.pas',
  FluentQuery.Union in '..\Source\FluentQuery.Union.pas',
  FluentQuery.Concat in '..\Source\FluentQuery.Concat.pas',
  FluentQuery.Order in '..\Source\FluentQuery.Order.pas',
  FluentQuery.SelectIndexed in '..\Source\FluentQuery.SelectIndexed.pas',
  FluentQuery.SelectManyIndexed in '..\Source\FluentQuery.SelectManyIndexed.pas',
  FluentQuery.SelectManyCollection in '..\Source\FluentQuery.SelectManyCollection.pas',
  FluentQuery.SelectManyCollectionIndexed in '..\Source\FluentQuery.SelectManyCollectionIndexed.pas',
  FluentQuery.SkipWhileIndexed in '..\Source\FluentQuery.SkipWhileIndexed.pas',
  FluentQuery.TakeWhileIndexed in '..\Source\FluentQuery.TakeWhileIndexed.pas',
  FluentQuery.Chunk in '..\Source\FluentQuery.Chunk.pas',
  FluentQuery.ThenBy in '..\Source\FluentQuery.ThenBy.pas',
  FluentQuery.Cast in '..\Source\FluentQuery.Cast.pas',
  FluentQuery.Queryable in '..\Source\FluentQuery.Queryable.pas',
  FluentQuery.Xml in '..\Source\FluentQuery.Xml.pas',
  FluentQuery.Json in '..\Source\FluentQuery.Json.pas',
  FluentQuery.Xml.Provider in '..\Source\FluentQuery.Xml.Provider.pas',
  FluentQuery.Json.Provider in '..\Source\FluentQuery.Json.Provider.pas',
  FluentQuery.Helpers in '..\Source\FluentQuery.Helpers.pas',
  FluentQuery.Parse in '..\Source\FluentQuery.Parse.pas',
  FluentQuery.Expression in '..\Source\FluentQuery.Expression.pas';

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
