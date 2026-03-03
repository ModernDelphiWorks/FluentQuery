unit UTestFluentQuery.CQL;

interface

uses
  Classes,
  SysUtils,
  DUnitX.TestFramework,
  DataEngine.FactoryFireDac,
  FluentQuery,
  FluentQuery.Queryable,
  ModernSyntax.Tuple,
  FireDAC.Comp.Client,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.Phys.FB;

type
  TConnection = class(TComponent)
  end;

  TCliente = class
  private
    FID: Integer;
    FNome: String;
    FIdade: Integer;
  public
    property ID: Integer read FID write FID;
    property Nome: String read FNome write FNome;
    property Idade: Integer read FIdade write FIdade;
  end;

  [TestFixture]
  TTestFluentCQLFirebird = class
  private
    FQueryable: IFluentQueryable<String>;
    FFDConnection: TFDConnection;
    FConnection: IDBConnection;
    function GetSQL: string;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestSelectAllFromClientes;
    [Test]
    procedure TestSelectWhereNome;
    [Test]
    procedure TestMinValue;
    [Test]
    procedure TestMaxValue;
    [Test]
    procedure TestCountValue;
    [Test]
    procedure TestFromBeforeSelect;
    [Test]
    procedure TestSelectBeforeWhere;
    [Test]
    procedure TestInnerJoin;
    [Test]
    procedure TestGroupBy;
    [Test]
    procedure TestOrderBy;
    [Test]
    procedure TestWhereJoinSelect;
    [Test]
    procedure TestWhereCompositeConditions;
    [Test]
    procedure TestSelectSpecificColumns;
    [Test]
    procedure TestTableAlias;
    [Test]
    procedure TestMultipleJoins;
    [Test]
    procedure TestWhereWithLike;
    [Test]
    procedure TestWhereWithOrAndParentheses;
    [Test]
    procedure TestSelectWithAliasColumns;
    [Test]
    procedure TestJoinWithMultipleConditions;
    [Test]
    procedure TestEmptyWhereClause;
    [Test]
    procedure TestOrderByMultipleColumns;
    [Test]
    procedure TestSelectWhereNomeForTuple;
    [Test]
    procedure TestSelectSingleFieldInvalidType;
    [Test]
    procedure TestSelectSingleFieldString;
    [Test]
    procedure TestSelectMultipleFieldsInvalidType;
    [Test]
    procedure TestJoinSimple;
    [Test]
    procedure TestGroupBySimple;
//    [Test]
//    procedure TestGroupByOrdersByCustomerId;
    [Test]
    procedure TestCountWithLambdaExpression;
    [Test]
    procedure TestAllWithLambdaExpression;
    [Test]
    procedure TestFirstWithLambdaExpression;
    [Test]
    procedure TestFirstOrDefaultWithLambdaExpression;
    [Test]
    procedure TestTakeWithLambdaExpression;
    [Test]
    procedure TestLastWithLambdaExpression;
    [Test]
    procedure TestLastOrDefaultWithLambdaExpression;
    [Test]
    procedure TestSingleWithLambdaExpression;
    [Test]
    procedure TestLongCountWithLambdaExpression;
    [Test]
    procedure TestGroupByWithSelect;
    [Test]
    procedure TestOrderByDescWithTQE;
    [Test]
    procedure TestThenByWithTQE;
    [Test]
    procedure TestThenByDescendingWithTQE;
    [Test]
    procedure TestSelectWithTQE;
    [Test]
    procedure TestMinFirebird;
    [Test]
    procedure TestMinByFirebird;
    [Test]
    procedure TestSumFirebird;
    [Test]
    procedure TestAverageFirebird;
  end;

implementation

uses
  DataEngine.FactoryInterfaces,
  System.Generics.Collections,
  FluentQuery.Collections,
  FluentQuery.Expression;

function TTestFluentCQLFirebird.GetSQL: string;
begin
  Result := FQueryable.AsString;
end;

procedure TTestFluentCQLFirebird.Setup;
begin
  FFDConnection := TFDConnection.Create(nil);
  FFDConnection.DriverName := 'FB';
  FFDConnection.Params.Database := 'D:\PROJETOS-4D\FLUENT4D\TEST DELPHI\CLIENTES.FDB'; // Ajuste o caminho
  FFDConnection.Params.UserName := 'SYSDBA';
  FFDConnection.Params.Password := 'masterkey';
  FFDConnection.Params.Add('Server=127.0.0.1');
  FFDConnection.Params.Add('Port=3050');
  FFDConnection.Params.Add('CharacterSet=WIN1252');
  FFDConnection.Params.Add('Protocol=TCPIP');
  FFDConnection.Open;

  FConnection := TFactoryFireDAC.Create(FFDConnection, TDBEngineDriver.dnFirebird);

  FQueryable := IFluentQueryable<String>.CreateForDatabase(
    procedure(var ADatabase: TDBEngineDriver; var AConnection: IDBConnection)
    begin
      ADatabase := TDBEngineDriver.dnFirebird;
      AConnection := FConnection;
    end);
end;

procedure TTestFluentCQLFirebird.TearDown;
begin
  FFDConnection.Close;
  FFDConnection.Free;
end;

