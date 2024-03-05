import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> addAllClaims(uid) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setAllClaims');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid.text.trim()});
      debugPrint("Admin set successfully: ${result.data}");
      return true;
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return false;
    } on Exception catch (e) {
      debugPrint("General Exception: $e");
      return false;
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return false;
    }
  }

  //funcao para setar dev
  Future<bool> addDev(uid) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setDevClaim');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid.text.trim()});
      debugPrint("Dev set successfully: ${result.data}");
      return true;
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return false;
    } on Exception catch (e) {
      debugPrint("General Exception: $e");
      return false;
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return false;
    }
  }

  Future<bool> addAdmin(uid) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setAdmin');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid.text.trim()});
      debugPrint("Admin set successfully: ${result.data}");
      return true;
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return false;
    } on Exception catch (e) {
      debugPrint("General Exception: $e");
      return false;
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return false;
    }
  }

  Future<bool> addGestor(uid) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setGestor');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid.text.trim()});
      debugPrint("Gestor set successfully: ${result.data}");
      return true;
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return false;
    } on Exception catch (e) {
      debugPrint("General Exception: $e");
      return false;
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return false;
    }
  }

  Future<bool> addOperador(uid) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setOperador');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid.text.trim()});
      debugPrint("Admin set successfully: ${result.data}");
      return true;
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return false;
    } on Exception catch (e) {
      debugPrint("General Exception: $e");
      return false;
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return false;
    }
  }

  Future<bool> addAdminCliente(uid, id) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setAdminCliente');
    try {
      final HttpsCallableResult result = await callable
          .call(<String, dynamic>{'uid': uid, 'id': id});
      debugPrint("Admin cliente set successfully: ${result.data}");
      return true;
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return false;
    } on Exception catch (e) {
      debugPrint("General Exception: $e");
      return false;
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return false;
    }
  }

  Future<bool> addOperadorCliente(uid, id) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setOperadorCliente');
    try {
      final HttpsCallableResult result = await callable
          .call(<String, dynamic>{'uid': uid, 'id': id});
      debugPrint("Operador cliente set successfully: ${result.data}");
      return true;
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return false;
    } on Exception catch (e) {
      debugPrint("General Exception: $e");
      return false;
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return false;
    }
  }

  Future<bool> deleteAllUsers() async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('deleteAllUsers2');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{});
      debugPrint("Delete successfully: ${result.data}");
      return true;
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return false;
    } on Exception catch (e) {
      debugPrint("General Exception: $e");
      return false;
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return false;
    }
  }

  Future<void> refreshUserToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.getIdToken(true);
    }
  }

  Future<Map<String, dynamic>?> getCustomClaims() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult(true);
      return idTokenResult.claims; // Retorna as custom claims
    }
    return null;
  }

  Future<bool> checkIfUserIsAdmin() async {
    Map<String, dynamic>? claims = await getCustomClaims();
    if (claims != null && claims.containsKey('admin')) {
      return claims['admin'] ==
          true; // Verifica se a claim 'admin' é verdadeira
    }
    return false;
  }

  Future<bool> checkIfUserIsDev() async {
    Map<String, dynamic>? claims = await getCustomClaims();
    if (claims != null && claims.containsKey('dev')) {
      return claims['dev'] == true; // Verifica se a claim 'admin' é verdadeira
    }
    return false;
  }

  Future<bool> checkIfUserIsGestor() async {
    Map<String, dynamic>? claims = await getCustomClaims();
    if (claims != null && claims.containsKey('gestor')) {
      return claims['gestor'] ==
          true; // Verifica se a claim 'admin' é verdadeira
    }
    return false;
  }

  Future<bool> checkIfUserIsOperador() async {
    Map<String, dynamic>? claims = await getCustomClaims();
    if (claims != null && claims.containsKey('operador')) {
      return claims['operador'] ==
          true; // Verifica se a claim 'admin' é verdadeira
    }
    return false;
  }

  Future<ClaimResponse> checkIfUserIsAdminCliente() async {
    Map<String, dynamic>? claims = await getCustomClaims();
    if (claims != null && claims.containsKey('adminCliente')) {
      final hasClaim = claims['adminCliente'] == true;
      final empresaId = claims['empresaId'] as String;
      return ClaimResponse(hasClaim: hasClaim, empresaId: empresaId);
    }
    return ClaimResponse(hasClaim: false, empresaId: '');
  }

  Future<ClaimResponse> checkIfUserIsOperadorCliente() async {
    Map<String, dynamic>? claims = await getCustomClaims();
    if (claims != null && claims.containsKey('operadorCliente')) {
      final hasClaim = claims['operadorCliente'] == true;
      final empresaId = claims['empresaId'] as String;
      return ClaimResponse(hasClaim: hasClaim, empresaId: empresaId);
    }
    return ClaimResponse(hasClaim: false, empresaId: '');
  }

  Future<List<Usuario>?> getAllUsers() async {
    try {
      final users = await firestore.collection('User Name').get();
      if (users.docs.isNotEmpty) {
        return users.docs
            .map((snapshot) => Usuario.fromFirestore(snapshot.data()))
            .toList();
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar os dados do usuário: $e');
      return null;
    }
  }
}

class ClaimResponse {
  final bool hasClaim;
  final String empresaId;

  ClaimResponse({required this.hasClaim, required this.empresaId});
}

class Usuario {
  final String nome;
  final String uid;
  final String? email;
  
  Usuario({required this.nome, required this.uid, this.email});

  factory Usuario.fromFirestore(Map<String, dynamic> firestore) {
    return Usuario(
      nome: firestore['Nome'],
      uid: firestore['UID'],
      email: firestore['Email'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'Nome': nome,
      'UID': uid,
      'Email': email,
    };
  }
}
