import 'package:cloud_firestore/cloud_firestore.dart';

class AgenteAdmList {
   String uid;
  //final String endereco;
   String logradouro;
   String numero;
   String complemento;
   String bairro;
   String cidade;
   String estado;
   String cep;
   String celular;
   String rg;
   String cpf;
   String? rgFotoFrenteUrl;
   String? rgFotoVersoUrl;
   String? compResidFotoUrl;
   Timestamp timestamp;
   String? nivel;
   String nome;

  AgenteAdmList({
    required this.uid,
    //required this.endereco,
    required this.logradouro,
    required this.numero,
    required this.complemento,
    required this.bairro,
    required this.cidade,
    required this.estado,
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
      logradouro: data['logradouro'],
      numero: data['numero'],
      complemento: data['complemento'],
      bairro: data['bairro'],
      cidade: data['cidade'],
      estado: data['estado'],
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
      'logradouro': logradouro,
      'numero': numero,
      'complemento': complemento,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
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
