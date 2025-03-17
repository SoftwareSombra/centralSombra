import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sombra/web/home/screens/mapa_teste.dart';
import '../../../chat_view/src/models/message.dart';
import '../../../missao/model/missao_model.dart';

class DadosRelatorioCliente {
  final String cnpjString;
  final String missaoIdString;
  final bool? tipo;
  final bool? cnpj;
  final bool? nomeDaEmpresa;
  final bool? local;
  final bool? placaCavalo;
  final bool? placaCarreta;
  final bool? motorista;
  final bool? corVeiculo;
  final bool? observacao;
  final bool? missaoId;
  final bool? uid;
  final bool? inicio;
  final bool? fim;
  final bool? serverFim;
  final bool? fotos;
  final bool? fotosPosMissao;
  final bool? infos;
  final bool? distancia;
  final bool? distanciaOdometro;
  final bool? rota;
  final String uidOperadorSombra;

  DadosRelatorioCliente({
    required this.cnpjString,
    required this.missaoIdString,
    this.tipo,
    this.cnpj,
    this.nomeDaEmpresa,
    this.local,
    this.placaCavalo,
    this.placaCarreta,
    this.motorista,
    this.corVeiculo,
    this.observacao,
    this.missaoId,
    this.uid,
    this.inicio,
    this.fim,
    this.serverFim,
    this.fotos,
    this.fotosPosMissao,
    this.infos,
    this.distancia,
    this.distanciaOdometro,
    this.rota,
    required this.uidOperadorSombra,
  });

  //metodo from firestore
  factory DadosRelatorioCliente.fromFirestore(Map<String, dynamic> data) {
    return DadosRelatorioCliente(
      cnpjString: data['cnpjString'],
      missaoIdString: data['missaoIdString'],
      tipo: data['tipo'] ?? false,
      cnpj: data['cnpj'] ?? false,
      nomeDaEmpresa: data['nomeDaEmpresa'] ?? false,
      local: data['local'] ?? false,
      placaCavalo: data['placaCavalo'] ?? false,
      placaCarreta: data['placaCarreta'] ?? false,
      motorista: data['motorista'] ?? false,
      corVeiculo: data['corVeiculo'] ?? false,
      observacao: data['observacao'] ?? false,
      missaoId: data['missaoId'] ?? false,
      uid: data['uid'] ?? false,
      inicio: data['inicio'] ?? false,
      fim: data['fim'] ?? false,
      serverFim: data['serverFim'] ?? false,
      fotos: data['fotos'] ?? false,
      fotosPosMissao: data['fotosPosMissao'] ?? false,
      infos: data['infos'] ?? false,
      distancia: data['distancia'] ?? false,
      distanciaOdometro: data['distanciaOdometro'] ?? false,
      rota: data['rota'] ?? false,
      uidOperadorSombra: data['uidOperadorSombra'],
    );
  }

  //metodo to firestore
  Map<String, dynamic> toFirestore() {
    return {
      'cnpjString': cnpjString,
      'missaoIdString': missaoIdString,
      'tipo': tipo ?? false,
      'cnpj': cnpj ?? false,
      'nomeDaEmpresa': nomeDaEmpresa ?? false,
      'local': local ?? false,
      'placaCavalo': placaCavalo ?? false,
      'placaCarreta': placaCarreta ?? false,
      'motorista': motorista ?? false,
      'corVeiculo': corVeiculo ?? false,
      'observacao': observacao ?? false,
      'missaoId': missaoId ?? false,
      'uid': uid ?? false,
      'inicio': inicio ?? false,
      'fim': fim ?? false,
      'serverFim': serverFim ?? false,
      'fotos': fotos ?? false,
      'fotosPosMissao': fotosPosMissao ?? false,
      'infos': infos ?? false,
      'distancia': distancia ?? false,
      'distanciaOdometro': distanciaOdometro ?? false,
      'rota': rota ?? false,
      'uidOperadorSombra': uidOperadorSombra,
    };
  }
}

class RelatorioCliente {
  final String? cnpj;
  final String? missaoId;
  final String? uidOperadorSombra;
  final String? tipo;
  final String? nomeDaEmpresa;
  final String? local;
  final double? missaoLat;
  final double? missaoLng;
  final String? placaCavalo;
  final String? placaCarreta;
  final String? motorista;
  final String? corVeiculo;
  final String? observacao;
  final String? uid;
  final Timestamp? inicio;
  final Timestamp? fim;
  final Timestamp? serverFim;
  final List<Foto>? fotos;
  final List<Foto>? fotosPosMissao;
  final Foto? odometroInicial;
  final Foto? odometroFinal;
  final List<Message>? messages;
  final String? infos;
  final String? infosComplementares;
  final double? distancia;
  final double? distanciaOdometro;
  final List<CoordenadaComTimestamp>? rota;

