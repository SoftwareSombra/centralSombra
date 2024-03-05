class UsuarioEmpresa {
  String uid;
  String nome;
  String email;
  String cargo;
  String cnpj;
  String timestamp;

  UsuarioEmpresa({
    required this.uid,
    required this.nome,
    required this.email,
    required this.cargo,
    required this.cnpj,
    required this.timestamp,
  });
  // Método para converter os dados do documento Firestore em um objeto Publicacao
  factory UsuarioEmpresa.fromFirestore(Map<String, dynamic> data) {
    return UsuarioEmpresa(
      uid: data['uid'],
      nome: data['nome'],
      email: data['email'],
      cargo: data['cargo'],
      cnpj: data['cnpj'],
      timestamp: data['timestamp'],
    );
  }
}
