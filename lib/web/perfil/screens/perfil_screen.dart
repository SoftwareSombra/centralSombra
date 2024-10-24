import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../autenticacao/services/user_services.dart';

class CentralPerfilScreen extends StatefulWidget {
  const CentralPerfilScreen({super.key});

  @override
  State<CentralPerfilScreen> createState() => _CentralPerfilScreenState();
}

final UserServices userServices = UserServices();
final TextEditingController nomeController = TextEditingController();
final GlobalKey<FormState> resetNamePerfilFormKey = GlobalKey<FormState>();

class _CentralPerfilScreenState extends State<CentralPerfilScreen> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final email = FirebaseAuth.instance.currentUser!.email;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.25),
              child: Form(
                key: resetNamePerfilFormKey,
                child: TextFormField(
                  controller: nomeController,
                  keyboardType: TextInputType.name,
                  //style: const TextStyle(color: Colors.white),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu novo nome.';
                    }
                    if (value.length < 3) {
                      return 'Precisa ter mais que 3 caracteres';
                    }
                    if (value.length > 40) {
                      return 'Precisa conter menos de 40 caracteres';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Novo nome',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(
                      Icons.edit,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                if (resetNamePerfilFormKey.currentState!.validate()) {
                  await userServices.updateUserName(
                      context, uid, nomeController.text.trim());
                }
              },
              child: const Text(
                'Alterar nome',
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            const SizedBox(
              width: 400,
              child: Text(
                textAlign: TextAlign.center,
                'Ao clicar no botão abaixo você receberá um email com o link para realizar a troca da senha.',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () async {
                await userServices.resetPassword(context, email!);
              },
              child: const Text(
                'Enviar email',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
