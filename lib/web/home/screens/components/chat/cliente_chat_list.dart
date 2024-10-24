import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:searchable_listview/searchable_listview.dart';
import '../../../../../chat/screens/cliente_chat_screen.dart';
import '../../../../../chat/services/chat_services.dart';
import '../../../../empresa/model/empresa_model.dart';
import '../../../../empresa/services/empresa_services.dart';

class ClienteChatList extends StatefulWidget {
  const ClienteChatList({super.key});

  @override
  State<ClienteChatList> createState() => _ClienteChatListState();
}

class _ClienteChatListState extends State<ClienteChatList> {
  final ChatServices chatServices = ChatServices();
  final Map<String, String> empresas = {};
  List<String> currentCnpjs = []; // Armazena os uids atuais
  final TextEditingController searchTextController = TextEditingController();

  Future<void> fetchEmpresasNames(List<String> cnpjs) async {
    final names = await chatServices.getEmpresasNames(cnpjs);
    if (mounted) {
      setState(() {
        empresas.addAll(names);
      });
      debugPrint('empresas names: ${names.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.black.withOpacity(0.6),
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            showDialog(context: context, builder: (context) => buscarAgentes());
          }),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatServices.getClientsConversations(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                debugPrint(
                    'resultado da busca de conversas com os clientes: ${snapshot.data.toString()}');
                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                      child: Text('Nenhuma conversa disponível'));
                }

                // Extraia os uids dos documentos
                final cnpjs = docs.map((doc) => doc.id).toList();

                // Verifica se os uids são diferentes dos atuais antes de buscar os nomes
                if (!listEquals(cnpjs, currentCnpjs)) {
                  currentCnpjs = cnpjs;
                  fetchEmpresasNames(cnpjs);
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final cnpj = doc.id;
                    final data = doc.data() as Map<String, dynamic>;
                    final unreadCount = data['unreadCount'] ?? 0;
                    final nome = empresas[cnpj] ?? 'Carregando...';

                    return Card(
                      color: Colors.grey[200],
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      //color: Colors.black,
                      elevation: 4,
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(nome),
                                ],
                              ),
                            ),
                            if (unreadCount > 0)
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Text(
                                  '($unreadCount)',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ClienteChatScreen(
                                cnpj: cnpj,
                                empresaNome: nome,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buscarAgentes() {
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text('EMPRESAS'),
      content: Container(
        height: 400,
        width: 600,
        child: SearchableList<Empresa>.async(
          shrinkWrap: true,
          onPaginate: () async {
            // await Future.delayed(
            //     const Duration(milliseconds: 000));
            // setState(() {
            //   actors.addAll([
            //     Actor(
            //         age: 22,
            //         name: 'Fathi',
            //         lastName: 'Hadawi'),
            //     Actor(
            //         age: 22,
            //         name: 'Hichem',
            //         lastName: 'Rostom'),
            //     Actor(
            //         age: 22,
            //         name: 'Kamel',
            //         lastName: 'Twati'),
            //   ]);
            // });
          },
          itemBuilder: (Empresa empresa) => MouseRegion(
            cursor: WidgetStateMouseCursor.clickable,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ClienteChatScreen(
                      cnpj: empresa.cnpj,
                      empresaNome: empresa.nomeEmpresa,
                    ),
                  ),
                );
              },
              child: EmpresaItem(empresa: empresa),
            ),
          ),
          loadingWidget:
              //const SizedBox.shrink(),
              const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(
                height: 15,
              ),
              Text('Buscando empresas...')
            ],
          ),
          errorWidget: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error,
                color: Colors.red,
              ),
              SizedBox(
                height: 20,
              ),
              Text('Error ao buscar empresas')
            ],
          ),
          asyncListCallback: () async {
            List<Empresa>? empresas = await EmpresaServices().getAllEmpresas();
            return empresas;
          },
          asyncListFilter: (q, list) {
            List<Empresa>? geral = [];
            List<Empresa> nome = list
                .where((element) =>
                    element.nomeEmpresa.toLowerCase().contains(q.toLowerCase()))
                .toList();
            List<Empresa> uids =
                list.where((element) => element.cnpj.contains(q)).toList();
            geral.addAll(nome);
            searchTextController.text.isNotEmpty ? geral.addAll(uids) : null;
            return geral;
          },
          searchTextController: searchTextController,
          emptyWidget: const EmptyView(),
          onRefresh: () async {},
          // onItemSelected: (Empresa item) {
          //   Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => ClienteChatScreen(
          //         cnpj: item.cnpj,
          //         empresaNome: item.nomeEmpresa,
          //       ),
          //     ),
          //   );
          // },
          inputDecoration: const InputDecoration(
            labelText: 'Nome ou cnpj da empresa',
            labelStyle: TextStyle(fontSize: 13, color: Colors.grey),
            //suffixIcon: Icon(Icons.search),
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
    );
  }
}

class EmpresaItem extends StatelessWidget {
  final Empresa empresa;

  const EmpresaItem({
    Key? key,
    required this.empresa,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 4,
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            //color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),
              const Icon(
                Icons.business_center,
                color: Colors.white,
              ),
              const SizedBox(
                width: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        empresa.nomeEmpresa,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Cnpj: ${empresa.cnpj}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          Icons.error,
          color: Colors.red,
        ),
        Text('Nenhuma empresa encontrada'),
      ],
    );
  }
}
