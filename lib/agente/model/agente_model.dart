import 'package:cloud_firestore/cloud_firestore.dart';

class Agente {
  final String uid;
  //final String endereco;
  final String logradouro;
  final String numero;
  final String bairro;
  final String cidade;
  final String estado;
  final String complemento;
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
    //required this.endereco,
    required this.logradouro,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.estado,
    required this.complemento,
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
        //endereco: data['Endereço'],
        logradouro: data['logradouro'],
        numero: data['numero'],
        bairro: data['bairro'],
        cidade: data['cidade'],
        estado: data['estado'],
        complemento: data['complemento'],
        cep: data['Cep'],
        celular: data['Celular'],
        rg: data['RG'],
        cpf: data['CPF'],
        rgFotoFrenteUrl: data['RG frente'],
        rgFotoVersoUrl: data['RG verso'],
        compResidFotoUrl: data['Comprovante de residência'],
        timestamp: data['Timestamp'],
        nome: data['Nome']);
  }
}
