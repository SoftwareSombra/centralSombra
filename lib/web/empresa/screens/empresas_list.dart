import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/get_empresas_bloc.dart';
import '../bloc/get_empresas_event.dart';
import '../bloc/get_empresas_state.dart';
import '../model/empresa_model.dart';
import 'add_empresa.dart';
import 'empresa_details.dart';

class EmpresasScreen extends StatelessWidget {
  const EmpresasScreen({super.key});

  List<DataColumn> get columns => const [
        DataColumn(label: Text('Nome da empresa')),
        DataColumn(label: Text('CNPJ')),
        DataColumn(label: Text('Prazo do contrato inicio')),
        DataColumn(label: Text('Prazo do contrato fim')),
        DataColumn(label: Text('Opções')),
      ];

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<GetEmpresasBloc>(context).add(GetEmpresas());
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        elevation: 0,
      ),
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
            return Column(
              children: [
                Container(
                  color: const Color.fromARGB(255, 3, 9, 18),
                  width: width * 0.99,
                  child: state.empresas!.isNotEmpty
                      ? PaginatedDataTable(
                          // headingRowColor: const MaterialStatePropertyAll(
                          //   Color.fromARGB(255, 8, 8, 11),
                          // ),
                          columns: columns,
                          source: EmpresaDataSource(
                              empresas: state.empresas!, context: context),
                          header: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Empresas cadastradas'),
                              SizedBox(
                                width: width * 0.2,
                                height: 31,
                                child: TextFormField(
                                  cursorHeight: 12,
                                  decoration: InputDecoration(
                                    labelText: 'Buscar empresa pelo CNPJ',
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
                            ],
                          ),
                          columnSpacing:
                              MediaQuery.of(context).size.width * 0.05,
                          showCheckboxColumn: false,
                          rowsPerPage: state.empresas!.length < 10
                              ? state.empresas!.length
                              : 10,
                        )
                      : const Center(
                          child: Text('Nenhuma empresa cadastrada'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  backgroundColor: const Color.fromARGB(255, 3, 9, 18),
                  content: SizedBox(
                    height: height * 0.8,
                    width: width * 0.8,
                    child: const AddEmpresaScreen(),
                  ),
                );
              });
        },
        backgroundColor: Colors.blue.withOpacity(0.11),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

class EmpresaDataSource extends DataTableSource {
  List<Empresa> empresas;
  final BuildContext context;
  EmpresaDataSource({required this.empresas, required this.context});

  @override
  DataRow? getRow(int index) {
    assert(index >= 0);
    if (index >= empresas.length) {
      return null;
    }
    final empresa = empresas[index];

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
              // const SizedBox(
              //   width: 2,
              // ),
              Text(empresa.nomeEmpresa)
            ],
          ),
        ),
        DataCell(Text(empresa.cnpj)),
        DataCell(
            Text(DateFormat('dd/MM/yyyy').format(empresa.prazoContratoInicio))),
        DataCell(
            Text(DateFormat('dd/MM/yyyy').format(empresa.prazoContratoFim))),
        DataCell(
          Row(
            children: [
              MouseRegion(
                cursor: MaterialStateMouseCursor.clickable,
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.edit,
                        color: Colors.blue.withOpacity(0.8),
                        size: 15,
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      const Text(
                        'Editar',
                        style: TextStyle(
                          //color: Colors.blue,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              MouseRegion(
                cursor: MaterialStateMouseCursor.clickable,
                child: GestureDetector(
                  onTap: () {},
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete,
                        color: Colors.red.withOpacity(0.8),
                        size: 15,
                      ),
                      const SizedBox(
                        height: 1,
                      ),
                      const Text(
                        'Excluir',
                        style: TextStyle(
                          //color: Colors.red,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              MouseRegion(
                cursor: MaterialStateMouseCursor.clickable,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmpresaDetails(empresa: empresa),
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
  int get rowCount => empresas.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
