import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sombra/autenticacao/services/user_services.dart';
import '../model/agente_model.dart';

class AgenteServices {
  final UserServices userServices = UserServices();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> preAddUserInfos(
    String uid,
    String nome,
    String logradouro,
    String numero,
    String complemento,
    String bairro,
    String cidade,
    String estado,
    String cep,
    String celular,
    String rg,
    String cpf,
    dynamic rgFotoFrente,
    dynamic rgFotoVerso,
    dynamic compResidFoto,
  ) async {
    try {
      String? rgFotoFrenteUrl;
      String? rgFotoVersoUrl;
      String? compResidFotoUrl;
      String? rgFotoFrenteBase64;
      String? rgFotoVersoBase64;
      String? compResidFotoBase64;

      debugPrint('Início da função preAddUserInfos');

      // Processa RG frente
      if (rgFotoFrente is PlatformFile) {
        debugPrint('Processando upload de rgFotoFrente');
        rgFotoFrenteBase64 = await fileToBase64(rgFotoFrente);
      } else if (rgFotoFrente is String) {
        debugPrint('rgFotoFrente é uma String');
        rgFotoFrenteUrl = rgFotoFrente;
      }

      // Processa RG verso
      if (rgFotoVerso is PlatformFile) {
        debugPrint('Processando upload de rgFotoVerso');
        rgFotoVersoBase64 = await fileToBase64(rgFotoVerso);
      } else if (rgFotoVerso is String) {
        rgFotoVersoUrl = rgFotoVerso;
      }

      // Processa Comprovante de residência
      if (compResidFoto is PlatformFile) {
        debugPrint('Processando upload de compResidFoto');
        compResidFotoBase64 = await fileToBase64(compResidFoto);
      } else if (compResidFoto is String) {
        compResidFotoUrl = compResidFoto;
      }

      //debugPrint de todos os dados
      debugPrint('uid: $uid');
      debugPrint('nome: $nome');
      debugPrint('endereco: $logradouro, $numero, $bairro, $cidade, $estado');
      debugPrint('cep: $cep');
      debugPrint('celular: $celular');
      debugPrint('rg: $rg');
      debugPrint('cpf: $cpf');
      debugPrint('rgFotoFrenteUrl: $rgFotoFrenteUrl');
      debugPrint('rgFotoVersoUrl: $rgFotoVersoUrl');
      debugPrint('compResidFotoUrl: $compResidFotoUrl');
      debugPrint('rgFotoFrenteBase64: $rgFotoFrenteBase64');
      debugPrint('rgFotoVersoBase64: $rgFotoVersoBase64');
      debugPrint('compResidFotoBase64: $compResidFotoBase64');

      var dio = Dio();
      try {
        var response = await dio.post(
            'https://southamerica-east1-sombratestes.cloudfunctions.net/preAddDocumentosDoAgente',
            data: {
              'uid': uid,
              'logradouro': logradouro,
              'numero': numero,
              'complemento': complemento,
              'bairro': bairro,
              'cidade': cidade,
              'estado': estado,
              'cep': cep,
              'celular': celular,
              'rg': rg,
              'cpf': cpf,
              rgFotoFrenteUrl != null ? 'rgFotoFrente' : 'rgFotoFrenteBase64':
                  rgFotoFrenteUrl ?? rgFotoFrenteBase64,
              rgFotoVersoUrl != null ? 'rgFotoVerso' : 'rgFotoVersoBase64':
                  rgFotoVersoUrl ?? rgFotoVersoBase64,
              compResidFotoUrl != null
                      ? 'compResidFoto'
                      : 'compResidFotoBase64':
                  compResidFotoUrl ?? compResidFotoBase64,
              'nome': nome,
            });

        debugPrint(response.data);
      } catch (e) {
        if (e is DioException) {
          debugPrint('Erro na função preAddUserInfos: ${e.error}${e.response}');
        } else {
          debugPrint('Erro na função preAddUserInfos: $e');
        }
        return false;
      }

      debugPrint('Informações salvas com sucesso');
      return true;
    } catch (e) {
      debugPrint('Erro na função preAddUserInfos: $e');
      return false;
    }
  }

