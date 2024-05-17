import 'dart:async';
import 'dart:js_interop';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sombra_testes/agente/model/agente_model.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../autenticacao/services/user_services.dart';
import '../../empresa/model/empresa_model.dart';
import '../../empresa/model/usuario_empresa_model.dart';
import '../agentes/model/agente_model.dart';

class AdminServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> addAllClaims(String uid) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setAllClaims');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid});
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
  Future<bool> addDev(String uid) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setDevClaim');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid});
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

  Future<bool> addAdmin(String uid, {nome, email}) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setAdmin');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid});
      debugPrint("Admin set successfully: ${result.data}");
      if (nome != null && email != null) {
        await firestore.collection('Central Users').doc(uid).set({
          'uid': uid,
          'nome': nome,
          'email': email,
          'cargo': 'administrador',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
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

  Future<bool> addGestor(String uid, {nome, email}) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setGestor');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid});
      debugPrint("Gestor set successfully: ${result.data}");
      if (nome != null && email != null) {
        await firestore.collection('Central Users').doc(uid).set({
          'uid': uid,
          'nome': nome,
          'email': email,
          'cargo': 'gestor',
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
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

  Future<bool> addOperador(String uid, {nome, email}) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setOperador');
    debugPrint('======adicionando operador=======');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid});
      debugPrint("Admin set successfully: ${result.data}");
      await firestore.collection('Central Users').doc(uid).set({
        'uid': uid,
        'nome': nome,
        'email': email,
        'cargo': 'operador',
        'timestamp': FieldValue.serverTimestamp(),
      });
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

  Future<bool> addAdminCliente(String uid, id, {nome, email}) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setAdminCliente');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid, 'id': id});
      debugPrint("Admin cliente set successfully: ${result.data}");
      await firestore
          .collection('Empresa')
          .doc(id)
          .collection('Usuarios')
          .doc(uid)
          .set({
        'uid': uid,
        'nome': nome,
        'email': email,
        'cargo': 'administrador',
        'cnpj': id,
        'timestamp': FieldValue.serverTimestamp(),
      });
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

  Future<bool> addOperadorCliente(String uid, id, {nome, email}) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('setOperadorCliente');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid, 'id': id});
      debugPrint("Operador cliente set successfully: ${result.data}");
      await firestore
          .collection('Empresa')
          .doc(id)
          .collection('Usuarios')
          .doc(uid)
          .set({
        'uid': uid,
        'nome': nome,
        'email': email,
        'cargo': 'operador',
        'cnpj': id,
        'timestamp': FieldValue.serverTimestamp(),
      });
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

  //funcao que retorna uma string com a funcao do usuario
  Future<String> getUserRole() async {
    Map<String, dynamic>? claims = await getCustomClaims();
    if (claims != null) {
      if (claims.containsKey('dev')) {
        return 'Desenvolvedor';
      } else if (claims.containsKey('admin')) {
        return 'Administrador';
      } else if (claims.containsKey('gestor')) {
        return 'Gestor';
      } else if (claims.containsKey('operador')) {
        return 'Operador';
      }
    }
    return 'Função não encontrada';
  }

  Future<bool> removeCentralCustomCalims(uid) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('removeCentralCustomCalims');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid});

      DocumentReference docRef =
          FirebaseFirestore.instance.collection('Central Users').doc(uid);

      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.delete();
      }
      debugPrint("Custom claims removed successfully: ${result.data}");
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

  Future<bool> removeClientCustomClaims(uid, cnpj) async {
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'southamerica-east1')
            .httpsCallable('removeClientCustomCalims');
    try {
      final HttpsCallableResult result =
          await callable.call(<String, dynamic>{'uid': uid});
      debugPrint("Custom claims removed successfully: ${result.data}");
      DocumentReference docRef = FirebaseFirestore.instance
          .collection('Empresa')
          .doc(cnpj)
          .collection('Usuarios')
          .doc(uid);

      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.delete();
      }
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

  Future<List<Usuario>?> getAllUsers2() async {
    // HttpsCallable callable =
    //     FirebaseFunctions.instanceFor(region: 'southamerica-east1')
    //         .httpsCallable('getAllUsersAdmin');

    final Dio dio = Dio();

    const firebaseFunctionUrl =
        "https://southamerica-east1-sombratestes.cloudfunctions.net/getAllUsersAdmin";

    try {
      final result = await dio.get(
        firebaseFunctionUrl,
      );

      if (result.statusCode != 200) {
        throw Exception(
            "API call failed with status code ${result.statusCode}");
      }

      // final HttpsCallableResult result =
      //     await callable.call(<String, dynamic>{});
      debugPrint("Users fetched successfully: ${result.data}");
      //debugPrint('$result');
      List<Usuario> users = [];
      for (var user in result.data) {
        //debugPrint("User: $user");
        users.add(Usuario.fromFirestore2(user));
      }
      if (users.isEmpty) {
        return null;
      }
      return users;
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return [];
    } on Exception catch (e) {
      debugPrint("General Exception: $e");
      return [];
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return [];
    }
  }

  Future<bool> deleteUser(uid) async {
    // HttpsCallable callable =
    //     FirebaseFunctions.instanceFor(region: 'southamerica-east1')
    //         .httpsCallable('deleteUser');
    try {
      // final HttpsCallableResult result =
      //     await callable.call(<String, dynamic>{'uid': uid});

      final Dio dio = Dio();

      const firebaseFunctionUrl =
          "https://southamerica-east1-sombratestes.cloudfunctions.net/deleteUser";

      final result = await dio.get(
        firebaseFunctionUrl,
        queryParameters: {
          "uid": uid.toString(),
        },
      );

      if (result.statusCode != 200) {
        throw Exception(
            "API call failed with status code ${result.statusCode}");
      }
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('Central Users').doc(uid);

      DocumentSnapshot docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        await docRef.delete();
      }
      debugPrint("User deleted successfully: ${result.data}");
      return true;
      //result.data.toString();
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("erroo: $e");
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return false;
      //e.message!;
    } on Exception catch (e) {
      debugPrint("General Exception: $e");
      return false;
      //e.toString();
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return false;
      //e.toString();
    }
  }

  //deletar empresa
  Future<bool> deleteEmpresa(cnpj) async {
    // HttpsCallable callable =
    //     FirebaseFunctions.instanceFor(region: 'southamerica-east1')
    //         .httpsCallable('deleteEmpresa');

    final Dio dio = Dio();

    const firebaseFunctionUrl =
        "https://southamerica-east1-sombratestes.cloudfunctions.net/deleteEmpresa";
    try {
      final result = await dio.get(
        firebaseFunctionUrl,
        queryParameters: {
          "cnpj": cnpj,
        },
      );
      // final HttpsCallableResult result =
      //     await callable.call(<String, dynamic>{'cnpj': cnpj});
      // DocumentReference docRef =
      //     FirebaseFirestore.instance.collection('Empresa').doc(cnpj);

      // DocumentSnapshot docSnapshot = await docRef.get();

      // if (docSnapshot.exists) {
      //   await docRef.delete();
      // }
      debugPrint("Empresa deleted successfully: ${result.data}");
      return true;
      //result.data.toString();
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return false;
      //e.message!;
    } on Exception catch (e) {
      debugPrint("General Exception: $e");
      return false;
      //e.toString();
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return false;
      //e.toString();
    }
  }

  Future<bool> isUser(uid) async {
    DocumentReference docRef =
        FirebaseFirestore.instance.collection('User infos').doc(uid);

    DocumentSnapshot docSnapshot = await docRef.get();

    return docSnapshot.exists;
  }

  //buscar todos os usuarios da central
  Future<List<Usuario>> getCentralUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await firestore.collection('Central Users').get();
      List<Usuario> usuarios = [];
      for (var doc in querySnapshot.docs) {
        usuarios.add(Usuario.fromFirestore(doc.data() as Map<String, dynamic>));
      }
      return usuarios;
    } catch (e) {
      rethrow;
    }
  }

  //buscar todos os usuarios da empresa
  Future<List<UsuarioEmpresa>> getEmpresaUsers(String cnpj) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Empresa')
          .doc(cnpj)
          .collection('Usuarios')
          .get();
      List<UsuarioEmpresa> usuarios = [];
      for (var doc in querySnapshot.docs) {
        usuarios.add(
            UsuarioEmpresa.fromFirestore(doc.data() as Map<String, dynamic>));
      }
      return usuarios;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getUserInfos(String uid) async {
    try {
      DocumentSnapshot doc =
          await firestore.collection('User infos').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<AgenteAdmList?> getAgentInfos(String uid) async {
    try {
      DocumentSnapshot doc =
          await firestore.collection('User infos').doc(uid).get();
      if (doc.exists) {
        return AgenteAdmList.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar os dados do usuário: $e');
      return null;
    }
  }

  Future<bool> editUserInfos(
    String uid,
    //String endereco,
    String logradouro,
    String numero,
    String bairro,
    String cidade,
    String estado,
    String complemento,
    String cep,
    String celular,
    String rg,
    String cpf,
    String? rgFotoFrenteUrl,
    String? rgFotoVersoUrl,
    String? compResidFotoUrl,
    dynamic //Timestamp ou DateTime
        timestamp,
    String nome,
  ) async {
    try {
      AgenteAdmList? agente = await getAgentInfos(uid);
      if (agente != null) {
        await saveDeletedOrEditedAgentData(agente);
      }
      await firestore.collection('User infos').doc(uid).set({
        'uid': uid,
        //'Endereço': endereco,
        'logradouro': logradouro,
        'numero': numero,
        'bairro': bairro,
        'cidade': cidade,
        'estado': estado,
        'complemento': complemento,
        'Cep': cep,
        'Celular': celular,
        'RG': rg,
        'CPF': cpf,
        'RG frente': rgFotoFrenteUrl,
        'RG verso': rgFotoVersoUrl,
        'Comprovante de residência': compResidFotoUrl,
        'Timestamp': timestamp,
        'Nome': nome,
      });

      return true;
    } catch (e) {
      debugPrint('Erro ao editar os dados do usuário: $e');
      return false;
    }
  }

  //funcao para salvar os dados do agente excluído ou editado em uma coleção de agentes excluídos
  Future<bool> saveDeletedOrEditedAgentData(
    AgenteAdmList agente,
  ) async {
    try {
      await firestore.collection('Agentes Editados').doc(agente.uid).set({
        'uid': agente.uid,
        'Nome': agente.nome,
        //'Email': agente.email,
        'rg': agente.rg,
        'cpf': agente.cpf,
        //'Data de Nascimento': agente.dataNascimento,
        'logradouro': agente.logradouro,
        'numero': agente.numero,
        'bairro': agente.bairro,
        'cidade': agente.cidade,
        'estado': agente.estado,
        'complemento': agente.complemento,
        'Cep': agente.cep,
        'Celular': agente.celular,
        'RG frente': agente.rgFotoFrenteUrl,
        'RG verso': agente.rgFotoVersoUrl,
        'Comprovante de residência': agente.compResidFotoUrl,
        'Nível': agente.nivel,
        'Timestamp': agente.timestamp,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> editDisplayName(String uid, String displayName) async {
    debugPrint('------> edit display name !!!!!!!!!!!');
    final Dio dio = Dio();

    const firebaseFunctionUrl =
        "https://southamerica-east1-sombratestes.cloudfunctions.net/editDisplayName";
    try {
      final result = await dio.post(
        firebaseFunctionUrl,
        data: {
          "uid": uid,
          "displayName": displayName,
        },
      );

      debugPrint("Nome editado com sucesso: ${result.data}");
      return true;
      //result.data.toString();
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return false;
      //e.message!;
    } on Exception catch (e) {
      debugPrint("General Exception: $e");
      return false;
      //e.toString();
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return false;
      //e.toString();
    }
  }

  Future<bool> updateUserData(
      String uid, String? displayName, String? email, phoneNumber) async {
    bool emailIsValid;

    //verificar se o email é valido
    if (email != null) {
      final UserServices userServices = UserServices();
      emailIsValid = userServices.isEmailValid(email);

      if (!emailIsValid) {
        return false;
      }
    }

    final Dio dio = Dio();

    const firebaseFunctionUrl =
        "https://southamerica-east1-sombratestes.cloudfunctions.net/editUserInfos";
    try {
      final result = await dio.post(
        firebaseFunctionUrl,
        data: {
          "uid": uid,
          if (displayName != null) "displayName": displayName,
          if (email != null) "email": email,
          if (phoneNumber != null) "phoneNumber": phoneNumber,
        },
      );

      debugPrint("usuario atualizado com sucesso: ${result.data}");
      return true;
      //result.data.toString();
    } on FirebaseFunctionsException catch (e) {
      // Verifica se há detalhes adicionais na exceção
      if (e.details != null) {
        debugPrint("Error details: ${e.details}");
      }
      debugPrint("FirebaseFunctionsException: ${e.code}, ${e.message}");
      debugPrint(e.stackTrace.toString());
      return false;
      //e.message!;
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint(
            'Erro no servidor: ${e.response!.statusCode}, ${e.response!.data}');
        return false;
      } else {
        debugPrint('Erro de rede ou configuração: ${e.message}');
        return false;
      }
    } on Exception catch (e) {
      debugPrint("General Exception: $e, ${e.toString()}, ${e.jsify()}");
      return false;
      //e.toString();
    } catch (e, s) {
      debugPrint("Unknown error: $e");
      debugPrint("Stack trace: $s");
      return false;
      //e.toString();
    }
  }

  //get Empresa pelo cnpj
  Future<Empresa?> getEmpresa(String cnpj) async {
    try {
      DocumentSnapshot doc =
          await firestore.collection('Empresa').doc(cnpj).get();
      if (doc.exists) {
        return Empresa.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao buscar os dados da empresa: $e');
      return null;
    }
  }

  //funcao para salvar os dados da empresa excluída ou editada em uma coleção de empresas excluídas
  Future<bool> saveDeletedOrEditedEmpresaData(
    String cnpj,
  ) async {
    try {
      final empresaData = await getEmpresa(cnpj);
      if (empresaData != null) {
        final empresaDataToJson = empresaData.toFirestore(empresaData);
        await firestore
            .collection('Empresas Editadas')
            .doc(cnpj)
            .set(empresaDataToJson);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> editEmpresa(Empresa empresa) async {
    try {
      await saveDeletedOrEditedEmpresaData(empresa.cnpj);
      final empresaToJson = empresa.toFirestore(empresa);
      await firestore
          .collection('Empresa')
          .doc(empresa.cnpj)
          .set(empresaToJson);
      return true;
    } catch (e) {
      debugPrint('Erro ao editar os dados da empresa: $e');
      return false;
    }
  }
}

class ClaimResponse {
  final bool hasClaim;
  final String empresaId;

  ClaimResponse({required this.hasClaim, required this.empresaId});
}

class Usuario {
  String nome;
  String uid;
  String? email;
  String? lastLogin;
  bool? emailVerified;
  String? photoUrl;
  String? creationTime;
  String? lastRefreshTime;
  String? phoneNumber;
  String? cargo;
  String? empresaId;

  Usuario(
      {required this.nome,
      required this.uid,
      this.email,
      this.lastLogin,
      this.emailVerified,
      this.photoUrl,
      this.creationTime,
      this.lastRefreshTime,
      this.phoneNumber,
      this.cargo,
      this.empresaId});

  factory Usuario.fromFirestore(Map<String, dynamic> firestore) {
    return Usuario(
      nome: firestore['Nome'],
      uid: firestore['UID'],
      email: firestore['Email'] ?? '',
    );
  }

  static String formatarData(String dataString) {
    // Convertendo a string para DateTime
    DateTime tempDate = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'")
        .parse(dataString, true)
        .toUtc();

    // Ajustando para o fuso horário de Brasília (assumindo UTC-3)
    tz.Location brasilia = tz.getLocation('America/Sao_Paulo');
    tz.TZDateTime dataBrasilia = tz.TZDateTime.from(tempDate, brasilia);

    // Formatando no padrão brasileiro
    String dataFormatada = DateFormat("dd/MM/yyyy HH:mm").format(dataBrasilia);

    return dataFormatada;
  }

  //from firestore de um um User do firebase auth
  factory Usuario.fromFirestore2(Map<String, dynamic> firestore) {
    final lastLoginFormated = firestore['metadata']['lastSignInTime'] != null
        ? formatarData(firestore['metadata']['lastSignInTime'])
        : null;

    final creationTimeFormated = firestore['metadata']['creationTime'] != null
        ? formatarData(firestore['metadata']['creationTime'])
        : null;

    final lastRefreshTimeFormated =
        firestore['metadata']['lastRefreshTime'] != null
            ? formatarData(firestore['metadata']['lastRefreshTime'])
            : null;

    return Usuario(
      nome: firestore['displayName'] ?? '',
      uid: firestore['uid'],
      email: firestore['email'] ?? '',
      //o campo de lastSignInTime fica dentro do campo metadata
      lastLogin: lastLoginFormated,
      emailVerified: firestore['emailVerified'],
      photoUrl: firestore['photoUrl'] ??
          'https://firebasestorage.googleapis.com/v0/b/sombratestes.appspot.com/o/FotoNull%2FfotoDePerfilNull.jpg?alt=media&token=bec8dce5-1251-418a-821d-0ded68cf42e7',

      creationTime: creationTimeFormated,
      lastRefreshTime: lastRefreshTimeFormated,
      phoneNumber: firestore['phoneNumber'] ?? 'Não informado',
      cargo: firestore['customClaims'] != null
          ? firestore['customClaims']['admin'] == true
              ? 'Administrador'
              : firestore['customClaims']['gestor'] == true
                  ? 'Gestor'
                  : firestore['customClaims']['operador'] == true
                      ? 'Operador'
                      : firestore['customClaims']['dev'] == true
                          ? 'Desenvolvedor'
                          : firestore['customClaims']['adminCliente'] == true
                              ? 'Administrador Cliente'
                              : firestore['customClaims']['operadorCliente'] ==
                                      true
                                  ? 'Operador Cliente'
                                  : 'Nenhum'
          : 'Não informado',

      empresaId: firestore['customClaims'] != null
          ? firestore['customClaims']['empresaId']
          : null,
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
