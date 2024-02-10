import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../model/empresa_model.dart';
import '../services/empresa_services.dart';

class AddEmpresaScreen extends StatefulWidget {
  const AddEmpresaScreen({super.key});

  @override
  State<AddEmpresaScreen> createState() => _AddEmpresaScreenState();
}

class _AddEmpresaScreenState extends State<AddEmpresaScreen> {
  final _formKey = GlobalKey<FormState>();
  final nomeEmpresaController = TextEditingController();
  final cnpjController = TextEditingController();
  final enderecoController = TextEditingController();
  final telefoneController = TextEditingController();
  final emailController = TextEditingController();
  final representanteLegalNomeController = TextEditingController();
  final representanteLegalCpfController = TextEditingController();
  final observacaoController = TextEditingController();
  DateTime? prazoContratoInicio;
  DateTime? prazoContratoFim;
  EmpresaServices empresaServices = EmpresaServices();
  MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
  TratamentoDeErros tratamentoDeErros = TratamentoDeErros();

  Widget buildTextFormField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        keyboardType: keyboardType,
        controller: controller,
        // Adicione validadores e onSave se necessário
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? prazoContratoInicio ?? DateTime.now()
          : prazoContratoFim ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2040),
    );
    if (picked != null &&
        picked != (isStartDate ? prazoContratoInicio : prazoContratoFim)) {
      setState(() {
        if (isStartDate) {
          prazoContratoInicio = picked;
        } else {
          prazoContratoFim = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar empresa'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    buildTextFormField(
                        'Nome da empresa', nomeEmpresaController),
                    buildTextFormField('CNPJ', cnpjController,
                        keyboardType: TextInputType.number),
                    buildTextFormField('Endereço', enderecoController),
                    buildTextFormField('Telefone', telefoneController,
                        keyboardType: TextInputType.phone),
                    buildTextFormField('Email', emailController,
                        keyboardType: TextInputType.emailAddress),
                    buildTextFormField('Representante legal nome',
                        representanteLegalNomeController),
                    buildTextFormField('Representante legal CPF',
                        representanteLegalCpfController,
                        keyboardType: TextInputType.number),
                    // Campo para selecionar a data de início do contrato
                    ListTile(
                      title: const Text('Prazo do contrato: início'),
                      subtitle: Text(prazoContratoInicio != null
                          ? DateFormat('dd/MM/yyyy')
                              .format(prazoContratoInicio!)
                          : 'Selecionar data'),
                      onTap: () => _selectDate(context, true),
                    ),
                    // Campo para selecionar a data de fim do contrato
                    ListTile(
                      title: const Text('Prazo do contrato: fim'),
                      subtitle: Text(prazoContratoFim != null
                          ? DateFormat('dd/MM/yyyy').format(prazoContratoFim!)
                          : 'Selecionar data'),
                      onTap: () => _selectDate(context, false),
                    ),
                    buildTextFormField('Observação', observacaoController),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final resposta =
                              await empresaServices.addEmpresa(Empresa(
                            nomeEmpresa: nomeEmpresaController.text.trim(),
                            cnpj: cnpjController.text.trim(),
                            endereco: enderecoController.text.trim(),
                            telefone: telefoneController.text.trim(),
                            email: emailController.text.trim(),
                            representanteLegalNome:
                                representanteLegalNomeController.text.trim(),
                            representanteLegalCpf:
                                representanteLegalCpfController.text.trim(),
                            prazoContratoInicio: prazoContratoInicio!,
                            prazoContratoFim: prazoContratoFim!,
                            observacao: observacaoController.text.trim(),
                          ));
                          if (context.mounted) {
                            if (resposta) {
                              mensagemDeSucesso.showSuccessSnackbar(
                                  context, 'Empresa adicionada com sucesso!');
                              nomeEmpresaController.clear();
                              cnpjController.clear();
                              enderecoController.clear();
                              telefoneController.clear();
                              emailController.clear();
                              representanteLegalNomeController.clear();
                              representanteLegalCpfController.clear();
                              prazoContratoInicio = null;
                              prazoContratoFim = null;
                              observacaoController.clear();
                            } else {
                              tratamentoDeErros.showErrorSnackbar(context,
                                  'Erro ao adicionar empresa. Tente novamente.');
                            }
                          }
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nomeEmpresaController.dispose();
    cnpjController.dispose();
    enderecoController.dispose();
    telefoneController.dispose();
    emailController.dispose();
    representanteLegalNomeController.dispose();
    representanteLegalCpfController.dispose();
    observacaoController.dispose();
    super.dispose();
  }
}
