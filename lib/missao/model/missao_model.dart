import 'package:cloud_firestore/cloud_firestore.dart';

class Missao {
  final String cnpj;
  final String nomeDaEmpresa;
  final String? placaCavalo;
  final String? placaCarreta;
  final String? motorista;
  final String? corVeiculo;
  final String? observacao;
  final String tipo;
  final String missaoId;
  final String uid;
  final double userLatitude;
  final double userLongitude;
  final double? userFinalLatitude;
  final double? userFinalLongitude;
  final double missaoLatitude;
  final double missaoLongitude;
  final String local;
  final Timestamp? inicio;
  final Timestamp? fim;

  Missao({
    required this.cnpj,
    required this.nomeDaEmpresa,
    this.placaCavalo,
    this.placaCarreta,
    this.motorista,
    this.corVeiculo,
    this.observacao,
    required this.tipo,
    required this.missaoId,
    required this.uid,
    required this.userLatitude,
    required this.userLongitude,
    this.userFinalLatitude,
    this.userFinalLongitude,
    required this.missaoLatitude,
    required this.missaoLongitude,
    required this.local,
    this.inicio,
    this.fim,
  });

  // Método para converter os dados do documento Firestore em um objeto Missao
  factory Missao.fromFirestore(Map<String, dynamic> data) {
    return Missao(
      cnpj: data['cnpj'],
      nomeDaEmpresa: data['nome da empresa'],
      placaCavalo: data['placaCavalo'],
      placaCarreta: data['placaCarreta'],
      motorista: data['motorista'],
      corVeiculo: data['corVeiculo'],
      observacao: data['observacao'],
      tipo: data['tipo de missao'],
      missaoId: data['missaoID'],
      uid: data['userUid'],
      userLatitude: data['userLatitude'],
      userLongitude: data['userLongitude'],
      userFinalLatitude: data['userFinalLatitude'],
      userFinalLongitude: data['userFinalLongitude'],
      missaoLatitude: data['missaoLatitude'],
      missaoLongitude: data['missaoLongitude'],
      local: data['local'],
      inicio: data['inicio'],
      fim: data['fim'],
    );
  }
}

class MissaoConcluida {
  final bool relatorio;
  final String missaoID;

  MissaoConcluida({
    required this.relatorio,
    required this.missaoID,
  });

  // Factory constructor para criar um objeto MissaoConcluida a partir de um Map
  factory MissaoConcluida.fromFirestore(Map<String, dynamic> data, String uid) {
    return MissaoConcluida(
      relatorio: data['relatorio'],
      missaoID: data['missaoID'],
    );
  }
}

class MissaoRelatorio {
  final String cnpj;
  final String nomeDaEmpresa;
  final String? placaCavalo;
  final String? placaCarreta;
  final String? motorista;
  final String? corVeiculo;
  final String? observacao;
  final String tipo;
  final String missaoId;
  final String uid;
  final double userLatitude;
  final double userLongitude;
  final double? userFinalLatitude;
  final double? userFinalLongitude;
  final double missaoLatitude;
  final double missaoLongitude;
  final String? local;
  final Timestamp? inicio;
  final Timestamp? fim;
  // Novos campos
  final List<Foto>? fotos;
  final List<Foto>? fotosPosMissao;
  final String? infos;
  final String? nome;
  final Timestamp? serverFim;
  final String? infosComplementares;
  final String? odometroInicial;
  final String? odometroFinal;

  MissaoRelatorio(
      {required this.cnpj,
      required this.nomeDaEmpresa,
      this.placaCavalo,
      this.placaCarreta,
      this.motorista,
      this.corVeiculo,
      this.observacao,
      required this.tipo,
      required this.missaoId,
      required this.uid,
      required this.userLatitude,
      required this.userLongitude,
      this.userFinalLatitude,
      this.userFinalLongitude,
      required this.missaoLatitude,
      required this.missaoLongitude,
      this.local,
      this.inicio,
      this.fim,
      // Inicialização dos novos campos
      this.fotos,
      this.fotosPosMissao,
      this.infos,
      this.nome,
      this.serverFim,
      this.infosComplementares,
      this.odometroInicial,
      this.odometroFinal});

  factory MissaoRelatorio.fromFirestore(Map<String, dynamic> data) {
    // Mapeamento de 'fotos'
    List<Foto>? fotos = data['fotos'] != null
        ? List.from(data['fotos']).map((e) => Foto.fromMap(e)).toList()
        : null; // Ou atribua uma lista vazia se preferir: []
    // Mapeamento de 'fotosPosMissao'
    List<Foto>? fotosPosMissao = data['fotosPosMissao'] != null
        ? List.from(data['fotosPosMissao']).map((e) => Foto.fromMap(e)).toList()
        : null; // Ou atribua uma lista vazia se preferir: []

    return MissaoRelatorio(
        cnpj: data['cnpj'],
        nomeDaEmpresa: data['nome da empresa'],
        placaCavalo: data['placaCavalo'],
        placaCarreta: data['placaCarreta'],
        motorista: data['motorista'],
        corVeiculo: data['corVeiculo'],
        observacao: data['observacao'],
        tipo: data['tipo'],
        missaoId: data['missaoId'],
        uid: data['uid'],
        userLatitude: data['userInitialLatitude'],
        userLongitude: data['userInitialLongitude'],
        userFinalLatitude: data['userFinalLatitude'],
        userFinalLongitude: data['userFinalLongitude'],
        missaoLatitude: data['missaoLatitude'],
        missaoLongitude: data['missaoLongitude'],
        local: data['local'],
        inicio: data['inicio'],
        fim: data['fim'],
        fotos: fotos,
        fotosPosMissao: fotosPosMissao,
        infos: data['infos'],
        nome: data['nome'] ?? '', // Valor padrão vazio
        serverFim: data['serverFim'],
        infosComplementares: data['infosComplementares'],
        odometroInicial: data['odometroInicial'],
        odometroFinal: data['odometroFinal']);
  }

