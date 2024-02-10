import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/get_empresas_bloc.dart';
import '../bloc/get_empresas_event.dart';
import '../bloc/get_empresas_state.dart';
import '../model/empresa_model.dart';
import 'add_empresa.dart';

class EmpresasScreen extends StatelessWidget {
  const EmpresasScreen({super.key});

  List<DataColumn> get columns => const [
        DataColumn(label: Text('Nome da empresa')),
        DataColumn(label: Text('CNPJ')),
        DataColumn(label: Text('Prazo do contrato inicio')),
        DataColumn(label: Text('Prazo do contrato fim')),
        DataColumn(label: Text('Ver detalhes')),
      ];

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<GetEmpresasBloc>(context).add(GetEmpresas());
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<GetEmpresasBloc, GetEmpresasState>(
        builder: (context, state) {
          if (state is GetEmpresasInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is GetEmpresasLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is GetEmpresasError) {
            return Center(
              child: Text(state.message),
            );
          } else if (state is GetEmpresasLoaded) {
            return Center(
              child: Container(
                width: width * 0.99,
                child: state.empresas!.isNotEmpty ? PaginatedDataTable(
                  columns: columns,
                  source: EmpresaDataSource(empresas: state.empresas!),
                  header: const Text('Empresas'),
                  columnSpacing: MediaQuery.of(context).size.width * 0.05,
                  showCheckboxColumn: true,
                  rowsPerPage:
                      state.empresas!.length < 10 ? state.empresas!.length : 10,
                ) : const Center(
                  child: Text('Nenhuma empresa cadastrada'),
                )
              ),
            );
          } else {
            return const Center(
              child: Text('Recarregue a página'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEmpresaScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EmpresaDataSource extends DataTableSource {
  List<Empresa> empresas;
  EmpresaDataSource({required this.empresas});

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= empresas.length) {
      return null;
    }
    final empresa = empresas[index];

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
              Text(empresa.nomeEmpresa)
            ],
          ),
        ),
        DataCell(Text(empresa.cnpj)),
        DataCell(
            Text(DateFormat('dd/MM/yyyy').format(empresa.prazoContratoInicio))),
        DataCell(
            Text(DateFormat('dd/MM/yyyy').format(empresa.prazoContratoFim))),
        DataCell(IconButton(
          // Adicione um IconButton para ver detalhes
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            // Navegue para a tela de detalhes
          },
        )),
      ],
    );
  }

  @override
  int get rowCount => empresas.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
