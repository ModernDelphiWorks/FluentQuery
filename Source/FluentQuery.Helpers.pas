{
  ------------------------------------------------------------------------------
  FluentQuery
  LINQ-inspired fluent query API for Delphi.

  SPDX-License-Identifier: Apache-2.0
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{$include ./FluentQuery.inc}

unit FluentQuery.Helpers;

interface

uses
{$IFDEF MSWINDOWS}
  Winapi.Windows,
{$ENDIF MSWINDOWS}
  Math,
  Classes,
  StrUtils,
  SysUtils,
  SysConst,
  Generics.Collections,
  Generics.Defaults,
  FluentQuery,
  FluentQuery.Adapters;

{$D-}

type
  TFluentChar = record helper for Char
  public
    function ToUpper: Char;
    function ToLower: Char;
    function IsLetter: Boolean;
    function IsDigit: Boolean;
  end;

  TFluentString = record helper for string
  private type
    TSplitKind = (StringSeparatorsNoQuoted, StringSeparatorsQuoted, StringSeparatorNoQuoted,
      CharSeparatorsNoQuoted, CharSeparatorsQuoted, CharSeparatorNoQuoted);
  private
    function GetChars(Index: Integer): Char; inline;
    function GetLength: Integer; inline;
    class function CharInArray(const C: Char; const InArray: array of Char): Boolean; static;
    function InternalSplit(SplitType: TSplitKind; const SeparatorC: array of Char; const SeparatorS: array of string;
      QuoteStart, QuoteEnd: Char; Count: Integer; Options: TStringSplitOptions): TArray<string>;
    function IndexOfAny(const Values: array of string; var Index: Integer; StartIndex: Integer): Integer; overload;
    function IndexOfAnyUnquoted(const Values: array of string; StartQuote, EndQuote: Char; var Index: Integer; StartIndex: Integer): Integer; overload;
    function IndexOfQuoted(const Value: string; StartQuote, EndQuote: Char; StartIndex: Integer): Integer; overload;
    class function InternalCompare(const StrA: string; IndexA: Integer; const StrB: string;
      IndexB, LengthA, LengthB: Integer; IgnoreCase: Boolean; LocaleID: TLocaleID): Integer; overload; static;
    class function InternalCompare(const StrA: string; IndexA: Integer; const StrB: string;
      IndexB, LengthA, LengthB: Integer; Options: TCompareOptions; LocaleID: TLocaleID): Integer; overload; static;
    function AsEnumerable(const AString: string): IFluentEnumerable<Char>;
  public
    const Empty = '';
    // TStringHelper (System.SysUtils)
    class function Create(C: Char; Count: Integer): string; overload; inline; static;
    class function Create(const Value: array of Char; StartIndex: Integer; Length: Integer): string; overload; static;
    class function Create(const Value: array of Char): string; overload; static;
    class function Compare(const StrA: string; const StrB: string): Integer; overload; static; inline;
    class function Compare(const StrA: string; const StrB: string; LocaleID: TLocaleID): Integer; overload; static; inline;
    class function Compare(const StrA: string; const StrB: string; Options: TCompareOptions): Integer; overload; static; inline;
    class function Compare(const StrA: string; const StrB: string; Options: TCompareOptions; LocaleID: TLocaleID): Integer; overload; static; inline;
    class function Compare(const StrA: string; IndexA: Integer; const StrB: string; IndexB: Integer; Length: Integer): Integer; overload; static; inline;
    class function Compare(const StrA: string; IndexA: Integer; const StrB: string; IndexB: Integer; Length: Integer; LocaleID: TLocaleID): Integer; overload; static; inline;
    class function Compare(const StrA: string; IndexA: Integer; const StrB: string; IndexB: Integer; Length: Integer; Options: TCompareOptions): Integer; overload; static; inline;
    class function Compare(const StrA: string; IndexA: Integer; const StrB: string; IndexB: Integer; Length: Integer; Options: TCompareOptions; LocaleID: TLocaleID): Integer; overload; static; inline;
    class function CompareOrdinal(const StrA: string; const StrB: string): Integer; overload; static;
    class function CompareOrdinal(const StrA: string; IndexA: Integer; const StrB: string; IndexB: Integer; Length: Integer): Integer; overload; static;
    class function CompareText(const StrA: string; const StrB: string): Integer; static; inline;
    class function Parse(const Value: Integer): string; overload; static; inline;
    class function Parse(const Value: Int64): string; overload; static; inline;
    class function Parse(const Value: Boolean): string; overload; static; inline;
    class function Parse(const Value: Extended): string; overload; static; inline;
    class function ToBoolean(const S: string): Boolean; overload; static; inline;
    class function ToInteger(const S: string): Integer; overload; static; inline;
    class function ToInt64(const S: string): Int64; overload; static; inline;
    class function ToSingle(const S: string): Single; overload; static; inline;
    class function ToDouble(const S: string): Double; overload; static; inline;
    class function ToExtended(const S: string): Extended; overload; static; inline;
    class function LowerCase(const S: string): string; overload; static; inline;
    class function LowerCase(const S: string; LocaleOptions: TLocaleOptions): string; overload; static; inline;
    class function UpperCase(const S: string): string; overload; static; inline;
    class function UpperCase(const S: string; LocaleOptions: TLocaleOptions): string; overload; static; inline;
    function CompareTo(const strB: string): Integer;
    function Contains(const Value: string): Boolean;
    class function Copy(const Str: string): string; inline; static;
    procedure CopyTo(SourceIndex: Integer; var destination: array of Char; DestinationIndex: Integer; Count: Integer);
    function CountChar(const C: Char): Integer;
    function DeQuotedString: string; overload;
    function DeQuotedString(const QuoteChar: Char): string; overload;
    class function EndsText(const ASubText, AText: string): Boolean; static;
    function EndsWith(const Value: string): Boolean; overload; inline;
    function EndsWith(const Value: string; IgnoreCase: Boolean): Boolean; overload;
    function Equals(const Value: string): Boolean; overload;
    class function Equals(const a: string; const b: string): Boolean; overload; static;
    class function Format(const Format: string; const args: array of const): string; overload; static;
    function GetHashCode: Integer;
    function IndexOf(Value: Char): Integer; overload;
    function IndexOf(const Value: string): Integer; overload; inline;
    function IndexOf(Value: Char; StartIndex: Integer): Integer; overload;
    function IndexOf(const Value: string; StartIndex: Integer): Integer; overload;
    function IndexOf(Value: Char; StartIndex: Integer; Count: Integer): Integer; overload;
    function IndexOf(const Value: string; StartIndex: Integer; Count: Integer): Integer; overload;
    function IndexOfAny(const AnyOf: array of Char): Integer; overload;
    function IndexOfAny(const AnyOf: array of Char; StartIndex: Integer): Integer; overload;
    function IndexOfAny(const AnyOf: array of Char; StartIndex: Integer; Count: Integer): Integer; overload;
    function IndexOfAnyUnquoted(const AnyOf: array of Char; StartQuote, EndQuote: Char): Integer; overload;
    function IndexOfAnyUnquoted(const AnyOf: array of Char; StartQuote, EndQuote: Char; StartIndex: Integer): Integer; overload;
    function IndexOfAnyUnquoted(const AnyOf: array of Char; StartQuote, EndQuote: Char; StartIndex: Integer; Count: Integer): Integer; overload;
    function Insert(StartIndex: Integer; const Value: string): string;
    function IsDelimiter(const Delimiters: string; Index: Integer): Boolean;
    function IsEmpty: Boolean; inline;
    class function IsNullOrEmpty(const Value: string): Boolean; static; inline;
    class function IsNullOrWhiteSpace(const Value: string): Boolean; static;
    class function Join(const Separator: string; const Values: array of const): string; overload; static;
    class function Join(const Separator: string; const Values: array of string): string; overload; static;
    class function Join(const Separator: string; const Values: IEnumerator<string>): string; overload; static;
    class function Join(const Separator: string; const Values: IEnumerable<string>): string; overload; static; inline;
    class function Join(const Separator: string; const Values: array of string; StartIndex: Integer; Count: Integer): string; overload; static;
    function LastDelimiter(const Delims: string): Integer; overload;
    function LastDelimiter(const Delims: TSysCharSet): Integer; overload;
    function LastIndexOf(Value: Char): Integer; overload;
    function LastIndexOf(const Value: string): Integer; overload;
    function LastIndexOf(Value: Char; StartIndex: Integer): Integer; overload;
    function LastIndexOf(const Value: string; StartIndex: Integer): Integer; overload;
    function LastIndexOf(Value: Char; StartIndex: Integer; Count: Integer): Integer; overload;
    function LastIndexOf(const Value: string; StartIndex: Integer; Count: Integer): Integer; overload;
    function LastIndexOfAny(const AnyOf: array of Char): Integer; overload;
    function LastIndexOfAny(const AnyOf: array of Char; StartIndex: Integer): Integer; overload;
    function LastIndexOfAny(const AnyOf: array of Char; StartIndex: Integer; Count: Integer): Integer; overload;
    function PadLeft(TotalWidth: Integer): string; overload; inline;
    function PadLeft(TotalWidth: Integer; PaddingChar: Char): string; overload; inline;
    function PadRight(TotalWidth: Integer): string; overload; inline;
    function PadRight(TotalWidth: Integer; PaddingChar: Char): string; overload; inline;
    function QuotedString: string; overload;
    function QuotedString(const QuoteChar: Char): string; overload;
    function Remove(StartIndex: Integer): string; overload; inline;
    function Remove(StartIndex: Integer; Count: Integer): string; overload; inline;
    function Replace(OldChar: Char; NewChar: Char): string; overload;
    function Replace(OldChar: Char; NewChar: Char; ReplaceFlags: TReplaceFlags): string; overload;
    function Replace(const OldValue: string; const NewValue: string): string; overload;
    function Replace(const OldValue: string; const NewValue: string; ReplaceFlags: TReplaceFlags): string; overload;
    function Split(const Separator: array of Char): TArray<string>; overload;
    function Split(const Separator: array of Char; Count: Integer): TArray<string>; overload;
    function Split(const Separator: array of Char; Options: TStringSplitOptions): TArray<string>; overload;
    function Split(const Separator: array of Char; Count: Integer; Options: TStringSplitOptions): TArray<string>; overload;
    function Split(const Separator: array of string): TArray<string>; overload;
    function Split(const Separator: array of string; Count: Integer): TArray<string>; overload;
    function Split(const Separator: array of string; Options: TStringSplitOptions): TArray<string>; overload;
    function Split(const Separator: array of string; Count: Integer; Options: TStringSplitOptions): TArray<string>; overload;
    function Split(const Separator: array of Char; Quote: Char): TArray<string>; overload;
    function Split(const Separator: array of Char; QuoteStart, QuoteEnd: Char): TArray<string>; overload;
    function Split(const Separator: array of Char; QuoteStart, QuoteEnd: Char; Options: TStringSplitOptions): TArray<string>; overload;
    function Split(const Separator: array of Char; QuoteStart, QuoteEnd: Char; Count: Integer): TArray<string>; overload;
    function Split(const Separator: array of Char; QuoteStart, QuoteEnd: Char; Count: Integer; Options: TStringSplitOptions): TArray<string>; overload;
    function Split(const Separator: array of string; Quote: Char): TArray<string>; overload;
    function Split(const Separator: array of string; QuoteStart, QuoteEnd: Char): TArray<string>; overload;
    function Split(const Separator: array of string; QuoteStart, QuoteEnd: Char; Options: TStringSplitOptions): TArray<string>; overload;
    function Split(const Separator: array of string; QuoteStart, QuoteEnd: Char; Count: Integer): TArray<string>; overload;
    function Split(const Separator: array of string; QuoteStart, QuoteEnd: Char; Count: Integer; Options: TStringSplitOptions): TArray<string>; overload;
    class function StartsText(const ASubText, AText: string): Boolean; static;
    function StartsWith(const Value: string): Boolean; overload; inline;
    function StartsWith(const Value: string; IgnoreCase: Boolean): Boolean; overload;
    function Substring(StartIndex: Integer): string; overload; inline;
    function Substring(StartIndex: Integer; Length: Integer): string; overload; inline;
    function ToBoolean: Boolean; overload; inline;
    function ToInteger: Integer; overload; inline;
    function ToInt64: Int64; overload; inline;
    function ToSingle: Single; overload; inline;
    function ToDouble: Double; overload; inline;
    function ToExtended: Extended; overload; inline;
    function ToCharArray: TArray<Char>; overload;
    function ToCharArray(StartIndex: Integer; Length: Integer): TArray<Char>; overload;
    function ToLower: string; overload; inline;
    function ToLower(LocaleID: TLocaleID): string; overload;
    function ToLowerInvariant: string; {$IF Defined(USE_LIBICU) and not Defined(Linux)}inline;{$ENDIF}
    function ToUpper: string; overload; inline;
    function ToUpper(LocaleID: TLocaleID): string; overload;
    function ToUpperInvariant: string; {$IF Defined(USE_LIBICU) and not Defined(Linux)}inline;{$ENDIF}
    function Trim: string; overload;
    function TrimLeft: string; overload;
    function TrimRight: string; overload;
    function Trim(const TrimChars: array of Char): string; overload;
    function TrimLeft(const TrimChars: array of Char): string; overload;
    function TrimRight(const TrimChars: array of Char): string; overload;
    function TrimEnd(const TrimChars: array of Char): string; deprecated 'Use TrimRight';
    function TrimStart(const TrimChars: array of Char): string; deprecated 'Use TrimLeft';
    property Chars[Index: Integer]: Char read GetChars;
    property Length: Integer read GetLength;
    // Fluent4D
    procedure Partition(const APredicate: TFunc<Char, Boolean>; out ALeft, ARight: String);
    function Where(const APredicate: TFunc<Char, Boolean>): IFluentEnumerable<Char>;
    function Collect: IFluentEnumerable<String>;
    function Select<TResult>(const ATransform: TFunc<Char, TResult>): IFluentEnumerable<TResult>;
    function SelectMany<TResult>(const ASelector: TFunc<Char, TArray<TResult>>): IFluentEnumerable<TResult>;
    function Sum: Integer;
    function First: Char;
    function Last: Char;
    function Aggregate<T>(const AInitialValue: T; const AAccumulator: TFunc<T, Char, T>): T;
    function Exists(const APredicate: TFunc<Char, Boolean>): Boolean;
    function All(const APredicate: TFunc<Char, Boolean>): Boolean;
    function Any(const APredicate: TFunc<Char, Boolean>): Boolean;
    function Sort: IFluentEnumerable<Char>;
    function Take(const ACount: Integer): IFluentEnumerable<Char>;
    function Skip(const ACount: Integer): IFluentEnumerable<Char>;
    function GroupBy<TKey>(const AKeySelector: TFunc<Char, TKey>): IGroupByEnumerable<TKey, Char>;
    function Reverse: IFluentEnumerable<Char>;
    function CountWhere(const APredicate: TFunc<Char, Boolean>): Integer;
  end;

  TFluentInteger = record helper for Integer
  public
    function Select(const ATransform: TFunc<Integer, Integer>): Integer;
    function IsEven: Boolean;
    function IsOdd: Boolean;
    function Times(const ATransform: TFunc<Integer, Integer>): Integer;
  end;

  TFluentBoolean = record helper for Boolean
  public
    function Select<T>(const ATrueValue, AFalseValue: T): T;
    procedure IfTrue(const AAction: TProc);
    procedure IfFalse(const AAction: TProc);
  end;

  TFluentFloat = record helper for Double
  public
    function Select(const ATransform: TFunc<Double, Double>): Double;
    function Round: Integer;
    function ApproxEqual(const AValue: Double; const ATolerance: Double = 0.0001): Boolean;
  end;

  TFluentDateTime = record helper for TDateTime
  public
    function Select(const ATransform: TFunc<TDateTime, TDateTime>): TDateTime;
    function AddDays(ADays: Integer): TDateTime;
    function IsPast: Boolean;
    function ToFormat(const AFormat: String): String;
  end;

implementation

{ TFluentChar }

function TFluentChar.ToUpper: Char;
begin
  if CharInSet(Self, ['a'..'z']) then
    Result := Chr(Ord(Self) - 32)
  else
    Result := Self;
end;

function TFluentChar.ToLower: Char;
begin
  Result := System.SysUtils.LowerCase(Self)[1];
end;

function TFluentChar.IsLetter: Boolean;
begin
  Result := System.SysUtils.CharInSet(Self, ['A'..'Z', 'a'..'z']);
end;

function TFluentChar.IsDigit: Boolean;
begin
  Result := System.SysUtils.CharInSet(Self, ['0'..'9']);
end;

{$ZEROBASEDSTRINGS ON}
{ TFluentString }

class function TFluentString.CharInArray(const C: Char; const InArray: array of Char): Boolean;
var
  LFor: Integer;
begin
  Result := False;
  for LFor := Low(InArray) to High(InArray) do
    if InArray[LFor] = C then
      Exit(True);
end;

class function TFluentString.Compare(const StrA, StrB: string; Options: TCompareOptions; LocaleID: TLocaleID): Integer;
begin
  Result := InternalCompare(StrA, 0, StrB, 0, StrA.Length, StrB.Length, Options, LocaleID);
end;

class function TFluentString.Compare(const StrA, StrB: string; Options: TCompareOptions): Integer;
begin
  Result := InternalCompare(StrA, 0, StrB, 0, StrA.Length, StrB.Length, Options, SysLocale.DefaultLCID);
end;

class function TFluentString.Compare(const StrA: string; IndexA: Integer; const StrB: string; IndexB, Length: Integer;
  Options: TCompareOptions; LocaleID: TLocaleID): Integer;
begin
  Result := InternalCompare(StrA, IndexA, StrB, IndexB, Length, Length, Options, LocaleID);
end;

class function TFluentString.Compare(const StrA: string; IndexA: Integer; const StrB: string; IndexB, Length: Integer;
  Options: TCompareOptions): Integer;
begin
  Result := InternalCompare(StrA, IndexA, StrB, IndexB, Length, Length, Options, SysLocale.DefaultLCID);
end;

class function TFluentString.Compare(const StrA, StrB: string): Integer;
begin
  Result := InternalCompare(StrA, 0, StrB, 0, StrA.Length, StrB.Length, [], SysLocale.DefaultLCID);
end;

class function TFluentString.Compare(const StrA, StrB: string; LocaleID: TLocaleID): Integer;
begin
  Result := InternalCompare(StrA, 0, StrB, 0, StrA.Length, StrB.Length, [], LocaleID);
end;

class function TFluentString.Compare(const StrA: string; IndexA: Integer; const StrB: string; IndexB: Integer; Length: Integer): Integer;
begin
  Result := InternalCompare(StrA, IndexA, StrB, IndexB, Length, Length, False, SysLocale.DefaultLCID);
end;

class function TFluentString.Compare(const StrA: string; IndexA: Integer; const StrB: string; IndexB: Integer; Length: Integer; LocaleID: TLocaleID): Integer;
begin
  Result := InternalCompare(StrA, IndexA, StrB, IndexB, Length, Length, False, LocaleID);
end;

class function TFluentString.CompareOrdinal(const StrA, StrB: string): Integer;
var
  LMaxLen: Integer;
begin
  if StrA.Length > StrB.Length then
    LMaxLen := StrA.Length
  else
    LMaxLen := StrB.Length;
  Result := System.SysUtils.StrLComp(PChar(@StrA[0]), PChar(@StrB[0]), LMaxLen);
end;

class function TFluentString.CompareOrdinal(const StrA: string; IndexA: Integer; const StrB: string; IndexB,
  Length: Integer): Integer;
begin
  Result := System.SysUtils.StrLComp(PChar(@StrA[IndexA]), PChar(@StrB[IndexB]), Length);
end;

class function TFluentString.CompareText(const StrA: string; const StrB: string): Integer;
begin
  Result := System.SysUtils.CompareText(StrA, StrB);
end;

class function TFluentString.ToBoolean(const S: string): Boolean;
begin
  Result := StrToBool(S);
end;

class function TFluentString.ToInteger(const S: string): Integer;
begin
  Result := StrToInt(S);
end;

class function TFluentString.ToInt64(const S: string): Int64;
begin
  Result := StrToInt64(S);
end;

class function TFluentString.ToSingle(const S: string): Single;
begin
  Result := StrToFloat(S);
end;

class function TFluentString.ToDouble(const S: string): Double;
begin
  Result := StrToFloat(S);
end;

class function TFluentString.ToExtended(const S: string): Extended;
begin
  Result := StrToFloat(S);
end;

class function TFluentString.Parse(const Value: Integer): string;
begin
  Result := IntToStr(Value);
end;

class function TFluentString.Parse(const Value: Int64): string;
begin
  Result := IntToStr(Value);
end;

class function TFluentString.Parse(const Value: Boolean): string;
begin
  Result := BoolToStr(Value);
end;

class function TFluentString.Parse(const Value: Extended): string;
begin
  Result := FloatToStr(Value);
end;

class function TFluentString.LowerCase(const S: string): string;
begin
  Result := System.SysUtils.LowerCase(S);
end;

class function TFluentString.LowerCase(const S: string; LocaleOptions: TLocaleOptions): string;
begin
  Result := System.SysUtils.LowerCase(S, LocaleOptions);
end;

class function TFluentString.UpperCase(const S: string): string;
begin
  Result := System.SysUtils.UpperCase(S);
end;

class function TFluentString.UpperCase(const S: string; LocaleOptions: TLocaleOptions): string;
begin
  Result := System.SysUtils.UpperCase(S, LocaleOptions);
end;

function TFluentString.CompareTo(const strB: string): Integer;
begin
  Result := System.SysUtils.StrComp(PChar(Self), PChar(strB));
end;

function TFluentString.Contains(const Value: string): Boolean;
begin
  Result := System.Pos(Value, Self) > 0;
end;

class function TFluentString.Copy(const Str: string): string;
begin
  Result := System.Copy(Str, 1, Str.Length);
end;

procedure TFluentString.CopyTo(SourceIndex: Integer; var Destination: array of Char; DestinationIndex, Count: Integer);
begin
  Move((PChar(Self) + SourceIndex)^, Destination[DestinationIndex], Count * SizeOf(Char));
end;

function TFluentString.CountChar(const C: Char): Integer;
var
  LFor: Integer;
begin
  Result := 0;
  for LFor := Low(Self) to High(Self) do
    if Self[LFor] = C then
      Inc(Result);
end;

class function TFluentString.Create(C: Char; Count: Integer): string;
begin
  Result := StringOfChar(C, Count);
end;

class function TFluentString.Create(const Value: array of Char; StartIndex, Length: Integer): string;
begin
  SetLength(Result, Length);
  Move(Value[StartIndex], PChar(Result)^, Length * SizeOf(Char));
end;

class function TFluentString.Create(const Value: array of Char): string;
begin
  SetLength(Result, System.Length(Value));
  Move(Value[0], PChar(Result)^, System.Length(Value) * SizeOf(Char));
end;

function TFluentString.DeQuotedString(const QuoteChar: Char): string;
var
  LFor: Integer;
  LastQuoted: Boolean;
  LPosDest: Integer;
  LResult: array of Char;
begin
  if (Self.Length >= 2) and (Self[Low(Self)] = QuoteChar) and (Self[High(Self)] = QuoteChar) then
  begin
    LastQuoted := False;
    LPosDest := 0;
    SetLength(LResult, Self.Length - 2);
    for LFor := Low(Self) + 1 to High(Self) - 1 do
    begin
      if (Self[LFor] = QuoteChar) then
      begin
        if LastQuoted then
        begin
          LastQuoted := False;
          LResult[LPosDest] := Self[LFor];
          Inc(LPosDest);
        end
        else LastQuoted := True;
      end
      else
      begin
        if LastQuoted then
        begin
          LastQuoted := false;
        end;
        LResult[LPosDest] := Self[LFor];
        Inc(LPosDest);
      end;
    end;
    Result := string.Create(LResult, 0, LPosDest)
  end
  else
    Result := Self;
end;

function TFluentString.DeQuotedString: string;
begin
  Result := Self.DeQuotedString('''');
end;

class function TFluentString.EndsText(const ASubText, AText: string): Boolean;
begin
  Result := AText.EndsWith(ASubText, True);
end;

function TFluentString.EndsWith(const Value: string): Boolean;
begin
  Result := EndsWith(Value, False);
end;

function TFluentString.EndsWith(const Value: string; IgnoreCase: Boolean): Boolean;
var
  LSubTextLocation: Integer;
  LOptions: TCompareOptions;
begin
  if Value = Empty then
    Result := True
  else
  begin
    LSubTextLocation := Self.Length - Value.Length;
    if (LSubTextLocation >= 0) and (ByteType(Self, LSubTextLocation) <> mbLeadByte) then
    begin
      if IgnoreCase then
        LOptions := [coIgnoreCase]
      else
        LOptions := [];
      Result := string.Compare(Value, 0, Self, LSubTextLocation, Value.Length, LOptions) = 0;
    end
    else
      Result := False;
  end;
end;

class function TFluentString.Equals(const a, b: string): Boolean;
begin
  Result := a = b;
end;

function TFluentString.Equals(const Value: string): Boolean;
begin
  Result := Self = Value;
end;

class function TFluentString.Format(const Format: string; const args: array of const): string;
begin
  Result := System.SysUtils.Format(Format, args);
end;

function TFluentString.IndexOf(Value: Char; StartIndex, Count: Integer): Integer;
begin
  Result := System.Pos(Value, Self, StartIndex + 1) - 1;
  if (Result + 1) > (StartIndex + Count) then
    Result := -1;
end;

function TFluentString.IndexOf(const Value: string; StartIndex, Count: Integer): Integer;
begin
  Result := System.Pos(Value, Self, StartIndex + 1) - 1;
  if (Result + Value.Length) > (StartIndex + Count) then
    Result := -1;
end;

function TFluentString.IndexOf(const Value: string; StartIndex: Integer): Integer;
begin
  Result := System.Pos(Value, Self, StartIndex + 1) - 1;
end;

function TFluentString.IndexOf(const Value: string): Integer;
begin
  Result := System.Pos(Value, Self) - 1;
end;

function TFluentString.IndexOf(Value: Char): Integer;
var
  LPoniter: PChar;
  LFor: Integer;
begin
  LPoniter := Pointer(Self);
  for LFor := 0 to System.Length(Self) - 1 do
    if LPoniter[LFor] = Value then Exit(LFor);
  Result := -1;
end;

function TFluentString.IndexOf(Value: Char; StartIndex: Integer): Integer;
var
  LPointer: PChar;
  LFor: Integer;
begin
  LPointer := Pointer(Self);
  if StartIndex >= 0 then
    for LFor := StartIndex to System.Length(Self) - 1 do
      if LPointer[LFor] = Value then Exit(LFor);
  Result := -1;
end;

function TFluentString.IndexOfAny(const AnyOf: array of Char; StartIndex, Count: Integer): Integer;
var
  LFor: Integer;
  LChar: Char;
  LMax: Integer;
begin
  if (StartIndex + Count) >= Self.Length then
    LMax := Self.Length
  else
    LMax := StartIndex + Count;

  LFor := StartIndex;
  while LFor < LMax do
  begin
    for LChar in AnyOf do
      if Self[LFor] = LChar then
        Exit(LFor);
    Inc(LFor);
  end;
  Result := -1;
end;

function TFluentString.IndexOfAny(const AnyOf: array of Char; StartIndex: Integer): Integer;
begin
  Result := IndexOfAny(AnyOf, StartIndex, Self.Length);
end;

function TFluentString.IndexOfAny(const AnyOf: array of Char): Integer;
begin
  Result := IndexOfAny(AnyOf, 0, Self.Length);
end;

function TFluentString.IndexOfAnyUnquoted(const AnyOf: array of Char; StartQuote, EndQuote: Char): Integer;
begin
  Result := IndexOfAnyUnquoted(AnyOf, StartQuote, EndQuote, 0, Self.Length);
end;

function TFluentString.IndexOfAnyUnquoted(const AnyOf: array of Char; StartQuote, EndQuote: Char;
  StartIndex: Integer): Integer;
begin
  Result := IndexOfAnyUnquoted(AnyOf, StartQuote, EndQuote, StartIndex, Self.Length);
end;

function TFluentString.IndexOfAnyUnquoted(const AnyOf: array of Char; StartQuote, EndQuote: Char; StartIndex,
  Count: Integer): Integer;
var
  LIndex: Integer;
  LChar: Char;
  LMax: Integer;
  LInQuote: Integer;
  LInQuoteBool: Boolean;
begin
  if (StartIndex + Count) >= Length then
    LMax := Length
  else
    LMax := StartIndex + Count;

  LIndex := StartIndex;
  if StartQuote <> EndQuote then
  begin
    LInQuote := 0;
    while LIndex < LMax do
    begin
      if Self[LIndex] = StartQuote then
        Inc(LInQuote)
      else
        if (Self[LIndex] = EndQuote) and (LInQuote > 0) then
          Dec(LInQuote);

      if LInQuote = 0 then
        for LChar in AnyOf do
          if Self[LIndex] = LChar then
            Exit(LIndex);
      Inc(LIndex);
    end;
  end
  else
  begin
    LInQuoteBool := False;
    while LIndex < LMax do
    begin
      if Self[LIndex] = StartQuote then
        LInQuoteBool := not LInQuoteBool;

      if not LInQuoteBool then
        for LChar in AnyOf do
          if Self[LIndex] = LChar then
            Exit(LIndex);
      Inc(LIndex);
    end;
  end;
  Result := -1;
end;

function TFluentString.Insert(StartIndex: Integer; const Value: string): string;
begin
  Result := Self;
  System.Insert(Value, Result, StartIndex + 1);
end;

function TFluentString.IsDelimiter(const Delimiters: string; Index: Integer): Boolean;
begin
  Result := False;
  if (Index < Low(string)) or (Index > High(Self)) or (ByteType(Self, Index) <> mbSingleByte) then exit;
  Result := StrScan(PChar(Delimiters), Self[Index]) <> nil;
end;

function TFluentString.IsEmpty: Boolean;
begin
  Result := Self = Empty;
end;

class function TFluentString.IsNullOrEmpty(const Value: string): Boolean;
begin
  Result := Value = Empty;
end;

class function TFluentString.IsNullOrWhiteSpace(const Value: string): Boolean;
begin
  Result := Value.Trim.Length = 0;
end;

class function TFluentString.Join(const Separator: string; const Values: array of const): string;
var
  LFor: Integer;
  LLength: Integer;
  function ValueToString(const val: TVarRec): string;
  begin
    case val.VType of
      vtInteger: Result := IntToStr(val.VInteger);
      vtBoolean: Result := BoolToStr(val.VBoolean, True);
{$IFNDEF NEXTGEN}
      vtChar: Result := Char(val.VChar);
      vtPChar: Result := string(val.VPChar);
{$ENDIF !NEXTGEN}
      vtExtended: Result := FloatToStr(val.VExtended^);
      vtObject: Result := TObject(val.VObject).Classname;
      vtClass: Result := val.VClass.Classname;
      vtCurrency: Result := CurrToStr(val.VCurrency^);
      vtInt64: Result := IntToStr(PInt64(val.VInt64)^);
      vtUnicodeString: Result := string(val.VUnicodeString);
    else
      Result := Format('(Unknown) : %d', [val.VType]);
    end;
  end;
begin
  LLength := System.Length(Values);
  if LLength = 0 then
    Result := ''
  else begin
    Result := ValueToString(Values[0]);
    for LFor := 1 to LLength - 1 do
      Result := Result + Separator + ValueToString(Values[LFor]);
  end;
end;

class function TFluentString.Join(const Separator: string; const Values: array of string): string;
begin
  Result := Join(Separator, Values, 0, System.Length(Values));
end;

class function TFluentString.Join(const Separator: string; const Values: IEnumerator<string>): string;
begin
  if (Values <> nil) and Values.MoveNext then
  begin
    Result := Values.Current;
    while Values.MoveNext do
      Result := Result + Separator + Values.Current;
  end
  else
    Result := '';
end;

class function TFluentString.Join(const Separator: string; const Values: IEnumerable<string>): string;
begin
  if Values <> nil then
    Result := Join(Separator, Values.GetEnumerator)
  else
    Result := '';
end;

class function TFluentString.Join(const Separator: string; const Values: array of string; StartIndex,
  Count: Integer): string;
var
  LFor: Integer;
  LMax: Integer;
begin
  if (Count = 0) or ((System.Length(Values) = 0) and (StartIndex = 0)) then
    Result := ''
  else
  begin
    if (Count < 0) or (StartIndex >= System.Length(Values)) then
      raise ERangeError.CreateRes(@SRangeError);

    if (StartIndex + Count) > System.Length(Values) then
      LMax := System.Length(Values)
    else
      LMax := StartIndex + Count;

    Result := Values[StartIndex];
    for LFor := StartIndex + 1 to LMax - 1 do
      Result := Result + Separator + Values[LFor];
  end;
end;

function TFluentString.LastDelimiter(const Delims: string): Integer;
var
  LHigh, LFor: Integer;
begin
  LHigh := High(Self);
  while LHigh >= Low(string) do
  begin
    for LFor := Low(string) to High(Delims) do
      if Self.Chars[LHigh] = Delims.Chars[LFor] then
        Exit(LHigh);
    Dec(LHigh);
  end;
  Result := -1;
end;

function TFluentString.LastDelimiter(const Delims: TSysCharSet): Integer;
var
  LPointerSelf, LPointerChar: PChar;
begin
  LPointerSelf := Pointer(Self);
  if LPointerSelf <> nil then
  begin
    LPointerChar := LPointerSelf + Length - 1;
    while LPointerChar >= LPointerSelf do
    begin
      if CharInSet(LPointerChar^, Delims) then
        Exit(LPointerChar - LPointerSelf);
      Dec(LPointerChar);
    end;
  end;
  Result := -1;
end;

function TFluentString.LastIndexOf(const Value: string; StartIndex: Integer): Integer;
begin
  Result := LastIndexOf(Value, StartIndex, StartIndex + 1);
end;

function TFluentString.LastIndexOf(Value: Char; StartIndex: Integer): Integer;
begin
  Result := LastIndexOf(Value, StartIndex, StartIndex + 1);
end;

function TFluentString.LastIndexOf(Value: Char): Integer;
begin
  Result := LastIndexOf(Value, Self.Length - 1, Self.Length);
end;

function TFluentString.LastIndexOf(const Value: string): Integer;
begin
  Result := LastIndexOf(Value, Self.Length - 1, Self.Length);
end;

function TFluentString.LastIndexOf(const Value: string; StartIndex, Count: Integer): Integer;
var
  LIndex: Integer;
  LMin: Integer;
begin
  if (Value.Length = 0) then
    Exit(-1);
  if StartIndex < Self.Length then
    LIndex := StartIndex - Value.Length + 1
  else
    LIndex := Self.Length - Value.Length;
  if (StartIndex - Count) < 0 then
    LMin := 0
  else
    LMin := StartIndex - Count + 1;
  while LIndex >= LMin do
  begin
    if (StrLComp(@PChar(Self)[LIndex], PChar(Value), Value.Length) = 0) then
      Exit(LIndex);
    Dec(LIndex);
  end;
  Result := -1;
end;

function TFluentString.LastIndexOf(Value: Char; StartIndex, Count: Integer): Integer;
var
  LIndex: Integer;
  LMin: Integer;
begin
  if StartIndex < Self.Length then
    LIndex := StartIndex
  else
    LIndex := Self.Length - 1;
  if (StartIndex - Count) < 0 then
    LMin := 0
  else
    LMin := StartIndex - Count + 1;
  while LIndex >= LMin do
  begin
    if Self[LIndex] = Value then
      Exit(LIndex);
    Dec(LIndex);
  end;
  Result := -1;
end;

function TFluentString.LastIndexOfAny(const AnyOf: array of Char): Integer;
begin
  Result := LastIndexOfAny(AnyOf, Self.Length - 1, Self.Length);
end;

function TFluentString.LastIndexOfAny(const AnyOf: array of Char; StartIndex, Count: Integer): Integer;
var
  LIndex: Integer;
  LMin: Integer;
  LChar: Char;
begin
  if StartIndex < Self.Length then
    LIndex := StartIndex
  else
    LIndex := Self.Length - 1;
  if (StartIndex - Count) < 0 then
    LMin := 0
  else
    LMin := StartIndex - Count + 1;
  while LIndex >= LMin do
  begin
    for LChar in AnyOf do
      if Self[LIndex] = LChar then
        Exit(LIndex);
    Dec(LIndex);
  end;
  Result := -1;
end;

function TFluentString.LastIndexOfAny(const AnyOf: array of Char; StartIndex: Integer): Integer;
begin
  Result := LastIndexOfAny(AnyOf, StartIndex, Self.Length);
end;

function TFluentString.PadLeft(TotalWidth: Integer; PaddingChar: Char): string;
begin
  TotalWidth := TotalWidth - Length;
  if TotalWidth > 0 then
    Result := System.StringOfChar(PaddingChar, TotalWidth) + Self
  else
    Result := Self;
end;

function TFluentString.PadLeft(TotalWidth: Integer): string;
begin
  Result := PadLeft(TotalWidth, ' ');
end;

function TFluentString.PadRight(TotalWidth: Integer; PaddingChar: Char): string;
begin
  TotalWidth := TotalWidth - Length;
  if TotalWidth > 0 then
    Result := Self + System.StringOfChar(PaddingChar, TotalWidth)
  else
    Result := Self;
end;

function TFluentString.PadRight(TotalWidth: Integer): string;
begin
  Result := PadRight(TotalWidth, ' ');
end;

function TFluentString.QuotedString(const QuoteChar: Char): string;
var
  LFor: Integer;
begin
  Result := Self.Substring(0);
  for LFor := Result.Length - 1 downto 0 do
    if Result.Chars[LFor] = QuoteChar then Result := Result.Insert(LFor, QuoteChar);
  Result := QuoteChar + Result + QuoteChar;
end;

function TFluentString.QuotedString: string;
var
  LFor: Integer;
begin
  Result := Self.Substring(0);
  for LFor := Result.Length - 1 downto 0 do
    if Result.Chars[LFor] = '''' then Result := Result.Insert(LFor, '''');
  Result := '''' + Result + '''';
end;

function TFluentString.Remove(StartIndex, Count: Integer): string;
begin
  Result := Self;
  System.Delete(Result, StartIndex + 1, Count);
end;

function TFluentString.Remove(StartIndex: Integer): string;
begin
  Result := Self;
  System.Delete(Result, StartIndex + 1, Result.Length);
end;

function TFluentString.Replace(OldChar, NewChar: Char): string;
begin
  Result := System.SysUtils.StringReplace(Self, OldChar, NewChar, [rfReplaceAll]);
end;

function TFluentString.Replace(OldChar: Char; NewChar: Char; ReplaceFlags: TReplaceFlags): string;
begin
  Result := System.SysUtils.StringReplace(Self, OldChar, NewChar, ReplaceFlags);
end;

function TFluentString.Replace(const OldValue: string; const NewValue: string): string;
begin
  Result := System.SysUtils.StringReplace(Self, OldValue, NewValue, [rfReplaceAll]);
end;

function TFluentString.Replace(const OldValue: string; const NewValue: string; ReplaceFlags: TReplaceFlags): string;
begin
  Result := System.SysUtils.StringReplace(Self, OldValue, NewValue, ReplaceFlags);
end;

function TFluentString.Split(const Separator: array of Char; Options: TStringSplitOptions): TArray<string>;
begin
  Result := Split(Separator, MaxInt, Options);
end;

function TFluentString.Split(const Separator: array of Char; Count: Integer): TArray<string>;
begin
  Result := Split(Separator, Count, TStringSplitOptions.None);
end;

function TFluentString.Split(const Separator: array of Char): TArray<string>;
begin
  Result := Split(Separator, MaxInt, TStringSplitOptions.None);
end;

function TFluentString.IndexOfAny(const Values: array of string; var Index: Integer; StartIndex: Integer): Integer;
var
  LFor, LIndex, LIoA: Integer;
begin
  LIoA := -1;
  for LFor := 0 to High(Values) do
  begin
    LIndex := IndexOf(Values[LFor], StartIndex);
    if (LIndex >= 0) and ((LIndex < LIoA) or (LIoA = -1)) then
    begin
      LIoA := LIndex;
      Index := LFor;
    end;
  end;
  Result := LIoA;
end;

function TFluentString.IndexOfAnyUnquoted(const Values: array of string; StartQuote, EndQuote: Char; var Index: Integer; StartIndex: Integer): Integer;
var
  LFor, LIndex, LIoA: Integer;
begin
  LIoA := -1;
  for LFor := 0 to High(Values) do
  begin
    LIndex := IndexOfQuoted(Values[LFor], StartQuote, EndQuote, StartIndex);
    if (LIndex >= 0) and ((LIndex < LIoA) or (LIoA = -1)) then
    begin
      LIoA := LIndex;
      Index := LFor;
    end;
  end;
  Result := LIoA;
end;

function TFluentString.IndexOfQuoted(const Value: string; StartQuote, EndQuote: Char; StartIndex: Integer): Integer;
var
  LFor, LIterCnt, LLength, LWhile: Integer;
  LPSubStr, LPS: PWideChar;
  LInQuote: Integer;
  LInQuoteBool: Boolean;
begin
  LLength := Value.Length;
  LIterCnt := Self.Length - StartIndex - LLength + 1;

  if (StartIndex >= 0) and (LIterCnt >= 0) and (LLength > 0) then
  begin
    LPSubStr := PWideChar(Value);
    LPS := PWideChar(Self);
    Inc(LPS, StartIndex);

    if StartQuote <> EndQuote then
    begin
      LInQuote := 0;

      for LFor := 0 to LIterCnt do
      begin
        LWhile := 0;
        while (LWhile >= 0) and (LWhile < LLength) do
        begin
          if LPS[LFor + LWhile] = StartQuote then
            Inc(LInQuote)
          else
            if LPS[LFor + LWhile] = EndQuote then
              Dec(LInQuote);

          if LInQuote > 0 then
            LWhile := -1
          else
          begin
            if LPS[LFor + LWhile] = LPSubStr[LWhile] then
              Inc(LWhile)
            else
              LWhile := -1;
          end;
        end;
        if LWhile >= LLength then
          Exit(LFor + StartIndex);
      end;
    end
    else
    begin
      LInQuoteBool := False;
      for LFor := 0 to LIterCnt do
      begin
        LWhile := 0;
        while (LWhile >= 0) and (LWhile < LLength) do
        begin
          if LPS[LFor + LWhile] = StartQuote then
            LInQuoteBool := not LInQuoteBool;

          if LInQuoteBool then
            LWhile := -1
          else
          begin
            if LPS[LFor + LWhile] = LPSubStr[LWhile] then
              Inc(LWhile)
            else
              LWhile := -1;
          end;
        end;
        if LWhile >= LLength then
          Exit(LFor + StartIndex);
      end;
    end;
  end;

  Result := -1;
end;

function TFluentString.InternalSplit(SplitType: TSplitKind; const SeparatorC: array of Char; const SeparatorS: array of string;
  QuoteStart, QuoteEnd: Char; Count: Integer; Options: TStringSplitOptions): TArray<string>;
const
  DeltaGrow = 32;
var
  LNextSeparator, LLastIndex, LLength: Integer;
  LTotal: Integer;
  LCurrentLength: Integer;
  LSeparatorIndex: Integer;
begin
  if IsEmpty then
    Exit(nil);

  LTotal := 0;
  LLastIndex := 0;
  LCurrentLength := 0;
  LSeparatorIndex := 0;
  case SplitType of
    TSplitKind.StringSeparatorsNoQuoted,
    TSplitKind.StringSeparatorNoQuoted:
      if High(SeparatorS) = 0 then
      begin
        SplitType := TSplitKind.StringSeparatorNoQuoted;
        LNextSeparator := IndexOf(SeparatorS[0], LLastIndex);
      end
      else
        LNextSeparator := IndexOfAny(SeparatorS, LSeparatorIndex, LLastIndex);
    TSplitKind.StringSeparatorsQuoted:
      LNextSeparator := IndexOfAnyUnquoted(SeparatorS, QuoteStart, QuoteEnd, LSeparatorIndex, LLastIndex);
    TSplitKind.CharSeparatorsNoQuoted,
    TSplitKind.CharSeparatorNoQuoted:
      if High(SeparatorC) = 0 then
      begin
        SplitType := TSplitKind.CharSeparatorNoQuoted;
        LNextSeparator := IndexOf(SeparatorC[0], LLastIndex);
      end
      else
        LNextSeparator := IndexOfAny(SeparatorC, LLastIndex);
    TSplitKind.CharSeparatorsQuoted:
      LNextSeparator := IndexOfAnyUnquoted(SeparatorC, QuoteStart, QuoteEnd, LLastIndex);
  else
    LNextSeparator := -1;
  end;
  while (LNextSeparator >= 0) and (LTotal < Count) do
  begin
    LLength := LNextSeparator - LLastIndex;
    if (LLength > 0) or (Options <> TStringSplitOptions.ExcludeEmpty) then
    begin
      Inc(LTotal);
      if LCurrentLength < LTotal then
      begin
        LCurrentLength := LTotal + DeltaGrow;
        SetLength(Result, LCurrentLength);
      end;
      Result[LTotal - 1] := System.Copy(Self, LLastIndex + 1, LLength);
    end;

    case SplitType of
      TSplitKind.StringSeparatorsNoQuoted:
      begin
        LLastIndex := LNextSeparator + SeparatorS[LSeparatorIndex].Length;
        LNextSeparator := IndexOfAny(SeparatorS, LSeparatorIndex, LLastIndex);
      end;
      TSplitKind.StringSeparatorsQuoted:
      begin
        LLastIndex := LNextSeparator + SeparatorS[LSeparatorIndex].Length;
        LNextSeparator := IndexOfAnyUnquoted(SeparatorS, QuoteStart, QuoteEnd, LSeparatorIndex, LLastIndex);
      end;
      TSplitKind.StringSeparatorNoQuoted:
      begin
        LLastIndex := LNextSeparator + SeparatorS[0].Length;
        LNextSeparator := IndexOf(SeparatorS[0], LLastIndex);
      end;
      TSplitKind.CharSeparatorsNoQuoted:
      begin
        LLastIndex := LNextSeparator + 1;
        LNextSeparator := IndexOfAny(SeparatorC, LLastIndex);
      end;
      TSplitKind.CharSeparatorsQuoted:
      begin
        LLastIndex := LNextSeparator + 1;
        LNextSeparator := IndexOfAnyUnquoted(SeparatorC, QuoteStart, QuoteEnd, LLastIndex);
      end;
      TSplitKind.CharSeparatorNoQuoted:
      begin
        LLastIndex := LNextSeparator + 1;
        LNextSeparator := IndexOf(SeparatorC[0], LLastIndex);
      end;
    end;
  end;

  LLength := Self.Length - LLastIndex;
  if (LLength >= 0) and (LTotal < Count) then
  begin
    if (LLength > 0) or not (Options in [TStringSplitOptions.ExcludeEmpty, TStringSplitOptions.ExcludeLastEmpty]) then
    begin
      Inc(LTotal);
      SetLength(Result, LTotal);
      Result[LTotal - 1] := System.Copy(Self, LLastIndex + 1, LLength);
    end
    else
      SetLength(Result, LTotal);
  end
  else
    SetLength(Result, LTotal);
end;

function TFluentString.Split(const Separator: array of string; Count: Integer;
  Options: TStringSplitOptions): TArray<string>;
begin
  Result := InternalSplit(TSplitKind.StringSeparatorsNoQuoted, [], Separator, Char(0), Char(0), Count, Options);
end;

function TFluentString.Split(const Separator: array of string; QuoteStart, QuoteEnd: Char;
  Count: Integer; Options: TStringSplitOptions): TArray<string>;
begin
  Result := InternalSplit(TSplitKind.StringSeparatorsQuoted, [], Separator, QuoteStart, QuoteEnd, Count, Options);
end;

function TFluentString.Split(const Separator: array of Char; Count: Integer;
  Options: TStringSplitOptions): TArray<string>;
begin
  Result := InternalSplit(TSplitKind.CharSeparatorsNoQuoted, Separator, [], Char(0), Char(0), Count, Options);
end;

function TFluentString.Split(const Separator: array of Char; QuoteStart, QuoteEnd: Char; Count: Integer;
  Options: TStringSplitOptions): TArray<string>;
begin
  Result := InternalSplit(TSplitKind.CharSeparatorsQuoted, Separator, [], QuoteStart, QuoteEnd, Count, Options);
end;

function TFluentString.Split(const Separator: array of Char; QuoteStart, QuoteEnd: Char): TArray<string>;
begin
  Result := Split(Separator, QuoteStart, QuoteEnd, MaxInt, TStringSplitOptions.None);
end;

function TFluentString.Split(const Separator: array of Char; Quote: Char): TArray<string>;
begin
  Result := Split(Separator, Quote, Quote, MaxInt, TStringSplitOptions.None);
end;

function TFluentString.Split(const Separator: array of Char; QuoteStart, QuoteEnd: Char;
  Count: Integer): TArray<string>;
begin
  Result := Split(Separator, QuoteStart, QuoteEnd, Count, TStringSplitOptions.None);
end;

function TFluentString.Split(const Separator: array of Char; QuoteStart, QuoteEnd: Char;
  Options: TStringSplitOptions): TArray<string>;
begin
  Result := Split(Separator, QuoteStart, QuoteEnd, MaxInt, Options);
end;

function TFluentString.Split(const Separator: array of string): TArray<string>;
begin
  Result := Split(Separator, MaxInt, TStringSplitOptions.None);
end;

function TFluentString.Split(const Separator: array of string; Count: Integer): TArray<string>;
begin
  Result := Split(Separator, Count, TStringSplitOptions.None);
end;

function TFluentString.Split(const Separator: array of string; Options: TStringSplitOptions): TArray<string>;
begin
  Result := Split(Separator, MaxInt, Options);
end;

function TFluentString.Split(const Separator: array of string; Quote: Char): TArray<string>;
begin
  Result := Split(Separator, Quote, Quote, MaxInt, TStringSplitOptions.None);
end;

function TFluentString.Split(const Separator: array of string; QuoteStart, QuoteEnd: Char): TArray<string>;
begin
  Result := Split(Separator, QuoteStart, QuoteEnd, MaxInt, TStringSplitOptions.None);
end;

function TFluentString.Split(const Separator: array of string; QuoteStart, QuoteEnd: Char; Options: TStringSplitOptions): TArray<string>;
begin
  Result := Split(Separator, QuoteStart, QuoteEnd, MaxInt, Options);
end;

function TFluentString.Split(const Separator: array of string; QuoteStart, QuoteEnd: Char; Count: Integer): TArray<string>;
begin
  Result := Split(Separator, QuoteStart, QuoteEnd, Count, TStringSplitOptions.None);
end;

class function TFluentString.StartsText(const ASubText, AText: string): Boolean;
var
  LSubLen: Integer;
begin
  LSubLen := ASubText.Length;
  if LSubLen = 0 then
    Result := True
  else if AText.Length >= LSubLen then
    Result := AnsiStrLIComp(PChar(Pointer(ASubText)), PChar(Pointer(AText)), LSubLen) = 0
  else
    Result := False;
end;

function TFluentString.StartsWith(const Value: string): Boolean;
begin
  Result := StartsWith(Value, False);
end;

function TFluentString.StartsWith(const Value: string; IgnoreCase: Boolean): Boolean;
var
  LValLen: Integer;
begin
  LValLen := Value.Length;
  if LValLen = 0 then
    Result := True
  else if IgnoreCase then
    Result := StartsText(Value, Self)
  else if Length >= LValLen then
    Result := CompareMem(Pointer(Value), Pointer(Self), LValLen * SizeOf(Char))
  else
    Result := False;
end;

function TFluentString.ToBoolean: Boolean;
begin
  Result := StrToBool(Self);
end;

function TFluentString.ToInteger: Integer;
begin
  Result := StrToInt(Self);
end;

function TFluentString.ToInt64: Int64;
begin
  Result := StrToInt64(Self);
end;

function TFluentString.ToSingle: Single;
begin
  Result := StrToFloat(Self);
end;

function TFluentString.ToDouble: Double;
begin
  Result := StrToFloat(Self);
end;

function TFluentString.ToExtended: Extended;
begin
  Result := StrToFloat(Self);
end;

function TFluentString.ToCharArray: TArray<Char>;
begin
  Result := ToCharArray(0, Self.Length);
end;

function TFluentString.ToCharArray(StartIndex, Length: Integer): TArray<Char>;
begin
  SetLength(Result, Length);
  Move((PChar(Self) + StartIndex)^, Result[0], Length * SizeOf(Char));
end;

function TFluentString.ToLower: string;
begin
  Result := ToLower(SysLocale.DefaultLCID);
end;

function TFluentString.ToLower(LocaleID: TLocaleID): string;
{$IF defined(MSWINDOWS)}
begin
  Result := Self;
  if Result <> '' then
  begin
    UniqueString(Result);
    if LCMapString(LocaleID, LCMAP_LOWERCASE or LCMAP_LINGUISTIC_CASING, PChar(Self), Self.Length,
       PChar(Result), Result.Length) = 0 then
      RaiseLastOSError;
  end;
end;
{$ELSEIF defined(USE_LIBICU)}
{$IFDEF LINUX}
var
  ResLen: Integer;
  ErrorCode: UErrorCode;
begin
  if IsICUAvailable then
  begin
    if Self.Length > 0 then
    begin
      ErrorCode := U_ZERO_ERROR;
      SetLength(Result, Self.Length);
      ResLen := u_strToLower(PChar(Result), Result.Length, PChar(Self), Self.Length, LocaleID, ErrorCode);
      if (ErrorCode > U_ZERO_ERROR) then
      begin
        ErrorCode := U_ZERO_ERROR;
        SetLength(Result, ResLen);
        ResLen := u_strToLower(PChar(Result), Result.Length, PChar(Self), Self.Length, LocaleID, ErrorCode);
        if (ErrorCode > U_ZERO_ERROR) then
          raise EOverflow.CreateFmt(SICUErrorOverflow, [Int32(ErrorCode), UTF8ToString(u_errorName(ErrorCode)), ResLen]);
      end;
    end
    else Result := Self;
  end
  else
    Result := UCS4StringToUnicodeString(UCS4LowerCase(UnicodeStringToUCS4String(Self), LocaleID));
end;
{$ELSE !LINUX}
var
  ResLen: Integer;
  ErrorCode: UErrorCode;
begin
  if Self.Length > 0 then
  begin
    ErrorCode := U_ZERO_ERROR;
    SetLength(Result, Self.Length);
    ResLen := u_strToLower(PChar(Result), Result.Length, PChar(Self), Self.Length, LocaleID, ErrorCode);
    if (ErrorCode > U_ZERO_ERROR) then
    begin
      ErrorCode := U_ZERO_ERROR;
      SetLength(Result, ResLen);
      ResLen := u_strToLower(PChar(Result), Result.Length, PChar(Self), Self.Length, LocaleID, ErrorCode);
      if (ErrorCode > U_ZERO_ERROR) then
        raise EOverflow.CreateFmt(SICUErrorOverflow, [Int32(ErrorCode), UTF8ToString(u_errorName(ErrorCode)), ResLen]);
    end;
  end
  else Result := Self;
end;
{$ENDIF LINUX}
{$ELSEIF defined(MACOS)}
var
  MutableStringRef: CFMutableStringRef;
  LOrig: Integer;
  LNew: Integer;
begin
  Result := Self;
  if Result <> '' then
  begin
    LOrig := Result.Length;
    LNew := 2 * LOrig;
    SetLength(Result, LNew);
    MutableStringRef := CFStringCreateMutableWithExternalCharactersNoCopy(kCFAllocatorDefault,
      PChar(Result), LOrig, LNew, kCFAllocatorNull);
    if MutableStringRef <> nil then
    try
      if LocaleID = nil then
        LocaleID := UTF8CompareLocale;
      CFStringLowercase(MutableStringRef, LocaleID);
      LNew := CFStringGetLength(CFStringRef(MutableStringRef));
      SetLength(Result, LNew);
    finally
      CFRelease(MutableStringRef);
    end else
      raise ECFError.Create(SCFStringFailed);
  end;
end;
{$ELSEIF defined(LINUX)}
begin
  Result := UCS4StringToUnicodeString(UCS4LowerCase(UnicodeStringToUCS4String(Self), LocaleID));
end;
{$ELSE !MSWINDOWS !MACOS}
begin
  Error(rePlatformNotImplemented);
end;
{$ENDIF !MSWINDOWS !MACOS}

function TFluentString.ToLowerInvariant: string;
{$IF defined(MSWINDOWS)}
var
  LMapLocale: LCID;
begin
  Result := Self;
  if Result <> '' then
  begin
    UniqueString(Result);
    if TOSVersion.Check(5, 1) then
      LMapLocale := LOCALE_INVARIANT
    else
      LMapLocale := LOCALE_SYSTEM_DEFAULT;
    if LCMapString(LMapLocale, LCMAP_LOWERCASE {or LCMAP_LINGUISTIC_CASING}, PChar(Self), Self.Length,
       PChar(Result), Result.Length) = 0 then
      RaiseLastOSError;
  end;
end;
{$ELSEIF defined(USE_LIBICU)}
{$IFDEF LINUX}
begin
  if IsICUAvailable then
    Result := Self.ToLower('en_US_POSIX')
  else
    Result := UCS4StringToUnicodeString(UCS4LowerCase(UnicodeStringToUCS4String(Self)));
end;
{$ELSE !LINUX}
begin
  Result := Self.ToLower('en_US_POSIX');
end;
{$ENDIF LINUX}
{$ELSEIF defined(MACOS)}
var
  MutableStringRef: CFMutableStringRef;
  LOrig: Integer;
  LNew: Integer;
begin
  Result := Self;
  if Result <> '' then
  begin
    LOrig := Result.Length;
    LNew := 2 * LOrig;
    SetLength(Result, LNew);
    MutableStringRef := CFStringCreateMutableWithExternalCharactersNoCopy(kCFAllocatorDefault,
      PChar(Result), LOrig, LNew, kCFAllocatorNull);
    if MutableStringRef <> nil then
    try
      CFStringLowercase(MutableStringRef, nil); // nil locale = Invariant Locale
      LNew := CFStringGetLength(CFStringRef(MutableStringRef));
      SetLength(Result, LNew);
    finally
      CFRelease(MutableStringRef);
    end else
      raise ECFError.Create(SCFStringFailed);
  end;
end;
{$ELSEIF defined(LINUX)}
begin
  Result := UCS4StringToUnicodeString(UCS4LowerCase(UnicodeStringToUCS4String(Self)));
end;
{$ELSE !MSWINDOWS !USE_LIBICU !MACOS}
begin
  Error(rePlatformNotImplemented);
end;
{$ENDIF !MSWINDOWS !USE_LIBICU !MACOS}

function TFluentString.ToUpper: string;
begin
  Result := ToUpper(SysLocale.DefaultLCID);
end;

function TFluentString.ToUpper(LocaleID: TLocaleID): string;
{$IF defined(MSWINDOWS)}
begin
  Result := Self;
  if Result <> '' then
  begin
    UniqueString(Result);
    if LCMapString(LocaleID, LCMAP_UPPERCASE or LCMAP_LINGUISTIC_CASING, PChar(Self), Self.Length,
       PChar(Result), Result.Length) = 0 then
      RaiseLastOSError;
  end;
end;
{$ELSEIF defined(USE_LIBICU)}
{$IFDEF LINUX}
var
  SelfLen: Integer;
  ResLen: Integer;
  ErrorCode: UErrorCode;
begin
  if IsICUAvailable then
  begin
    SelfLen := Self.Length;
    if SelfLen > 0 then
    begin
      ErrorCode := U_ZERO_ERROR;
      SetLength(Result, SelfLen);
      ResLen := u_strToUpper(PChar(Result), SelfLen, PChar(Self), SelfLen, LocaleID, ErrorCode);
      if (ErrorCode > U_ZERO_ERROR) then
      begin
        ErrorCode := U_ZERO_ERROR;
        SetLength(Result, ResLen);
        ResLen := u_strToUpper(PChar(Result), ResLen, PChar(Self), SelfLen, LocaleID, ErrorCode);
        if (ErrorCode > U_ZERO_ERROR) then
          raise EOverflow.CreateFmt(SICUErrorOverflow, [Int32(ErrorCode), UTF8ToString(u_errorName(ErrorCode)), ResLen]);
      end;
    end
    else Result := Self;
  end
  else
    Result := UCS4StringToUnicodeString(UCS4UpperCase(UnicodeStringToUCS4String(Self), LocaleID));
end;
{$ELSE !LINUX}
var
  SelfLen: Integer;
  ResLen: Integer;
  ErrorCode: UErrorCode;
begin
  SelfLen := Self.Length;
  if SelfLen > 0 then
  begin
    ErrorCode := U_ZERO_ERROR;
    SetLength(Result, SelfLen);
    ResLen := u_strToUpper(PChar(Result), SelfLen, PChar(Self), SelfLen, LocaleID, ErrorCode);
    if (ErrorCode > U_ZERO_ERROR) then
    begin
      ErrorCode := U_ZERO_ERROR;
      SetLength(Result, ResLen);
      ResLen := u_strToUpper(PChar(Result), ResLen, PChar(Self), SelfLen, LocaleID, ErrorCode);
      if (ErrorCode > U_ZERO_ERROR) then
        raise EOverflow.CreateFmt(SICUErrorOverflow, [Int32(ErrorCode), UTF8ToString(u_errorName(ErrorCode)), ResLen]);
    end;
  end
  else Result := Self;
end;
{$ENDIF LINUX}
{$ELSEIF defined(MACOS)}
var
  MutableStringRef: CFMutableStringRef;
  LOrig: Integer;
  LNew: Integer;
begin
  Result := Self;
  if Result <> '' then
  begin
    LOrig := Result.Length;
    LNew := 2 * LOrig;
    SetLength(Result, LNew);
    MutableStringRef := CFStringCreateMutableWithExternalCharactersNoCopy(kCFAllocatorDefault,
      PChar(Result), LOrig, LNew, kCFAllocatorNull);
    if MutableStringRef <> nil then
    try
      if LocaleID = nil then
        LocaleID := UTF8CompareLocale;
      CFStringUppercase(MutableStringRef, LocaleID);
      LNew := CFStringGetLength(CFStringRef(MutableStringRef));
      SetLength(Result, LNew);
    finally
      CFRelease(MutableStringRef);
    end else
      raise ECFError.Create(SCFStringFailed);
  end;
end;
{$ELSEIF defined(LINUX)}
begin
  Result := UCS4StringToUnicodeString(UCS4UpperCase(UnicodeStringToUCS4String(Self), LocaleID));
end;
{$ELSE !MSWINDOWS !USE_LIBICU !MACOS}
begin
  Error(rePlatformNotImplemented);
end;
{$ENDIF !MSWINDOWS !USE_LIBICU !MACOS}

function TFluentString.ToUpperInvariant: string;
{$IF defined(MSWINDOWS)}
var
  MapLocale: LCID;
begin
  Result := Self;
  if Result <> '' then
  begin
    UniqueString(Result);
    if TOSVersion.Check(5, 1) then
      MapLocale := LOCALE_INVARIANT
    else
      MapLocale := LOCALE_SYSTEM_DEFAULT;
    if LCMapString(MapLocale, LCMAP_UPPERCASE {or LCMAP_LINGUISTIC_CASING}, PChar(Self), Self.Length,
       PChar(Result), Result.Length) = 0 then
      RaiseLastOSError;
  end;
end;
{$ELSEIF defined(USE_LIBICU)}
{$IFDEF LINUX}
begin
  if IsICUAvailable then
    Result := Self.ToUpper('en_US_POSIX')
  else
    Result := UCS4StringToUnicodeString(UCS4UpperCase(UnicodeStringToUCS4String(Self)));
end;
{$ELSE !LINUX}
begin
  Result := Self.ToUpper('en_US_POSIX');
end;
{$ENDIF LINUX}
{$ELSEIF defined(MACOS)}
var
  MutableStringRef: CFMutableStringRef;
  LOrig: Integer;
  LNew: Integer;
begin
  Result := Self;
  if Result <> '' then
  begin
    LOrig := Result.Length;
    LNew := 2 * LOrig;
    SetLength(Result, LNew);
    MutableStringRef := CFStringCreateMutableWithExternalCharactersNoCopy(kCFAllocatorDefault,
      PChar(Result), LOrig, LNew, kCFAllocatorNull);
    if MutableStringRef <> nil then
    try
      CFStringUppercase(MutableStringRef, nil); // nil locale = Invariant Locale
      LNew := CFStringGetLength(CFStringRef(MutableStringRef));
      SetLength(Result, LNew);
    finally
      CFRelease(MutableStringRef);
    end else
      raise ECFError.Create(SCFStringFailed);
  end;
end;
{$ELSEIF defined(LINUX)}
begin
  Result := UCS4StringToUnicodeString(UCS4UpperCase(UnicodeStringToUCS4String(Self)));
end;
{$ELSE !MSWINDOWS !USE_LIBICU !MACOS}
begin
  Error(rePlatformNotImplemented);
end;
{$ENDIF !MSWINDOWS !USE_LIBICU !MACOS}

function TFluentString.GetHashCode: Integer;
var
  LResult: UInt32;
  I: Integer;
begin
  LResult := 0;
  for I := 0 to System.Length(Self) - 1 do
  begin
    LResult := (LResult shl 5) or (LResult shr 27); // ROL Result, 5
    LResult := LResult xor UInt32(Self[I]);
  end;
  Result := Int32(LResult);
end;

function TFluentString.Trim: string;
var
  I, L: Integer;
begin
  L := Self.Length - 1;
  I := 0;
  if (L = -1) or (Self[I] > ' ') and (Self[L] > ' ') then Exit(Self);
  while (I <= L) and (Self[I] <= ' ') do Inc(I);
  if I > L then Exit('');
  while Self[L] <= ' ' do Dec(L);
  Result := Self.SubString(I, L - I + 1);
end;

function TFluentString.TrimLeft: string;
var
  I, L: Integer;
begin
  L := Self.Length - 1;
  I := 0;
  while (I <= L) and (Self[I] <= ' ') do Inc(I);
  if I > 0 then
    Result := Self.SubString(I)
  else
    Result := Self;
end;

function TFluentString.TrimRight: string;
var
  I: Integer;
begin
  I := Self.Length - 1;
  if (I >= 0) and (Self[I] > ' ') then Result := Self
  else begin
    while (I >= 0) and (Self.Chars[I] <= ' ') do Dec(I);
    Result := Self.SubString(0, I + 1);
  end;
end;

function TFluentString.Trim(const TrimChars: array of Char): string;
var
  I, L: Integer;
begin
  L := Self.Length - 1;
  I := 0;
  if (L > 0) and (not CharInArray(Self[I], TrimChars)) and (not CharInArray(Self[L], TrimChars)) then
    Exit(Self);
  while (I <= L) and (CharInArray(Self[I], TrimChars)) do
    Inc(I);
  if I > L then Exit('');
  while CharInArray(Self[L], TrimChars) do
    Dec(L);
  Result := Self.Substring(I, L - I + 1);
end;

function TFluentString.TrimLeft(const TrimChars: array of Char): string;
var
  I, L: Integer;
begin
  L := Self.Length;
  I := 0;
  while (I < L) and (CharInArray(Self[I], TrimChars)) do
    Inc(I);
  if I > 0 then
    Result := Self.SubString(I)
  else
    Result := Self;
end;

function TFluentString.TrimRight(const TrimChars: array of Char): string;
var
  I: Integer;
begin
  I := Self.Length - 1;
  if (I >= 0) and (not CharInArray(Self[I], TrimChars)) then
    Exit(Self);
  Dec(I);
  while (I >= 0) and (CharInArray(Self[I], TrimChars)) do
    Dec(I);
  Result := Self.SubString(0, I + 1);
end;

function TFluentString.TrimEnd(const TrimChars: array of Char): string;
begin
  Result := Self.TrimRight(TrimChars);
end;

function TFluentString.TrimStart(const TrimChars: array of Char): string;
begin
  Result := Self.TrimLeft(TrimChars);
end;

{$IF not defined(NEXTGEN) or defined(LINUX)}
{$ZEROBASEDSTRINGS OFF} // Desktop platforms use One-based string
{$ENDIF}

{$ZEROBASEDSTRINGS ON}
function TFluentString.GetChars(Index: Integer): Char;
begin
  Result := Self[Index];
end;

function TFluentString.GetLength: Integer;
begin
  Result := System.Length(Self);
end;

function TFluentString.Substring(StartIndex: Integer): string;
begin
  Result := System.Copy(Self, StartIndex + 1, Self.Length);
end;

function TFluentString.Substring(StartIndex, Length: Integer): string;
begin
  Result := System.Copy(Self, StartIndex + 1, Length);
end;
{$ZEROBASEDSTRINGS OFF}

class function TFluentString.InternalCompare(const StrA: string; IndexA: Integer; const StrB: string;
  IndexB, LengthA, LengthB: Integer; IgnoreCase: Boolean; LocaleID: TLocaleID): Integer;
begin
  if IgnoreCase then
    Result := AnsiStrLIComp(PChar(@StrA[IndexA]), PChar(@StrB[IndexB]), Min(LengthA, LengthB))
  else
    Result := AnsiStrLComp(PChar(@StrA[IndexA]), PChar(@StrB[IndexB]), Min(LengthA, LengthB));
end;

class function TFluentString.InternalCompare(const StrA: string; IndexA: Integer; const StrB: string;
  IndexB, LengthA, LengthB: Integer; Options: TCompareOptions; LocaleID: TLocaleID): Integer;
var
  LStrA, LStrB: string;
begin
  LStrA := StrA.Substring(IndexA, LengthA);
  LStrB := StrB.Substring(IndexB, LengthB);
  {$IF defined(MSWINDOWS)}
  if coIgnoreCase in Options then
    Result := AnsiStrLIComp(PChar(LStrA), PChar(LStrB), Min(LengthA, LengthB))
  else
    Result := AnsiStrLComp(PChar(LStrA), PChar(LStrB), Min(LengthA, LengthB));
  {$ELSE}
  if coIgnoreCase in Options then
    Result := System.SysUtils.CompareText(LStrA, LStrB)
  else
    Result := System.SysUtils.CompareStr(LStrA, LStrB);
  {$ENDIF}
end;

{ TFluentString }

function TFluentString.AsEnumerable(const AString: string): IFluentEnumerable<Char>;
begin
  Result := IFluentEnumerable<Char>.Create(TStringAdapter.Create(AString));
end;

procedure TFluentString.Partition(const APredicate: TFunc<Char, Boolean>; out ALeft, ARight: String);
var
  LChar: Char;
begin
  ALeft := '';
  ARight := '';
  for LChar in Self do
    if APredicate(LChar) then
      ALeft := ALeft + LChar
    else
      ARight := ARight + LChar;
end;

function TFluentString.Where(const APredicate: TFunc<Char, Boolean>): IFluentEnumerable<Char>;
begin
  Result := AsEnumerable(Self).Where(APredicate);
end;

function TFluentString.Collect: IFluentEnumerable<String>;
var
  LWords: TArray<string>;
begin
  LWords := SplitString(Self, ' ');
  Result := IFluentEnumerable<String>.Create(TArrayAdapter<string>.Create(LWords));
end;

function TFluentString.Select<TResult>(const ATransform: TFunc<Char, TResult>): IFluentEnumerable<TResult>;
begin
  Result := AsEnumerable(Self).Select<TResult>(ATransform);
end;

function TFluentString.SelectMany<TResult>(const ASelector: TFunc<Char, TArray<TResult>>): IFluentEnumerable<TResult>;
begin
  Result := AsEnumerable(Self).SelectMany<TResult>(ASelector);
end;

function TFluentString.Sum: Integer;
var
  LEnum: IFluentEnumerator<Char>;
  LSum: Integer;
begin
  LEnum := AsEnumerable(Self).GetEnumerator;
  LSum := 0;
  while LEnum.MoveNext do
    Inc(LSum, Ord(LEnum.Current));
  Result := LSum;
end;

function TFluentString.First: Char;
begin
  if System.Length(Self) > 0 then
    Result := Self[1]
  else
    Result := #0;
end;

function TFluentString.Last: Char;
begin
  if System.Length(Self) > 0 then
    Result := Self[System.Length(Self)]
  else
    Result := #0;
end;

function TFluentString.Aggregate<T>(const AInitialValue: T;
  const AAccumulator: TFunc<T, Char, T>): T;
begin
  Result := AsEnumerable(Self).Aggregate<T>(AInitialValue, AAccumulator);
end;

function TFluentString.Exists(const APredicate: TFunc<Char, Boolean>): Boolean;
begin
  Result := AsEnumerable(Self).Any(APredicate);
end;

function TFluentString.All(const APredicate: TFunc<Char, Boolean>): Boolean;
var
  LEnum: IFluentEnumerator<Char>;
begin
  LEnum := AsEnumerable(Self).GetEnumerator;
  while LEnum.MoveNext do
    if not APredicate(LEnum.Current) then
      Exit(False);
  Result := True;
end;

function TFluentString.Any(const APredicate: TFunc<Char, Boolean>): Boolean;
begin
  Result := AsEnumerable(Self).Any(APredicate);
end;

function TFluentString.Sort: IFluentEnumerable<Char>;
begin
  Result := AsEnumerable(Self).OrderBy(
    function(LA, LB: Char): Integer
    begin
      Result := CompareStr(string(LA), string(LB));
    end);
end;

function TFluentString.Take(const ACount: Integer): IFluentEnumerable<Char>;
begin
  Result := AsEnumerable(Self).Take(ACount);
end;

function TFluentString.Skip(const ACount: Integer): IFluentEnumerable<Char>;
begin
  Result := AsEnumerable(Self).Skip(ACount);
end;

function TFluentString.GroupBy<TKey>(const AKeySelector: TFunc<Char, TKey>): IGroupByEnumerable<TKey, Char>;
begin
  Result := AsEnumerable(Self).GroupBy<TKey>(AKeySelector);
end;

function TFluentString.Reverse: IFluentEnumerable<Char>;
var
  LArray: TArray<Char>;
  LIndex: Integer;
begin
  SetLength(LArray, System.Length(Self));
  for LIndex := 1 to System.Length(Self) do
    LArray[LIndex - 1] := Self[System.Length(Self) - LIndex + 1];
  Result := IFluentEnumerable<Char>.Create(TArrayAdapter<Char>.Create(LArray));
end;

function TFluentString.CountWhere(const APredicate: TFunc<Char, Boolean>): Integer;
begin
  Result := AsEnumerable(Self).Count(APredicate);
end;

{ TFluentInteger }

function TFluentInteger.Select(const ATransform: TFunc<Integer, Integer>): Integer;
begin
  Result := ATransform(Self);
end;

function TFluentInteger.IsEven: Boolean;
begin
  Result := (Self mod 2) = 0;
end;

function TFluentInteger.IsOdd: Boolean;
begin
  Result := (Self mod 2) <> 0;
end;

function TFluentInteger.Times(const ATransform: TFunc<Integer, Integer>): Integer;
var
  LCount: Integer;
  LResult: Integer;
begin
  LResult := Self;
  for LCount := 1 to Self do
    LResult := ATransform(LResult);
  Result := LResult;
end;

{ TFluentBoolean }

function TFluentBoolean.Select<T>(const ATrueValue, AFalseValue: T): T;
begin
  if Self then
    Result := ATrueValue
  else
    Result := AFalseValue;
end;

procedure TFluentBoolean.IfTrue(const AAction: TProc);
begin
  if Self then
    AAction;
end;

procedure TFluentBoolean.IfFalse(const AAction: TProc);
begin
  if not Self then
    AAction;
end;

{ TFluentFloat }

function TFluentFloat.Select(const ATransform: TFunc<Double, Double>): Double;
begin
  Result := ATransform(Self);
end;

function TFluentFloat.Round: Integer;
begin
  Result := System.Round(Self);
end;

function TFluentFloat.ApproxEqual(const AValue: Double; const ATolerance: Double): Boolean;
begin
  Result := Abs(Self - AValue) < ATolerance;
end;

{ TFluentDateTime }

function TFluentDateTime.Select(const ATransform: TFunc<TDateTime, TDateTime>): TDateTime;
begin
  Result := ATransform(Self);
end;

function TFluentDateTime.AddDays(ADays: Integer): TDateTime;
begin
  Result := Self + ADays;
end;

function TFluentDateTime.IsPast: Boolean;
begin
  Result := Self < Now;
end;

function TFluentDateTime.ToFormat(const AFormat: String): String;
begin
  Result := FormatDateTime(AFormat, Self);
end;

end.



