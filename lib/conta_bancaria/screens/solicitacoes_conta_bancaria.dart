import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/solicitacoes_conta_bancaria_bloc.dart';
import '../bloc/solicitacoes_conta_bancaria_event.dart';
import '../bloc/solicitacoes_conta_bancaria_state.dart';
import '../model/conta_bancaria_model.dart';
import '../services/conta_bancaria_services.dart';

class ContasBancariasSolicitacoes extends StatelessWidget {
  const ContasBancariasSolicitacoes({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const cardWidth = 350.0;
    final cardCount = (width / cardWidth).floor();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Solicitações de Aprovação'),
        backgroundColor: Colors.grey[900],
      ),
      body: BlocProvider(
        create: (context) => SolicitacoesContaBancariaBloc()
          ..add(FetchSolicitacoesContaBancaria()),
        child: BlocBuilder<SolicitacoesContaBancariaBloc,
            SolicitacoesContaBancariaState>(
          builder: (context, state) {
            if (state is SolicitacoesContaBancariaLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SolicitacoesContaBancariaLoaded) {
              return GridView.builder(
                padding: const EdgeInsets.all(12.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cardCount,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                itemCount: state.conta.length,
                itemBuilder: (context, index) {
                  return ContaBancariaCard(conta: state.conta[index]);
                },
              );
            } else if (state is SolicitacoesContaBancariaNotFound) {
              return const Center(
                child: Text(
                  'Nenhuma solicitação encontrada',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else if (state is SolicitacoesContaBancariaError) {
              return Center(child: Text('Erro: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
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
    await contaServices.addConta(
      widget.conta.uid,
      widget.conta.titular,
      widget.conta.numero,
      widget.conta.agencia,
      widget.conta.chavePix,
    );
    await contaServices.solicitacaoRemove(widget.conta.uid);
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
      _showRejectionConfirmationDialog(context, () async {
        // Chama a função de rejeição parcial
        await contaServices.rejeicaoParcial(
          widget.conta.uid,
          camposReprovados.contains('titular') ? widget.conta.titular : null,
          camposReprovados.contains('numero') ? widget.conta.numero : null,
          camposReprovados.contains('agencia') ? widget.conta.agencia : null,
          camposReprovados.contains('chavePix') ? widget.conta.chavePix : null,
        );

        // Chama a função de aprovação parcial
        await contaServices.aprovacaoParcial(
          widget.conta.uid,
          camposAprovados.contains('titular') ? widget.conta.titular : null,
          camposAprovados.contains('numero') ? widget.conta.numero : null,
          camposAprovados.contains('agencia') ? widget.conta.agencia : null,
          camposAprovados.contains('chavePix') ? widget.conta.chavePix : null,
        );
        await contaServices.solicitacaoRemove(widget.conta.uid);
        // Atualiza a UI ou recarrega a lista de contas conforme necessário
        if (context.mounted) {
          context
              .read<SolicitacoesContaBancariaBloc>()
              .add(FetchSolicitacoesContaBancaria());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
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
                  onPressed: aprovarConta,
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
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                onConfirm(); // Chama a função de confirmação
                Navigator.of(context).pop(); // Fecha o diálogo
              },
            ),
          ],
        );
      },
    );
  }
}