procedure TTestFluentCQLFirebird.TestSelectAllFromClientes;
begin
  FQueryable.Select('*').From('CLIENTES');
  Assert.AreEqual('SELECT * FROM CLIENTES', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestSelectWhereNome;
var
  LCliente: TCliente;
  FoundAna, FoundBruno, FoundClara: Boolean;
  LQueryable: IFluentQueryable<TCliente>;
  LResults: IFluentList<TCliente>;
  LClient: TCliente;
begin
  LQueryable := IFluentQueryable<TCliente>.CreateForDatabase(
    procedure(var ADatabase: TDBEngineDriver; var AConnection: IDBConnection)
    begin
      ADatabase := TDBEngineDriver.dnFirebird;
      AConnection := FConnection;
    end);

  LQueryable.From('CLIENTES').Where('NOME > ''Ana''').Select('*');
  Assert.AreEqual('SELECT * FROM CLIENTES WHERE NOME > ''Ana''', LQueryable.AsString, 'SQL gerado incorreto');

  LResults := LQueryable.ToList;
  try
    Assert.AreEqual(2, LResults.Count, 'Número de registros retornados incorreto');

    // Verifica se "Ana" está na lista
    FoundAna := False;
    FoundBruno := False;
    FoundClara := False;
    for LCliente in LResults do
    begin
      if LCliente.Nome = 'Ana' then
        FoundAna := True;
      if LCliente.Nome = 'Bruno' then
        FoundBruno := True;
      if LCliente.Nome = 'Clara' then
        FoundClara := True;
    end;

    Assert.IsFalse(FoundAna, 'Registro "Ana" não encontrado');
    Assert.IsTrue(FoundBruno, 'Registro "Bruno" encontrado');
    Assert.IsTrue(FoundClara, 'Registro "Clara" encontrado');

    // Validação adicional para garantir que os outros campos estão corretos
    LCliente := LResults.First;
    Assert.AreEqual(2, LCliente.ID, 'ID incorreto');
    Assert.AreEqual(30, LCliente.Idade, 'Idade incorreta');
  finally
    for LCliente in LResults do
      LCliente.Free;
  end;
end;

procedure TTestFluentCQLFirebird.TestMinValue;
var
  LQueryable: IFluentQueryable<Integer>;
  LResult: String;
begin
  LQueryable := IFluentQueryable<Integer>.CreateForDatabase(
    procedure(var ADatabase: TDBEngineDriver; var AConnection: IDBConnection)
    begin
      ADatabase := TDBEngineDriver.dnFirebird;
      AConnection := TFactoryFireDAC.Create(FFDConnection, ADatabase);
    end);
  LQueryable.From('CLIENTES').Select('ID').Min;
  LResult := LQueryable.AsString;

  Assert.AreEqual('SELECT MIN(ID) FROM CLIENTES', LResult, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestMaxValue;
var
  ProviderInt: IFluentQueryable<Integer>;
begin
  ProviderInt := IFluentQueryable<Integer>.CreateForDatabase(
    procedure(var ADatabase: TDBEngineDriver; var AConnection: IDBConnection)
    begin
      ADatabase := TDBEngineDriver.dnFirebird;
      AConnection := TFactoryFireDAC.Create(FFDConnection, ADatabase);
    end);
  ProviderInt.Select('IDADE').From('CLIENTES').Max;

  Assert.AreEqual('SELECT MAX(IDADE) FROM CLIENTES', ProviderInt.AsString, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestCountValue;
var
  LQueryable: IFluentQueryable<Integer>;
begin
  LQueryable := IFluentQueryable<Integer>.CreateForDatabase(
    procedure(var ADatabase: TDBEngineDriver; var AConnection: IDBConnection)
    begin
      ADatabase := TDBEngineDriver.dnFirebird;
      AConnection := TFactoryFireDAC.Create(FFDConnection, ADatabase);
    end);
  LQueryable.Select('ID').From('CLIENTES').Count;

  Assert.AreEqual('SELECT COUNT(ID) FROM CLIENTES', LQueryable.AsString, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestFromBeforeSelect;
begin
  FQueryable.From('CLIENTES').Select('*');

  Assert.AreEqual('SELECT * FROM CLIENTES', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestSelectBeforeWhere;
begin
  FQueryable.Select('*').Where('NOME = ''Ana''').From('CLIENTES');

  Assert.AreEqual('SELECT * FROM CLIENTES WHERE NOME = ''Ana''', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestInnerJoin;
begin
  FQueryable.Select('*').From('CLIENTES').InnerJoin('PEDIDOS', 'P').OnCond('CLIENTES.ID = P.ID_CLIENTE');

  Assert.AreEqual('SELECT * FROM CLIENTES INNER JOIN PEDIDOS AS P ON CLIENTES.ID = P.ID_CLIENTE', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestGroupBy;
begin
  FQueryable.Select('COUNT(*)').From('PEDIDOS').GroupBy('CLIENTE_ID');

  Assert.AreEqual('SELECT COUNT(*) FROM PEDIDOS GROUP BY CLIENTE_ID', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestOrderBy;
begin
  FQueryable.From('CLIENTES').Select('*').OrderBy('NOME');

  Assert.AreEqual('SELECT * FROM CLIENTES ORDER BY NOME ASC', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestWhereJoinSelect;
begin
  FQueryable.Where('NOME > ''B''').InnerJoin('PEDIDOS', 'P').OnCond('CLIENTES.ID = P.ID_CLIENTE').Select('*').From('CLIENTES');

  Assert.AreEqual('SELECT * FROM CLIENTES INNER JOIN PEDIDOS AS P ON CLIENTES.ID = P.ID_CLIENTE WHERE NOME > ''B''', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestWhereCompositeConditions;
begin
  FQueryable.Select('*').From('CLIENTES').Where('ID > 10 AND NOME < ''Z''');
  Assert.AreEqual('SELECT * FROM CLIENTES WHERE ID > 10 AND NOME < ''Z''', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestSelectSpecificColumns;
begin
  FQueryable.Select('NOME, IDADE').From('CLIENTES');

  Assert.AreEqual('SELECT NOME, IDADE FROM CLIENTES', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestTableAlias;
begin
  FQueryable.Select('*').From('CLIENTES', 'C');

  Assert.AreEqual('SELECT * FROM CLIENTES AS C', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestMultipleJoins;
begin
  FQueryable.Select('*').From('CLIENTES')
    .InnerJoin('PEDIDOS', 'P').OnCond('CLIENTES.ID = P.ID_CLIENTE')
    .InnerJoin('ITENS', 'I').OnCond('P.ID = I.ID_PEDIDO');

  Assert.AreEqual('SELECT * FROM CLIENTES INNER JOIN PEDIDOS AS P ON CLIENTES.ID = P.ID_CLIENTE INNER JOIN ITENS AS I ON P.ID = I.ID_PEDIDO', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestWhereWithLike;
begin
  FQueryable.Select('*').From('CLIENTES').Where('NOME LIKE ''A%''');

  Assert.AreEqual('SELECT * FROM CLIENTES WHERE NOME LIKE ''A%''', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestWhereWithOrAndParentheses;
begin
  FQueryable.Select('*').From('CLIENTES')
    .Where('NOME > ''A'' OR (IDADE < 30 AND STATUS = ''ATIVO'')');

  Assert.AreEqual('SELECT * FROM CLIENTES WHERE NOME > ''A'' OR (IDADE < 30 AND STATUS = ''ATIVO'')', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestSelectWithAliasColumns;
begin
  FQueryable.Select('NOME AS NomeCliente, IDADE AS IdadeCliente').From('CLIENTES');

  Assert.AreEqual('SELECT NOME AS NomeCliente, IDADE AS IdadeCliente FROM CLIENTES', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestJoinWithMultipleConditions;
begin
  FQueryable.Select('*').From('CLIENTES')
    .InnerJoin('PEDIDOS', 'P').OnCond('CLIENTES.ID = P.ID_CLIENTE AND CLIENTES.STATUS = P.STATUS');

  Assert.AreEqual('SELECT * FROM CLIENTES INNER JOIN PEDIDOS AS P ON CLIENTES.ID = P.ID_CLIENTE AND CLIENTES.STATUS = P.STATUS', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestEmptyWhereClause;
begin
  FQueryable.Select('*').From('CLIENTES').Where('');

  Assert.AreEqual('SELECT * FROM CLIENTES', GetSQL, 'SQL gerado incorreto (WHERE vazio deve ser ignorado)');
end;

procedure TTestFluentCQLFirebird.TestOrderByMultipleColumns;
begin
  FQueryable.Select.From('PEDIDOS').OrderBy('DATA, VALOR');

  Assert.AreEqual('SELECT * FROM PEDIDOS ORDER BY DATA, VALOR ASC', GetSQL, 'SQL gerado incorreto');
end;

procedure TTestFluentCQLFirebird.TestSelectWhereNomeForTuple;
var
  LTuple: TTuple<string>;
  FoundAna, FoundBruno, FoundClara: Boolean;
  LProvider: IFluentQueryable<TTuple<string>>;
  LResults: IFluentList<TTuple<string>>;
begin
  LProvider := IFluentQueryable<TTuple<string>>.CreateForDatabase(
    procedure(var ADatabase: TDBEngineDriver; var AConnection: IDBConnection)
    begin
      ADatabase := TDBEngineDriver.dnFirebird;
      AConnection := FConnection;
    end);

  LProvider.From('CLIENTES').Where('NOME > ''Ana''').Select('*');
  Assert.AreEqual('SELECT * FROM CLIENTES WHERE NOME > ''Ana''', LProvider.AsString, 'SQL generated incorrectly');

  LResults := LProvider.ToList;
  Assert.AreEqual(2, LResults.Count, 'Incorrect number of records returned');

  // Check if "Ana", "Bruno", and "Clara" are in the list
  FoundAna := False;
  FoundBruno := False;
  FoundClara := False;
  for LTuple in LResults do
  begin
    if LTuple.Get<string>('NOME') = 'Ana' then
      FoundAna := True;
    if LTuple.Get<string>('NOME') = 'Bruno' then
      FoundBruno := True;
    if LTuple.Get<string>('NOME') = 'Clara' then
      FoundClara := True;
  end;

  Assert.IsFalse(FoundAna, 'Record "Ana" found');
  Assert.IsTrue(FoundBruno, 'Record "Bruno" not found');
  Assert.IsTrue(FoundClara, 'Record "Clara" not found');

  // Additional validation to ensure other fields are correct
  LTuple := LResults.First;
  Assert.AreEqual(2, LTuple.Get<Integer>('ID'), 'ID incorrect');
  Assert.AreEqual(30, LTuple.Get<Integer>('IDADE'), 'Idade incorrect');
end;

procedure TTestFluentCQLFirebird.TestSelectSingleFieldInvalidType;
var
  LQueryable: IFluentQueryable<Integer>;
  LResults: IFluentList<Integer>;
begin
  LQueryable := IFluentQueryable<Integer>.CreateForDatabase(
    procedure(var ADatabase: TDBEngineDriver; var AConnection: IDBConnection)
    begin
      ADatabase := TDBEngineDriver.dnFirebird;
      AConnection := FConnection;
    end);

  LQueryable.From('CLIENTES').Where('NOME > ''Ana''').Select('NOME');
  Assert.AreEqual('SELECT NOME FROM CLIENTES WHERE NOME > ''Ana''', LQueryable.AsString, 'SQL generated incorrectly');

  try
    LResults := LQueryable.ToList;
    Assert.Fail('Expected exception for invalid field type');
  except
    on E: Exception do
      Assert.IsTrue(E.Message.Contains('Field ''NOME'' is string, but provider type is Integer'), 'Unexpected exception: ' + E.Message);
  end;
end;

procedure TTestFluentCQLFirebird.TestSelectSingleFieldString;
var
  LQueryable: IFluentQueryable<string>;
  LResults: IFluentList<string>;
  FoundBruno, FoundClara: Boolean;
  LItem: string;
begin
  LQueryable := IFluentQueryable<string>.CreateForDatabase(
    procedure(var ADatabase: TDBEngineDriver; var AConnection: IDBConnection)
    begin
      ADatabase := TDBEngineDriver.dnFirebird;
      AConnection := FConnection;
    end);

  LQueryable.From('CLIENTES').Where('NOME > ''Ana''').Select('NOME');
  Assert.AreEqual('SELECT NOME FROM CLIENTES WHERE NOME > ''Ana''', LQueryable.AsString, 'SQL generated incorrectly');

  LResults := LQueryable.ToList;
  Assert.AreEqual(2, LResults.Count, 'Incorrect number of records returned');

  // Check if 'Bruno' and 'Clara' are in the list
  FoundBruno := False;
  FoundClara := False;
  for LItem in LResults do
  begin
    if LItem = 'Bruno' then
      FoundBruno := True;
    if LItem = 'Clara' then
      FoundClara := True;
  end;

  Assert.IsTrue(FoundBruno, 'Nome ''Bruno'' not found');
  Assert.IsTrue(FoundClara, 'Nome ''Clara'' not found');
end;

procedure TTestFluentCQLFirebird.TestSelectMultipleFieldsInvalidType;
var
  LQueryable: IFluentQueryable<Integer>;
  LResults: IFluentList<Integer>;
begin
  LQueryable := IFluentQueryable<Integer>.CreateForDatabase(
    procedure(var ADatabase: TDBEngineDriver; var AConnection: IDBConnection)
    begin
      ADatabase := TDBEngineDriver.dnFirebird;
      AConnection := FConnection;
    end);

  LQueryable.From('CLIENTES').Where('NOME > ''Ana''').Select('*');
  Assert.AreEqual('SELECT * FROM CLIENTES WHERE NOME > ''Ana''', LQueryable.AsString, 'SQL generated incorrectly');

  try
    LResults := LQueryable.ToList;
    Assert.Fail('Expected exception for multiple fields with invalid provider type');
  except
    on E: Exception do
      Assert.IsTrue(E.Message.Contains('Multiple fields detected (FieldCount > 1). Use TTuple<string> as the provider type'),
        'Unexpected exception: ' + E.Message);
  end;
end;

procedure TTestFluentCQLFirebird.TestJoinSimple;
type
  TCustomer = record
    ID: Integer;
    Nome: string;
  end;

  TOrder = record
    OrderID: Integer;
    CustomerID: Integer;
    OrderDate: TDate;
  end;

  TCustomerOrder = record
    CustomerID: Integer;
    CustomerName: string;
    OrderDate: TDate;
  end;

var
  LQuery: IFluentQueryable<TCustomer>;
  LInnerQuery: IFluentQueryable<TOrder>;
  LResult: IFluentQueryable<TTuple<string>>;
  LOuterKeyExpr, LInnerKeyExpr, LCustomerIdExpr, LCustomerNameExpr, LOrderDateExpr: IFluentQueryExpression;
  LList: IFluentList<TTuple<string>>;
  LItem: TTuple<string>;
begin
  // Inicializar consultas fluentes
  LQuery := IFluentQueryable<TCustomer>.CreateForDatabase(dnFirebird, FConnection);

  LInnerQuery := IFluentQueryable<TOrder>.CreateForDatabase(dnFirebird, FConnection);
  // Configurar a tabela de junção
  LInnerQuery := LInnerQuery.From('PEDIDOS', 'P');

  // Define chaves e colunas para o Join
  LOuterKeyExpr := TQE.New<TCustomer>(dbnFirebird).Field('C.ID');
  LInnerKeyExpr := TQE.New<TOrder>(dbnFirebird).Field('P.ID_CLIENTE');
  LCustomerIdExpr := TQE.New<TTuple<string>>(dbnFirebird).Field('C.ID AS CustomerID');
  LCustomerNameExpr := TQE.New<TTuple<string>>(dbnFirebird).Field('C.NOME AS CustomerName');
  LOrderDateExpr := TQE.New<TTuple<string>>(dbnFirebird).Field('P.DATA AS OrderDate');

  // Consulta com Join usando a nova assinatura
  LResult := LQuery
    .From('CLIENTES', 'C')
    .Join<TOrder, TTuple<string>>(
      LInnerQuery,
      LOuterKeyExpr,
      LInnerKeyExpr,
      [LCustomerIdExpr, LCustomerNameExpr, LOrderDateExpr]);

  // Verificar o SQL gerado
  Assert.AreEqual(
    'SELECT C.ID AS CustomerID, C.NOME AS CustomerName, P.DATA AS OrderDate FROM CLIENTES AS C INNER JOIN PEDIDOS AS P ON C.ID = P.ID_CLIENTE',
    LResult.AsString,
    'SQL gerado incorreto'
  );

  // Validar os resultados
  LList := LResult.ToList;
  for LItem in LList do
  begin
    Assert.IsFalse(LItem['CUSTOMERNAME'].IsEmpty, 'CustomerName deve estar presente e não vazia');
    Assert.IsTrue(LItem['CUSTOMERID'].AsInteger > 0, 'CustomerID deve ser maior que zero');
    Assert.IsTrue(LItem['ORDERDATE'].AsVariant > 0, 'OrderDate deve ser válido');
  end;
end;

procedure TTestFluentCQLFirebird.TestGroupBySimple;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LTempList: IFluentList<TTuple<string>>;
  LGroups: IFluentEnumerable<IGrouping<Integer, TTuple<string>>>;
  LGroup: IGrouping<Integer, TTuple<string>>;
begin
  // Configura a consulta para agrupar pedidos por ID_CLIENTE e contar o total
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('COUNT(*) AS TOTAL, ID_CLIENTE')
    .From('PEDIDOS')
    .GroupBy('ID_CLIENTE');

  // Valida o SQL gerado
  Assert.AreEqual(
    'SELECT COUNT(*) AS TOTAL, ID_CLIENTE FROM PEDIDOS GROUP BY ID_CLIENTE',
    LQuery.AsString,
    'SQL gerado incorreto'
  );

  // Obtém a lista de tuplas
  LTempList := LQuery.ToList;
  Assert.IsTrue(LTempList.Count > 0, 'A consulta não retornou registros. A tabela PEDIDOS está vazia?');

  // Aplica o GroupBy em memória
  LGroups := LTempList
    .AsEnumerable
    .GroupBy<Integer>(function(T: TTuple<string>): Integer
                      begin
                        Result := T.Get<Integer>('ID_CLIENTE');
                      end)
    .AsEnumerable;

  // Valida o número total de grupos
  Assert.AreEqual(3, LGroups.Count, 'Número de grupos incorreto. Esperado: 3 grupos (ID_CLIENTE 1, 2 e 3)');

  // Encontra o grupo com ID_CLIENTE = 1
  LGroup := LGroups.FirstOrDefault(function(G: IGrouping<Integer, TTuple<string>>): Boolean
                                    begin
                                      Result := G.Key = 1;
                                    end);
  Assert.IsNotNull(LGroup, 'Grupo com ID_CLIENTE=1 não encontrado');

  // Valida que o grupo tem exatamente 1 tupla
  Assert.AreEqual(1, LGroup.Items.Count, 'Grupo com ID_CLIENTE=1 deveria ter exatamente 1 tupla');

  // Valida os dados da tupla
  Assert.IsTrue(LGroup.Items.First.Get<Integer>('TOTAL') > 0, 'TOTAL inválido para ID_CLIENTE=1. Esperado: TOTAL > 0');
  Assert.AreEqual(1, LGroup.Items.First.Get<Integer>('ID_CLIENTE'), 'ID_CLIENTE inválido. Esperado: 1');
end;

//procedure TTestFluentCQLFirebird.TestGroupByOrdersByCustomerId;
//var
//  LQuery: IFluentQueryable<TTuple<string>>;
//  LGroups: IFluentList<IGrouping<Integer, TTuple<string>>>;
//  LGroup: IGrouping<Integer, TTuple<string>>;
//  LFirstTuple: TTuple<string>;
//  Total: Integer;
//  IdCliente: Integer;
//begin
//  // Configura a consulta para agrupar pedidos por ID_CLIENTE e contar o total
//  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
//    .Select('COUNT(*) AS TOTAL, ID_CLIENTE')
//    .From('PEDIDOS')
//    .GroupBy('ID_CLIENTE');
//
//  // Valida o SQL gerado
//  Assert.AreEqual(
//    'SELECT COUNT(*) AS TOTAL, ID_CLIENTE FROM PEDIDOS GROUP BY ID_CLIENTE',
//    LQuery.AsString,
//    'SQL gerado incorreto'
//  );
//
//  // Obtém a lista de tuplas e aplica o GroupBy, armazenando os resultados
//  LGroups := LQuery.ToList
//    .AsEnumerable
//    .GroupBy<Integer>(function(T: TTuple<string>): Integer
//                      begin
//                        Result := T.Get<Integer>('ID_CLIENTE');
//                      end)
//    .AsEnumerable.ToList;
//
//  // Valida o número total de grupos
//  Assert.AreEqual(3, LGroups.Count, 'Número de grupos incorreto. Esperado: 3 grupos (ID_CLIENTE 1, 2 e 3)');
//
//  // Valida cada grupo esperado (ID_CLIENTE = 1, 2 e 3)
//  for var ExpectedId in [1, 2, 3] do
//  begin
//    // Encontra o grupo com o ID_CLIENTE esperado
//    LGroup := LGroups.FirstOrDefault(function(G: IGrouping<Integer, TTuple<string>>): Boolean
//                                      begin
//                                        Result := G.Key = ExpectedId;
//                                      end);
//    Assert.IsNotNull(LGroup, Format('Grupo com ID_CLIENTE=%d não encontrado', [ExpectedId]));
//
//    // Valida que o grupo tem exatamente 1 tupla
//    Assert.AreEqual(1, LGroup.Items.Count, Format('Grupo com ID_CLIENTE=%d deveria ter exatamente 1 tupla', [ExpectedId]));
//
//    // Obtém a primeira tupla do grupo
//    LFirstTuple := LGroup.Items.First;
//
//    // Valida que os campos esperados estão presentes
//    Assert.IsTrue(LFirstTuple.TryGet<Integer>('TOTAL', Total), Format('Campo TOTAL não encontrado na tupla para ID_CLIENTE=%d', [ExpectedId]));
//    Assert.IsTrue(LFirstTuple.TryGet<Integer>('ID_CLIENTE', IdCliente), Format('Campo ID_CLIENTE não encontrado na tupla para ID_CLIENTE=%d', [ExpectedId]));
//
//    // Valida os dados da tupla
//    Assert.IsTrue(Total > 0, Format('TOTAL inválido para ID_CLIENTE=%d. Esperado: TOTAL > 0', [ExpectedId]));
//    Assert.AreEqual(ExpectedId, IdCliente, Format('ID_CLIENTE inválido para o grupo com ID_CLIENTE=%d. Esperado: %d', [ExpectedId, ExpectedId]));
//  end;
//end;

procedure TTestFluentCQLFirebird.TestCountWithLambdaExpression;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LCount: Integer;
  LExpr: IFluentQueryExpression;
begin
  // Configura a consulta para contar usuários com Age > 18 e NAME = 'John'
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  // Valida o SQL gerado antes da contagem
  Assert.AreEqual(
    'SELECT ID, NOME, IDADE FROM CLIENTES',
    LQuery.AsString,
    'SQL gerado incorreto antes da contagem'
  );

  // Executa a contagem com a expressão fluida diretamente
  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(25)
              .AndWith('NOME')
              .Equal('Bruno');
  LCount := LQuery.Count(LExpr);

  // Valida o SQL gerado após a contagem
  Assert.AreEqual(
    'SELECT COUNT(*) FROM CLIENTES WHERE (IDADE > 25) AND (NOME = ''Bruno'')',
    LQuery.AsString,
    'SQL gerado incorreto com a condição'
  );

  // Valida o resultado da contagem (deve ser 1, pois há 1 usuários que atendem à condição)
  Assert.AreEqual(1, LCount, 'Contagem incorreta. Esperado: 1 usuários com IDADE > 25 e NOME = ''Bruno''');
end;

procedure TTestFluentCQLFirebird.TestAllWithLambdaExpression;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LResult: Boolean;
  LExpr: IFluentQueryExpression;
begin
  // Configura a consulta para verificar usuários com IDADE > 25 e NOME = 'Bruno'
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  // Valida o SQL gerado antes da verificação
  Assert.AreEqual(
    'SELECT ID, NOME, IDADE FROM CLIENTES',
    LQuery.AsString,
    'SQL gerado incorreto antes da verificação'
  );

  // Cenário 1: Verifica se TODOS os registros têm IDADE > 25 e NOME = 'Bruno' (esperado: False)
  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(25)
              .AndWith('NOME')
              .Equal('Bruno');
  LResult := LQuery.All(LExpr);

  // Valida o SQL gerado após a verificação
  Assert.AreEqual(
    'SELECT COUNT(*) FROM CLIENTES WHERE NOT ((IDADE > 25) AND (NOME = ''Bruno''))',
    LQuery.AsString,
    'SQL gerado incorreto com a condição NOT (IDADE > 25 AND NOME = ''Bruno'')'
  );

  // Valida o resultado (esperado: False, pois nem todos os registros satisfazem)
  Assert.IsFalse(LResult, 'Resultado incorreto. Esperado: False, pois nem todos os registros têm IDADE > 25 e NOME = ''Bruno''');

  // Cenário 2: Verifica se TODOS os registros têm IDADE > 0 (esperado: True)
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(0);
  LResult := LQuery.All(LExpr);

  // Valida o SQL gerado após a verificação
  Assert.AreEqual(
    'SELECT COUNT(*) FROM CLIENTES WHERE NOT ((IDADE > 0))',
    LQuery.AsString,
    'SQL gerado incorreto com a condição NOT ((IDADE > 0))'
  );

  // Valida o resultado (esperado: True, pois todos os registros têm IDADE > 0)
  Assert.IsTrue(LResult, 'Resultado incorreto. Esperado: True, pois todos os registros têm IDADE > 0');
end;

procedure TTestFluentCQLFirebird.TestFirstWithLambdaExpression;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LResult: TTuple<string>;
  LExpr: IFluentQueryExpression;
begin
  // Configura a consulta base
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  // Valida o SQL gerado antes da verificação
  Assert.AreEqual(
    'SELECT ID, NOME, IDADE FROM CLIENTES',
    LQuery.AsString,
    'SQL gerado incorreto antes da verificação'
  );

  // Executa a busca do primeiro registro com a expressão fluida
  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(25)
              .AndWith('NOME')
              .Equal('Bruno');
  LResult := LQuery.First(LExpr);

  // Valida o SQL gerado após a busca
  Assert.AreEqual(
    'SELECT FIRST 1 ID, NOME, IDADE FROM CLIENTES WHERE (IDADE > 25) AND (NOME = ''Bruno'')',
    LQuery.AsString,
    'SQL gerado incorreto com a condição'
  );

  // Valida o resultado (esperado: registro com NOME = 'Bruno' e IDADE > 25)
  Assert.IsTrue(LResult['NOME'].AsString = 'Bruno', 'Resultado incorreto. Esperado: NOME = ''Bruno''');
  Assert.IsTrue(LResult['IDADE'].AsInteger > 25, 'Resultado incorreto. Esperado: IDADE > 25');
end;

procedure TTestFluentCQLFirebird.TestFirstOrDefaultWithLambdaExpression;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LResult: TTuple<string>;
  LExpr: IFluentQueryExpression;
begin
  // Configura a consulta base
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  // Valida o SQL gerado antes da verificação
  Assert.AreEqual(
    'SELECT ID, NOME, IDADE FROM CLIENTES',
    LQuery.AsString,
    'SQL gerado incorreto antes da verificação'
  );

  // Cenário 1: Busca o primeiro registro com IDADE > 25 e NOME = 'Bruno' (esperado: registro válido)
  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(25)
              .AndWith('NOME')
              .Equal('Bruno');
  LResult := LQuery.FirstOrDefault(LExpr);

  // Valida o SQL gerado após a busca
  Assert.AreEqual(
    'SELECT FIRST 1 ID, NOME, IDADE FROM CLIENTES WHERE (IDADE > 25) AND (NOME = ''Bruno'')',
    LQuery.AsString,
    'SQL gerado incorreto com a condição'
  );

  // Valida o resultado (esperado: registro com NOME = 'Bruno' e IDADE > 25)
  Assert.IsNotNull(LResult, 'Resultado incorreto. Esperado: registro não nulo');
  Assert.IsTrue(LResult['NOME'].AsString = 'Bruno', 'Resultado incorreto. Esperado: NOME = ''Bruno''');
  Assert.IsTrue(LResult['IDADE'].AsInteger > 25, 'Resultado incorreto. Esperado: IDADE > 25');

  // Cenário 2: Busca o primeiro registro com IDADE > 100 (esperado: Default(T))
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(100);
  LResult := LQuery.FirstOrDefault(LExpr);

  // Valida o SQL gerado após a busca
  Assert.AreEqual(
    'SELECT FIRST 1 ID, NOME, IDADE FROM CLIENTES WHERE (IDADE > 100)',
    LQuery.AsString,
    'SQL gerado incorreto com a condição IDADE > 100'
  );
end;

procedure TTestFluentCQLFirebird.TestTakeWithLambdaExpression;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LResult: IFluentList<TTuple<string>>;
  LExpr: IFluentQueryExpression;
begin
  // Configura a consulta base
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  // Valida o SQL gerado antes da verificação
  Assert.AreEqual(
    'SELECT ID, NOME, IDADE FROM CLIENTES',
    LQuery.AsString,
    'SQL gerado incorreto antes da verificação'
  );

  // Executa a busca dos primeiros 2 registros com a expressão fluida
  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(20);
  LResult := LQuery.Where(LExpr).Take(2).ToList;

  // Valida o SQL gerado após a busca
  Assert.AreEqual(
    'SELECT FIRST 2 ID, NOME, IDADE FROM CLIENTES WHERE (IDADE > 20)',
    LQuery.AsString,
    'SQL gerado incorreto com a condição'
  );

  // Valida o resultado (esperado: até 2 registros com IDADE > 20)
  Assert.IsTrue(LResult.Count <= 2, 'Resultado incorreto. Esperado: até 2 registros');
  for var LItem in LResult do
    Assert.IsTrue(LItem['IDADE'].AsInteger > 20, 'Resultado incorreto. Esperado: IDADE > 20');
end;

procedure TTestFluentCQLFirebird.TestLastWithLambdaExpression;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LResult: TTuple<string>;
  LExpr: IFluentQueryExpression;
begin
  // Configura a consulta base
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  // Valida o SQL gerado antes da verificação
  Assert.AreEqual(
    'SELECT ID, NOME, IDADE FROM CLIENTES',
    LQuery.AsString,
    'SQL gerado incorreto antes da verificação'
  );

  // Executa a busca do último registro com a expressão fluida
  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(25)
              .AndWith('NOME')
              .Equal('Bruno');
  LResult := LQuery.Last(LExpr);

  // Valida o SQL gerado após a busca
  Assert.AreEqual(
    'SELECT FIRST 1 ID, NOME, IDADE FROM CLIENTES WHERE (IDADE > 25) AND (NOME = ''Bruno'') ORDER BY ID DESC',
    LQuery.AsString,
    'SQL gerado incorreto com a condição'
  );

  // Valida o resultado (esperado: último registro com NOME = 'Bruno' e IDADE > 25)
  Assert.IsTrue(LResult['NOME'].AsString = 'Bruno', 'Resultado incorreto. Esperado: NOME = ''Bruno''');
  Assert.IsTrue(LResult['IDADE'].AsInteger > 25, 'Resultado incorreto. Esperado: IDADE > 25');
end;

procedure TTestFluentCQLFirebird.TestLastOrDefaultWithLambdaExpression;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LResult: TTuple<string>;
  LExpr: IFluentQueryExpression;
begin
  // Configura a consulta base
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  // Valida o SQL gerado antes da verificação
  Assert.AreEqual(
    'SELECT ID, NOME, IDADE FROM CLIENTES',
    LQuery.AsString,
    'SQL gerado incorreto antes da verificação'
  );

  // Cenário 1: Busca o último registro com IDADE > 25 e NOME = 'Bruno'
  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(25)
              .AndWith('NOME')
              .Equal('Bruno');
  LResult := LQuery.LastOrDefault(LExpr);

  // Valida o SQL gerado após a busca
  Assert.AreEqual(
    'SELECT FIRST 1 ID, NOME, IDADE FROM CLIENTES WHERE (IDADE > 25) AND (NOME = ''Bruno'') ORDER BY ID DESC',
    LQuery.AsString,
    'SQL gerado incorreto com a condição'
  );

  // Valida o resultado (esperado: registro com NOME = 'Bruno' e IDADE > 25)
  Assert.IsNotNull(LResult, 'Resultado incorreto. Esperado: registro não nulo');
  Assert.IsTrue(LResult['NOME'].AsString = 'Bruno', 'Resultado incorreto. Esperado: NOME = ''Bruno''');
  Assert.IsTrue(LResult['IDADE'].AsInteger > 25, 'Resultado incorreto. Esperado: IDADE > 25');

  // Cenário 2: Busca o último registro com IDADE > 100
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(100);
  LResult := LQuery.LastOrDefault(LExpr);

  // Valida o SQL gerado após a busca
  Assert.AreEqual(
    'SELECT FIRST 1 ID, NOME, IDADE FROM CLIENTES WHERE (IDADE > 100) ORDER BY ID DESC',
    LQuery.AsString,
    'SQL gerado incorreto com a condição IDADE > 100'
  );
end;

procedure TTestFluentCQLFirebird.TestSingleWithLambdaExpression;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LResult: TTuple<string>;
  LExpr: IFluentQueryExpression;
begin
  // Cenário 1: Busca o único registro com IDADE > 25 e NOME = 'Bruno'
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(25)
              .AndWith('NOME')
              .Equal('Bruno');
  LResult := LQuery.Single(LExpr);

  // Valida o SQL gerado após a busca
  Assert.AreEqual(
    'SELECT FIRST 1 ID, NOME, IDADE FROM CLIENTES WHERE (IDADE > 25) AND (NOME = ''Bruno'')',
    LQuery.AsString,
    'SQL gerado incorreto com a condição'
  );

  // Valida o resultado
  Assert.IsTrue(LResult['NOME'].AsString = 'Bruno', 'Resultado incorreto. Esperado: NOME = ''Bruno''');
  Assert.IsTrue(LResult['IDADE'].AsInteger > 25, 'Resultado incorreto. Esperado: IDADE > 25');

  // Cenário 2: Busca com condição que retorna múltiplos registros (esperado: exceção)
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(20);
  Assert.WillRaise(
    procedure
    begin
      LQuery.Single(LExpr);
    end,
    EInvalidOperation,
    'Esperado: exceção para múltiplos registros com IDADE > 20'
  );

  // Cenário 3: Busca com condição que retorna zero registros (esperado: exceção)
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(100);
  Assert.WillRaise(
    procedure
    begin
      LQuery.Single(LExpr);
    end,
    EInvalidOperation,
    'Esperado: exceção para nenhum registro com IDADE > 100'
  );
end;

procedure TTestFluentCQLFirebird.TestLongCountWithLambdaExpression;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LCount: Int64;
  LExpr: IFluentQueryExpression;
begin
  // Cenário 1: Conta registros com IDADE > 25 e NOME = 'Bruno'
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  // Valida o SQL gerado antes da contagem
  Assert.AreEqual(
    'SELECT ID, NOME, IDADE FROM CLIENTES',
    LQuery.AsString,
    'SQL gerado incorreto antes da contagem'
  );

  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(25)
              .AndWith('NOME')
              .Equal('Bruno');
  LCount := LQuery.LongCount(LExpr);

  // Valida o SQL gerado após a contagem
  Assert.AreEqual(
    'SELECT ID, NOME, IDADE FROM CLIENTES WHERE (IDADE > 25) AND (NOME = ''Bruno'')',
    LQuery.AsString,
    'SQL gerado incorreto após a contagem'
  );

  // Valida o resultado (esperado: 1, conforme TestCountWithLambdaExpression)
  Assert.AreEqual(Int64(1), LCount, 'Contagem incorreta. Esperado: 1 registro com IDADE > 25 e NOME = ''Bruno''');

  // Cenário 2: Conta registros com IDADE > 100 (esperado: 0)
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE')
    .From('CLIENTES');

  LExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird)
              .Field('IDADE')
              .GreaterThan(100);
  LCount := LQuery.LongCount(LExpr);

  // Valida o SQL gerado após a contagem
  Assert.AreEqual(
    'SELECT ID, NOME, IDADE FROM CLIENTES WHERE (IDADE > 100)',
    LQuery.AsString,
    'SQL gerado incorreto após a contagem'
  );

  // Valida o resultado
  Assert.AreEqual(Int64(0), LCount, 'Contagem incorreta. Esperado: 0 registros com IDADE > 100');
end;

procedure TTestFluentCQLFirebird.TestGroupByWithSelect;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LResult: IFluentList<IGrouping<Integer, TTuple<string>>>;
  LKeyExpr, LCountExpr: IFluentQueryExpression;
  LGroup: IGrouping<Integer, TTuple<string>>;
  LItem: TTuple<string>;
begin
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('IDADE, COUNT(*) AS CNT').From('CLIENTES');

  LKeyExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird).Field('IDADE');
  LCountExpr := TQE.New<TTuple<string>>(TFluentSQLDriver.dbnFirebird).Field('CNT');
  LResult := LQuery.GroupBy<Integer>(LKeyExpr).ToList;

  Assert.AreEqual('SELECT IDADE, COUNT(*) AS CNT FROM CLIENTES GROUP BY IDADE', LQuery.AsString);
  for LGroup in LResult do
    for LItem in LGroup.Items do
      Assert.IsTrue(LItem['CNT'].AsInteger >= 0, 'Contagem CNT deve ser não-negativa');
end;

procedure TTestFluentCQLFirebird.TestOrderByDescWithTQE;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LResult: IFluentList<TTuple<string>>;
  LExpr: IFluentQueryExpression;
begin
  // Configura a consulta
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE').From('CLIENTES');

  // Aplica OrderByDesc
  LExpr := TQE.New<TTuple<string>>(dbnFirebird).Field('NOME');
  LResult := LQuery.OrderByDesc(LExpr).ToList;

  // Valida o SQL gerado
  Assert.AreEqual('SELECT ID, NOME, IDADE FROM CLIENTES ORDER BY NOME DESC', LQuery.AsString);

  // Valida que os resultados estão ordenados por NOME em ordem decrescente
  for var I := 1 to LResult.Count - 1 do
    Assert.IsTrue(LResult[I-1]['NOME'].AsString >= LResult[I]['NOME'].AsString, 'Resultados não ordenados por NOME DESC');
end;

procedure TTestFluentCQLFirebird.TestThenByWithTQE;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LResult: IFluentList<TTuple<string>>;
  LNameExpr, LAgeExpr: IFluentQueryExpression;
begin
  // Configura a consulta
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE').From('CLIENTES');

  // Aplica OrderByDesc seguido de ThenBy
  LNameExpr := TQE.New<TTuple<string>>(dbnFirebird).Field('NOME');
  LAgeExpr := TQE.New<TTuple<string>>(dbnFirebird).Field('IDADE');
  LResult := LQuery.OrderByDesc(LNameExpr).ThenBy(LAgeExpr).ToList;

  // Valida o SQL gerado
  Assert.AreEqual('SELECT ID, NOME, IDADE FROM CLIENTES ORDER BY NOME DESC, IDADE ASC', LQuery.AsString);

  // Valida que os resultados estão ordenados por NOME DESC e IDADE ASC
  for var I := 1 to LResult.Count - 1 do
  begin
    if LResult[I-1]['NOME'].AsString = LResult[I]['NOME'].AsString then
      Assert.IsTrue(LResult[I-1]['IDADE'].AsInteger <= LResult[I]['IDADE'].AsInteger,
        'IDADE não ordenada em ordem crescente para mesmo NOME')
    else
      Assert.IsTrue(LResult[I-1]['NOME'].AsString > LResult[I]['NOME'].AsString,
        'NOME não ordenado em ordem decrescente');
  end;
end;

procedure TTestFluentCQLFirebird.TestThenByDescendingWithTQE;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LResult: IFluentList<TTuple<string>>;
  LNameExpr, LAgeExpr: IFluentQueryExpression;
begin
  // Configura a consulta
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .Select('ID, NOME, IDADE').From('CLIENTES');

  // Aplica OrderByDesc seguido de ThenByDescending
  LNameExpr := TQE.New<TTuple<string>>(dbnFirebird).Field('NOME');
  LAgeExpr := TQE.New<TTuple<string>>(dbnFirebird).Field('IDADE');
  LResult := LQuery.OrderByDesc(LNameExpr).ThenByDescending(LAgeExpr).ToList;

  // Valida o SQL gerado
  Assert.AreEqual('SELECT ID, NOME, IDADE FROM CLIENTES ORDER BY NOME DESC, IDADE DESC', LQuery.AsString);

  // Valida que os resultados estão ordenados por NOME DESC e IDADE DESC
  for var I := 1 to LResult.Count - 1 do
  begin
    if LResult[I-1]['NOME'].AsString = LResult[I]['NOME'].AsString then
      Assert.IsTrue(LResult[I-1]['IDADE'].AsInteger >= LResult[I]['IDADE'].AsInteger,
        'IDADE não ordenada em ordem decrescente para mesmo NOME')
    else
      Assert.IsTrue(LResult[I-1]['NOME'].AsString > LResult[I]['NOME'].AsString,
        'NOME não ordenado em ordem decrescente');
  end;
end;

procedure TTestFluentCQLFirebird.TestSelectWithTQE;
var
  LQuery: IFluentQueryable<TTuple<string>>;
  LResult: IFluentList<TTuple<string>>;
  LNameExpr, LAgeExpr: IFluentQueryExpression;
begin
  // Configura a consulta
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .From('CLIENTES');

  // Aplica Select com múltiplas colunas
  LNameExpr := TQE.New<TTuple<string>>(dbnFirebird).Field('NOME');
  LAgeExpr := TQE.New<TTuple<string>>(dbnFirebird).Field('IDADE');
  LResult := LQuery.Select([LNameExpr, LAgeExpr]).ToList;

  // Valida o SQL gerado
  Assert.AreEqual('SELECT NOME, IDADE FROM CLIENTES', LQuery.AsString);

  // Valida que os resultados contêm as colunas NOME e IDADE
  for var LItem in LResult do
  begin
    Assert.IsFalse(LItem['NOME'].IsEmpty, 'Coluna NOME deve estar presente e não vazia');
    Assert.IsTrue(LItem['IDADE'].AsInteger > 0, 'Coluna IDADE deve ser maior que zero');
  end;
end;

procedure TTestFluentCQLFirebird.TestMinFirebird;
type
  TCustomer = record
    ID: Integer;
    Nome: string;
    Idade: Integer;
  end;

var
  LQuery: IFluentQueryable<TCustomer>;
  LMinAge: Integer;
begin
  // Inicializar consulta fluente
  LQuery := IFluentQueryable<TCustomer>.CreateForDatabase(dnFirebird, FConnection)
    .From('CLIENTES').Select('ID, NOME, IDADE');

  // Teste 1: Min com um único campo (IDADE)
  LMinAge := LQuery.Min<Integer>('IDADE', 'MinValue');

  Assert.AreEqual('SELECT MIN(IDADE) AS MinValue FROM CLIENTES', LQuery.AsString);
  Assert.IsTrue(LMinAge > 0, 'MinValue deve ser maior que zero');

  // Teste 2: Min com campo vazio
  try
    LQuery.Min<Integer>('');
    Assert.Fail('Deveria ter lançado exceção para campo vazio');
  except
    on E: EInvalidOperation do
      Assert.AreEqual('Field name cannot be empty', E.Message);
  end;

  // Teste 3: Min com campo inexistente
  try
    LQuery.Min<Integer>('CAMPO_INEXISTENTE');
    Assert.Fail('Deveria ter lançado exceção para campo inexistente');
  except
    on E: Exception do
      Assert.IsTrue(E.Message <> '', E.Message);
  end;
end;

procedure TTestFluentCQLFirebird.TestMinByFirebird;
type
  TCustomer = record
    ID: Integer;
    Nome: string;
    Idade: Integer;
  end;

var
  LQuery: IFluentQueryable<TTuple<string>>;
  LYoungestCustomer: TTuple<string>;
begin
  // Inicializar consulta fluente
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .From('CLIENTES').Select('ID, NOME, IDADE');

  // Teste 1: MinBy com campo IDADE
  LYoungestCustomer := LQuery.MinBy('IDADE');

  Assert.AreEqual('SELECT FIRST 1 ID, NOME, IDADE FROM CLIENTES ORDER BY IDADE ASC', LQuery.AsString);
  Assert.AreEqual('1', LYoungestCustomer['ID'].AsInteger.ToString, 'ID deve ser 1');
  Assert.AreEqual('Ana', LYoungestCustomer['NOME'].AsString, 'Nome deve ser Ana');
  Assert.AreEqual('25', LYoungestCustomer['IDADE'].AsExtended.ToString, 'Idade deve ser 25');

  // Teste 2: MinBy com campo vazio
  try
    LQuery.MinBy('');
    Assert.Fail('Deveria ter lançado exceção para campo vazio');
  except
    on E: EInvalidOperation do
      Assert.AreEqual('Field name cannot be empty', E.Message);
  end;

  // Teste 3: MinBy com campo inexistente
  try
    LQuery.MinBy('CAMPO_INEXISTENTE');
    Assert.Fail('Deveria ter lançado exceção para campo inexistente');
  except
    on E: EInvalidOperation do
      Assert.AreEqual('Column "CAMPO_INEXISTENTE" not found in the query.', E.Message);
  end;

  // Teste 4: MinBy com campo existente no banco, mas não no SELECT
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .From('CLIENTES').Select('ID, NOME');
  try
    LQuery.MinBy('IDADE');
    Assert.Fail('Deveria ter lançado exceção para campo não incluído no SELECT');
  except
    on E: EInvalidOperation do
      Assert.AreEqual('Column "IDADE" not found in the query.', E.Message);
  end;
end;

procedure TTestFluentCQLFirebird.TestSumFirebird;
type
  TCustomer = record
    ID: Integer;
    Nome: string;
    Idade: Integer;
  end;

var
  LQuery: IFluentQueryable<TTuple<string>>;
  LTotalAgeInt: Integer;
  LTotalAgeDouble: Double;
begin
  // Inicializar consulta fluente
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .From('CLIENTES').Select('ID, NOME, IDADE');

  // Teste 1: Sum com campo IDADE (Integer)
  LTotalAgeInt := LQuery.Sum<Integer>('IDADE', 'SumValue');
  Assert.AreEqual('SELECT SUM(IDADE) AS SumValue FROM CLIENTES', LQuery.AsString);
  Assert.AreEqual(83, LTotalAgeInt, 'TotalAge deve ser 83');

  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .From('CLIENTES').Select('ID, NOME, IDADE');

  // Teste 2: Sum com campo IDADE (Double)
  LTotalAgeDouble := LQuery.Sum<Double>('IDADE', 'SumValue');
  Assert.AreEqual('SELECT SUM(IDADE) AS SumValue FROM CLIENTES', LQuery.AsString);
  Assert.AreEqual(83.0, LTotalAgeDouble, 0.0001, 'TotalAgeDouble deve ser 83.0');

  // Teste 3: Sum com campo vazio
  try
    LQuery.Sum<Integer>('');
    Assert.Fail('Deveria ter lançado exceção para campo vazio');
  except
    on E: EInvalidOperation do
      Assert.AreEqual('Field name cannot be empty', E.Message);
  end;

  // Teste 4: Sum com campo inexistente
  try
    LQuery.Sum<Integer>('CAMPO_INEXISTENTE');
    Assert.Fail('Deveria ter lançado exceção para campo inexistente');
  except
    on E: EInvalidOperation do
      Assert.AreEqual('Column "CAMPO_INEXISTENTE" not found in the query.', E.Message);
  end;

  // Teste 5: Sum com campo existente no banco, mas não no SELECT
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .From('CLIENTES').Select('ID, NOME');
  try
    LQuery.Sum<Integer>('IDADE');
    Assert.Fail('Deveria ter lançado exceção para campo não incluído no SELECT');
  except
    on E: EInvalidOperation do
      Assert.AreEqual('Column "IDADE" not found in the query.', E.Message);
  end;

  // Teste 6: Sum com tipo inválido
  try
    LQuery.Sum<TTuple<string>>('IDADE');
    Assert.Fail('Deveria ter lançado exceção para tipo inválido');
  except
    on E: EInvalidOperation do
      Assert.Contains('Invalid result type "TTuple<System.string>" for Sum. Expected Integer, Int64, or Float.', E.Message);
  end;
end;

procedure TTestFluentCQLFirebird.TestAverageFirebird;
type
  TCustomer = record
    ID: Integer;
    Nome: string;
    Idade: Integer;
  end;

var
  LQuery: IFluentQueryable<TTuple<string>>;
  LAvgAgeDouble: Double;
  LAvgAgeInt: Integer;
begin
  // Inicializar consulta fluente
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .From('CLIENTES').Select('ID, NOME, IDADE');

  // Teste 1: Average com campo IDADE (Double)
  LAvgAgeDouble := LQuery.Average<Double>('IDADE', 'AvgValue');
  Assert.AreEqual('SELECT AVG(IDADE) AS AvgValue FROM CLIENTES', LQuery.AsString);
  Assert.AreEqual(27, LAvgAgeDouble, 0.0001, 'AvgAge deve ser aproximadamente 27.666...');

  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .From('CLIENTES').Select('ID, NOME, IDADE');

  // Teste 2: Average com campo IDADE (Integer)
  LAvgAgeInt := LQuery.Average<Integer>('IDADE', 'AvgValue');
  Assert.AreEqual('SELECT AVG(IDADE) AS AvgValue FROM CLIENTES', LQuery.AsString);
  Assert.AreEqual(27, LAvgAgeInt, 'AvgAge deve ser arredondado para 28');

  // Teste 3: Average com campo vazio
  try
    LQuery.Average<Double>('', 'AvgValue');
    Assert.Fail('Deveria ter lançado exceção para campo vazio');
  except
    on E: EInvalidOperation do
      Assert.AreEqual('Field name cannot be empty', E.Message);
  end;

  // Teste 4: Average com campo inexistente
  try
    LQuery.Average<Double>('CAMPO_INEXISTENTE', 'AvgValue');
    Assert.Fail('Deveria ter lançado exceção para campo inexistente');
  except
    on E: EInvalidOperation do
      Assert.AreEqual('Column "CAMPO_INEXISTENTE" not found in the query.', E.Message);
  end;

  // Teste 5: Average com campo existente no banco, mas não no SELECT
  LQuery := IFluentQueryable<TTuple<string>>.CreateForDatabase(dnFirebird, FConnection)
    .From('CLIENTES').Select('ID, NOME');
  try
    LQuery.Average<Double>('IDADE', 'AvgValue');
    Assert.Fail('Deveria ter lançado exceção para campo não incluído no SELECT');
  except
    on E: EInvalidOperation do
      Assert.AreEqual('Column "IDADE" not found in the query.', E.Message);
  end;

  // Teste 6: Average com tipo inválido
  try
    LQuery.Average<TTuple<string>>('IDADE', 'AvgValue');
    Assert.Fail('Deveria ter lançado exceção para tipo inválido');
  except
    on E: EInvalidOperation do
      Assert.Contains('Invalid result type "TTuple<System.string>" for Average. Expected Integer, Int64, or Float.', E.Message);
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TTestFluentCQLFirebird);

end.
