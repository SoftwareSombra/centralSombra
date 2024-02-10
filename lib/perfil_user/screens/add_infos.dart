import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../agente/bloc/get_user/agente_bloc.dart';
import '../../autenticacao/services/user_services.dart';
import '../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc.dart';
import '../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_event.dart';
import '../bloc/infos/foto_bloc.dart';
import '../bloc/infos/states_foto.dart';
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

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Adicionar informações',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FormAddInfo(
                    infosContext: context,
                    nome: nome,
                    endereco: endereco,
                    cep: cep,
                    celular: celular,
                    rg: rg,
                    cpf: cpf,
                    formKey: formKey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