  //metodo toMap para converter os dados do objeto MissaoRelatorio em um Map
  Map<String, dynamic> toMap() {
    return {
      'cnpj': cnpj,
      'nome da empresa': nomeDaEmpresa,
      'placaCavalo': placaCavalo,
      'placaCarreta': placaCarreta,
      'motorista': motorista,
      'corVeiculo': corVeiculo,
      'observacao': observacao,
      'tipo': tipo,
      'missaoId': missaoId,
      'uid': uid,
      'userInitialLatitude': userLatitude,
      'userInitialLongitude': userLongitude,
      'userFinalLatitude': userFinalLatitude,
      'userFinalLongitude': userFinalLongitude,
      'missaoLatitude': missaoLatitude,
      'missaoLongitude': missaoLongitude,
      'local': local,
      'inicio': inicio,
      'fim': fim,
      'fotos': fotos?.map((e) => e.toMap()).toList(),
      'fotosPosMissao': fotosPosMissao?.map((e) => e.toMap()).toList(),
      'infos': infos,
      'nome': nome,
      'serverFim': serverFim,
      'infosComplementares': infosComplementares,
      'odometroInicial': odometroInicial,
      'odometroFinal': odometroFinal
    };
  }

  static Map<String, dynamic> objectToMap(MissaoRelatorio relatorio) {
    return {
      'cnpj': relatorio.cnpj,
      'nome da empresa': relatorio.nomeDaEmpresa,
      'placaCavalo': relatorio.placaCavalo,
      'placaCarreta': relatorio.placaCarreta,
      'motorista': relatorio.motorista,
      'corVeiculo': relatorio.corVeiculo,
      'observacao': relatorio.observacao,
      'tipo': relatorio.tipo,
      'missaoId': relatorio.missaoId,
      'uid': relatorio.uid,
      'userInitialLatitude': relatorio.userLatitude,
      'userInitialLongitude': relatorio.userLongitude,
      'userFinalLatitude': relatorio.userFinalLatitude,
      'userFinalLongitude': relatorio.userFinalLongitude,
      'missaoLatitude': relatorio.missaoLatitude,
      'missaoLongitude': relatorio.missaoLongitude,
      'local': relatorio.local,
      'inicio': relatorio.inicio,
      'fim': relatorio.fim,
      //'fotos': relatorio.fotos?.map((e) => e.toMap()).toList(),
      // 'fotosPosMissao':
      //     relatorio.fotosPosMissao?.map((e) => e.toMap()).toList(),
      'infos': relatorio.infos,
      'nome': relatorio.nome,
      'serverFim': relatorio.serverFim,
      'infosComplementares': relatorio.infosComplementares,
      //'odometroInicial': relatorio.odometroInicial,
      //'odometroFinal': relatorio.odometroFinal,
    };
  }
}

// Classe auxiliar para Foto
// class Foto {
//   final String caption;
//   final Timestamp timestamp;
//   final String url;
//   final bool? enviada;

//   Foto({required this.caption, required this.timestamp, required this.url, this.enviada});

//   factory Foto.fromMap(Map<String, dynamic> data) {
//     return Foto(
//       caption: data['caption'] ?? '',
//       timestamp: data['timestamp'] ?? //valor zerado se for nulo
//           Timestamp.fromDate(DateTime.fromMillisecondsSinceEpoch(0)),
//       url: data['url'],
//       enviada: data['enviada']
//     );
//   }
//   Map<String, dynamic> toMap() {
//     return {
//       'url': url,
//       'caption': caption,
//       'timestamp': timestamp.toDate().toIso8601String(),
//       'enviada': enviada
//     };
//   }
// }

class Foto {
  final String caption;
  final Timestamp timestamp;
  final String url;
  final bool? enviada;
  bool? check = true;

  Foto(
      {required this.caption,
      required this.timestamp,
      required this.url,
      this.enviada,
      this.check});

  factory Foto.fromMap(Map<String, dynamic> data) {
    return Foto(
        caption: data['caption'] ?? '',
        timestamp: data['timestamp'] ?? //valor zerado se for nulo
            DateTime.now(),
        url: data['url'],
        enviada: data['enviada'],
        check: data['check'] ?? true);
  }
  Map<String, dynamic> toMap() {
    return {
      'url': url,
      'caption': caption,
      'timestamp': timestamp.toDate(),
      'enviada': enviada,
      'check': check
    };
  }
}
// class FotoIncremento {
//   final String caption;
//   final String filePath;

//   FotoIncremento(
//       {required this.caption, required this.filePath});

//   factory FotoIncremento.fromMap(Map<String, dynamic> data) {
//     return FotoIncremento(
//       caption: data['caption'],
//       filePath: data['filePath'],
//     );
//   }
//   Map<String, dynamic> toMap() {
//     return {
//       'filePath': filePath,
//       'caption': caption,
//     };
//   }
// }