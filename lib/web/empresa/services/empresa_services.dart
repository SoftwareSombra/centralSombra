import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../model/empresa_model.dart';
import '../model/usuario_empresa_model.dart';

class EmpresaServices {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> addEmpresa(Empresa empresa) async {
    if (empresa.cnpj.isEmpty ||
        empresa.nomeEmpresa.isEmpty ||
        empresa.endereco.isEmpty ||
        empresa.telefone.isEmpty ||
        empresa.email.isEmpty ||
        empresa.representanteLegalNome.isEmpty ||
        empresa.representanteLegalCpf.isEmpty) {
      return false;
    }
    try {
      await firestore.collection('Empresas').doc(empresa.cnpj).set({
        'Nome da empresa': empresa.nomeEmpresa,
        'CNPJ': empresa.cnpj,
        'Endereço': empresa.endereco,
        'Telefone': empresa.telefone,
        'Email': empresa.email,
        'Representante legal nome': empresa.representanteLegalNome,
        'Representante legal CPF': empresa.representanteLegalCpf,
        'Prazo do contrato inicio': empresa.prazoContratoInicio,
        'Prazo do contrato fim': empresa.prazoContratoFim,
        'Observação': empresa.observacao,
      });
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  //funcao para adicionar usuários da empresa, os quais podem ser 'administrador' ou 'operador
  Future<bool> addUsuarioEmpresa(
      String cnpj, String cargo, String uid, String nome, String email) async {
    try {
      await firestore
          .collection('Empresa')
          .doc(cnpj)
          .collection('Usuarios')
          .doc(uid)
          .set({
        'uid': uid,
        'cargo': cargo,
        'nome': nome,
        'email': email,
        'cnpj': cnpj,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  //funcao para pegar os usuários da empresa
  Future<List<UsuarioEmpresa>> getUsuariosEmpresa(String cnpj) async {
    try {
      QuerySnapshot querySnapshot = await firestore
          .collection('Empresa')
          .doc(cnpj)
          .collection('Usuarios')
          .get();
      List<UsuarioEmpresa> usuarios = [];
      for (var doc in querySnapshot.docs) {
        debugPrint(doc.data().toString());
        usuarios.add(
            UsuarioEmpresa.fromFirestore(doc.data() as Map<String, dynamic>));
      }
      return usuarios;
    } catch (e) {
      rethrow;
    }
  }

  //funcao para exclusao de usuario da empresa
  Future<bool> deleteUsuarioEmpresa(String cnpj, String uid) async {
    try {
      await firestore
          .collection('Empresa')
          .doc(cnpj)
          .collection('Usuarios')
          .doc(uid)
          .delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  //funcao para pegar os dados da empresa
  Future<Empresa?> getEmpresa(String cnpj) async {
    try {
      DocumentSnapshot doc =
          await firestore.collection('Empresas').doc(cnpj).get();
      return Empresa.fromFirestore(doc.data() as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  //funcao para atualizar os dados da empresa
  Future<bool> updateEmpresa(Empresa empresa) async {
    if (empresa.cnpj.isEmpty ||
        empresa.nomeEmpresa.isEmpty ||
        empresa.endereco.isEmpty ||
        empresa.telefone.isEmpty ||
        empresa.email.isEmpty ||
        empresa.representanteLegalNome.isEmpty ||
        empresa.representanteLegalCpf.isEmpty) {
      return false;
    }
    try {
      await firestore.collection('Empresas').doc(empresa.cnpj).update({
        'Nome da empresa': empresa.nomeEmpresa,
        'CNPJ': empresa.cnpj,
        'Endereço': empresa.endereco,
        'Telefone': empresa.telefone,
        'Email': empresa.email,
        'Representante legal nome': empresa.representanteLegalNome,
        'Representante legal CPF': empresa.representanteLegalCpf,
        'Prazo do contrato inicio': empresa.prazoContratoInicio,
        'Prazo do contrato fim': empresa.prazoContratoFim,
        'Observação': empresa.observacao,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  //funcao para exclusao de empresa
  Future<bool> deleteEmpresa(String cnpj) async {
    try {
      await firestore.collection('Empresas').doc(cnpj).delete();
      return true;
    } catch (e) {
      return false;
    }
  }

  //funcao que retorna todas as empresas cadastradas
  Future<List<Empresa>> getAllEmpresas() async {
    debugPrint('buscando empresas...');
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Empresas').get();
      List<Empresa> empresas = [];
      for (var doc in querySnapshot.docs) {
        empresas.add(Empresa.fromFirestore(doc.data() as Map<String, dynamic>));
      }
      return empresas;
    } catch (e) {
      rethrow;
    }
  }
}
