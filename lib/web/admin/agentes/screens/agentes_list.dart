import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/agentes_list_bloc.dart';
import '../bloc/agentes_list_event.dart';
import '../bloc/agentes_list_state.dart';
import '../model/agente_model.dart';

class AgentesList extends StatelessWidget {
  const AgentesList({super.key});

  List<DataColumn> get columns => const [
        DataColumn(label: Text('Nome')),
        DataColumn(label: Text('UID')),
        DataColumn(label: Text('Telefone')),
        DataColumn(label: Text('Nível')),
        DataColumn(label: Text('Ver detalhes')),
      ];

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<AgentesListBloc>(context).add(FetchAgentesList());
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<AgentesListBloc, AgentesListState>(
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
            return Center(
              child: Container(
                width: width * 0.99,
                child: state.agentes.isNotEmpty
                    ? PaginatedDataTable(
                        columns: columns,
                        source: EmpresaDataSource(agentes: state.agentes),
                        header: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Agentes'),
                            SizedBox(
                              width: width * 0.4,
                              height: 40,
                              child: TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Buscar agente pelo nome',
                                  labelStyle: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  suffixIcon: Icon(Icons.search),
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
                          ],
                        ),
                        columnSpacing: MediaQuery.of(context).size.width * 0.05,
                        showCheckboxColumn: true,
                        rowsPerPage: state.agentes.length < 10
                            ? state.agentes.length
                            : 10,
                      )
                    : const Center(
                        child: Text('Nenhum agente cadastrado'),
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
    );
  }
}

class EmpresaDataSource extends DataTableSource {
  List<AgenteAdmList> agentes;
  EmpresaDataSource({required this.agentes});

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= agentes.length) {
      return null;
    }
    final agente = agentes[index];

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
              SelectableText(agente.nome),
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
  int get rowCount => agentes.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
