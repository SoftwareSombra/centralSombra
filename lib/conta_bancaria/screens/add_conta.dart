import 'package:flutter/material.dart';
import 'package:sombra_testes/conta_bancaria/screens/components/form_add_conta.dart';

class AddContaBancariaScreeen extends StatelessWidget {
  AddContaBancariaScreeen({super.key});

  final TextEditingController titular = TextEditingController();
  final TextEditingController numero = TextEditingController();
  final TextEditingController agencia = TextEditingController();
  final TextEditingController chavePix = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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
            'Adicionar conta bancária',
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
                children: <Widget>[
                  FormAddConta(
                    titular: titular,
                    numero: numero,
                    agencia: agencia,
                    chavePix: chavePix,
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
