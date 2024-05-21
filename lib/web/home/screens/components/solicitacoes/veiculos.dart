import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/web/home/screens/components/solicitacoes/agente.dart';
import '../../../../../veiculos/bloc/solicitacoes_list/solicitacoes_veiculos_bloc.dart';
import '../../../../../veiculos/bloc/solicitacoes_list/states.dart';
import '../../../../../veiculos/model/veiculo_model.dart';
import '../../../../../veiculos/services/veiculos_services.dart';

class VeiculoListDialog extends StatelessWidget {
  const VeiculoListDialog({super.key});

  static const bgColor = Color.fromARGB(255, 0, 1, 5);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VeiculoSolicitacaoBloc, VeiculoSolicitacaoState>(
      builder: (context, state) {
        if (state is VeiculoSolicitacaoLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is VeiculoSolicitacaoNotFound) {
          return AlertDialog(
            backgroundColor: bgColor,
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Solicitações de Cadastro'),
              ],
            ),
            content: const Text('Nenhuma solicitação encontrada.'),
            actions: [
              TextButton(
                child: const Text('Fechar'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        }
        if (state is VeiculoSolicitacaoLoaded) {
          return ListView.builder(
            itemCount: state.veiculo.length,
            itemBuilder: (context, index) {
              return AlertDialog(
                backgroundColor: bgColor,
                title: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Solicitações de Cadastro'),
                  ],
                ),
                content: Container(
                  height: MediaQuery.of(context).size.height * 0.8,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CadastroVeiculoList(veiculo: state.veiculo[index]),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    child: const Text('Fechar'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        }
        if (state is VeiculoSolicitacaoError) {
          return Center(
            child: Text('Erro: ${state.message}'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class CadastroVeiculoList extends StatelessWidget {
  final Veiculo veiculo;
  const CadastroVeiculoList({super.key, required this.veiculo});
  static const bgColor = Color.fromARGB(255, 0, 1, 5);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MouseRegion(
        cursor: MaterialStateMouseCursor.clickable,
        child: Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Agente: ${veiculo.nome}'),
                    Text(
                      veiculo.placa,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  ],
                ),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: bgColor,
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DETALHES',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Container(
                height: 480,
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      VeiculoCard(
                        veiculo: veiculo,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Fechar'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class VeiculoCard extends StatefulWidget {
  final Veiculo veiculo;

  const VeiculoCard({super.key, required this.veiculo});

  @override
  _VeiculoCardState createState() => _VeiculoCardState();
}

class _VeiculoCardState extends State<VeiculoCard> {
  final VeiculoServices veiculoServices = VeiculoServices();
  Map<String, bool> camposParaReprovar = {
    'nome': false,
    'placa': false,
    'marca': false,
    'modelo': false,
    'cor': false,
    'ano': false,
  };
  bool mostrarCheckboxes = false;

  void toggleCampo(String chaveCampo) {
    setState(() {
      camposParaReprovar[chaveCampo] = !camposParaReprovar[chaveCampo]!;
    });
  }

  Widget campoComCheckbox(String tituloCampo, String chaveCampo) {
    String valorCampo = getValorCampo(chaveCampo);

    return Row(
      children: [
        mostrarCheckboxes
            ? Checkbox(
                value: camposParaReprovar[chaveCampo],
                onChanged: (bool? value) {
                  toggleCampo(chaveCampo);
                },
              )
            : const SizedBox.shrink(),
        Text('$tituloCampo: $valorCampo'),
      ],
    );
  }

  String getValorCampo(String chaveCampo) {
    switch (chaveCampo) {
      case 'nome':
        return widget.veiculo.nome;
      case 'placa':
        return widget.veiculo.placa;
      case 'marca':
        return widget.veiculo.marca;
      case 'modelo':
        return widget.veiculo.modelo;
      case 'cor':
        return widget.veiculo.cor;
      case 'ano':
        return widget.veiculo.ano.toString();
      default:
        return '';
    }
  }

  void aprovarVeiculo() async {
    try {
      await veiculoServices.addVeiculo(
        widget.veiculo.nome,
        widget.veiculo.uid,
        widget.veiculo.placa,
        widget.veiculo.marca,
        widget.veiculo.modelo,
        widget.veiculo.cor,
        widget.veiculo.ano,
        widget.veiculo.timestamp,
      );
      await veiculoServices.solicitacaoRemove(
          widget.veiculo.uid, widget.veiculo.placa);
      await veiculoServices.excluirPendencias(widget.veiculo.uid);
      List<String> userTokens =
          await firebaseMessagingService.fetchUserTokens(widget.veiculo.uid);

      debugPrint('Tokens: $userTokens');

      for (String token in userTokens) {
        debugPrint('FCM Token: $token');
        try {
          await firebaseMessagingService.sendNotification(
              token, 'Cadastro', 'Veículos atualizados', 'cadastro');
        } catch (e) {
          debugPrint('Erro ao enviar notificação: $e');
        }
        debugPrint('Notificação enviada');
        if (context.mounted) {
          //context.read<AgenteSolicitacaoBloc>().add(FetchAgenteSolicitacoes());
          mensagemDeSucesso.showSuccessSnackbar(
              context, 'Veículo aprovado com sucesso');
        }
      }
    } catch (e) {
      if (context.mounted) {
        tratamentoDeErros.showErrorSnackbar(
          context,
          'Erro ao aprovar veículo',
        );
      }
      debugPrint(e.toString());
    }
  }

  void reprovarSelecionados() async {
    List<String> camposAprovados = [];
    List<String> camposReprovados = [];

    camposParaReprovar.forEach((chave, valor) {
      if (valor) {
        camposReprovados.add(chave);
      } else {
        camposAprovados.add(chave);
      }
    });

    if (camposReprovados.isNotEmpty) {
      _showRejectionConfirmationDialog(
        context,
        () async {
          try {
            await veiculoServices.rejeicaoParcial(
              widget.veiculo.uid,
              camposReprovados.contains('nome') ? widget.veiculo.placa : null,
              camposReprovados.contains('placa') ? widget.veiculo.placa : null,
              camposReprovados.contains('marca') ? widget.veiculo.marca : null,
              camposReprovados.contains('modelo')
                  ? widget.veiculo.modelo
                  : null,
              camposReprovados.contains('cor') ? widget.veiculo.cor : null,
              camposReprovados.contains('ano') ? widget.veiculo.ano : null,
            );

            await veiculoServices.aprovacaoParcial(
              widget.veiculo.uid,
              camposAprovados.contains('nome') ? widget.veiculo.placa : null,
              camposAprovados.contains('placa') ? widget.veiculo.placa : null,
              camposAprovados.contains('marca') ? widget.veiculo.marca : null,
              camposAprovados.contains('modelo') ? widget.veiculo.modelo : null,
              camposAprovados.contains('cor') ? widget.veiculo.cor : null,
              camposAprovados.contains('ano') ? widget.veiculo.ano : null,
            );
            debugPrint('Veículo rejeitado');
            await veiculoServices.solicitacaoRemove(
                widget.veiculo.uid, widget.veiculo.placa);
            debugPrint('Veículo removido da lista de solicitações');

            List<String> userTokens = await firebaseMessagingService
                .fetchUserTokens(widget.veiculo.uid);

            debugPrint('Tokens: $userTokens');

            for (String token in userTokens) {
              debugPrint('FCM Token: $token');
              try {
                await firebaseMessagingService.sendNotification(
                    token, 'Atualização', 'Veículos atualizados', 'cadastro');
              } catch (e) {
                debugPrint('Erro ao enviar notificação: $e');
              }
              debugPrint('Notificação enviada');
              if (context.mounted) {
                //Navigator.of(context).pop();
                mensagemDeSucesso.showSuccessSnackbar(
                    context, 'Veículo rejeitado com sucesso');
              }
            }
          } catch (e) {
            if (context.mounted) {
              tratamentoDeErros.showErrorSnackbar(
                context,
                'Erro ao reprovar veículo',
              );
            }
            debugPrint(e.toString());
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      //elevation: 4,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            campoComCheckbox('Nome', 'nome'),
            campoComCheckbox('Placa', 'placa'),
            campoComCheckbox('Marca', 'marca'),
            campoComCheckbox('Modelo', 'modelo'),
            campoComCheckbox('Cor', 'cor'),
            campoComCheckbox('Ano', 'ano'),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.green)),
                  onPressed: () {
                    showAcceptDialog(context, aprovarVeiculo);
                  },
                  child: const Text(
                    'Aprovar',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red)),
                  onPressed: () {
                    if (mostrarCheckboxes &&
                        camposParaReprovar.containsValue(true)) {
                      reprovarSelecionados();
                    } else {
                      setState(() {
                        mostrarCheckboxes = true;
                      });
                    }
                  },
                  child: const Text('Reprovar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showAcceptDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmação de Aprovação'),
          content: const Text(
              'Tem certeza de que deseja aprovar todos os dados do veículo? '),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showRejectionConfirmationDialog(
      BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação de Rejeição'),
          content: const Text(
              'Tem certeza de que deseja rejeitar os itens selecionados? '
              'Os itens não selecionados serão aceitos.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
