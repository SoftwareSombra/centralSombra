import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../paginated_data_table/paginated_data_table.dart';
import '../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc.dart';
import '../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_event.dart';
import '../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_state.dart';
import '../../admin/services/admin_services.dart';
import '../bloc/get_empresas_bloc.dart';
import '../bloc/get_empresas_event.dart';
import '../bloc/get_empresas_state.dart';
import '../model/empresa_model.dart';
import 'add_empresa.dart';
import 'empresa_details.dart';

class EmpresasScreen extends StatefulWidget {
  const EmpresasScreen({super.key});

  @override
  State<EmpresasScreen> createState() => _EmpresasScreenState();
}

class _EmpresasScreenState extends State<EmpresasScreen> {
  final canvasColor = const Color.fromARGB(255, 0, 15, 42);
  TextEditingController searchController = TextEditingController();
  List<Empresa> empresas = [];
  List<DataColumn> get columns => const [
        DataColumn(label: Text('Nome da empresa')),
        DataColumn(label: Text('CNPJ')),
        DataColumn(label: Text('Prazo do contrato inicio')),
        DataColumn(label: Text('Prazo do contrato fim')),
        DataColumn(label: Text('Opções')),
      ];
  List<Empresa> filtrarEmpresas(List<Empresa> empresas, String searchText) {
    searchText = searchText.toLowerCase();
    return empresas.where((empresas) {
      return empresas.nomeEmpresa.toLowerCase().contains(searchText);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<GetEmpresasBloc>(context).add(GetEmpresas());
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
            empresas = state.empresas!;

            List<Empresa> empresasFiltradas =
                filtrarEmpresas(empresas, searchController.text.toLowerCase());

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
                            labelText: 'Buscar empresa pelo nome',
                            labelStyle: TextStyle(
                                color: Colors.grey[500], fontSize: 12),
                            suffixIcon: Icon(
                              Icons.search,
                              size: 20,
                              color: Colors.grey[500]!,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[500]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[500]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey[500]!),
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
                Container(
                  color: const Color.fromARGB(255, 3, 9, 18),
                  width: width * 0.99,
                  child: empresasFiltradas.isNotEmpty
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
                          // headingRowColor: const MaterialStatePropertyAll(
                          //   Color.fromARGB(255, 8, 8, 11),
                          // ),
                          columns: columns,
                          source: EmpresaDataSource(
                              empresas: empresasFiltradas, context: context),
                          header: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Empresas cadastradas'),
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

  final AdminServices adminServices = AdminServices();
  final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();
  final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();

  //dialogo de exclusão
  void _showDialog(Empresa empresa) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 3, 9, 18),
          title: const Text('Confirmação'),
          content: const Text('Deseja realmente excluir esta empresa?'),
          actions: <Widget>[
            BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
              builder: (buttonContext, buttonState) {
                return buttonState is ElevatedButtonBlocLoading
                    ? const CircularProgressIndicator()
                    : Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () async {
                              buttonContext.read<ElevatedButtonBloc>().add(
                                    ElevatedButtonPressed(),
                                  );
                              final delete = await adminServices
                                  .deleteEmpresa(empresa.cnpj);
                              if (context.mounted) {
                                if (delete) {
                                  mensagemDeSucesso.showSuccessSnackbar(
                                      context, 'Empresa excluída com sucesso.');
                                } else {
                                  tratamentoDeErros.showErrorSnackbar(context,
                                      'Erro ao excluir empresa, tente novamente.');
                                }
                                context
                                    .read<GetEmpresasBloc>()
                                    .add(GetEmpresas());
                                buttonContext.read<ElevatedButtonBloc>().add(
                                      ElevatedButtonReset(),
                                    );
                                Navigator.of(context).pop();
                              }
                            },
                            child: const Text('Confirmar'),
                          ),
                        ],
                      );
              },
            ),
          ],
        );
      },
    );
  }

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
                  onTap: () {
                    _showDialog(empresa);
                  },
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
                        builder: (context) => EmpresaDetails(
                          empresa: empresa,
                          context: context,
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
  int get rowCount => empresas.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;
}
