import 'package:flutter/material.dart';
//import 'package:stepper_a/stepper_a.dart';
import '../../autenticacao/services/user_services.dart';
import 'components/form_add_infos.dart';

class AddInfosScreen extends StatelessWidget {
  AddInfosScreen({super.key});

  final TextEditingController nome = TextEditingController();
  final TextEditingController endereco = TextEditingController();
  final TextEditingController cep = TextEditingController();
  final TextEditingController celular = TextEditingController();
  final TextEditingController rg = TextEditingController();
  final TextEditingController cpf = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final UserServices userServices = UserServices();
  //final StepperAController stepperController = StepperAController();
  final TextEditingController logradouroController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController complementoController = TextEditingController();
  final TextEditingController bairroController = TextEditingController();
  final TextEditingController cidadeController = TextEditingController();
  final TextEditingController estadoController = TextEditingController();
  final TextEditingController cepController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 14, 14, 14),
        appBar: AppBar(
          title: const Text(
            'Cadastro',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FormAddInfo(
                infosContext: context,
                nome: nome,
                endereco: endereco,
                cep: cep,
                celular: celular,
                rg: rg,
                cpf: cpf,
                formKey: formKey,
                //stepperController: stepperController,
                logradouroController: logradouroController,
                numeroController: numeroController,
                complementoController: complementoController,
                bairroController: bairroController,
                cidadeController: cidadeController,
                estadoController: estadoController,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
