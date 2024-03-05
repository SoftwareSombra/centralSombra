import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sombra_testes/web/relatorios/bloc/list/relatorios_list_bloc.dart';
import 'package:sombra_testes/web/relatorios/screens/detalhes_missao_select.dart';
import '../../../missao/model/missao_model.dart';
import '../bloc/list/relatorios_list_event.dart';
import '../bloc/list/relatorios_list_state.dart';
import '../services/relatorio_services.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

String? _selectedFilterOption;

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  final missoesConcluidasFuture = RelatorioServices().buscarTodosRelatorios();
  final canvasColor = const Color.fromARGB(255, 0, 15, 42);

  List<DataColumn> get columns => const [
        DataColumn(label: Text('Tipo')),
        DataColumn(label: Text('Data do fim')),
        DataColumn(label: Text('ID da missão')),
        DataColumn(label: Text('Empresa')),
        DataColumn(label: Text('Ver detalhes')),
      ];

  @override
  void initState() {
    super.initState();
    BlocProvider.of<RelatoriosListBloc>(context).add(BuscarRelatoriosEvent());
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    debugPrint('chegou aqui');

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      ),
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  // ResponsiveRowColumn(
                  //   layout:
                  //       ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                  //           ? ResponsiveRowColumnType.COLUMN
                  //           : ResponsiveRowColumnType.ROW,
                  //   rowMainAxisAlignment: MainAxisAlignment.start,
                  //   children: const [
                  //     ResponsiveRowColumnItem(
                  //       child: Padding(
                  //         padding: EdgeInsets.symmetric(
                  //             horizontal: 100, vertical: 15),
                  //         child: Text(
                  //           'Buscar missões:',
                  //           style: TextStyle(
                  //               fontWeight: FontWeight.w400, fontSize: 16),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width * 0.084,
                        right: MediaQuery.of(context).size.width * 0.08,
                        bottom: 20),
                    child: ResponsiveRowColumn(
                      layout:
                          ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                              ? ResponsiveRowColumnType.COLUMN
                              : ResponsiveRowColumnType.ROW,
                      rowMainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //rowPadding: const EdgeInsets.symmetric(horizontal: 100),
                      children: [
                        const ResponsiveRowColumnItem(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(
                                    'assets/images/fotoDePerfilNull.jpg'),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Nome do usuário',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    'Função',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 11),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        ResponsiveRowColumnItem(
                          child: Row(
                            children: [
                              SizedBox(
                                width: width * 0.2,
                                height: 31,
                                child: TextFormField(
                                  cursorHeight: 12,
                                  decoration: InputDecoration(
                                    labelText: 'Buscar missão pelo ID',
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
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 0),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.filter_list,
                                    color: Colors.grey[500]!,
                                    size: 25,
                                  ),
                                  onPressed: () {
                                    // Coloque a lógica do filtro aqui
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.refresh_outlined,
                                    color: Colors.grey[500]!,
                                    size: 25,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  BlocBuilder<RelatoriosListBloc, RelatoriosListState>(
                    builder: (context, state) {
                      if (state is RelatoriosListInitial) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is RelatoriosListLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else if (state is RelatoriosListError) {
                        return Center(
                          child: Text(state.message),
                        );
                      } else if (state is RelatoriosListEmpty) {
                        return const Center(
                          child: Text('Nenhum user cadastrado'),
                        );
                      } else if (state is RelatoriosListLoaded) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: SizedBox(
                              width: width * 0.99,
                              child: state.relatorios.isNotEmpty
                                  ? PaginatedDataTable(
                                      columns: columns,
                                      source: EmpresaDataSource(
                                        missoes: state.relatorios,
                                        context: context,
                                      ),
                                      header:
                                          const Text('Relatórios de missões'),
                                      columnSpacing:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                      showCheckboxColumn: false,
                                      rowsPerPage: state.relatorios.length < 10
                                          ? state.relatorios.length
                                          : 10,
                                    )
                                  : const Center(
                                      child: Text('Nenhum user cadastrado'),
                                    ),
                            ),
                          ),
                        );
                      } else {
                        return const Center(
                          child: Text('Recarregue a página'),
                        );
                      }
                    },
                  ),
                  // ResponsiveRowColumnItem(
                  //   child: Padding(
                  //     padding: EdgeInsets.symmetric(horizontal: width * 0.0),
                  //     child: FutureBuilder<List<MissaoRelatorio?>>(
                  //       future: missoesConcluidasFuture,
                  //       builder: (BuildContext context,
                  //           AsyncSnapshot<List<MissaoRelatorio?>> snapshot) {
                  //         if (snapshot.hasError) {
                  //           return Center(
                  //               child: Text('Erro: ${snapshot.error}'));
                  //         }

                  //         if (snapshot.connectionState ==
                  //             ConnectionState.waiting) {
                  //           return const Center(
                  //               child: CircularProgressIndicator());
                  //         }

                  //         if (!snapshot.hasData) {
                  //           return const Center(
                  //               child: Text('Nenhum relatório disponível'));
                  //         }

                  //         final dataSource = EmpresaDataSource(
                  //             missoes: snapshot.data!
                  //                 .where((missao) => missao != null)
                  //                 .toList()
                  //                 .cast<MissaoRelatorio>());

                  //         return PaginatedDataTable(
                  //           columns: columns,
                  //           source: dataSource,
                  //           header: const Text('Relatórios de missões'),
                  //           actions: [
                  //             IconButton(
                  //               icon: const Icon(Icons.refresh),
                  //               onPressed: () {
                  //                 setState(() {
                  //                   // Atualize a lista de missões
                  //                 });
                  //               },
                  //             ),
                  //           ],
                  //           rowsPerPage: dataSource.missoes.length < 10 ? dataSource.missoes.length : 10,
                  //           availableRowsPerPage: const [10, 20, 50],
                  //           columnSpacing: MediaQuery.of(context).size.width * 0.05,
                  //           onRowsPerPageChanged: (int? value) {
                  //             // Atualize o número de linhas por página
                  //           },
                  //         );

                  // List<TableRow> missionRows =
                  //     snapshot.data!.map((MissaoRelatorio? missao) {
                  //   // Verifica se o objeto Missao não é nulo
                  //   if (missao != null) {
                  //     return TableRow(
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: Text(missao
                  //               .tipo), // Substitua 'tipo' pelo campo correspondente na sua classe Missao
                  //         ),
                  //         Container(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: Text(missao.inicio != null
                  //               ? DateFormat('dd/MM/yyyy HH:mm')
                  //                   .format(missao.inicio!.toDate())
                  //               : 'N/A'),
                  //         ),
                  //         Container(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: Text(missao
                  //               .missaoId), // Substitua 'id' pelo campo correspondente na sua classe Missao
                  //         ),
                  //         Container(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: TextButton(
                  //             onPressed: () {
                  //               Navigator.push(
                  //                 context,
                  //                 MaterialPageRoute(
                  //                   builder: (context) =>
                  //                       MissionDetails(
                  //                     missaoId: missao.missaoId,
                  //                     agenteId: missao.uid,
                  //                   ),
                  //                 ),
                  //               );
                  //             },
                  //             child: const Text('Ver detalhes'),
                  //           ),
                  //         ),
                  //       ],
                  //     );
                  //   } else {
                  //     return TableRow(children: [
                  //       Container(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: const Text('Dados não disponíveis')),
                  //       // Outros containers vazios ou com textos placeholder podem ser adicionados aqui
                  //     ]);
                  //   }
                  // }).toList();

                  // return Table(
                  //   border: TableBorder.all(),
                  //   columnWidths: const {
                  //     0: FractionColumnWidth(0.25),
                  //     1: FractionColumnWidth(0.25),
                  //     2: FractionColumnWidth(0.25),
                  //     3: FractionColumnWidth(0.25),
                  //   },
                  //   children: [
                  //     TableRow(
                  //       children: [
                  //         Container(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: const Text('Tipo'),
                  //         ),
                  //         Container(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: const Text('Data de início'),
                  //         ),
                  //         Container(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: const Text('ID da missão'),
                  //         ),
                  //         Container(
                  //           padding: const EdgeInsets.all(8.0),
                  //           child: const Text(''),
                  //         ),
                  //       ],
                  //     ),
                  //     ...missionRows, // Adiciona as linhas de missões aqui
                  //   ],
                  // );
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmpresaDataSource extends DataTableSource {
  List<MissaoRelatorio?> missoes;
  BuildContext context;
  EmpresaDataSource({required this.missoes, required this.context});

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= missoes.length) {
      return null;
    }
    final missao = missoes[index];

    return DataRow.byIndex(
      color: const MaterialStatePropertyAll(
        Color.fromARGB(255, 3, 9, 18),
      ),
      index: index,
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
              const SizedBox(
                width: 2,
              ),
              SelectableText(missao!.tipo),
            ],
          ),
        ),
        DataCell(
          SelectableText(missao.serverFim != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(missao.serverFim!.toDate())
              : 'N/A'),
        ),
        DataCell(
          SelectableText(missao.missaoId),
        ),
        DataCell(
          SelectableText(missao.nomeDaEmpresa),
        ),
        DataCell(
          Row(
            children: [
              MouseRegion(
                cursor: MaterialStateMouseCursor.clickable,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MissionDetails(
                          missaoId: missao.missaoId,
                          agenteId: missao.uid,
                        ),
                      ),
                    );
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
  int get rowCount => missoes.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
