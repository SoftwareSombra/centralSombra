import 'package:cloud_firestore/cloud_firestore.dart';

class AgenteAdmList {
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
  final String? nivel;
  final String nome;

  AgenteAdmList({
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
    this.nivel,
    required this.nome,
  });

  factory AgenteAdmList.fromFirestore(Map<String, dynamic> data) {
    return AgenteAdmList(
      uid: data['uid'],
      endereco: data['Endereço'],
      cep: data['Cep'],
      celular: data['Celular'],
      rg: data['RG'],
      cpf: data['CPF'],
      rgFotoFrenteUrl: data['RG frente'] ?? 'S/A',
      rgFotoVersoUrl: data['RG verso'] ?? 'S/A',
      compResidFotoUrl: data['Comprovante de residência'] ?? 'S/A',
      timestamp: data['Timestamp'],
      nivel: data['Nível'] ?? 'S/N',
      nome: data['Nome'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'Endereço': endereco,
      'Cep': cep,
      'Celular': celular,
      'RG': rg,
      'CPF': cpf,
      'RG frente': rgFotoFrenteUrl,
      'RG verso': rgFotoVersoUrl,
      'Comprovante de residência': compResidFotoUrl,
      'Timestamp': timestamp,
      'Nível': nivel,
      'Nome': nome,
    };
  }
}
