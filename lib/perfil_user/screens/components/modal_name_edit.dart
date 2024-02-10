import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../autenticacao/services/user_services.dart';

class MySquareModal extends StatelessWidget {
  MySquareModal({super.key});

  final TextEditingController nome = TextEditingController();
  final GlobalKey<FormState> editkey = GlobalKey<FormState>();
  final UserServices userServices = UserServices();

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final user = firebaseAuth.currentUser;
    final uid = user?.uid;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      child: SizedBox(
        width: 200,
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Editar nome',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(
              height: 5,
            ),
            Form(
              key: editkey,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: TextFormField(
                  controller: nome,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome desejado.';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Novo nome',
                    labelStyle: TextStyle(color: Colors.grey),
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
            ElevatedButton(
                onPressed: () async {
                  if (editkey.currentState!.validate()) {
                    final atualizado = await userServices.updateUserName(
                        context, uid, nome.text.trim());
                    if (atualizado) {
                      nome.clear();
                    }
                  }
                },
                child: const Text('Alterar'))
          ],
        ),
      ),
    );
  }
}
