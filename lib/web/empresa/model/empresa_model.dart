import 'package:cloud_firestore/cloud_firestore.dart';

class Empresa {
  String nomeEmpresa;
  String cnpj;
  String endereco;
  String telefone;
  String email;
  String representanteLegalNome;
  String representanteLegalCpf;
  DateTime prazoContratoInicio;
  DateTime prazoContratoFim;
  String? observacao;

  Empresa({
    required this.nomeEmpresa,
    required this.cnpj,
    required this.endereco,
    required this.telefone,
    required this.email,
    required this.representanteLegalNome,
    required this.representanteLegalCpf,
    required this.prazoContratoInicio,
    required this.prazoContratoFim,
    this.observacao = '',
  });

  factory Empresa.fromFirestore(Map<String, dynamic> data, String id) {
    return Empresa(
      nomeEmpresa: data['Nome da empresa'],
      cnpj: data['CNPJ'],
      endereco: data['Endereço'],
      telefone: data['Telefone'],
      email: data['Email'],
      representanteLegalNome: data['Representante legal nome'],
      representanteLegalCpf: data['Representante legal CPF'],
      prazoContratoInicio: (data['Prazo do contrato inicio'] as Timestamp).toDate(),
      prazoContratoFim: (data['Prazo do contrato fim'] as Timestamp).toDate(),
      observacao: data['Observação'],
    );
  }
}
