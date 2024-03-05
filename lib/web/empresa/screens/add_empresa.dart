import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';
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

  Widget buildTextFormField(
      String label, TextEditingController controller, double width,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: SizedBox(
        width: ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
            ? width * 0.6 + 10
            : width * 0.3,
        child: TextFormField(
          //enabled: false,
          //initialValue: empresa.representanteLegalNome,
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            fillColor: Colors.grey,
            focusColor: Colors.grey,
            hoverColor: Colors.grey,
            labelText: label,
            labelStyle: const TextStyle(
              color: Colors.grey,
            ),
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
          ),
          style: const TextStyle(
              fontSize: 17, fontWeight: FontWeight.w300, color: Colors.grey),
        ),
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
    final width = MediaQuery.of(context).size.width;
    return
        // Scaffold(
        //   appBar: AppBar(
        //     title: const Text('Adicionar empresa'),
        //   ),
        //   body:
        Material(
      color: const Color.fromARGB(255, 3, 9, 18),
      child: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Adicionar empresa',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ResponsiveRowColumn(
                    layout:
                        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                            ? ResponsiveRowColumnType.COLUMN
                            : ResponsiveRowColumnType.ROW,
                    rowMainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ResponsiveRowColumnItem(
                        child: buildTextFormField(
                            'Nome da empresa', nomeEmpresaController, width),
                      ),
                      ResponsiveRowColumnItem(
                        child: buildTextFormField('CNPJ', cnpjController, width,
                            keyboardType: TextInputType.number),
                      ),
                    ],
                  ),
                  ResponsiveRowColumn(
                    layout:
                        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                            ? ResponsiveRowColumnType.COLUMN
                            : ResponsiveRowColumnType.ROW,
                    rowMainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ResponsiveRowColumnItem(
                        child: buildTextFormField(
                            'Endereço', enderecoController, width),
                      ),
                      ResponsiveRowColumnItem(
                        child: buildTextFormField(
                            'Telefone', telefoneController, width,
                            keyboardType: TextInputType.phone),
                      ),
                    ],
                  ),
                  ResponsiveRowColumn(
                    layout:
                        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                            ? ResponsiveRowColumnType.COLUMN
                            : ResponsiveRowColumnType.ROW,
                    rowMainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ResponsiveRowColumnItem(
                        child: buildTextFormField(
                            'Email', emailController, width,
                            keyboardType: TextInputType.emailAddress),
                      ),
                      ResponsiveRowColumnItem(
                        child: buildTextFormField('Representante legal nome',
                            representanteLegalNomeController, width),
                      ),
                    ],
                  ),
                  ResponsiveRowColumn(
                    layout:
                        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                            ? ResponsiveRowColumnType.COLUMN
                            : ResponsiveRowColumnType.ROW,
                    rowMainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ResponsiveRowColumnItem(
                        child: buildTextFormField('Representante legal CPF',
                            representanteLegalCpfController, width,
                            keyboardType: TextInputType.number),
                      ),
                      ResponsiveRowColumnItem(
                        child: buildTextFormField(
                            'Observação', observacaoController, width),
                      ),
                    ],
                  ),
                  ResponsiveRowColumn(
                    layout:
                        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                            ? ResponsiveRowColumnType.COLUMN
                            : ResponsiveRowColumnType.ROW,
                    rowMainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ResponsiveRowColumnItem(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 25, horizontal: 10),
                          //width: width * 0.3,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero)),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Prazo do contrato: início'),
                              ],
                            ),
                            // subtitle: Text(prazoContratoInicio != null
                            //     ? DateFormat('dd/MM/yyyy')
                            //         .format(prazoContratoInicio!)
                            //     : 'Selecionar data'),
                            onPressed: () => _selectDate(context, true),
                          ),
                        ),
                      ),
                      // Campo para selecionar a data de fim do contrato
                      ResponsiveRowColumnItem(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          //width: width * 0.3,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero)),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.calendar_month,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Text('Prazo do contrato: fim'),
                              ],
                            ),
                            // subtitle: Text(prazoContratoFim != null
                            //     ? DateFormat('dd/MM/yyyy')
                            //         .format(prazoContratoFim!)
                            //     : 'Selecionar data'),
                            onPressed: () => _selectDate(context, false),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
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
