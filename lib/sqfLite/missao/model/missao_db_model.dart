class FotoRelatorioTable {
  static const String tableName = 'foto_relatorio';

  static const String columnId = 'id';
  static const String columnUid = 'uid';
  static const String columnMissaoId = 'missaoId';
  static const String columnImageBase64 = 'image';
  static const String columnCaption = 'caption';
  static const String columnTimestamp = 'timestamp';

  static String createTableQuery() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnUid TEXT NOT NULL,
        $columnMissaoId TEXT NOT NULL,
        $columnImageBase64 TEXT NOT NULL,
        $columnCaption TEXT,
        $columnTimestamp TEXT NOT NULL
      )
    ''';
  }
}

class RelatorioTable {
  static const String tableName = 'relatorio_missao';

  static const String columnId = 'id';
  static const String columnUid = 'uid';
  static const String columnMissaoId = 'missaoId';
  static const String columnCnpj = 'cnpj';
  static const String columnNomeDaEmpresa = 'nomeDaEmpresa';
  static const String columnPlacaCavalo = 'placaCavalo';
  static const String columnPlacaCarreta = 'placaCarreta';
  static const String columnMotorista = 'motorista';
  static const String columnCorVeiculo = 'corVeiculo';
  static const String columnObservacao = 'observacao';
  static const String columnNome = 'nome';
  static const String columnTipo = 'tipo';
  static const String columnInfos = 'infos';
  static const String columnUserInitialLatitude = 'userInitialLatitude';
  static const String columnUserInitialLongitude = 'userInitialLongitude';
  static const String columnUserFinalLatitude = 'userFinalLatitude';
  static const String columnUserFinalLongitude = 'userFinalLongitude';
  static const String columnMissaoLatitude = 'missaoLatitude';
  static const String columnMissaoLongitude = 'missaoLongitude';
  static const String columnLocal = 'local';
  static const String columnFinalizador = 'finalizador';
  static const String columnFim = 'fim';

  static String createTableQuery() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnUid TEXT NOT NULL,
        $columnMissaoId TEXT NOT NULL,
        $columnCnpj TEXT NOT NULL,
        $columnNomeDaEmpresa TEXT NOT NULL,
        $columnPlacaCavalo TEXT NOT NULL,
        $columnPlacaCarreta TEXT,
        $columnMotorista TEXT NOT NULL,
        $columnCorVeiculo TEXT,
        $columnObservacao TEXT,
        $columnNome TEXT NOT NULL,
        $columnTipo TEXT NOT NULL,
        $columnInfos TEXT,
        $columnUserInitialLatitude TEXT NOT NULL,
        $columnUserInitialLongitude TEXT NOT NULL,
        $columnUserFinalLatitude TEXT NOT NULL,
        $columnUserFinalLongitude TEXT NOT NULL,
        $columnMissaoLatitude TEXT NOT NULL,
        $columnMissaoLongitude TEXT NOT NULL,
        $columnLocal TEXT NOT NULL,
        $columnFinalizador TEXT NOT NULL,
        $columnFim TEXT
      )
    ''';
  }
}

class MissaoFinalizadaTable {
  static const String tableName = 'missao_finalizada';

  static const String columnId = 'id';
  static const String columnUid = 'uid';
  static const String columnMissaoId = 'missaoId';
  static const String columnCnpj = 'cnpj';
  static const String columnNomeDaEmpresa = 'nomeDaEmpresa';
  static const String columnPlacaCavalo = 'placaCavalo';
  static const String columnPlacaCarreta = 'placaCarreta';
  static const String columnMotorista = 'motorista';
  static const String columnCorVeiculo = 'corVeiculo';
  static const String columnObservacao = 'observacao';
  static const String columnTipo = 'tipo';
  static const String columnUserLatitude = 'userLatitude';
  static const String columnUserLongitude = 'userLongitude';
  static const String columnUserFinalLatitude = 'userFinalLatitude';
  static const String columnUserFinalLongitude = 'userFinalLongitude';
  static const String columnMissaoLatitude = 'missaoLatitude';
  static const String columnMissaoLongitude = 'missaoLongitude';
  static const String columnLocal = 'local';
  static const String columnFim = 'fim';

