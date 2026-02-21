{
                          Apache License
                      Version 2.0, January 2004
                   http://www.apache.org/licenses/

       Licensed under the Apache License, Version 2.0 (the "License");
       you may not use this file except in compliance with the License.
       You may obtain a copy of the License at

             http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing, software
       distributed under the License is distributed on an "AS IS" BASIS,
       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
       See the License for the specific language governing permissions and
       limitations under the License.
}

{
  @abstract(Fluent4D: Fluent Data Processing Framework for Delphi)
  @description(A powerful and intuitive framework for fluent-style data manipulation in Delphi)
  @created(03 Abr 2025)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @Discord(https://discord.gg/T2zJC8zX)
}

{$include ./fluent4d.inc}

unit Fluent.Parse;

interface

uses
  DB,
  Rtti,
  Classes,
  TypInfo,
  SysUtils,
  Generics.Collections,
  DBEngine.FactoryInterfaces,
  System.Fluent,
  System.Fluent.Collections,
  System.Evolution.Tuple;

type
  // Parser for object types (classes)
  TFluentParseObjectDataSet<T> = class
  private
    function _ParseDataSet(const ADataSet: IDBDataSet): TFluentList<T>;
  public
    function ToList(const ADataSet: IDBDataSet): TFluentList<T>;
    function ToArray(const ADataSet: IDBDataSet): TFluentArray<T>;
    function ToDictionary<TKey, TValue>(
      const ADataSet: IDBDataSet;
      const AKeySelector: TFunc<T, TKey>;
      const AValueSelector: TFunc<T, TValue>): TFluentDictionary<TKey, TValue>;
  end;

  // Parser for scalar types (primitives or tuples)
  TFluentParseScalarDataSet<T> = class
  private
    function _ParseDataSet(const ADataSet: IDBDataSet): TFluentList<T>;
  public
    function ToList(const ADataSet: IDBDataSet): TFluentList<T>;
    function ToArray(const ADataSet: IDBDataSet): TFluentArray<T>;
    function ToDictionary<TKey, TValue>(
      const ADataSet: IDBDataSet;
      const AKeySelector: TFunc<T, TKey>;
      const AValueSelector: TFunc<T, TValue>): TFluentDictionary<TKey, TValue>;
  end;

implementation

{ TFluentParseObjectDataSet<T> }

function TFluentParseObjectDataSet<T>._ParseDataSet(const ADataSet: IDBDataSet): TFluentList<T>;
var
  LItem: T;
  LValue: TValue;
  LContext: TRttiContext;
  LType: TRttiType;
  LProperty: TRttiProperty;
  LField: TField;
  LInstance: TObject;
  LFor: Integer;
begin
  Result := TFluentList<T>.Create;
  LContext := TRttiContext.Create;
  try
    LType := LContext.GetType(TypeInfo(T));
    if not (LType.TypeKind in [tkClass, tkInterface]) then
      raise Exception.Create('Type T must be a class for TFluentParseObjectDataSet');

    while not ADataSet.Eof do
    begin
      try
        LInstance := LType.AsInstance.MetaclassType.Create;
        try
          // Map all fields from the dataset
          for LFor := 0 to ADataSet.FieldCount - 1 do
          begin
            LField := ADataSet.Fields[LFor];
            LProperty := LType.GetProperty(LField.FieldName);
            if Assigned(LProperty) and LProperty.IsWritable then
            begin
              case LField.DataType of
                ftString, ftWideString:
                  LProperty.SetValue(LInstance, LField.AsString);
                ftInteger, ftSmallint, ftWord:
                  LProperty.SetValue(LInstance, LField.AsInteger);
                ftFloat, ftCurrency:
                  LProperty.SetValue(LInstance, LField.AsFloat);
                ftDate, ftDateTime:
                  LProperty.SetValue(LInstance, LField.AsDateTime);
                ftBoolean:
                  LProperty.SetValue(LInstance, LField.AsBoolean);
                else
                  raise EInvalidCast.Create('Unsupported field type: ' + GetEnumName(TypeInfo(TFieldType), Ord(LField.DataType)));
              end;
            end;
          end;
          LValue := TValue.From(LInstance);
          if not LValue.TryAsType<T>(LItem) then
            raise EInvalidCast.Create('Cannot convert instance to type T');
          Result.Add(LItem);
        except
          LInstance.Free;
          Result.Free;
          LContext.Free;
          raise;
        end;
      except
        Result.Free;
        LContext.Free;
        raise;
      end;
      ADataSet.Next;
    end;
  finally
    LContext.Free;
  end;
end;

function TFluentParseObjectDataSet<T>.ToList(const ADataSet: IDBDataSet): TFluentList<T>;
begin
  Result := _ParseDataSet(ADataSet);
end;

function TFluentParseObjectDataSet<T>.ToArray(const ADataSet: IDBDataSet): TFluentArray<T>;
var
  LList: IFluentList<T>;
begin
  LList := _ParseDataSet(ADataSet);
  try
    Result := TFluentArray<T>.Create(LList.ToArray.ArrayData);
  finally
    LList := nil;
  end;
end;

function TFluentParseObjectDataSet<T>.ToDictionary<TKey, TValue>(
  const ADataSet: IDBDataSet;
  const AKeySelector: TFunc<T, TKey>;
  const AValueSelector: TFunc<T, TValue>): TFluentDictionary<TKey, TValue>;
var
  LList: IFluentList<T>;
  LItem: T;
begin
  LList := _ParseDataSet(ADataSet);
  try
    Result := TFluentDictionary<TKey, TValue>.Create;
    try
      for LItem in LList do
        Result.Add(AKeySelector(LItem), AValueSelector(LItem));
    except
      Result.Free;
      raise;
    end;
  finally
    LList := nil;
  end;
end;

{ TFluentParseScalarDataSet<T> }

function TFluentParseScalarDataSet<T>._ParseDataSet(const ADataSet: IDBDataSet): TFluentList<T>;
var
  LItem: T;
  LValue: TValue;
  LKeys: TArray<string>;
  LValues: TArray<TValue>;
  LTuple: TTuple<string>;
  LField: TField;
  LFor: Integer;
  LContext: TRttiContext;
  LType: TRttiType;
  LIsTupleValid: Boolean;
  LFieldType: TFieldType;
begin
  if not Assigned(ADataSet) then
    raise EInvalidOperation.Create('DataSet is nil');

  Result := TFluentList<T>.Create;
  LContext := TRttiContext.Create;
  try
    try
      LType := LContext.GetType(TypeInfo(T));
      if not Assigned(LType) then
        raise EInvalidOperation.Create('Type information not available for T');

      if ADataSet.FieldCount = 0 then
        raise EInvalidOperation.Create('No fields available in dataset');

      while not ADataSet.Eof do
      begin
        if (ADataSet.FieldCount = 1) and not
          ((LType.TypeKind = tkRecord) and (LType.Name = 'TFluentTuple<System.string>')) then
        begin
          LField := ADataSet.Fields[0];
          if not Assigned(LField) then
            raise EInvalidOperation.Create('Field at index 0 is nil');

          LFieldType := LField.DataType;
          case LFieldType of
            ftString, ftWideString:
              if not (LType.TypeKind in [tkUString]) then
                raise EInvalidCast.Create('Field ''' + LField.FieldName + ''' is string, but provider type is ' + LType.Name);
            ftInteger, ftSmallint, ftWord:
              if not (LType.TypeKind in [tkInteger, tkInt64]) then
                raise EInvalidCast.Create('Field ''' + LField.FieldName + ''' is integer, but provider type is ' + LType.Name);
            ftLargeint:
              if not (LType.TypeKind in [tkInteger, tkInt64, tkFloat]) then
                raise EInvalidCast.Create('Field ''' + LField.FieldName + ''' is integer, but provider type is ' + LType.Name);
            ftFloat, ftCurrency:
              if not (LType.TypeKind in [tkFloat]) then
                raise EInvalidCast.Create('Field ''' + LField.FieldName + ''' is float, but provider type is ' + LType.Name);
            ftDate, ftDateTime:
              if not (LType.TypeKind in [tkFloat]) then
                raise EInvalidCast.Create('Field ''' + LField.FieldName + ''' is datetime, but provider type is ' + LType.Name);
            ftBoolean:
              if not (LType.TypeKind in [tkEnumeration]) then
                raise EInvalidCast.Create('Field ''' + LField.FieldName + ''' is boolean, but provider type is ' + LType.Name);
            else
              raise EInvalidCast.Create('Unsupported field type: ' + GetEnumName(TypeInfo(TFieldType), Ord(LFieldType)));
          end;

          case LFieldType of
            ftString, ftWideString:
              LValue := TValue.From(LField.AsString);
            ftInteger, ftSmallint, ftWord:
              LValue := TValue.From(LField.AsInteger);
            ftLargeint:
              LValue := TValue.From(LField.AsVariant);
            ftFloat, ftCurrency:
              LValue := TValue.From(LField.AsFloat);
            ftDate, ftDateTime:
              LValue := TValue.From(LField.AsDateTime);
            ftBoolean:
              LValue := TValue.From(LField.AsBoolean);
          end;

          if LValue.TryAsType<T>(LItem) then
            Result.Add(LItem)
          else
            raise EInvalidCast.Create('Cannot convert field ''' + LField.FieldName + ''' to type ' + LType.Name);
        end
        else
        begin
          LIsTupleValid := (LType.TypeKind = tkRecord) and (LType.Name = 'TTuple<System.string>');
          if not LIsTupleValid then
            raise Exception.Create('Multiple fields detected (FieldCount > 1). Use TTuple<string> as the provider type.');

          SetLength(LKeys, ADataSet.FieldCount);
          SetLength(LValues, ADataSet.FieldCount);
          for LFor := 0 to ADataSet.FieldCount - 1 do
          begin
            LField := ADataSet.Fields[LFor];
            if not Assigned(LField) then
              raise EInvalidOperation.Create('Field at index ' + IntToStr(LFor) + ' is nil');

            LKeys[LFor] := Trim(LField.FieldName);
            WriteLn('Campo: ', LField.FieldName, ' -> Normalizado: ', LKeys[LFor]);

            case LField.DataType of
              ftString, ftWideString:
                LValues[LFor] := TValue.From(LField.AsString);
              ftInteger, ftSmallint, ftWord:
                LValues[LFor] := TValue.From(LField.AsInteger);
              ftFloat, ftCurrency:
                LValues[LFor] := TValue.From(LField.AsFloat);
              ftDate, ftDateTime:
                LValues[LFor] := TValue.From(LField.AsDateTime);
              ftBoolean:
                LValues[LFor] := TValue.From(LField.AsBoolean);
            else
              raise EInvalidCast.Create('Unsupported field type: ' + GetEnumName(TypeInfo(TFieldType), Ord(LField.DataType)));
            end;
            WriteLn('Valor do campo ', LKeys[LFor], ': ', LValues[LFor].ToString);
          end;
          LTuple := TTuple<string>.New(LKeys, LValues);
          LValue := TValue.From(LTuple);
          if not LValue.TryAsType<T>(LItem) then
            raise EInvalidCast.Create('Cannot convert tuple to type T');
          Result.Add(LItem);
        end;
        ADataSet.Next;
      end;
    except
      Result.Free;
      raise;
    end;
  finally
    LContext.Free;
  end;
end;

function TFluentParseScalarDataSet<T>.ToList(const ADataSet: IDBDataSet): TFluentList<T>;
begin
  Result := _ParseDataSet(ADataSet);
end;

function TFluentParseScalarDataSet<T>.ToArray(const ADataSet: IDBDataSet): TFluentArray<T>;
var
  LList: IFluentList<T>;
begin
  LList := _ParseDataSet(ADataSet);
  try
    Result := TFluentArray<T>.Create(LList.ToArray.ArrayData);
  finally
    LList := nil;
  end;
end;

function TFluentParseScalarDataSet<T>.ToDictionary<TKey, TValue>(
  const ADataSet: IDBDataSet;
  const AKeySelector: TFunc<T, TKey>;
  const AValueSelector: TFunc<T, TValue>): TFluentDictionary<TKey, TValue>;
var
  LList: IFluentList<T>;
  LItem: T;
begin
  LList := _ParseDataSet(ADataSet);
  try
    Result := TFluentDictionary<TKey, TValue>.Create;
    try
      for LItem in LList do
        Result.Add(AKeySelector(LItem), AValueSelector(LItem));
    except
      Result.Free;
      raise;
    end;
  finally
    LList := nil;
  end;
end;

end.

