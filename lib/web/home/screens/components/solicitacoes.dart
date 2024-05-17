import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_grid/responsive_grid.dart';
import '../../../../agente/bloc/solicitacoes/events.dart';
import '../../../../agente/bloc/solicitacoes/solicitacoes_agente_bloc.dart';
import '../../../../agente/services/agente_services.dart';
import '../../../../conta_bancaria/bloc/solicitacoes_conta_bancaria_bloc.dart';
import '../../../../conta_bancaria/bloc/solicitacoes_conta_bancaria_event.dart';
import '../../../../conta_bancaria/services/conta_bancaria_services.dart';
import '../../../../veiculos/bloc/solicitacoes_list/events.dart';
import '../../../../veiculos/bloc/solicitacoes_list/solicitacoes_veiculos_bloc.dart';
import '../../../../veiculos/services/veiculos_services.dart';
import 'solicitacoes/agente.dart';
import 'solicitacoes/conta_bancaria.dart';
import 'solicitacoes/veiculos.dart';

class SolicitacoesComponent extends StatelessWidget {
  const SolicitacoesComponent({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            vertical: 0,
            horizontal: width < 800 ? width * 0.04 : width * 0.08,
          ),
          child: ResponsiveGridRow(
            crossAxisAlignment: CrossAxisAlignment.center,
            rowSegments: 6,
            children: [
              ResponsiveGridCol(
                xs: 3,
                md: 2,
                child: container(
                  'Solicitações',
                  'Cadastro',
                  Icons.person,
                  const CadastroListDialog(),
                  context,
                  AgenteServices().existeDocumentoAguardandoAprovacao(),
                ),
              ),
              ResponsiveGridCol(
                xs: 3,
                md: 2,
                child: container(
                  'Solicitações',
                  'Veículos',
                  Icons.directions_car,
                  const VeiculoListDialog(),
                  context,
                  VeiculoServices().existeDocumentoAguardandoAprovacao(),
                ),
              ),
              ResponsiveGridCol(
                xs: 3,
                md: 2,
                child: container(
                  'Solicitações',
                  'Conta Bancária',
                  Icons.file_copy,
                  const ContaBancariaListDialog(),
                  context,
                  ContaBancariaServices().existeDocumentoAguardandoAprovacao(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget container(subtitle, title, icon, Widget dialogo, BuildContext context,
    Stream<bool> stream) {
  const canvasColor = Color.fromARGB(255, 0, 15, 42);
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: GestureDetector(
      child: MouseRegion(
        cursor: MaterialStateMouseCursor.clickable,
        child: Container(
          height: 52,
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
            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subtitle,
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                          const SizedBox(
                            height: 1,
                          ),
                          Text(
                            title,
                            style: const TextStyle(fontSize: 14),
                          )
                        ],
                      ),
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Icon(
                            icon,
                            color: Colors.white,
                            size: 24,
                          ),
                          StreamBuilder<bool>(
                            stream: stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<bool> snapshot) {
                              if (snapshot.hasData && snapshot.data == true) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 1),
                                  ),
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        if (title == 'Cadastro') {
          context.read<AgenteSolicitacaoBloc>().add(FetchAgenteSolicitacoes());
        } else if (title == 'Veículos') {
          context
              .read<VeiculoSolicitacaoBloc>()
              .add(FetchVeiculoSolicitacoes());
        } else if (title == 'Conta Bancária') {
          context
              .read<SolicitacoesContaBancariaBloc>()
              .add(FetchSolicitacoesContaBancaria());
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return dialogo;
          },
        );
      },
    ),
  );
}