  static String createTableQuery() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnUid TEXT NOT NULL,
        $columnMissaoId TEXT NOT NULL,
        $columnCnpj TEXT NOT NULL,
        $columnNomeDaEmpresa TEXT NOT NULL,
        $columnPlacaCavalo TEXT NOT NULL,
        $columnPlacaCarreta TEXT,
        $columnMotorista TEXT NOT NULL,
        $columnCorVeiculo TEXT,
        $columnObservacao TEXT,
        $columnTipo TEXT NOT NULL,
        $columnUserLatitude TEXT NOT NULL,
        $columnUserLongitude TEXT NOT NULL,
        $columnUserFinalLatitude TEXT NOT NULL,
        $columnUserFinalLongitude TEXT NOT NULL,
        $columnMissaoLatitude TEXT NOT NULL,
        $columnMissaoLongitude TEXT NOT NULL,
        $columnLocal TEXT NOT NULL,
        $columnFim TEXT NOT NULL
      )
    ''';
  }
}

class IncrementoRelatorioTable {
  static const String tableName = 'incremento_relatorio';

  static const String columnId = 'id';
  static const String columnUid = 'uid';
  static const String columnMissaoId = 'missaoId';
  static const String columnInfos = 'infos';

  static String createTableQuery() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUid TEXT NOT NULL,
        $columnMissaoId TEXT NOT NULL,
        $columnInfos TEXT
      )
    ''';
  }
}

class FotosIncrementoTable {
  static const String tableName = 'fotos_incremento';

  static const String columnId = 'id';
  static const String columnIncrementoRelatorioId = 'incrementoRelatorioId';
  static const String columnCaption = 'caption';
  static const String columnFilePath = 'filePath';
  static const String columnTimestamp = 'timestamp';

  static String createTableQuery() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnIncrementoRelatorioId INTEGER NOT NULL,
        $columnCaption TEXT,
        $columnFilePath TEXT NOT NULL,
        $columnTimestamp TEXT NOT NULL,
        FOREIGN KEY ($columnIncrementoRelatorioId) REFERENCES ${IncrementoRelatorioTable.tableName}(${IncrementoRelatorioTable.columnId})
      )
    ''';
  }
}

class FinalLocalTable {
  static const String tableName = 'final_local';

  static const String columnId = 'id';
  static const String columnUid = 'uid';
  static const String columnMissaoId = 'missaoId';
  static const String columnLatitude = 'latitude';
  static const String columnLongitude = 'longitude';

  static String createTableQuery() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnUid TEXT NOT NULL,
        $columnMissaoId TEXT NOT NULL,
        $columnLatitude TEXT NOT NULL,
        $columnLongitude TEXT NOT NULL
      )
    ''';
  }
}

class MissaoIniciadaTable {
  static const String tableName = 'missao_iniciada';

  static const String columnId = 'id';
  static const String columnUid = 'uid';
  static const String columnMissaoId = 'missaoId';
  static const String columnMissaoLatitude = 'missaoLatitude';
  static const String columnMissaoLongitude = 'missaoLongitude';
  static const String columnLocal = 'local';
  static const String columnPlacaCavalo = 'placaCavalo';
  static const String columnPlacaCarreta = 'placaCarreta';
  static const String columnMotorista = 'motorista';
  static const String columnCorVeiculo = 'corVeiculo';
  static const String columnTipo = 'tipo';

  static String createTableQuery() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnUid TEXT NOT NULL,
        $columnMissaoId TEXT NOT NULL,
        $columnMissaoLatitude REAL NOT NULL,
        $columnMissaoLongitude REAL NOT NULL,
        $columnLocal TEXT NOT NULL,
        $columnPlacaCavalo TEXT,
        $columnPlacaCarreta TEXT,
        $columnMotorista TEXT,
        $columnCorVeiculo TEXT,
        $columnTipo TEXT
      )
    ''';
  }
}

class ChatMissaoTable {
  static const String tableName = 'chat_missao';

  static const String columnId = 'id';
  static const String columnUserUid = 'userUid';
  static const String columnMensagem = 'Mensagem';
  static const String columnImagem = 'Imagem';
  static const String columnTimestamp = 'Timestamp';
  static const String columnMissaoId = 'missaoId';
  static const String columnAutor = 'Autor';
  static const String columnFotoUrl = 'FotoUrl';

  static String createTableQuery() {
    return '''
      CREATE TABLE $tableName (
        $columnId INTEGER PRIMARY KEY,
        $columnUserUid TEXT NOT NULL,
        $columnMensagem TEXT NULL,
        $columnImagem TEXT,
        $columnTimestamp TEXT NOT NULL,
        $columnMissaoId TEXT NOT NULL,
        $columnAutor TEXT NOT NULL,
        $columnFotoUrl TEXT
      )
    ''';
  }
}