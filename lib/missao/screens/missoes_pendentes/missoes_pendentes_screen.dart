import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '../../../web/missoes/criar_missao/screens/components/missoes_pendentes_card.dart';
import '../../bloc/missoes_pendentes/missoes_pendentes_bloc.dart';
import '../../bloc/missoes_pendentes/missoes_pendentes_event.dart';
import '../../bloc/missoes_pendentes/missoes_pendentes_state.dart';

class MissoesPendentesScreen extends StatefulWidget {
  const MissoesPendentesScreen({super.key});

  @override
  State<MissoesPendentesScreen> createState() => _MissoesPendentesScreenState();
}

class _MissoesPendentesScreenState extends State<MissoesPendentesScreen> {
  @override
  void initState() {
    context.read<MissoesPendentesBloc>().add(BuscarMissoesPendentes());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 9, 18),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 3, 9, 18),
        //title: const Text('Solicitações de Missão'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.084,
                  right: MediaQuery.of(context).size.width * 0.08,
                  bottom: 20),
              child: ResponsiveRowColumn(
                layout: ResponsiveBreakpoints.of(context).smallerThan(DESKTOP)
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
                          backgroundImage:
                              AssetImage('assets/images/fotoDePerfilNull.jpg'),
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
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 11),
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
                            onPressed: () {
                              context
                                  .read<MissoesPendentesBloc>()
                                  .add(BuscarMissoesPendentes());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 0.084,
                  right: MediaQuery.of(context).size.width * 0.08,
                  bottom: 20),
              child: BlocBuilder<MissoesPendentesBloc, MissoesPendentesState>(
                builder: (context, state) {
                  if (state is MissoesPendentesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is MissoesPendentesEmpty) {
                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        Card(
                          color: Colors.black,
                          elevation: 1,
                          margin: EdgeInsets.all(8.0),
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text('Nenhuma missão encontrada'),
                          ),
                        ),
                      ],
                    );
                  } else if (state is MissoesPendentesLoaded) {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          child: Container(
                            constraints: const BoxConstraints(
                              maxWidth: 2600,
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                debugPrint('maxWidth: ${constraints.maxWidth}');
                                int rowSegments = 12;
                                if (constraints.maxWidth < 600) {
                                  rowSegments = 2;
                                } else if (constraints.maxWidth < 800) {
                                  rowSegments = 4;
                                } else if (constraints.maxWidth < 1200) {
                                  rowSegments = 4;
                                } else if (constraints.maxWidth < 1400) {
                                  rowSegments = 6;
                                } else if (constraints.maxWidth < 1600) {
                                  rowSegments = 6;
                                } else if (constraints.maxWidth < 1800) {
                                  rowSegments = 8;
                                } else if (constraints.maxWidth < 2200) {
                                  rowSegments = 10;
                                } else if (constraints.maxWidth < 2600) {
                                  rowSegments = 12;
                                }
                                debugPrint('rowSegments: $rowSegments');
                                return ResponsiveGridRow(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  rowSegments: rowSegments,
                                  children: [
                                    for (var missao in state.missoes)
                                       ResponsiveGridCol(
                                        xs: 3,
                                        md: 2,
                                        child: MissaoPendenteCard(
                                          missaoSolicitada: missao,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                    //  ResponsiveGridRow(
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   rowSegments: 6,
                    //   children: [
                    //     //para cada missão solicitada, criar um card
                    //     for (var missao in state.missoes)
                    //       ResponsiveGridCol(
                    //         xs: 3,
                    //         md: 2,
                    //         child: SolicitacaoMissaoCard(
                    //           missaoSolicitada: missao,
                    //         ),
                    //       ),
                    //   ],
                    // ),
                    //);
                    // GridView.builder(
                    //   padding: const EdgeInsets.all(12.0),
                    //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //     crossAxisCount: cardCount,
                    //     crossAxisSpacing: 12.0,
                    //     mainAxisSpacing: 12.0,
                    //   ),
                    //   itemCount: state.missoes.length,
                    //   itemBuilder: (context, index) {
                    //     return BlocProvider<MissaoSolicitacaoCardBloc>(
                    //       create: (context) => MissaoSolicitacaoCardBloc(),
                    //       child:
                    //  SolicitacaoMissaoCard(
                    //   missaoSolicitada: state.missoes[index],
                    // ),
                    //     );
                    //   },
                    // );
                  }
                  //else if (state is MissoesPendentesNotFound) {
                  //   return const Center(
                  //     child: Text(
                  //       'Nenhuma solicitação encontrada',
                  //       style: TextStyle(color: Colors.white),
                  //     ),
                  //   );
                  // }
                  else if (state is MissoesPendentesError) {
                    return Center(
                        child: Text(
                      'Erro: ${state.error}',
                      style: const TextStyle(color: Colors.white),
                    ));
                  }
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Algum erro ocorrreu, reinicie a página.',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
