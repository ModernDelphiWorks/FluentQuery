program PTestColligoArrayStatic;

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
  UTestColligo.ArrayStatic in 'UTestColligo.ArrayStatic.pas',
  Colligo.Adapters in '..\Source\Colligo.Adapters.pas',
  Colligo.Cast in '..\Source\Colligo.Cast.pas',
  Colligo.Chunk in '..\Source\Colligo.Chunk.pas',
  Colligo.Collections in '..\Source\Colligo.Collections.pas',
  Colligo.Concat in '..\Source\Colligo.Concat.pas',
  Colligo.Core in '..\Source\Colligo.Core.pas',
  Colligo.Distinct in '..\Source\Colligo.Distinct.pas',
  Colligo.Exclude in '..\Source\Colligo.Exclude.pas',
  Colligo.GroupBy in '..\Source\Colligo.GroupBy.pas',
  Colligo.GroupJoin in '..\Source\Colligo.GroupJoin.pas',
  Colligo.Helpers in '..\Source\Colligo.Helpers.pas',
  Colligo.Intersect in '..\Source\Colligo.Intersect.pas',
  Colligo.Join in '..\Source\Colligo.Join.pas',
  Colligo.Json in '..\Source\Colligo.Json.pas',
  Colligo.Json.Provider in '..\Source\Colligo.Json.Provider.pas',
  Colligo.OfType in '..\Source\Colligo.OfType.pas',
  Colligo.OrderBy in '..\Source\Colligo.OrderBy.pas',
  Colligo in '..\Source\Colligo.pas',
  Colligo.Select in '..\Source\Colligo.Select.pas',
  Colligo.SelectIndexed in '..\Source\Colligo.SelectIndexed.pas',
  Colligo.SelectMany in '..\Source\Colligo.SelectMany.pas',
  Colligo.SelectManyCollection in '..\Source\Colligo.SelectManyCollection.pas',
  Colligo.SelectManyCollectionIndexed in '..\Source\Colligo.SelectManyCollectionIndexed.pas',
  Colligo.SelectManyIndexed in '..\Source\Colligo.SelectManyIndexed.pas',
  Colligo.Skip in '..\Source\Colligo.Skip.pas',
  Colligo.SkipWhile in '..\Source\Colligo.SkipWhile.pas',
  Colligo.SkipWhileIndexed in '..\Source\Colligo.SkipWhileIndexed.pas',
  Colligo.Take in '..\Source\Colligo.Take.pas',
  Colligo.TakeWhile in '..\Source\Colligo.TakeWhile.pas',
  Colligo.TakeWhileIndexed in '..\Source\Colligo.TakeWhileIndexed.pas',
  Colligo.Union in '..\Source\Colligo.Union.pas',
  Colligo.Where in '..\Source\Colligo.Where.pas',
  Colligo.Xml in '..\Source\Colligo.Xml.pas',
  Colligo.Xml.Provider in '..\Source\Colligo.Xml.Provider.pas',
  Colligo.Zip in '..\Source\Colligo.Zip.pas';

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
