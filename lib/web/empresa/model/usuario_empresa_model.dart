import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioEmpresa {
  String uid;
  String nome;
  String? email;
  String cargo;
  String cnpj;
  DateTime timestamp;

  UsuarioEmpresa({
    required this.uid,
    required this.nome,
    this.email,
    required this.cargo,
    required this.cnpj,
    required this.timestamp,
  });
  // Método para converter os dados do documento Firestore em um objeto
  factory UsuarioEmpresa.fromFirestore(Map<String, dynamic> data) {
    return UsuarioEmpresa(
      uid: data['uid'],
      nome: data['nome'],
      email: data['email'] ?? '',
      cargo: data['cargo'],
      cnpj: data['cnpj'],
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  //toMap
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nome': nome,
      'email': email ?? '',
      'cargo': cargo,
      'cnpj': cnpj,
      'timestamp': timestamp,
    };
  }
}
