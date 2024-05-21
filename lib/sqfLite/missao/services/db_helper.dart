import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/missao_db_model.dart';

class MissionDatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 2;

  // tornar esta classe singleton
  MissionDatabaseHelper._privateConstructor();
  static final MissionDatabaseHelper instance =
      MissionDatabaseHelper._privateConstructor();

  // tem apenas uma referência ao banco de dados
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    // instancia o db na primeira vez que é acessado
    _database = await _initDatabase();
    return _database!;
  }

  // abre o banco de dados e cria a tabela se ela não existir
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // Código SQL para criar a tabela
  Future _onCreate(Database db, int version) async {
    await db.execute(FotoRelatorioTable.createTableQuery());
    await db.execute(RelatorioTable.createTableQuery());
    await db.execute(MissaoFinalizadaTable.createTableQuery());
    await db.execute(IncrementoRelatorioTable.createTableQuery());
    await db.execute(FinalLocalTable.createTableQuery());
    await db.execute(MissaoIniciadaTable.createTableQuery());
    await db.execute(FotosIncrementoTable.createTableQuery());
    await db.execute(ChatMissaoTable.createTableQuery());
  }

  static Future<void> listAllTablesAndColumns(Database db) async {
    debugPrint('Listando todas as tabelas e colunas do banco de dados');
    // Primeiro, obter todas as tabelas
    List<Map> tables =
        await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");

    // Iterar sobre cada tabela e listar suas colunas
    for (var table in tables) {
      String tableName = table['name'];
      debugPrint('Tabela: $tableName');

      // Obter informações das colunas
      List<Map> columns = await db.rawQuery("PRAGMA table_info($tableName)");
      for (var column in columns) {
        debugPrint('  Coluna: ${column['name']} - Tipo: ${column['type']}');
      }
    }
  }

  Future<bool> verificarMissaoIniciada() async {
    Database db = await instance.database;

    // Consulta para contar o número de linhas na tabela
    List<Map<String, dynamic>> result = await db.query(
      MissaoIniciadaTable.tableName,
      columns: ['COUNT(*)'], // Contar o número de linhas
    );

    // Verificar se a tabela está preenchida
    int count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  Future<Map<String, dynamic>> buscarValoresMissaoIniciada() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> results =
        await db.query(MissaoIniciadaTable.tableName);
    //mapa com os valores da missão iniciada
    Map<String, dynamic> missionDetails = results.first;
    //retornar o mapa com os valores da missão iniciada nomeando cada valor
    return missionDetails;
  }
}
