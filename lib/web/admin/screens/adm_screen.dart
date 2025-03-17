import 'package:flutter/material.dart';
import '../../empresa/screens/empresas_list.dart';
import '../agentes/screens/agentes_list.dart';
import '../notificacoes/screens/notificacoes_screen.dart';
import '../relatorios/screens/adm_relatorios_screen.dart';
import '../services/admin_services.dart';
import '../usuarios/screens/users_list.dart';
import 'add_cargos.dart';

class AddRolesScreen extends StatelessWidget {
  final String cargo;
  final String nome;
  AddRolesScreen({super.key, required this.cargo, required this.nome});

  final TextEditingController uidController = TextEditingController();
  final AdminServices adminServices = AdminServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Administrador'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 50,
              ),
              const AdmButtonCard(
                  title: 'Adicionar cargos',
                  imagePath: 'assets/images/escudo.png',
                  destination: AddCargos(),
                  descricao: 'Adicione cargos para os usuários do sistema'),
              AdmButtonCard(
                title: 'Relatórios',
                imagePath: 'assets/images/relatorios.jpeg',
                destination: AdmRelatoriosScreen(
                  cargo: cargo,
                  nome: nome,
                ),
                descricao: 'Acesse os relatórios completos das missões',
              ),
              const AdmButtonCard(
                title: 'Agentes',
                imagePath: 'assets/images/agentes.jpeg',
                destination: AgentesList(),
                descricao: 'Acesse a lista de agentes cadastrados',
              ),
              const AdmButtonCard(
                title: 'Empresas',
                imagePath: 'assets/images/empresas.png',
                destination: EmpresasScreen(),
                descricao: 'Acesse a lista de empresas cadastradas',
              ),
              const AdmButtonCard(
                title: 'Usuários',
                imagePath: 'assets/images/users.jpg',
                destination: UsersList(),
                descricao: 'Acesse a lista de usuários cadastrados',
              ),
              const AdmButtonCard(
                title: 'Notificações',
                imagePath: 'assets/images/notificacao.jpeg',
                destination: NotificacoesAdmScreen(),
                descricao: 'Envie notificações e avisos',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdmButtonCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Widget destination;
  final String descricao;

  const AdmButtonCard(
      {super.key,
      required this.title,
      required this.imagePath,
      required this.destination,
      this.descricao = ''});

  final Color canvasColor = const Color.fromARGB(255, 3, 9, 18);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: MouseRegion(
        cursor: WidgetStateMouseCursor.clickable,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => destination),
            );
          },
          child: Container(
            width: 300,
            height: 65,
            decoration: BoxDecoration(
              color: canvasColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        bottomLeft: Radius.circular(15),
                      ),
                      child: Image.asset(
                        imagePath,
                        height: 65,
                        width: 65,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  Text(title),
                  const Icon(Icons.arrow_forward),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
