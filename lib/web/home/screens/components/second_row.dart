import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '../../../../missao/bloc/missoes_pendentes/qtd_missoes_pendentes_bloc.dart';
import '../../../../missao/bloc/missoes_pendentes/qtd_missoes_pendentes_state.dart';
import '../../../../missao/screens/missoes_pendentes/missoes_pendentes_screen.dart';
import '../../../../missao/services/missao_services.dart';
import '../../../missoes/criar_missao/screens/components/solicitacao_card.dart';
import 'solicitacoes/bloc/solicitacoes_bloc/notificacao_chat_bloc.dart';

class SecondRow extends StatelessWidget {
  const SecondRow({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 20,
            horizontal: width < 800 ? width * 0.04 : width * 0.08,
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
                md: 1,
                child: const MissoesPendentesContainer(),
              ),
              ResponsiveGridCol(
                xs: 3,
                md: 3,
                child: AttWidget(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MissoesPendentesContainer extends StatelessWidget {
  const MissoesPendentesContainer({super.key});

  static const canvasColor = Color.fromARGB(255, 0, 15, 42);
  final TextStyle defaultStyle = const TextStyle(fontSize: 100);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          //width: 400,
          height: 190,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Positioned(
                top: -16,
                left: 288,
                child: Icon(
                  Icons.access_time,
                  color: Colors.blue.withOpacity(0.05),
                  size: 100,
                ),
              ),
              const Positioned(
                top: 145,
                left: 330,
                child: Icon(Icons.arrow_forward, color: Colors.white),
              ),
              MouseRegion(
                cursor: WidgetStateMouseCursor.clickable,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Column(
                            //   children: [
                            //     Icon(
                            //       Icons.access_time,
                            //       color: Colors.white.withOpacity(0.3),
                            //       size: 100,
                            //     ),
                            //   ],
                            // ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5, top: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AutoSizeText(
                                    'MISSÕES PENDENTES',
                                    maxFontSize: 20,
                                    minFontSize: 18,
                                    style: TextStyle(
                                        fontSize: 100,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(
                                    height: 1,
                                  ),
                                  BlocBuilder<QtdMissoesPendentesBloc,
                                      QtdMissoesPendentesState>(
                                    builder: (context, qtdState) {
                                      if (qtdState
                                          is QtdMissoesPendentesLoading) {
                                        return const CircularProgressIndicator();
                                      } else if (qtdState
                                          is QtdMissoesPendentesLoaded) {
                                        return AutoSizeText(
                                            qtdState.qtd.toString(),
                                            maxFontSize: 41,
                                            minFontSize: 18,
                                            style: defaultStyle);
                                      } else if (qtdState
                                          is QtdMissoesPendentesEmpty) {
                                        return AutoSizeText('0',
                                            maxFontSize: 41,
                                            minFontSize: 18,
                                            style: defaultStyle);
                                      } else if (qtdState
                                          is QtdMissoesPendentesError) {
                                        return AutoSizeText(
                                            'Erro, atualize a página',
                                            maxFontSize: 12,
                                            minFontSize: 9,
                                            maxLines: 2,
                                            style: defaultStyle);
                                      }
                                      // Tratamento do estado inicial ou qualquer outro estado não capturado
                                      return AutoSizeText('Atualize a página',
                                          maxFontSize: 12,
                                          minFontSize: 9,
                                          maxLines: 2,
                                          style: defaultStyle);
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
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
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MissoesPendentesScreen(),
          ),
        );
      },
    );
  }
}

class AttWidget extends StatelessWidget {
  AttWidget({super.key});

  static const canvasColor = Color.fromARGB(255, 0, 15, 42);
  final MissaoServices _missaoServices = MissaoServices();
  final ScrollController missoesScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white
        ),
        child:
            // Stack(
            //   children: [
            //     // Positioned(
            //     //   top: -16,
            //     //   left: MediaQuery.of(context).size.width * 0.548,
            //     //   child: Icon(
            //     //     Icons.new_releases_outlined,
            //     //     color: Colors.blue.withOpacity(0.1),
            //     //     size: 100,
            //     //   ),
            //     // ),
            //     const Positioned(
            //       top: 145,
            //       left: 1095,
            //       child: Icon(Icons.arrow_forward, color: Colors.white),
            //     ),
            //     GestureDetector(
            //       child: Padding(
            //         padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 3),
            //         child: Row(
            //           children: [
            //             Expanded(
            //               child: Row(
            //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //                 children: [
            // Column(
            //   children: [
            //     Icon(
            //       Icons.access_time,
            //       color: Colors.white.withOpacity(0.3),
            //       size: 100,
            //     ),
            //   ],
            // ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 5, top: 10),
            //   child:
            // Column(
            //   crossAxisAlignment: CrossAxisAlignment.start,
            //   children: [
            //     const Row(
            //       children: [
            //         AutoSizeText(
            //           'ATUALIZAÇÕES',
            //           maxFontSize: 20,
            //           minFontSize: 18,
            //           style: TextStyle(
            //               fontSize: 100,
            //               fontWeight: FontWeight.w400),
            //         ),
            //       ],
            //     ),
            //     const SizedBox(
            //       height: 1,
            //     ),
            //     Container(
            //       width:
            //           MediaQuery.of(context).size.width * 0.5,
            //       child: const AutoSizeText(
            //         'O relatório da missão XXXXXXXXXXXXXXXXXXXXXX foi enviado hoje às 18:30h',
            //         maxFontSize: 14,
            //         minFontSize: 10,
            //         textAlign: TextAlign.start,
            //         style: TextStyle(
            //             fontSize: 14, color: Colors.grey),
            //       ),
            //     ),
            //   ],
            // ),
            Stack(
          children: [
            BlocBuilder<MissoesSolicitadasStreamBloc,
                MissoesSolicitadasStreamState>(
              builder: (context, missoesStreamState) {
                if (missoesStreamState is MissoesSolicitadasStreamError) {
                  return const Center(
                      child: Text('Erro ao buscar missoes solicitadas.'));
                }

                if (missoesStreamState is MissoesSolicitadasStreamLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (missoesStreamState is MissoesSolicitadasStreamLoaded) {
                  return missoesStreamState.missoesSolicitadas.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                textAlign: TextAlign.center,
                                'SEM SOLICITAÇÃO NO MOMENTO',
                                maxFontSize: 20,
                                minFontSize: 18,
                                style: TextStyle(
                                    fontSize: 100, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(
                              //horizontal: 30,
                              horizontal: 15),
                          child: ListView.builder(
                            //physics: const NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            controller: missoesScrollController,
                            shrinkWrap: true,
                            itemCount:
                                missoesStreamState.missoesSolicitadas.length,
                            itemBuilder: (context, index) {
                              return SolicitacaoMissaoCard(
                                missaoSolicitada: missoesStreamState
                                    .missoesSolicitadas[index],
                                padding: false,
                                home: true,
                              );
                            },
                          ),
                        );
                } else {
                  return const Center(
                      child: Text('Falha na conexão, atualize a tela'));
                }
              },
            ),
            Positioned(
              left: 0, //adjust the position as needed
              top: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                // seta para a esquerda
                onPressed: () {
                  // Aqui, você implementa a lógica para rolar a ListView para a esquerda
                  missoesScrollController.animateTo(
                    missoesScrollController.offset - 300,
                    // 200 é o valor que você quer rolar. Ajuste conforme necessário
                    curve: Curves.linear,
                    duration: const Duration(milliseconds: 500),
                  );
                },
              ),
            ),
            Positioned(
              right: 0, //adjust the position as needed
              top: 0,
              bottom: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                // seta para a direita
                onPressed: () {
                  missoesScrollController.animateTo(
                    missoesScrollController.offset + 300,
                    curve: Curves.linear,
                    duration: const Duration(milliseconds: 400),
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
