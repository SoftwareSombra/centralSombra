import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:sombra/autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../../../agente/bloc/solicitacoes/events.dart';
import '../../../../../agente/bloc/solicitacoes/solicitacoes_agente_bloc.dart';
import '../../../../../agente/bloc/solicitacoes/states.dart';
import '../../../../../agente/model/agente_model.dart';
import '../../../../../agente/services/agente_services.dart';
import '../../../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../../../notificacoes/fcm.dart';
import '../../../../../notificacoes/notificacoess.dart';

class CadastroListDialog extends StatelessWidget {
  const CadastroListDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgenteSolicitacaoBloc, AgenteSolicitacaoState>(
      builder: (context, state) {
        if (state is AgenteSolicitacaoLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AgenteSolicitacaoNotFound) {
          return AlertDialog(
            backgroundColor: Colors.grey[300],
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
        if (state is AgenteSolicitacaoLoaded) {
          // Exibe um único AlertDialog com uma lista de todos os agentes
          return AlertDialog(
            backgroundColor: Colors.grey[300],
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Solicitações de Cadastro'),
              ],
            ),
            content: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width * 0.6,
              child: ListView.builder(
                itemCount: state.agente.length,
                itemBuilder: (context, index) {
                  return CadastroAgenteList(agente: state.agente[index]);
                },
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
        }

        if (state is AgenteSolicitacaoError) {
          return Center(
            child: Text('Erro: ${state.message}'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class CadastroAgenteList extends StatelessWidget {
  final Agente agente;
  const CadastroAgenteList({super.key, required this.agente});

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
                    Text('Nome: ${agente.nome}'),
                    Text(
                      agente.celular,
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
          builder: (context) {
            return AlertDialog(
              title: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DETALHES',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: SizedBox(
                height: 480,
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      AgenteCard(
                        agente: agente,
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

class AgenteCard extends StatefulWidget {
  final Agente agente;
  const AgenteCard({super.key, required this.agente});

  @override
  State<AgenteCard> createState() => _AgenteCardState();
}

final NotificationService notificationService = NotificationService();
final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

final FirebaseMessagingService firebaseMessagingService =
    FirebaseMessagingService(notificationService);

class _AgenteCardState extends State<AgenteCard> {
  final AgenteServices agenteServices = AgenteServices();
  Map<String, bool> camposParaReprovar = {
    'nome': false,
    //'endereco': false,
    'logradouro': false,
    'numero': false,
    'bairro': false,
    'cidade': false,
    'estado': false,
    'complemento': false,
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
                child: TextButton(
                  onPressed: onViewPressed,
                  child: Text(
                    'Ver $tituloCampo',
                    style: const TextStyle(color: Colors.blue),
                  ),
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
    try {
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
      await agenteServices.excluirPendencias(widget.agente.uid);
    } catch (error) {
      if (context.mounted) {
        tratamentoDeErros.showErrorSnackbar(
            context, 'Erro ao aprovar agente, tenta novamente');
        //Navigator.of(context).pop();
      }
    }
    if (context.mounted) {
      context.read<AgenteSolicitacaoBloc>().add(FetchAgenteSolicitacoes());
      mensagemDeSucesso.showSuccessSnackbar(
          context, 'Agente aprovado com sucesso');
      List<String> userTokens =
          await firebaseMessagingService.fetchUserTokens(widget.agente.uid);

      debugPrint('Tokens: $userTokens');

      for (String token in userTokens) {
        debugPrint('FCM Token: $token');
        try {
          await firebaseMessagingService.sendNotification(
              token, 'Cadastro', 'Cadastro atualizado', null,
              data: {'tipo': 'cadastro'});
          debugPrint('Notificação enviada');
        } catch (e) {
          debugPrint('Erro ao enviar notificação: $e');
        }

        if (context.mounted) {
          //context.read<AgenteSolicitacaoBloc>().add(FetchAgenteSolicitacoes());
        }
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
          // Chama a função de rejeição parcial
          try {
            await agenteServices.rejeicaoParcial(
              widget.agente.uid,
              camposReprovados.contains('nome') ? widget.agente.nome : null,
              //camposReprovados.contains('endereco') ? widget.agente.endereco : null,
              camposReprovados.contains('logradouro')
                  ? widget.agente.logradouro
                  : null,
              camposReprovados.contains('numero') ? widget.agente.numero : null,
              camposReprovados.contains('bairro') ? widget.agente.bairro : null,
              camposReprovados.contains('cidade') ? widget.agente.cidade : null,
              camposReprovados.contains('estado') ? widget.agente.estado : null,
              camposReprovados.contains('complemento')
                  ? widget.agente.complemento
                  : null,
              camposReprovados.contains('cep') ? widget.agente.cep : null,
              camposReprovados.contains('celular')
                  ? widget.agente.celular
                  : null,
              camposReprovados.contains('rg') ? widget.agente.rg : null,
              camposReprovados.contains('cpf') ? widget.agente.cpf : null,
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
              camposAprovados.contains('logradouro')
                  ? widget.agente.logradouro
                  : null,
              camposAprovados.contains('numero') ? widget.agente.numero : null,
              camposAprovados.contains('bairro') ? widget.agente.bairro : null,
              camposAprovados.contains('cidade') ? widget.agente.cidade : null,
              camposAprovados.contains('estado') ? widget.agente.estado : null,
              camposAprovados.contains('complemento')
                  ? widget.agente.complemento
                  : null,
              camposAprovados.contains('cep') ? widget.agente.cep : null,
              camposAprovados.contains('celular')
                  ? widget.agente.celular
                  : null,
              camposAprovados.contains('rg') ? widget.agente.rg : null,
              camposAprovados.contains('cpf') ? widget.agente.cpf : null,
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
            List<String> userTokens = await firebaseMessagingService
                .fetchUserTokens(widget.agente.uid);

            debugPrint('Tokens: $userTokens');

            for (String token in userTokens) {
              debugPrint('FCM Token: $token');
              try {
                await firebaseMessagingService.sendNotification(
                    token, 'Atualização', 'Cadastro atualizado', 'cadastro');
              } catch (e) {
                debugPrint('Erro ao enviar notificação: $e');
              }
              debugPrint('Notificação enviada');
              if (context.mounted) {
                //Navigator.of(context).pop();
              }
            }
          } catch (error) {
            debugPrint('Erro ao rejeitar/agrovar parcialmente: $error');
            if (context.mounted) {
              tratamentoDeErros.showErrorSnackbar(
                  context, 'Erro ao rejeitar dados, tente novamente');
              //Navigator.of(context).pop();
            }
          }
          // Atualiza a UI ou recarrega a lista de contas conforme necessário
          if (context.mounted) {
            context
                .read<AgenteSolicitacaoBloc>()
                .add(FetchAgenteSolicitacoes());
            mensagemDeSucesso.showSuccessSnackbar(
                context, 'Dados rejeitados com sucesso');
            //Navigator.of(context).pop();
          }
        },
      );
    }
  }

  @override
  Widget build(context) {
    return Card(
      //elevation: 4,
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
                      backgroundColor: MaterialStatePropertyAll(Colors.green)),
                  onPressed: () {
                    showAcceptDialog(
                      context,
                      () {
                        aprovarAgente();
                      },
                    );
                  },
                  child: const Text('Aprovar'),
                ),
                const SizedBox(width: 5),
                ElevatedButton(
                  style: const ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(Colors.red)),
                  onPressed: () async {
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
    debugPrint('------- Imagem: $imageUrl -------');
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(
          color: Colors.black,
          child: Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                debugPrint(
                    'Erro ao carregar a imagem: ${exception.toString()}');
                if (stackTrace != null) {
                  debugPrint('Stack trace: $stackTrace');
                }
                return const Center(
                  child: Text('Não foi possível carregar a imagem'),
                );
              },
            ),
          ),
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
              'Tem certeza de que deseja aprovar todos os dados do agente? '),
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

  void showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width * 0.6,
            child: PhotoView(
              //enquanto estiver carregando a imagem, exibe um indicador de progresso
              loadingBuilder: (context, event) => const Center(
                child: CircularProgressIndicator(),
              ),
              errorBuilder: (context, error, stackTrace) {
                return Center(
                  child: Text('Erro ao carregar a imagem ${error.toString()}'),
                );
              },
              imageProvider: CachedNetworkImageProvider(
                imageUrl,
              ),
              backgroundDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
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
    builder: (context) {
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
