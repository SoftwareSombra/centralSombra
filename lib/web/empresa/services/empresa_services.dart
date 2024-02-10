import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/empresa_model.dart';

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
      return false;
    }
  }

  //funcao para pegar os dados da empresa
  Future<Empresa> getEmpresa(String cnpj) async {
    try {
      DocumentSnapshot doc =
          await firestore.collection('Empresas').doc(cnpj).get();
      return Empresa.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      rethrow;
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
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Empresas').get();
      List<Empresa> empresas = [];
      for (var doc in querySnapshot.docs) {
        empresas.add(
            Empresa.fromFirestore(doc.data() as Map<String, dynamic>, doc.id));
      }
      return empresas;
    } catch (e) {
      rethrow;
    }
  }
}
