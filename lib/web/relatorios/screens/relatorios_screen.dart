import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:sombra_testes/web/relatorios/bloc/list/relatorios_list_bloc.dart';
import 'package:sombra_testes/web/relatorios/screens/detalhes_missao_select.dart';
import '../../../missao/model/missao_model.dart';
import '../../../paginated_data_table/paginated_data_table.dart';
import '../../admin/services/admin_services.dart';
import '../bloc/list/relatorios_list_event.dart';
import '../bloc/list/relatorios_list_state.dart';
import '../services/relatorio_services.dart';

class RelatoriosScreen extends StatefulWidget {
  final String cargo;
  final String nome;
  const RelatoriosScreen({super.key, required this.cargo, required this.nome});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  final missoesConcluidasFuture = RelatorioServices().buscarTodosRelatorios();
  final canvasColor = const Color.fromARGB(255, 0, 15, 42);
  AdminServices adminServices = AdminServices();
  FirebaseAuth auth = FirebaseAuth.instance;
  //String funcao = 'carregando...';
  //String nome = 'carregando...';
  TextEditingController searchController = TextEditingController();
  List<MissaoRelatorio?> relatorios = [];

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
    //nome = auth.currentUser!.displayName!;
    BlocProvider.of<RelatoriosListBloc>(context).add(BuscarRelatoriosEvent());
    //buscarFuncao();
  }

  List<MissaoRelatorio?> filtrarRelatorios(
      List<MissaoRelatorio?> relatorios, String searchText) {
    searchText = searchText.toLowerCase();
    return relatorios.where((relatorio) {
      return relatorio?.missaoId.toLowerCase().contains(searchText) ?? false;
    }).toList();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  // Future<void> buscarFuncao() async {
  //   final getFunction = await adminServices.getUserRole();
  //   setState(() {
  //     funcao = getFunction;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    debugPrint('chegou aqui');

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      ),
      body: BlocBuilder<RelatoriosListBloc, RelatoriosListState>(
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
              child: Text('Nenhum relatório encontrado'),
            );
          } else if (state is RelatoriosListLoaded) {
            relatorios = state.relatorios;

            // Filtra a lista com base no texto atual no campo de pesquisa
            List<MissaoRelatorio?> relatoriosFiltrados =
                filtrarRelatorios(relatorios, searchController.text);

            return SingleChildScrollView(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.084,
                              right: MediaQuery.of(context).size.width * 0.08,
                              bottom: 20),
                          child: ResponsiveRowColumn(
                            layout: ResponsiveBreakpoints.of(context)
                                    .smallerThan(DESKTOP)
                                ? ResponsiveRowColumnType.COLUMN
                                : ResponsiveRowColumnType.ROW,
                            rowMainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            //rowPadding: const EdgeInsets.symmetric(horizontal: 100),
                            children: [
                              ResponsiveRowColumnItem(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const CircleAvatar(
                                      radius: 20,
                                      backgroundImage: AssetImage(
                                          'assets/images/fotoDePerfilNull.jpg'),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.nome,
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        Text(
                                          widget.cargo,
                                          style: const TextStyle(
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
                                      height: 40,
                                      child: TextFormField(
                                        controller: searchController,
                                        cursorHeight: 15,
                                        decoration: InputDecoration(
                                          labelText: 'Buscar missão pelo ID',
                                          labelStyle: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12),
                                          suffixIcon: Icon(
                                            Icons.search,
                                            size: 20,
                                            color: Colors.grey[500]!,
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[500]!),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[500]!),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: BorderSide(
                                                color: Colors.grey[500]!),
                                          ),
                                        ),
                                        onChanged: (text) {
                                          setState(() {
                                            //relatorios = filtrarRelatorios();
                                          });
                                        },
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
                                        onPressed: () {
                                          context
                                              .read<RelatoriosListBloc>()
                                              .add(BuscarRelatoriosEvent());
                                        },
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
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: SizedBox(
                              width: width * 0.99,
                              child: relatoriosFiltrados.isNotEmpty
                                  ? PaginatedDataTable2(
                                      colors: [
                                        canvasColor.withOpacity(0.3),
                                        canvasColor.withOpacity(0.33),
                                        canvasColor.withOpacity(0.35),
                                        canvasColor.withOpacity(0.38),
                                        canvasColor.withOpacity(0.4),
                                        canvasColor.withOpacity(0.43),
                                        canvasColor.withOpacity(0.45),
                                        canvasColor.withOpacity(0.48),
                                        canvasColor.withOpacity(0.5),
                                        canvasColor.withOpacity(0.53),
                                        canvasColor.withOpacity(0.55),
                                        canvasColor.withOpacity(0.58),
                                      ],
                                      columns: columns,
                                      source: EmpresaDataSource(
                                        missoes: relatoriosFiltrados,
                                        context: context,
                                      ),
                                      header: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AutoSizeText(
                                            'RELATÓRIOS',
                                            maxFontSize: 20,
                                            minFontSize: 18,
                                            style: TextStyle(
                                                fontSize: 100,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                      columnSpacing:
                                          MediaQuery.of(context).size.width *
                                              0.05,
                                      showCheckboxColumn: false,
                                      rowsPerPage: state.relatorios.length < 10
                                          ? state.relatorios.length
                                          : 10,
                                    )
                                  : const Center(
                                      child:
                                          Text('Nenhum relatório disponível'),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('Recarregue a página'),
            );
          }
        },
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
              ? DateFormat('dd/MM/yyyy HH:mm')
                  .format(missao.serverFim!.toDate())
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
