import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../empresa/screens/empresas_list.dart';
import '../agentes/screens/agentes_list.dart';
import '../services/admin_services.dart';
import '../usuarios/screens/users_list.dart';
import 'add_cargos.dart';

class AddRolesScreen extends StatelessWidget {
  AddRolesScreen({super.key});

  final TextEditingController uidController = TextEditingController();
  final AdminServices adminServices = AdminServices();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    int crossAxisCount = (screenWidth ~/ 400).clamp(3, 4);
    List cards = [
      AdmCard(
        title: 'Adicionar cargos',
        imagePath: 'assets/images/escudo.png',
        destination: const AddCargos(),
      ),
      AdmCard(
        title: 'Relatórios',
        imagePath: 'assets/images/escudo.png',
        destination: Container(),
      ),
      AdmCard(
        title: 'Agentes',
        imagePath: 'assets/images/escudo.png',
        destination: AgentesList(),
      ),
      AdmCard(
        title: 'Empresas',
        imagePath: 'assets/images/escudo.png',
        destination: EmpresasScreen(),
      ),
      AdmCard(
        title: 'Usuários',
        imagePath: 'assets/images/escudo.png',
        destination: UsersList(),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor:  Colors.transparent,
        title: const Text('Administrador'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: screenHeight * 0.1),
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

  AdmCard({
    required this.title,
    required this.imagePath,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[800],
      child: InkWell(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => destination));
        },
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  height: 85,
                ),
              ),
              AutoSizeText(title,
                  maxLines: 1,
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
