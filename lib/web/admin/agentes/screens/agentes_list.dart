import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../paginated_data_table/paginated_data_table.dart';
import '../bloc/agentes_list_bloc.dart';
import '../bloc/agentes_list_event.dart';
import '../bloc/agentes_list_state.dart';
import '../model/agente_model.dart';
import 'agente_details.dart';

class AgentesList extends StatefulWidget {
  const AgentesList({super.key});

  @override
  State<AgentesList> createState() => _AgentesListState();
}

class _AgentesListState extends State<AgentesList> {
  final canvasColor = const Color.fromARGB(255, 0, 15, 42);
  TextEditingController searchController = TextEditingController();
  List<AgenteAdmList?> agentes = [];
  List<DataColumn> get columns => const [
        DataColumn(label: Text('Nome')),
        DataColumn(label: Text('UID')),
        DataColumn(label: Text('Telefone')),
        DataColumn(label: Text('Nível')),
        DataColumn(label: Text('Ver detalhes')),
      ];

  List<AgenteAdmList?> filtrarAgentes(
      List<AgenteAdmList?> agentes, String searchText) {
    searchText = searchText.toLowerCase();
    return agentes.where((agentes) {
      return agentes?.nome.toLowerCase().contains(searchText) ?? false;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<AgentesListBloc>(context).add(FetchAgentesList());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
        //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      ),
      body: SingleChildScrollView(
        child: BlocBuilder<AgentesListBloc, AgentesListState>(
          builder: (context, state) {
            if (state is AgentesListInitial) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is AgentesListLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is AgentesListError) {
              return Center(
                child: Text(state.message),
              );
            } else if (state is AgentesListEmpty) {
              return const Center(
                child: Text('Nenhum agente cadastrado'),
              );
            } else if (state is AgentesListLoaded) {
              agentes = state.agentes;

              List<AgenteAdmList?> agentesFiltrados =
                  filtrarAgentes(agentes, searchController.text);

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 15),
                        child: SizedBox(
                          width: width * 0.4,
                          height: 40,
                          child: TextFormField(
                            controller: searchController,
                            cursorHeight: 15,
                            decoration: InputDecoration(
                              labelText: 'Buscar agente pelo nome',
                              labelStyle: TextStyle(
                                  color: Colors.grey[500], fontSize: 12),
                              suffixIcon: Icon(
                                Icons.search,
                                size: 20,
                                color: Colors.grey[500]!,
                              ),
                              border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[500]!),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[500]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey[500]!),
                              ),
                            ),
                            onChanged: (text) {
                              setState(() {
                                //relatorios = filtrarRelatorios();
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    //color: const Color.fromARGB(255, 3, 9, 18),
                    width: width * 0.99,
                    child: agentesFiltrados.isNotEmpty
                        ? PaginatedDataTable(
                            // colors: [
                            //   canvasColor.withOpacity(0.3),
                            //   canvasColor.withOpacity(0.33),
                            //   canvasColor.withOpacity(0.35),
                            //   canvasColor.withOpacity(0.38),
                            //   canvasColor.withOpacity(0.4),
                            //   canvasColor.withOpacity(0.43),
                            //   canvasColor.withOpacity(0.45),
                            //   canvasColor.withOpacity(0.48),
                            //   canvasColor.withOpacity(0.5),
                            //   canvasColor.withOpacity(0.53),
                            //   canvasColor.withOpacity(0.55),
                            //   canvasColor.withOpacity(0.58),
                            // ],
                            columns: columns,
                            source: EmpresaDataSource(
                              agentes: agentesFiltrados,
                              context: context,
                            ),
                            header: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Agentes'),
                              ],
                            ),
                            columnSpacing:
                                MediaQuery.of(context).size.width * 0.05,
                            showCheckboxColumn: true,
                            rowsPerPage: state.agentes.length < 10
                                ? state.agentes.length
                                : 10,
                          )
                        : const Center(
                            child: Text('Nenhum agente cadastrado'),
                          ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text('Recarregue a página'),
              );
            }
          },
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => const AddEmpresaScreen(),
        //   ),
        // );
        //   },
        //   child: const Icon(Icons.add),
        // ),
      ),
    );
  }
}

class EmpresaDataSource extends DataTableSource {
  List<AgenteAdmList?> agentes;
  BuildContext context;
  EmpresaDataSource({required this.agentes, required this.context});

  Color canvasColor = const Color.fromARGB(255, 3, 9, 18);

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= agentes.length) {
      return null;
    }
    final agente = agentes[index];

    return DataRow.byIndex(
      index: index,
      color: WidgetStatePropertyAll(
        canvasColor.withAlpha(15),
      ),
      cells: [
        DataCell(
          Row(
            children: [
              // Checkbox(
              //   value: false,
              //   onChanged: (value) {
              //     value = !value!;
              //   },
              // ),
              // const SizedBox(
              //   width: 2,
              // ),
              SelectableText(agente!.nome),
            ],
          ),
        ),
        DataCell(SelectableText(agente.uid)),
        DataCell(
          SelectableText(agente.celular),
        ),
        DataCell(
          Text(agente.nivel ?? 'S/N'),
        ),
        DataCell(
          Row(
            children: [
              MouseRegion(
                cursor: MaterialStateMouseCursor.clickable,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AgenteDetailsScreen(agente: agente);
                    }));
                  },
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_forward_outlined,
                        size: 15,
                      ),
                      SizedBox(
                        height: 1,
                      ),
                      Text(
                        'Detalhes',
                        style: TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  int get rowCount => agentes.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
