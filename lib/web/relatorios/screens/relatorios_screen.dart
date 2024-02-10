import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import '../../../missao/model/missao_model.dart';
import '../services/relatorio_services.dart';
import 'detalhes_missao_select.dart';

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
        DataColumn(label: Text('Início')),
        DataColumn(label: Text('ID da missão')),
        DataColumn(label: Text('')),
      ];

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    debugPrint('chegou aqui');

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  ResponsiveRowColumn(
                    layout:
                        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                            ? ResponsiveRowColumnType.COLUMN
                            : ResponsiveRowColumnType.ROW,
                    rowMainAxisAlignment: MainAxisAlignment.start,
                    children: const [
                      ResponsiveRowColumnItem(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 100, vertical: 15),
                          child: Text(
                            'Buscar missões:',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  ResponsiveRowColumn(
                    layout:
                        ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
                            ? ResponsiveRowColumnType.COLUMN
                            : ResponsiveRowColumnType.ROW,
                    rowMainAxisAlignment: MainAxisAlignment.start,
                    //rowPadding: const EdgeInsets.symmetric(horizontal: 100),
                    children: [
                      ResponsiveRowColumnItem(
                        child: ResponsiveRowColumn(
                          layout: ResponsiveBreakpoints.of(context)
                                  .smallerThan(DESKTOP)
                              ? ResponsiveRowColumnType.COLUMN
                              : ResponsiveRowColumnType.ROW,
                          rowMainAxisAlignment: MainAxisAlignment.start,
                          //rowPadding: const EdgeInsets.symmetric(horizontal: 100),
                          children: [
                            ResponsiveRowColumnItem(
                              child: Padding(
                                padding: EdgeInsets.only(left: width * 0.1),
                                child: SizedBox(
                                  width: width * 0.4,
                                  height: 40,
                                  child: TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Buscar missão pelo ID',
                                      suffixIcon: Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            ResponsiveRowColumnItem(
                              child: Padding(
                                padding: EdgeInsets.only(right: width * 0.05),
                                child: IconButton(
                                  icon: const Icon(Icons.filter_list),
                                  onPressed: () {
                                    // Coloque a lógica do filtro aqui
                                  },
                                ),
                              ),
                            ),
                            const ResponsiveRowColumnItem(
                              child: Text('de'),
                            ),
                            const ResponsiveRowColumnItem(
                              child: SizedBox(
                                width: 5,
                              ),
                            ),
                            ResponsiveRowColumnItem(
                              child: DropdownButton<String>(
                                hint: const Text(
                                  "data",
                                  style: TextStyle(color: Colors.grey),
                                ),

                                // Defina a largura do dropdown se necessário, ou deixe como está para ajuste automático
                                // A lógica para determinar o valor selecionado e as ações do onChanged devem ser implementadas
                                value: _selectedFilterOption,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedFilterOption = newValue;
                                  });
                                },
                                items: <String>[
                                  'Data 1',
                                  'Data 2',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                            const ResponsiveRowColumnItem(
                              child: SizedBox(
                                width: 20,
                              ),
                            ),
                            const ResponsiveRowColumnItem(
                              child: Text('até'),
                            ),
                            const ResponsiveRowColumnItem(
                              child: SizedBox(
                                width: 5,
                              ),
                            ),
                            ResponsiveRowColumnItem(
                              child: DropdownButton<String>(
                                hint: const Text(
                                  "data",
                                  style: TextStyle(color: Colors.grey),
                                ),

                                // Defina a largura do dropdown se necessário, ou deixe como está para ajuste automático
                                // A lógica para determinar o valor selecionado e as ações do onChanged devem ser implementadas
                                value: _selectedFilterOption,
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedFilterOption = newValue;
                                  });
                                },
                                items: <String>[
                                  'Data 1',
                                  'Data 2',
                                ].map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const ResponsiveRowColumnItem(
                    child: SizedBox(
                      height: 20,
                    ),
                  ),
                  ResponsiveRowColumnItem(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.1),
                      child: FutureBuilder<List<MissaoRelatorio?>>(
                        future: missoesConcluidasFuture,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<MissaoRelatorio?>> snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                                child: Text('Erro: ${snapshot.error}'));
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData) {
                            return const Center(
                                child: Text('Nenhum relatório disponível'));
                          }

                          List<TableRow> missionRows =
                              snapshot.data!.map((MissaoRelatorio? missao) {
                            // Verifica se o objeto Missao não é nulo
                            if (missao != null) {
                              return 
                              TableRow(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(missao
                                        .tipo), // Substitua 'tipo' pelo campo correspondente na sua classe Missao
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(missao.inicio != null
                                        ? DateFormat('dd/MM/yyyy HH:mm')
                                            .format(missao.inicio!.toDate())
                                        : 'N/A'),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(missao
                                        .missaoId), // Substitua 'id' pelo campo correspondente na sua classe Missao
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                MissionDetails(
                                              missaoId: missao.missaoId,
                                              agenteId: missao.uid,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text('Ver detalhes'),
                                    ),
                                  ),
                                ],
                              );
                            } else {
                              return TableRow(children: [
                                Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Text('Dados não disponíveis')),
                                // Outros containers vazios ou com textos placeholder podem ser adicionados aqui
                              ]);
                            }
                          }).toList();

                          return Table(
                            border: TableBorder.all(),
                            columnWidths: const {
                              0: FractionColumnWidth(0.25),
                              1: FractionColumnWidth(0.25),
                              2: FractionColumnWidth(0.25),
                              3: FractionColumnWidth(0.25),
                            },
                            children: [
                              TableRow(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Text('Tipo'),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Text('Data de início'),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Text('ID da missão'),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: const Text(''),
                                  ),
                                ],
                              ),
                              ...missionRows, // Adiciona as linhas de missões aqui
                            ],
                          );
                        },
                      ),
                    ),
                  )
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
  List<MissaoRelatorio> missoes;
  EmpresaDataSource({required this.missoes});

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= missoes.length) {
      return null;
    }
    final missao = missoes[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(
          Row(
            children: [
              Checkbox(
                value: false,
                onChanged: (value) {
                  value = !value!;
                },
              ),
              const SizedBox(
                width: 2,
              ),
              SelectableText(missao.tipo),
            ],
          ),
        ),
        DataCell(
          SelectableText(missao.fim != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(missao.fim!.toDate())
              : 'N/A'),
        ),
        DataCell(
          SelectableText(missao.missaoId),
        ),
        DataCell(
          IconButton(
            // Adicione um IconButton para ver detalhes
            icon: const Icon(Icons.arrow_forward),
            onPressed: () {
              // Navegue para a tela de detalhes
            },
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
