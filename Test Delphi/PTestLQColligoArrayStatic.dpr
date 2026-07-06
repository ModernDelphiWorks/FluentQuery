program PTestLQColligoArrayStatic;

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
  UTestLQColligo.ArrayStatic in 'UTestLQColligo.ArrayStatic.pas',
  LQColligo.Adapters in '..\Source\LQColligo.Adapters.pas',
  LQColligo.Cast in '..\Source\LQColligo.Cast.pas',
  LQColligo.Chunk in '..\Source\LQColligo.Chunk.pas',
  LQColligo.Collections in '..\Source\LQColligo.Collections.pas',
  LQColligo.Concat in '..\Source\LQColligo.Concat.pas',
  LQColligo.Core in '..\Source\LQColligo.Core.pas',
  LQColligo.Distinct in '..\Source\LQColligo.Distinct.pas',
  LQColligo.Exclude in '..\Source\LQColligo.Exclude.pas',
  LQColligo.GroupBy in '..\Source\LQColligo.GroupBy.pas',
  LQColligo.GroupJoin in '..\Source\LQColligo.GroupJoin.pas',
  LQColligo.Helpers in '..\Source\LQColligo.Helpers.pas',
  LQColligo.Intersect in '..\Source\LQColligo.Intersect.pas',
  LQColligo.Join in '..\Source\LQColligo.Join.pas',
  LQColligo.Json in '..\Source\LQColligo.Json.pas',
  LQColligo.Json.Provider in '..\Source\LQColligo.Json.Provider.pas',
  LQColligo.OfType in '..\Source\LQColligo.OfType.pas',
  LQColligo.OrderBy in '..\Source\LQColligo.OrderBy.pas',
  LQColligo in '..\Source\LQColligo.pas',
  LQColligo.Select in '..\Source\LQColligo.Select.pas',
  LQColligo.SelectIndexed in '..\Source\LQColligo.SelectIndexed.pas',
  LQColligo.SelectMany in '..\Source\LQColligo.SelectMany.pas',
  LQColligo.SelectManyCollection in '..\Source\LQColligo.SelectManyCollection.pas',
  LQColligo.SelectManyCollectionIndexed in '..\Source\LQColligo.SelectManyCollectionIndexed.pas',
  LQColligo.SelectManyIndexed in '..\Source\LQColligo.SelectManyIndexed.pas',
  LQColligo.Skip in '..\Source\LQColligo.Skip.pas',
  LQColligo.SkipWhile in '..\Source\LQColligo.SkipWhile.pas',
  LQColligo.SkipWhileIndexed in '..\Source\LQColligo.SkipWhileIndexed.pas',
  LQColligo.Take in '..\Source\LQColligo.Take.pas',
  LQColligo.TakeWhile in '..\Source\LQColligo.TakeWhile.pas',
  LQColligo.TakeWhileIndexed in '..\Source\LQColligo.TakeWhileIndexed.pas',
  LQColligo.Union in '..\Source\LQColligo.Union.pas',
  LQColligo.Where in '..\Source\LQColligo.Where.pas',
  LQColligo.Xml in '..\Source\LQColligo.Xml.pas',
  LQColligo.Xml.Provider in '..\Source\LQColligo.Xml.Provider.pas',
  LQColligo.Zip in '..\Source\LQColligo.Zip.pas';

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
