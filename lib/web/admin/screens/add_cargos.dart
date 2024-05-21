import 'package:flutter/material.dart';
import '../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../services/admin_services.dart';

class AddCargos extends StatefulWidget {
  final String? uid;
  const AddCargos({super.key, this.uid});

  @override
  State<AddCargos> createState() => _AddCargosState();
}

class _AddCargosState extends State<AddCargos> {
  String? uid;
  bool? isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.uid != null) {
      setState(() {
        uid = widget.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    final TextEditingController admController = TextEditingController();
    final TextEditingController gestorController = TextEditingController();
    final TextEditingController operadorController = TextEditingController();
    final AdminServices adminServices = AdminServices();
    final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
    final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        title: const Text('Adicionar cargos'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.2, vertical: 20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                uid != null
                    ? SelectableText('Uid do usuário criado: $uid')
                    : const SizedBox.shrink(),
                const SizedBox(height: 25),
                buildTextFieldWithValidation(
                  campo: 'Administrador',
                  controller: admController,
                  label: 'uid',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o uid do usuário';
                    }
                    return null;
                  },
                ),
                buildElevatedButton(onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final userName = await adminServices
                      .getUserInfos(admController.text.trim());
                  final admResult = await adminServices.addAdmin(admController.text.trim(),
                      nome: userName);
                  if (context.mounted) {
                    setState(() {
                      isLoading = false;
                    });
                    if (admResult) {
                      mensagemDeSucesso.showSuccessSnackbar(
                          context, 'Cargo adicionado com sucesso');
                      admController.clear();
                    } else {
                      tratamentoDeErros.showErrorSnackbar(
                          context, 'Erro ao adicionar cargo');
                    }
                  }
                }),
                const SizedBox(height: 25),
                buildTextFieldWithValidation(
                  campo: 'Gestor',
                  controller: gestorController,
                  label: 'uid',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o uid do usuário';
                    }
                    return null;
                  },
                ),
                buildElevatedButton(onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final userName = await adminServices
                      .getUserInfos(admController.text.trim());
                  final gestorResult = await adminServices
                      .addGestor(gestorController.text.trim(), nome: userName);
                  if (context.mounted) {
                    setState(() {
                      isLoading = false;
                    });
                    if (gestorResult) {
                      mensagemDeSucesso.showSuccessSnackbar(
                          context, 'Cargo adicionado com sucesso');
                      gestorController.clear();
                    } else {
                      tratamentoDeErros.showErrorSnackbar(
                          context, 'Erro ao adicionar cargo');
                    }
                  }
                }),
                const SizedBox(height: 25),
                buildTextFieldWithValidation(
                  campo: 'Operador',
                  controller: operadorController,
                  label: 'uid',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o uid do usuário';
                    }
                    return null;
                  },
                ),
                buildElevatedButton(onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  final userName = await adminServices
                      .getUserInfos(admController.text.trim());
                  final operadorResult = await adminServices
                      .addOperador(operadorController.text.trim(), nome: userName);
                  if (context.mounted) {
                    setState(() {
                      isLoading = false;
                    });
                    if (operadorResult) {
                      mensagemDeSucesso.showSuccessSnackbar(
                          context, 'Cargo adicionado com sucesso');
                      operadorController.clear();
                    } else {
                      tratamentoDeErros.showErrorSnackbar(
                          context, 'Erro ao adicionar cargo');
                    }
                  }
                }),
                const SizedBox(height: 25),
                // buildTextFieldWithValidation(
                //   campo: 'Administrador cliente',
                //   controller: admClienteController,
                //   label: 'uid',
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Por favor, insira o uid do usuário';
                //     }
                //     return null;
                //   },
                // ),
                // buildTextFieldWithValidation(
                //   controller: admClienteCnpjController,
                //   label: 'CNPJ',
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Por favor, insira o CNPJ da empresa';
                //     }
                //     return null;
                //   },
                // ),
                // buildElevatedButton(
                //   onPressed: () async {
                //     setState(() {
                //       isLoading = true;
                //     });
                //     final admClienteResult =
                //         await adminServices.addAdminCliente(
                //       admClienteController,
                //       admClienteCnpjController,
                //     );
                //     if (context.mounted) {
                //       setState(() {
                //         isLoading = false;
                //       });
                //       if (admClienteResult) {
                //         mensagemDeSucesso.showSuccessSnackbar(
                //             context, 'Cargo adicionado com sucesso');
                //         admClienteController.clear();
                //         admClienteCnpjController.clear();
                //       } else {
                //         tratamentoDeErros.showErrorSnackbar(
                //             context, 'Erro ao adicionar cargo');
                //       }
                //     }
                //   },
                // ),
                // const SizedBox(height: 25),
                // buildTextFieldWithValidation(
                //   campo: 'Operador cliente',
                //   controller: operadorClienteController,
                //   label: 'uid',
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Por favor, insira o uid do usuário';
                //     }
                //     return null;
                //   },
                // ),
                // buildTextFieldWithValidation(
                //   controller: operadorClienteCnpjController,
                //   label: 'CNPJ',
                //   validator: (value) {
                //     if (value == null || value.isEmpty) {
                //       return 'Por favor, insira o CNPJ da empresa';
                //     }
                //     return null;
                //   },
                // ),
                // buildElevatedButton(
                //   onPressed: () async {
                //     setState(() {
                //       isLoading = true;
                //     });
                //     final operadorClienteResult =
                //         await adminServices.addOperadorCliente(
                //       operadorClienteController,
                //       operadorClienteCnpjController,
                //     );
                //     if (context.mounted) {
                //       setState(() {
                //         isLoading = false;
                //       });
                //       if (operadorClienteResult) {
                //         mensagemDeSucesso.showSuccessSnackbar(
                //             context, 'Cargo adicionado com sucesso');
                //         operadorClienteController.clear();
                //         operadorClienteCnpjController.clear();
                //       } else {
                //         tratamentoDeErros.showErrorSnackbar(
                //             context, 'Erro ao adicionar cargo');
                //       }
                //     }
                //   },
                // ),
                //const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFieldWithValidation({
    String? campo,
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        campo != null
            ? Text(
                campo,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              )
            : const SizedBox.shrink(),
        TextFormField(
          controller: controller,
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
          validator: validator,
        ),
        const SizedBox(height: 5),
      ],
    );
  }

  Widget buildElevatedButton({required VoidCallback onPressed}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
      onPressed: isLoading! ? null : onPressed,
      child: isLoading! ? const Text('...') : const Text('Adicionar'),
    );
  }
}
