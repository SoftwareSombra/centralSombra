import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import '../bloc/solicitacoes/events.dart';
import '../bloc/solicitacoes/solicitacoes_agente_bloc.dart';
import '../bloc/solicitacoes/states.dart';
import '../model/agente_model.dart';
import '../services/agente_services.dart';

class AgentesSolicitacoes extends StatelessWidget {
  const AgentesSolicitacoes({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const cardWidth = 500.0;
    final cardCount = (width / cardWidth).floor();

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Solicitações de Aprovação'),
        backgroundColor: Colors.grey[900],
      ),
      body: BlocProvider(
        create: (context) =>
            AgenteSolicitacaoBloc()..add(FetchAgenteSolicitacoes()),
        child: BlocBuilder<AgenteSolicitacaoBloc, AgenteSolicitacaoState>(
          builder: (context, state) {
            if (state is AgenteSolicitacaoLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AgenteSolicitacaoLoaded) {
              return GridView.builder(
                padding: const EdgeInsets.all(12.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  
                  crossAxisCount: cardCount,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                ),
                itemCount: state.agente.length,
                
                itemBuilder: (context, index) {
                  return AgenteCard(agente: state.agente[index]);
                },
              );
            } else if (state is AgenteSolicitacaoNotFound) {
              return const Center(
                  child: Text(
                'Nenhuma solicitação encontrada',
                style: TextStyle(color: Colors.white),
              ));
            } else if (state is AgenteSolicitacaoError) {
              return Center(child: Text('Erro: ${state.message}'));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class AgenteCard extends StatefulWidget {
  final Agente agente;

  const AgenteCard({super.key, required this.agente});

  @override
  State<AgenteCard> createState() => _AgenteCardState();
}

class _AgenteCardState extends State<AgenteCard> {
  final AgenteServices agenteServices = AgenteServices();
  Map<String, bool> camposParaReprovar = {
    'nome': false,
    'endereco': false,
    'celular': false,
    'cep': false,
    'cpf': false,
    'rg': false,
    'rgFotoFrenteUrl': false,
    'rgFotoVersoUrl': false,
    'compResidFotoUrl': false,
  };
  bool mostrarCheckboxes = false;

  void toggleCampo(String chaveCampo) {
    setState(() {
      camposParaReprovar[chaveCampo] = !camposParaReprovar[chaveCampo]!;
    });
  }

  Widget campoComCheckbox(String tituloCampo, String chaveCampo,
      {VoidCallback? onViewPressed}) {
    String valorCampo = getValorCampo(chaveCampo);
    bool isDocument = chaveCampo.contains('Url');

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
        isDocument
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ElevatedButton(
                  onPressed: onViewPressed,
                  child: Text('Ver $tituloCampo'),
                ),
              )
            : Text('$tituloCampo: $valorCampo'),
      ],
    );
  }

  String getValorCampo(String chaveCampo) {
    switch (chaveCampo) {
      case 'nome':
        return widget.agente.nome;
      // case 'endereco':
      //   return widget.agente.endereco;
      case 'logradouro':
        return widget.agente.logradouro;
      case 'numero':
        return widget.agente.numero;
      case 'bairro':
        return widget.agente.bairro;
      case 'cidade':
        return widget.agente.cidade;
      case 'estado':
        return widget.agente.estado;
      case 'complemento':
        return widget.agente.complemento;
      case 'celular':
        return widget.agente.celular;
      case 'cep':
        return widget.agente.cep;
      case 'cpf':
        return widget.agente.cpf;
      case 'rg':
        return widget.agente.rg;
      case 'rgFotoFrenteUrl':
        return widget.agente.rgFotoFrenteUrl!;
      case 'rgFotoVersoUrl':
        return widget.agente.rgFotoVersoUrl!;
      case 'compResidFotoUrl':
        return widget.agente.compResidFotoUrl!;
      default:
        return '';
    }
  }

  void aprovarAgente() async {
    // Implemente a lógica para aprovar o agente
    // Por exemplo:
    await agenteServices.addUserInfos(
      widget.agente.uid,
      //widget.agente.endereco,
      widget.agente.logradouro,
      widget.agente.numero,
      widget.agente.bairro,
      widget.agente.cidade,
      widget.agente.estado,
      widget.agente.complemento,
      widget.agente.cep,
      widget.agente.celular,
      widget.agente.rg,
      widget.agente.cpf,
      widget.agente.rgFotoFrenteUrl,
      widget.agente.rgFotoVersoUrl,
      widget.agente.compResidFotoUrl,
      widget.agente.timestamp,
      widget.agente.nome,
    );
    await agenteServices.solicitacaoRemove(widget.agente.uid);
    // Atualize a UI ou recarregue a lista de agentes conforme necessário
    if (context.mounted) {
      context.read<AgenteSolicitacaoBloc>().add(FetchAgenteSolicitacoes());
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
        await agenteServices.rejeicaoParcial(
          widget.agente.uid,
          camposReprovados.contains('nome') ? widget.agente.nome : null,
          //camposReprovados.contains('endereco') ? widget.agente.endereco : null,
          camposReprovados.contains('logradouro') ? widget.agente.logradouro : null,
          camposReprovados.contains('numero') ? widget.agente.numero : null,
          camposReprovados.contains('bairro') ? widget.agente.bairro : null,
          camposReprovados.contains('cidade') ? widget.agente.cidade : null,
          camposReprovados.contains('estado') ? widget.agente.estado : null,
          camposReprovados.contains('complemento') ? widget.agente.complemento : null,
          camposReprovados.contains('cep') ? widget.agente.cep : null,
          camposReprovados.contains('celular') ? widget.agente.celular : null,
          camposReprovados.contains('rg') ? widget.agente.rg : null,
          camposReprovados.contains('rgFotoFrenteUrl')
              ? widget.agente.rgFotoFrenteUrl
              : null,
          camposReprovados.contains('rgFotoVersoUrl')
              ? widget.agente.rgFotoVersoUrl
              : null,
          camposReprovados.contains('compResidFotoUrl')
              ? widget.agente.compResidFotoUrl
              : null,
        );

        // Chama a função de aprovação parcial
        await agenteServices.aprovacaoParcial(
          widget.agente.uid,
          camposAprovados.contains('nome') ? widget.agente.nome : null,
          //camposAprovados.contains('endereco') ? widget.agente.endereco : null,
          camposAprovados.contains('logradouro') ? widget.agente.logradouro : null,
          camposAprovados.contains('numero') ? widget.agente.numero : null,
          camposAprovados.contains('bairro') ? widget.agente.bairro : null,
          camposAprovados.contains('cidade') ? widget.agente.cidade : null,
          camposAprovados.contains('estado') ? widget.agente.estado : null,
          camposAprovados.contains('complemento') ? widget.agente.complemento : null,
          camposAprovados.contains('cep') ? widget.agente.cep : null,
          camposAprovados.contains('celular') ? widget.agente.celular : null,
          camposAprovados.contains('rg') ? widget.agente.rg : null,
          camposAprovados.contains('rgFotoFrenteUrl')
              ? widget.agente.rgFotoFrenteUrl
              : null,
          camposAprovados.contains('rgFotoVersoUrl')
              ? widget.agente.rgFotoVersoUrl
              : null,
          camposAprovados.contains('compResidFotoUrl')
              ? widget.agente.compResidFotoUrl
              : null,
        );
        await agenteServices.solicitacaoRemove(widget.agente.uid);
        // Atualiza a UI ou recarrega a lista de contas conforme necessário
        if (context.mounted) {
          context.read<AgenteSolicitacaoBloc>().add(FetchAgenteSolicitacoes());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      //margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            campoComCheckbox('Nome', 'nome'),
            //campoComCheckbox('Endereço', 'endereco'),
            campoComCheckbox('Logradouro', 'logradouro'),
            campoComCheckbox('Número', 'numero'),
            campoComCheckbox('Bairro', 'bairro'),
            campoComCheckbox('Cidade', 'cidade'),
            campoComCheckbox('Estado', 'estado'),
            campoComCheckbox('Complemento', 'complemento'),
            campoComCheckbox('Celular', 'celular'),
            campoComCheckbox('CEP', 'cep'),
            campoComCheckbox('CPF', 'cpf'),
            campoComCheckbox('RG', 'rg'),
            campoComCheckbox('RG frente', 'rgFotoFrenteUrl',
                onViewPressed: () =>
                    showImageDialog(context, widget.agente.rgFotoFrenteUrl!)),
            campoComCheckbox('RG verso', 'rgFotoVersoUrl',
                onViewPressed: () =>
                    showImageDialog(context, widget.agente.rgFotoVersoUrl!)),
            campoComCheckbox('Comprovante de residência', 'compResidFotoUrl',
                onViewPressed: () =>
                    showImageDialog(context, widget.agente.compResidFotoUrl!)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.green)),
                  onPressed: aprovarAgente,
                  child: const Text('Aprovar'),
                ),

                const SizedBox(width: 5),

                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.red)),
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

  void showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => GestureDetector(
        onTap: () => Navigator.of(ctx).pop(),
        child: Container(
          color: Colors.black,
          child: Center(
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }

  void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: PhotoView(
            imageProvider: NetworkImage(imageUrl),
            backgroundDecoration: const BoxDecoration(
              color: Colors.transparent,
            ),
          ),
        );
      },
    );
  }
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
