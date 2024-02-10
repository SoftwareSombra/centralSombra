import 'package:cloud_firestore/cloud_firestore.dart';

class Veiculo {
  final String nome;
  final String uid;
  final String placa;
  final String marca;
  final String modelo;
  final String cor;
  final String ano;
  final Timestamp timestamp;

  Veiculo(
      {required this.nome,
      required this.uid,
      required this.placa,
      required this.marca,
      required this.modelo,
      required this.cor,
      required this.ano,
      required this.timestamp});

  // Método para converter os dados do documento Firestore em um objeto Veiculo
  factory Veiculo.fromFirestore(Map<String, dynamic> data, String uid) {
    return Veiculo(
        nome: data['Nome'],
        uid: data['uid'],
        placa: data['Placa'],
        marca: data['Marca'],
        modelo: data['Modelo'],
        cor: data['Cor'],
        ano: data['Ano'],
        timestamp: data['Timestamp']);
  }
}
