import 'package:cloud_firestore/cloud_firestore.dart';

class AgenteAdmList {
  final String uid;
  //final String endereco;
  final String Logradouro;
  final String Numero;
  final String Complemento;
  final String Bairro;
  final String Cidade;
  final String Estado;
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
    //required this.endereco,
    required this.Logradouro,
    required this.Numero,
    required this.Complemento,
    required this.Bairro,
    required this.Cidade,
    required this.Estado,
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
      //endereco: data['Endereço'],
      Logradouro: data['logradouro'],
      Numero: data['numero'],
      Complemento: data['complemento'],
      Bairro: data['bairro'],
      Cidade: data['cidade'],
      Estado: data['estado'],
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
      //'Endereço': endereco,
      'logradouro': Logradouro,
      'numero': Numero,
      'complemento': Complemento,
      'bairro': Bairro,
      'cidade': Cidade,
      'estado': Estado,
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
