class Relatorio {
  final String uid;
  final String missaoId;
  final String nome;
  final String tipo;
  final String infos;
  final double userInitialLatitude;
  final double userInitialLongitude;
  final double userFinalLatitude;
  final double userFinalLongitude;
  final double missaoLatitude;
  final double missaoLongitude;
  final List<Map<String, dynamic>>? fotos;

  Relatorio({
    required this.uid,
    required this.missaoId,
    required this.nome,
    required this.tipo,
    required this.infos,
    this.fotos,
    required this.missaoLatitude,
    required this.missaoLongitude,
    required this.userFinalLatitude,
    required this.userFinalLongitude,
    required this.userInitialLatitude,
    required this.userInitialLongitude,
  });
  // Método para converter os dados do documento Firestore em um objeto Relatorio
  factory Relatorio.fromFirestore(Map<String, dynamic> data, String id) {
    List<Map<String, dynamic>> imagensList =
        List<Map<String, dynamic>>.from(data['fotos'] ?? []);

    return Relatorio(
      uid: data['uid'],
      missaoId: data['missaoId'],
      nome: data['nome'],
      tipo: data['tipo'],
      infos: data['infos'],
      fotos: imagensList,
      missaoLatitude: data['missaoLatitude'],
      missaoLongitude: data['missaoLongitude'],
      userFinalLatitude: data['userFinalLatitude'],
      userFinalLongitude: data['userFinalLongitude'],
      userInitialLatitude: data['userInitialLatitude'],
      userInitialLongitude: data['userInitialLongitude'],
    );
  }
}
