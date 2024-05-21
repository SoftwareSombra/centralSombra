import 'package:flutter/material.dart';
import 'package:image_card/image_card.dart';
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
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = (screenWidth ~/ 400).clamp(3, 4);
    List cards = [
      AdmCard(
        title: 'Adicionar cargos',
        imagePath: 'assets/images/escudo.png',
        destination: const AddCargos(),
        descricao: 'Adicione cargos para os usuários do sistema',
        cards: crossAxisCount,
      ),
      AdmCard(
        title: 'Relatórios',
        imagePath: 'assets/images/relatorios.jpeg',
        destination: AdmRelatoriosScreen(cargo: cargo, nome: nome,),
        descricao: 'Acesse os relatórios completos das missões',
        cards: crossAxisCount,
      ),
      AdmCard(
        title: 'Agentes',
        imagePath: 'assets/images/agentes.jpeg',
        destination: const AgentesList(),
        descricao: 'Acesse a lista de agentes cadastrados',
        cards: crossAxisCount,
      ),
      AdmCard(
        title: 'Empresas',
        imagePath: 'assets/images/empresas.png',
        destination: const EmpresasScreen(),
        descricao: 'Acesse a lista de empresas cadastradas',
        cards: crossAxisCount,
      ),
      AdmCard(
        title: 'Usuários',
        imagePath: 'assets/images/users.jpg',
        destination: const UsersList(),
        descricao: 'Acesse a lista de usuários cadastrados',
        cards: crossAxisCount,
      ),
      AdmCard(
        title: 'Notificações',
        imagePath: 'assets/images/notificacao.jpeg',
        destination: const NotificacoesAdmScreen(),
        descricao: 'Envie notificações e avisos',
        cards: crossAxisCount,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Administrador'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                constraints:
                    BoxConstraints(maxWidth: screenWidth > 1200 ? 1200 : 800),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 100),
                  child: GridView.builder(
                    //physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: cards.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 30,
                      mainAxisSpacing: 30,
                    ),
                    itemBuilder: (context, index) {
                      return cards[index];
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AdmCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Widget destination;
  final String descricao;
  final int cards;

  const AdmCard(
      {super.key,
      required this.title,
      required this.imagePath,
      required this.destination,
      this.descricao = '',
      required this.cards});

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'MediaQuery.of(context).size.width: ${MediaQuery.of(context).size.width}');
    return MouseRegion(
      cursor: MaterialStateMouseCursor.clickable,
      child: GestureDetector(
        child: FillImageCard(
          color: Colors.blue.withAlpha(30),
          width: double.infinity,
          heightImage: cards == 3 && MediaQuery.of(context).size.width > 1200
              ? 210
              : 160,
          imageProvider: AssetImage(imagePath),
          tags: const [],
          title: Row(
            children: [
              Text(title),
            ],
          ),
          description: MediaQuery.of(context).size.width > 1200 &&
                  MediaQuery.of(context).size.height > 700
              ? Row(
                  children: [
                    SizedBox(
                      width: 200,
                      child: Text(
                        descricao,
                        textAlign: TextAlign.start,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                )
              : null,
        ),
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => destination));
        },
      ),
    );
  }
}
