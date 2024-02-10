class ContaBancaria {
  final String titular;
  final String uid;
  final String numero;
  final String agencia;
  final String chavePix;

  ContaBancaria(
      {required this.titular,
      required this.uid,
      required this.numero,
      required this.agencia,
      required this.chavePix});

  // Método para converter os dados do documento Firestore em um objeto ContaBancaria
  factory ContaBancaria.fromFirestore(Map<String, dynamic> data, String uid) {
    return ContaBancaria(
        titular: data['Titular'],
        uid: data['uid'],
        numero: data['Numero'],
        agencia: data['Agência'],
        chavePix: data['Chave Pix']);
  }
}
