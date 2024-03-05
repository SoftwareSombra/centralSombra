import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/web/home/screens/components/solicitacoes/agente.dart';
import '../../../../../conta_bancaria/bloc/solicitacoes_conta_bancaria_bloc.dart';
import '../../../../../conta_bancaria/bloc/solicitacoes_conta_bancaria_event.dart';
import '../../../../../conta_bancaria/bloc/solicitacoes_conta_bancaria_state.dart';
import '../../../../../conta_bancaria/model/conta_bancaria_model.dart';
import '../../../../../conta_bancaria/services/conta_bancaria_services.dart';

class ContaBancariaListDialog extends StatelessWidget {
  const ContaBancariaListDialog({super.key});

  static const bgColor = Color.fromARGB(255, 0, 1, 5);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SolicitacoesContaBancariaBloc,
        SolicitacoesContaBancariaState>(
      builder: (context, state) {
        if (state is SolicitacoesContaBancariaLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SolicitacoesContaBancariaNotFound) {
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
        if (state is SolicitacoesContaBancariaLoaded) {
          return ListView.builder(
            itemCount: state.conta.length,
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
                        CadastroContaBancariaList(conta: state.conta[index]),
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
        if (state is SolicitacoesContaBancariaError) {
          return Center(
            child: Text('Erro: ${state.message}'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class CadastroContaBancariaList extends StatelessWidget {
  final ContaBancaria conta;
  const CadastroContaBancariaList({super.key, required this.conta});
  static const bgColor = Color.fromARGB(255, 0, 1, 5);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MouseRegion(
        cursor: MaterialStateMouseCursor.clickable,
        child: Card(
          elevation: 2,
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Titular: ${conta.titular}'),
                    Text(
                      conta.numero,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  ],
                ),
                Icon(Icons.arrow_forward),
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
                      ContaBancariaCard(
                        conta: conta,
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

class ContaBancariaCard extends StatefulWidget {
  final ContaBancaria conta;
  const ContaBancariaCard({super.key, required this.conta});

  @override
  State<ContaBancariaCard> createState() => _ContaBancariaCardState();
}

class _ContaBancariaCardState extends State<ContaBancariaCard> {
  final ContaBancariaServices contaServices = ContaBancariaServices();
  Map<String, bool> camposParaReprovar = {
    'titular': false,
    'numero': false,
    'agencia': false,
    'chavePix': false,
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
      case 'titular':
        return widget.conta.titular;
      case 'numero':
        return widget.conta.numero;
      case 'agencia':
        return widget.conta.agencia;
      case 'chavePix':
        return widget.conta.chavePix;
      default:
        return '';
    }
  }

  void aprovarConta() async {
    try {
      await contaServices.addConta(
        widget.conta.uid,
        widget.conta.titular,
        widget.conta.numero,
        widget.conta.agencia,
        widget.conta.chavePix,
      );
      await contaServices.solicitacaoRemove(widget.conta.uid);
      await contaServices.excluirAprovacaoParcial(widget.conta.uid);
      await contaServices.excluirRejeicaoParcial(widget.conta.uid);
      List<String> userTokens =
          await firebaseMessagingService.fetchUserTokens(widget.conta.uid);

      debugPrint('Tokens: $userTokens');

      for (String token in userTokens) {
        debugPrint('FCM Token: $token');
        try {
          await firebaseMessagingService.sendNotification(
              token, 'Cadastro', 'Conta bancária atualizada', 'cadastro');
        } catch (e) {
          debugPrint('Erro ao enviar notificação: $e');
        }
        debugPrint('Notificação enviada');
      }
      if (context.mounted) {
        mensagemDeSucesso.showSuccessSnackbar(
          context,
          'Conta bancária aprovada com sucesso.',
        );
      }
    } catch (e) {
      debugPrint(e.toString());
      if (context.mounted) {
        tratamentoDeErros.showErrorSnackbar(
          context,
          'Erro ao aprovar a conta bancária, tente novamente.',
        );
      }
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
            await contaServices.rejeicaoParcial(
              widget.conta.uid,
              camposReprovados.contains('titular')
                  ? widget.conta.titular
                  : null,
              camposReprovados.contains('numero') ? widget.conta.numero : null,
              camposReprovados.contains('agencia')
                  ? widget.conta.agencia
                  : null,
              camposReprovados.contains('chavePix')
                  ? widget.conta.chavePix
                  : null,
            );

            // Chama a função de aprovação parcial
            await contaServices.aprovacaoParcial(
              widget.conta.uid,
              camposAprovados.contains('titular') ? widget.conta.titular : null,
              camposAprovados.contains('numero') ? widget.conta.numero : null,
              camposAprovados.contains('agencia') ? widget.conta.agencia : null,
              camposAprovados.contains('chavePix')
                  ? widget.conta.chavePix
                  : null,
            );
            await contaServices.solicitacaoRemove(widget.conta.uid);
            List<String> userTokens = await firebaseMessagingService
                .fetchUserTokens(widget.conta.uid);

            debugPrint('Tokens: $userTokens');

            for (String token in userTokens) {
              debugPrint('FCM Token: $token');
              try {
                await firebaseMessagingService.sendNotification(
                    token, 'Atualização', 'Conta bancária atualizada', 'cadastro');
              } catch (e) {
                debugPrint('Erro ao enviar notificação: $e');
              }
              debugPrint('Notificação enviada');
              if (context.mounted) {
                //Navigator.of(context).pop();
                mensagemDeSucesso.showSuccessSnackbar(
                  context,
                  'Conta bancária rejeitada com sucesso.',
                );
              }
            }
          } catch (e) {
            debugPrint(e.toString());
            if (context.mounted) {
              tratamentoDeErros.showErrorSnackbar(
                context,
                'Erro ao rejeitar a conta bancária, tente novamente.',
              );
            }
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
            campoComCheckbox('Titular', 'titular'),
            campoComCheckbox('Número', 'numero'),
            campoComCheckbox('Agência', 'agencia'),
            campoComCheckbox('Chave Pix', 'chavePix'),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.green)),
                  onPressed: () {
                    showAcceptDialog(context, aprovarConta);
                  },
                  child: const Text('Aprovar'),
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
              'Tem certeza de que deseja aprovar todos os dados da conta bancária?'),
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
