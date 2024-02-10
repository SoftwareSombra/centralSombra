import 'package:flutter/material.dart';
import '../services/veiculos_services.dart';
import 'components/form_add_veiculo.dart';

class AddVeiculoScreen extends StatelessWidget {
  AddVeiculoScreen({super.key});

  final TextEditingController placa = TextEditingController();
  final TextEditingController marca = TextEditingController();
  final TextEditingController modelo = TextEditingController();
  final TextEditingController cor = TextEditingController();
  final TextEditingController ano = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final VeiculoServices veiculoServices = VeiculoServices();

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
                children: <Widget>[
                  FormAddVeiculo(
                    cor: cor,
                    placa: placa,
                    marca: marca,
                    modelo: modelo,
                    ano: ano,
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
