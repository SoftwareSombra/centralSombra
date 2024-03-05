import 'package:flutter/material.dart';
import '../../../autenticacao/services/log_services.dart';

class BuildDrawer extends StatelessWidget {
  BuildDrawer({super.key});

  final LogServices logServices = LogServices();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Stack(
        children: [
          const Column(
            children: [
              DrawerHeader(
                //decoration: BoxDecoration(color: Colors.blueAccent),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Teste'),
                  ],
                ),
              ),
              Card(
                //color: Colors.grey[100],
                child: ListTile(
                  title: Text(
                    'Teste',
                  ),
                  // Adicione mais propriedades conforme necessário
                ),
              ),
              Card(
                //color: Colors.grey[100],
                child: ListTile(
                  title: Text(
                    'Teste',
                  ),
                  // Adicionar mais propriedades conforme necessário
                ),
              ),
              //ThemeSwitcher(),
              // Adicionar mais Cards conforme necessário...
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ElevatedButton(
              //style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[100]),
              onPressed: () async {
                await logServices.logOut(context);
                if (context.mounted) {
                  await Navigator.of(context).pushNamedAndRemoveUntil(
                      '/', (Route<dynamic> route) => false);
                }
              },
              child: const Text('Sair'),
            ),
          ),
        ],
      ),
    );
  }
}
