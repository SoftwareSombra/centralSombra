import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MissaoSolicitada {
  final String cnpj;
  final String nomeDaEmpresa;
  final String? placaCavalo;
  final String? placaCarreta;
  final String? motorista;
  final String? corVeiculo;
  final String? observacao;
  final String missaoId;
  final double latitude;
  final double longitude;
  final String local;
  final DateTime timestamp;
  final String tipo;
  final String uid;

  MissaoSolicitada({
    required this.cnpj,
    required this.nomeDaEmpresa,
    this.placaCavalo,
    this.placaCarreta,
    this.motorista,
    this.corVeiculo,
    this.observacao,
    required this.missaoId,
    required this.latitude,
    required this.longitude,
    required this.local,
    required this.timestamp,
    required this.tipo,
    required this.uid,
  });

  factory MissaoSolicitada.fromFirestore(String id, Map<String, dynamic> data) {
    debugPrint(data.toString());
    return MissaoSolicitada(
      cnpj: data['cnpj'],//
      nomeDaEmpresa: data['nome da empresa'],
      placaCavalo: data['placaCavalo'],
      placaCarreta: data['placaCarreta'],
      motorista: data['motorista'],
      corVeiculo: data['corVeiculo'],
      observacao: data['observacao'],
      missaoId: data['missaoId'],
      tipo: data['tipo de missao'],
      uid: data['userUid'],
      latitude: data['missaoLatitude'],
      longitude: data['missaoLongitude'],
      local: data['local'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
}