  RelatorioCliente({
    this.cnpj,
    this.missaoId,
    this.uidOperadorSombra,
    this.tipo,
    this.nomeDaEmpresa,
    this.local,
    this.missaoLat,
    this.missaoLng,
    this.placaCavalo,
    this.placaCarreta,
    this.motorista,
    this.corVeiculo,
    this.observacao,
    this.uid,
    this.inicio,
    this.fim,
    this.serverFim,
    this.fotos,
    this.fotosPosMissao,
    this.odometroInicial,
    this.odometroFinal,
    this.messages,
    this.infos,
    this.infosComplementares,
    this.distancia,
    this.distanciaOdometro,
    this.rota,
  });

  //metodo from firestore
  factory RelatorioCliente.fromFirestore(Map<String, dynamic> data) {
    List<Foto>? fotosMapeadas = data['fotos'] != null
        ? List.from(data['fotos']).map((e) => Foto.fromMap(e)).toList()
        : null; // Ou atribua uma lista vazia se preferir: []
    // Mapeamento de 'fotosPosMissao'
    List<Foto>? fotosPosMissaoMapeadas = data['fotosPosMissao'] != null
        ? List.from(data['fotosPosMissao']).map((e) => Foto.fromMap(e)).toList()
        : null; // Ou atribua uma lista vazia se preferir: []

    List<CoordenadaComTimestamp>? rotaMapeada = data['rota'] != null
        ? List.from(data['rota'])
            .map((e) => CoordenadaComTimestamp.fromMap(e))
            .toList()
        : null;

    final fotoOdometroInicial = data['odometroInicial'] != null
        ? Foto.fromMap(data['odometroInicial'])
        : null;
    final fotoOdometroFinal = data['odometroFinal'] != null
        ? Foto.fromMap(data['odometroFinal'])
        : null;

    List<Message>? chatMessages = data['messages'] != null
        ? List.from(data['messages']).map((e) => Message.fromJson(e)).toList()
        : null;

    return RelatorioCliente(
      cnpj: data['cnpj'],
      missaoId: data['missaoId'],
      uidOperadorSombra: data['uidOperadorSombra'],
      tipo: data['tipo'],
      nomeDaEmpresa: data['nomeDaEmpresa'],
      local: data['local'],
      missaoLat: data['missaoLat'],
      missaoLng: data['missaoLng'],
      placaCavalo: data['placaCavalo'],
      placaCarreta: data['placaCarreta'],
      motorista: data['motorista'],
      corVeiculo: data['corVeiculo'],
      observacao: data['observacao'],
      uid: data['uid'],
      inicio: data['inicio'],
      fim: data['fim'],
      serverFim: data['serverFim'],
      fotos: fotosMapeadas,
      fotosPosMissao: fotosPosMissaoMapeadas,
      odometroInicial: fotoOdometroInicial,
      odometroFinal: fotoOdometroFinal,
      messages: chatMessages,
      infos: data['infos'],
      infosComplementares: data['infosComplementares'],
      distancia: data['distancia'],
      distanciaOdometro: data['distanciaOdometro'],
      rota: rotaMapeada,
    );
  }

  //metodo to firestore
  Map<String, dynamic> toFirestore() {
    //metodo para mapear as fotos
    List<Map<String, dynamic>>? fotos =
        this.fotos != null ? this.fotos!.map((e) => e.toMap()).toList() : null;
    //metodo para mapear as fotosPosMissao
    List<Map<String, dynamic>>? fotosPosMissao = this.fotosPosMissao != null
        ? this.fotosPosMissao!.map((e) => e.toMap()).toList()
        : null;

    //mapear a lista de coordenadas da rota considerando que a lista é do tipo Location e que nao existe um método toMap(), então é necessário mapear cada coordenada individualmente
    List<Map<String, dynamic>>? rota = this.rota != null
        ? this
            .rota!
            .map((e) =>
                {'latitude': e.ponto.latitude, 'longitude': e.ponto.longitude})
            .toList()
        : null;

    List<Map<String, dynamic>>? chatMessages = this.messages != null
        ? this.messages!.map((e) => e.paraJson()).toList()
        : null;

    Map<String, dynamic>? fotoOdometroInicial =
        this.odometroInicial != null ? this.odometroInicial!.toMap() : null;

    Map<String, dynamic>? fotoOdometroFinal =
        this.odometroFinal != null ? this.odometroFinal!.toMap() : null;

    return {
      'cnpj': cnpj,
      'missaoId': missaoId,
      'uidOperadorSombra': uidOperadorSombra,
      'tipo': tipo,
      'nomeDaEmpresa': nomeDaEmpresa,
      'local': local,
      'missaoLat': missaoLat,
      'missaoLng': missaoLng,
      'placaCavalo': placaCavalo,
      'placaCarreta': placaCarreta,
      'motorista': motorista,
      'corVeiculo': corVeiculo,
      'observacao': observacao,
      'uid': uid,
      'inicio': inicio,
      'fim': fim,
      'serverFim': serverFim,
      'fotos': fotos,
      'fotosPosMissao': fotosPosMissao,
      'odometroInicial': fotoOdometroInicial,
      'odometroFinal': fotoOdometroFinal,
      'messages': chatMessages,
      'infos': infos,
      'infosComplementares': infosComplementares,
      'distancia': distancia,
      'distanciaOdometro': distanciaOdometro,
      'rota': rota,
    };
  }
}
