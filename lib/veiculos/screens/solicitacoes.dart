import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/solicitacoes_list/events.dart';
import '../bloc/solicitacoes_list/solicitacoes_veiculos_bloc.dart';
import '../bloc/solicitacoes_list/states.dart';
import '../model/veiculo_model.dart';
import '../services/veiculos_services.dart';

class VeiculosSolicitacoes extends StatelessWidget {
  const VeiculosSolicitacoes({super.key});

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
        create: (context) =>
            VeiculoSolicitacaoBloc()..add(FetchVeiculoSolicitacoes()),
        child: BlocBuilder<VeiculoSolicitacaoBloc, VeiculoSolicitacaoState>(
          builder: (context, state) {
            if (state is VeiculoSolicitacaoLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is VeiculoSolicitacaoLoaded) {
              return GridView.builder(
                padding: const EdgeInsets.all(12.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cardCount,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                itemCount: state.veiculo.length,
                itemBuilder: (context, index) {
                  return VeiculoCard(veiculo: state.veiculo[index]);
                },
              );
            } else if (state is VeiculoSolicitacaoNotFound) {
              return const Center(
                child: Text(
                  'Nenhuma solicitação encontrada',
                  style: TextStyle(color: Colors.white),
                ),
              );
            } else if (state is VeiculoSolicitacaoError) {
              return Center(child: Text('Erro: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
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
    await veiculoServices.addVeiculo(
      widget.veiculo.uid,
      widget.veiculo.nome,
      widget.veiculo.placa,
      widget.veiculo.marca,
      widget.veiculo.modelo,
      widget.veiculo.cor,
      widget.veiculo.ano,
      widget.veiculo.timestamp,
    );
    await veiculoServices.solicitacaoRemove(
        widget.veiculo.uid, widget.veiculo.placa);
    if (context.mounted) {
      context.read<VeiculoSolicitacaoBloc>().add(FetchVeiculoSolicitacoes());
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
      _showRejectionConfirmationDialog(context, () async {
        // Chama a função de rejeição parcial
        await veiculoServices.rejeicaoParcial(
          widget.veiculo.uid,
          camposReprovados.contains('nome') ? widget.veiculo.placa : null,
          camposReprovados.contains('placa') ? widget.veiculo.placa : null,
          camposReprovados.contains('marca') ? widget.veiculo.marca : null,
          camposReprovados.contains('modelo') ? widget.veiculo.modelo : null,
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

        await veiculoServices.solicitacaoRemove(
        widget.veiculo.uid, widget.veiculo.placa);

        if (context.mounted) {
          context
              .read<VeiculoSolicitacaoBloc>()
              .add(FetchVeiculoSolicitacoes());
        }
        // Chama a função de aprovação parcial para campos não reprovados
        // Adicione a lógica conforme necessário
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
                  onPressed: aprovarVeiculo,
                  child: const Text('Aprovar', style: TextStyle(color: Colors.white),),
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
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
