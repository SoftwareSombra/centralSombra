import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:responsive_grid/responsive_grid.dart';

import '../../../../missao/model/missao_model.dart';
import '../../../../paginated_data_table/paginated_data_table.dart';
import '../../../relatorios/bloc/list/relatorios_list_bloc.dart';
import '../../../relatorios/bloc/list/relatorios_list_event.dart';
import '../../../relatorios/bloc/list/relatorios_list_state.dart';
import '../../../relatorios/screens/missao_detalhes.dart';
import '../../../relatorios/services/relatorio_services.dart';
import '../../services/admin_services.dart';

class AdmRelatoriosScreen extends StatefulWidget {
  final String cargo;
  final String nome;
  const AdmRelatoriosScreen(
      {super.key, required this.cargo, required this.nome});

  @override
  State<AdmRelatoriosScreen> createState() => _AdmRelatoriosScreenState();
}

class _AdmRelatoriosScreenState extends State<AdmRelatoriosScreen> {
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
      //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
          //backgroundColor: const Color.fromARGB(255, 3, 9, 18),
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

                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: SizedBox(
                              width: width * 0.99,
                              child: relatoriosFiltrados.isNotEmpty
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
                                        missoes: relatoriosFiltrados,
                                        context: context,
                                      ),
                                      header: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          AutoSizeText(
                                            'RELATÓRIOS',
                                            maxFontSize: 19,
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
                        const SizedBox(
                          height: 20,
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 35, vertical: 20),
                              child: Text(
                                'ANÁLISE DE DADOS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Container(
                        //   height: 150,
                        //   width: 1000,
                        //child:
                        Padding(
                          padding: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05,
                            right: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: ResponsiveGridRow(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            rowSegments: 4,
                            children: [
                              // ResponsiveGridCol(
                              //   xs: 3,
                              //   md: 1,
                              //   child: container('Aguardando', 'Missão', Icons.access_time),
                              // ),
                              ResponsiveGridCol(
                                xs: 3,
                                md: 2,
                                child: const MissoesMensaisLineChart(),
                              ),
                              ResponsiveGridCol(
                                xs: 3,
                                md: 2,
                                child: const PieChartSample(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
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
  Color canvasColor = const Color.fromARGB(255, 3, 9, 18);

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= missoes.length) {
      return null;
    }
    final missao = missoes[index];

    return DataRow.byIndex(
      color: WidgetStatePropertyAll(
        canvasColor.withAlpha(15),
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

class MissoesMensaisLineChart extends StatelessWidget {
  const MissoesMensaisLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        //width: 400,
        height: 250,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
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
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.blue.withOpacity(0.1),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: canvasColor.withOpacity(0.1),
              blurRadius: 10,
            )
          ],
          //color: Colors.blue,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 5,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'MISSÕES MENSAIS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 180,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      getDrawingHorizontalLine: (value) {
                        return const FlLine(
                          color: Colors.grey,
                          strokeWidth: 1,
                        );
                      },
                      getDrawingVerticalLine: (value) {
                        return const FlLine(
                          color: Colors.grey,
                          strokeWidth: 1,
                        );
                      },
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          //showTitles: true,
                          getTitlesWidget: (value, meta) => Text(
                            value.toString(),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 1,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          //showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              value.toString(),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 1,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    minX: 0,
                    maxX: 12,
                    minY: 0,
                    maxY: 20,
                    lineBarsData: [
                      LineChartBarData(
                        spots: [
                          const FlSpot(1, 1),
                          const FlSpot(2, 3),
                          const FlSpot(3, 4),
                          const FlSpot(4, 3.5),
                          const FlSpot(5, 4.5),
                          const FlSpot(6, 5),
                          const FlSpot(7, 20),
                          const FlSpot(8, 4),
                          const FlSpot(9, 2),
                          const FlSpot(10, 2.5),
                          const FlSpot(11, 3),
                          const FlSpot(12, 3.5),
                        ],
                        showingIndicators: [5],
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PieChartSample extends StatelessWidget {
  const PieChartSample({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Container(
        //width: 400,
        height: 350,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
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
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.blue.withOpacity(0.1),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: canvasColor.withOpacity(0.1),
              blurRadius: 10,
            )
          ],
          //color: Colors.blue,
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // const SizedBox(
              //   height: 5,
              // ),
              // const Row(
              //   mainAxisAlignment: MainAxisAlignment.start,
              //   children: [
              //     Text(
              //       'TIPOS DE MISSÕES',
              //       style: TextStyle(
              //         color: Colors.white,
              //         fontSize: 13,
              //       ),
              //     ),
              //   ],
              // ),
              // const SizedBox(
              //   height: 10,
              // ),
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2, // Espaço entre as seções
                    centerSpaceRadius: 30, // Raio do espaço central
                    sections: [
                      PieChartSectionData(
                        color: Colors.blue,
                        value: 25, // 25%
                        title: '25%',
                        radius: 50,
                      ),
                      PieChartSectionData(
                        color: Colors.red,
                        value: 15, // 30%
                        title: '15%',
                        radius: 50,
                      ),
                      PieChartSectionData(
                        color: Colors.green,
                        value: 45, // 45%
                        title: '45%',
                        radius: 50,
                      ),
                      PieChartSectionData(
                        color: Colors.yellow,
                        value: 15, // 20%
                        title: '15%',
                        radius: 50,
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 15),
                child: Column(
                  children: [
                    // Legenda para 'Preservação'
                    LegendWidget(color: Colors.blue, text: 'Preservação'),
                    // Legenda para 'Acompanhamento'
                    LegendWidget(color: Colors.red, text: 'Acompanhamento'),
                    // Legenda para 'Varredura'
                    LegendWidget(color: Colors.green, text: 'Varredura'),
                    // Legenda para 'Averiguação'
                    LegendWidget(color: Colors.yellow, text: 'Averiguação'),
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

class LegendWidget extends StatelessWidget {
  final Color color;
  final String text;

  const LegendWidget({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