  Future<bool> solicitacaoRemove(String uid) async {
    try {
      await firestore.collection('Aprovação de user infos').doc(uid).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> excluirPendencias(String uid) async {
    try {
      await firestore
          .collection('Infos agentes aguardando aprovação')
          .doc(uid)
          .delete();
      await firestore
          .collection('Infos agentes dados rejeitados')
          .doc(uid)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addUserInfos(
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

      const url =
          'https://southamerica-east1-sombratestes.cloudfunctions.net/updateUserName2';

      await Dio().post(url, data: {'uid': uid, 'nome': nome});

      return true;
    } catch (e) {
      return false;
    }
  }

  //funcao que transforma PlataformFile em base64
  Future<String?> fileToBase64(PlatformFile file) async {
    try {
      final File fileToRead = File(file.path!);
      final bytes = await fileToRead.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint("Erro ao converter arquivo para Base64: $e");
      return null;
    }
  }

  Future<bool> isAgent(String uid) async {
    try {
      final agente = await firestore.collection('User infos').doc(uid).get();
      if (agente.exists) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao buscar os dados do usuário: $e');
      return false;
    }
  }

  Future<Agente?> getAgenteInfos(String uid) async {
    try {
      DocumentReference docRef = firestore.collection('User infos').doc(uid);
      DocumentSnapshot snapshot = await docRef.get();

      if (!snapshot.exists) {
        return null;
      }

      //debugdebugPrint dos dados mapeados
      debugPrint('Dados do agente: ${snapshot.data().toString()}');
      return Agente.fromFirestore(snapshot.data() as Map<String, dynamic>, uid);
    } catch (e) {
      debugPrint('Erro ao buscar os dados do usuário: $e');
      return null;
    }
  }

  Future<bool> emAnalise(String uid) async {
    try {
      final emAnalise =
          await firestore.collection('Aprovação de user infos').doc(uid).get();
      if (emAnalise.exists) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Erro ao buscar os dados do usuário: $e');
      return false;
    }
  }

  bool validarRG(String rg) {
    // Remove espaços em branco e caracteres especiais
    String rgLimpo = rg.replaceAll(RegExp(r'[^0-9A-Za-z]'), '');

    // Verifica o comprimento mínimo e máximo esperado para um RG
    // Considerando a possibilidade de RGs com 7 a 9 dígitos/números e possíveis letras
    if (rgLimpo.length < 7 || rgLimpo.length > 9) {
      return false;
    }

    // Verificação básica de formato válido (números e até uma letra)
    // Esta expressão regular permite RGs que combinem números e uma letra (opcionalmente no final)
    bool formatoValido = RegExp(r'^[0-9]+[A-Za-z]?$').hasMatch(rgLimpo);

    return formatoValido;
  }

  bool validarNumeroCelular(String numero) {
    // Remove caracteres não numéricos.
    numero = numero.replaceAll(RegExp(r'\D'), '');

    // Verifica se o número possui 11 dígitos e começa com 9 após o DDD.
    return RegExp(r'^\d{2}9\d{8}$').hasMatch(numero);
  }

  bool validarCEP(String cep) {
    // Remove caracteres não numéricos
    String cepNumerico = cep.replaceAll(RegExp(r'\D'), '');

    // Checa o tamanho
    if (cepNumerico.length != 8) {
      return false;
    }

    return true;
  }

  Future<bool> aprovacaoParcial(
    String uid, [
    String? nome,
    //String? endereco,
    String? logradouro,
    String? numero,
    String? bairro,
    String? cidade,
    String? estado,
    String? complemento,
    String? cep,
    String? celular,
    String? rg,
    String? cpf,
    String? rgFotoFrenteUrl,
    String? rgFotoVersoUrl,
    String? compResidFotoUrl,
  ]) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      await firestore
          .collection('Infos agentes aguardando aprovação')
          .doc(uid)
          .set({
        "uid": uid,
        "timestamp": timestamp,
        if (nome != null) "Nome": nome,
        //if (endereco != null) "Endereço": endereco,
        if (logradouro != null) "logradouro": logradouro,
        if (numero != null) "numero": numero,
        if (bairro != null) "bairro": bairro,
        if (cidade != null) "cidade": cidade,
        if (estado != null) "estado": estado,
        if (complemento != null) "complemento": complemento,
        if (cep != null) "Cep": cep,
        if (celular != null) "Celular": celular,
        if (rg != null) "RG": rg,
        if (cpf != null) "CPF": cpf,
        if (rgFotoFrenteUrl != null) "RG frente": rgFotoFrenteUrl,
        if (rgFotoVersoUrl != null) "RG verso": rgFotoVersoUrl,
        if (compResidFotoUrl != null)
          "Comprovante de residência": compResidFotoUrl,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  //excluir collection da aprovação parcial
  Future<bool> excluirAprovacaoParcial(String uid) async {
    try {
      await firestore
          .collection('Infos agentes aguardando aprovação')
          .doc(uid)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> rejeicaoParcial(
    String uid, [
    String? nome,
    //String? endereco,
    String? logradouro,
    String? numero,
    String? bairro,
    String? cidade,
    String? estado,
    String? complemento,
    String? cep,
    String? celular,
    String? rg,
    String? cpf,
    String? rgFotoFrenteUrl,
    String? rgFotoVersoUrl,
    String? compResidFotoUrl,
  ]) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      await firestore
          .collection('Infos agentes dados rejeitados')
          .doc(uid)
          .set({
        "uid": uid,
        "timestamp": timestamp,
        if (nome != null) "Nome": nome,
        //if (endereco != null) "Endereço": endereco,
        if (logradouro != null) "logradouro": logradouro,
        if (numero != null) "numero": numero,
        if (bairro != null) "bairro": bairro,
        if (cidade != null) "cidade": cidade,
        if (estado != null) "estado": estado,
        if (complemento != null) "complemento": complemento,
        if (cep != null) "Cep": cep,
        if (celular != null) "Celular": celular,
        if (rg != null) "RG": rg,
        if (cpf != null) "CPF": cpf,
        if (rgFotoFrenteUrl != null) "RG frente": rgFotoFrenteUrl,
        if (rgFotoVersoUrl != null) "RG verso": rgFotoVersoUrl,
        if (compResidFotoUrl != null)
          "Comprovante de residência": compResidFotoUrl,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  //excluir collection da rejeição parcial
  Future<bool> excluirRejeicaoParcial(String uid) async {
    try {
      await firestore
          .collection('Infos agentes dados rejeitados')
          .doc(uid)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getDadosAguardandoAprovacao(String uid) async {
    try {
      var documento = await firestore
          .collection('Infos agentes aguardando aprovação')
          .doc(uid)
          .get();
      if (documento.exists) {
        var dados = documento.data();
        //dados?.remove('uid');
        //dados?.remove('timestamp');
        return dados ?? {};
      } else {
        return {};
      }
    } catch (e) {
      debugPrint("Erro ao buscar os dados aguardando aprovação: $e");
      return {};
    }
  }

  Future<Map<String, dynamic>> getDadosRejeitados(String uid) async {
    try {
      debugPrint('getDadosRejeitados');
      var documento = await firestore
          .collection('Infos agentes dados rejeitados')
          .doc(uid)
          .get();
      if (documento.exists) {
        var dados = documento.data();
        debugPrint(dados.toString());
        dados?.remove('uid');
        dados?.remove('timestamp');
        return dados ?? {};
      } else {
        return {};
      }
    } catch (e) {
      debugPrint("Erro ao buscar os dados rejeitados: $e");
      return {};
    }
  }

  Stream<bool> existeDocumentoAguardandoAprovacao() {
    try {
      return firestore
          .collection('Aprovação de user infos')
          .snapshots()
          .map((snapshot) => snapshot.docs.isNotEmpty);
    } catch (e) {
      debugPrint("Erro ao buscar os dados aguardando aprovação: $e");
      return Stream.value(false);
    }
  }
}
