import 'package:cloud_firestore/cloud_firestore.dart';

class Agente {
  final String uid;
  final String endereco;
  final String cep;
  final String celular;
  final String rg;
  final String cpf;
  final String? rgFotoFrenteUrl;
  final String? rgFotoVersoUrl;
  final String? compResidFotoUrl;
  final Timestamp timestamp;
  final String nome;

  Agente({
    required this.uid,
    required this.endereco,
    required this.cep,
    required this.celular,
    required this.rg,
    required this.cpf,
     this.rgFotoFrenteUrl,
     this.rgFotoVersoUrl,
     this.compResidFotoUrl,
    required this.timestamp,
    required this.nome,
  });
  // Método para converter os dados do documento Firestore em um objeto Publicacao
  factory Agente.fromFirestore(Map<String, dynamic> data, String id) {
    return Agente(
        uid: data['uid'],
        endereco: data['Endereço'],
        cep: data['Cep'],
        celular: data['Celular'],
        rg: data['RG'],
        cpf: data['CPF'],
        rgFotoFrenteUrl: data['RG frente'],
        rgFotoVersoUrl: data['RG verso'],
        compResidFotoUrl: data['Comprovante de residência'],
        timestamp: data['Timestamp'],
        nome: data['Nome']
        );
  }
}
