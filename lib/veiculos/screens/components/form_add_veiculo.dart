import 'package:brasil_fields/brasil_fields.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:persistent_bottom_nav_bar/persistent_tab_view.dart';
import 'package:sombra_testes/veiculos/services/veiculos_services.dart';
import '../../../autenticacao/screens/tratamento/error_snackbar.dart';
import '../../../autenticacao/screens/tratamento/success_snackbar.dart';
import '../../../perfil_user/screens/add_infos.dart';
import '../../../perfil_user/screens/perfil.dart';
import '../../bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_bloc.dart';
import '../../bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_event.dart';
import '../../bloc/veiculos_list/resposta/bloc/resposta_solicitacao_veiculo_state.dart';

class FormAddVeiculo extends StatelessWidget {
  final TextEditingController placa;
  final TextEditingController marca;
  final TextEditingController modelo;
  final TextEditingController cor;
  final TextEditingController ano;
  final GlobalKey<FormState> formKey;
  FormAddVeiculo(
      {super.key,
      required this.placa,
      required this.marca,
      required this.modelo,
      required this.cor,
      required this.ano,
      required this.formKey});

  final VeiculoServices veiculoServices = VeiculoServices();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final TratamentoDeErros tratamentoDeErro = TratamentoDeErros();
  final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

  bool isValidPlaca(String placa) {
    if (placa.length == 8) {
      RegExp regExp = RegExp(
        r'^[A-Za-z0-9-]+$',
      );
      return regExp.hasMatch(placa);
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = firebaseAuth.currentUser;
    final uid = user?.uid;
    final nome = user?.displayName;

    return BlocBuilder<RespostaSolicitacaoVeiculoBloc,
        RespostaSolicitacaoVeiculoState>(builder: (context, state) {
      if (state is RespostaSolicitacaoVeiculoLoading) {
        return const CircularProgressIndicator();
      } else if (state is SemCadastro) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PanaraInfoDialogWidget(
              title: "Dados pessoais",
              message:
                  "Não é possível adicionar um veículo sem ter os dados pessoais cadastrados",
              buttonText: "Cadastrar",
              onTapDismiss: () {
                PersistentNavBarNavigator.pushNewScreen(
                  context,
                  screen: AddInfosScreen(),
                  withNavBar: false,
                );
                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //     builder: (context) => AddInfosScreen(),
                //   ),
                // );
              },
              panaraDialogType: PanaraDialogType.normal,
              noImage: false,
              imagePath: 'assets/images/warning-pana.png',
              textColor: Colors.white,
              containerColor: Colors.grey[800],
              buttonTextColor: Colors.white,
            ),
          ],
        );
      } else if (state is RespostaSolicitacaoVeiculoAguardandoAprovacao) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PanaraInfoDialogWidget(
              title: "Aguardando aprovação",
              message:
                  "Aguarde a aprovação do seu veículo para adicionar outro",
              buttonText: "Voltar",
              onTapDismiss: () {
                Navigator.pop(context);
              },
              panaraDialogType: PanaraDialogType.normal,
              noImage: false,
              imagePath: 'assets/images/warning-pana.png',
              textColor: Colors.white,
              containerColor: Colors.grey[800],
              buttonTextColor: Colors.white,
            ),
          ],
        );
      } else if (state is RespostaSolicitacaoVeiculoLoaded) {
        final placaAceita = state.placa;
        final marcaAceita = state.marca;
        final modeloAceito = state.modelo;
        final corAceita = state.cor;
        final anoAceito = state.ano;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                state.dados.containsKey('Placa')
                    ? TextFormField(
                        controller: placa,
                        inputFormatters: [
                          PlacaVeiculoInputFormatter(),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Placa',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o número da placa do veículo';
                          }
                          if (!isValidPlaca(value.toUpperCase())) {
                            return 'Placa inválida';
                          }
                          return null;
                        },
                      )
                    : const SizedBox.shrink(),
                state.dados.containsKey('Placa')
                    ? const SizedBox(
                        height: 10,
                      )
                    : const SizedBox.shrink(),
                state.dados.containsKey('Marca')
                    ? TextFormField(
                        controller: marca,
                        inputFormatters: [
                          //limite de caracteres
                          LengthLimitingTextInputFormatter(20),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Marca',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira a marca do veículo';
                          }
                          return null;
                        },
                      )
                    : const SizedBox.shrink(),
                state.dados.containsKey('Marca')
                    ? const SizedBox(height: 10)
                    : const SizedBox.shrink(),
                state.dados.containsKey('Modelo')
                    ? TextFormField(
                        controller: modelo,
                        inputFormatters: [
                          //limite de caracteres
                          LengthLimitingTextInputFormatter(20),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Modelo',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o modelo do veículo';
                          }
                          return null;
                        },
                      )
                    : const SizedBox.shrink(),
                state.dados.containsKey('Modelo')
                    ? const SizedBox(
                        height: 10,
                      )
                    : const SizedBox.shrink(),
                state.dados.containsKey('Cor')
                    ? TextFormField(
                        controller: cor,
                        inputFormatters: [
                          //limite de caracteres
                          LengthLimitingTextInputFormatter(20),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Cor',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o modelo do veículo';
                          }
                          return null;
                        },
                      )
                    : const SizedBox.shrink(),
                state.dados.containsKey('Cor')
                    ? const SizedBox(
                        height: 10,
                      )
                    : const SizedBox.shrink(),
                state.dados.containsKey('Ano')
                    ? TextFormField(
                        controller: ano,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly,
                          //limite de caracteres
                          LengthLimitingTextInputFormatter(4),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Ano',
                          labelStyle: TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira o ano do veículo';
                          }
                          return null;
                        },
                      )
                    : const SizedBox.shrink(),
                state.dados.containsKey('Ano')
                    ? const SizedBox(
                        height: 10,
                      )
                    : const SizedBox.shrink(),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final placaValor = placa.text.trim() != ''
                          ? placa.text.trim()
                          : placaAceita != ''
                              ? placaAceita
                              : null;
                      final marcaValor = marca.text.trim() != ''
                          ? marca.text.trim()
                          : marcaAceita != ''
                              ? marcaAceita
                              : null;
                      final modeloValor = modelo.text.trim() != ''
                          ? modelo.text.trim()
                          : modeloAceito != ''
                              ? modeloAceito
                              : null;
                      final corValor = cor.text.trim() != ''
                          ? cor.text.trim()
                          : corAceita != ''
                              ? corAceita
                              : null;
                      final anoValor = ano.text.trim() != ''
                          ? ano.text.trim()
                          : anoAceito != ''
                              ? anoAceito
                              : null;
                      // Chama a função addUserInfos com todos os parâmetros necessários
                      if (placaValor == null ||
                          marcaValor == null ||
                          modeloValor == null ||
                          corValor == null ||
                          anoValor == null) {
                        return;
                      }
                      bool success = await veiculoServices.preAddVeiculo(
                        nome!,
                        uid!,
                        placaValor,
                        marcaValor,
                        modeloValor,
                        corValor,
                        anoValor,
                      );
                      if (success) {
                        placa.clear();
                        marca.clear();
                        modelo.clear();
                        cor.clear();
                        ano.clear();
                        if (context.mounted) {
                          mensagemDeSucesso.showSuccessSnackbar(
                              context, 'Veículo adicionado com sucesso');
                          context
                              .read<RespostaSolicitacaoVeiculoBloc>()
                              .add(FetchRespostaSolicitacaoVeiculo(uid));
                          Navigator.pop(context);
                        }
                      } else {
                        if (context.mounted) {
                          tratamentoDeErro.showErrorSnackbar(context,
                              'Erro ao adicionar veículo, tenta novamente');
                        }
                      }
                    }
                  },
                  child: const Text('Adicionar informações'),
                ),
              ],
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: placa,
                inputFormatters: [
                  PlacaVeiculoInputFormatter(),
                ],
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o número da placa do veículo';
                  }
                  if (!isValidPlaca(value.toUpperCase())) {
                    return 'Placa inválida';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: marca,
                inputFormatters: [
                  //limite de caracteres
                  LengthLimitingTextInputFormatter(20),
                ],
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a marca do veículo';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: modelo,
                inputFormatters: [
                  //limite de caracteres
                  LengthLimitingTextInputFormatter(20),
                ],
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o modelo do veículo';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: cor,
                inputFormatters: [
                  //limite de caracteres
                  LengthLimitingTextInputFormatter(20),
                ],
                decoration: const InputDecoration(
                  labelText: 'Cor',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o modelo do veículo';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: ano,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  //limite de caracteres
                  LengthLimitingTextInputFormatter(4),
                ],
                decoration: const InputDecoration(
                  labelText: 'Ano',
                  labelStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o ano do veículo';
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    // Chama a função addUserInfos com todos os parâmetros necessários
                    bool success = await veiculoServices.preAddVeiculo(
                      nome!,
                      uid!,
                      placa.text.trim(),
                      marca.text.trim(),
                      modelo.text.trim(),
                      cor.text.trim(),
                      ano.text.trim(),
                    );
                    if (success) {
                      placa.clear();
                      marca.clear();
                      modelo.clear();
                      cor.clear();
                      ano.clear();
                      if (context.mounted) {
                        mensagemDeSucesso.showSuccessSnackbar(
                            context, 'Veículo adicionado com sucesso');
                        context
                            .read<RespostaSolicitacaoVeiculoBloc>()
                            .add(FetchRespostaSolicitacaoVeiculo(uid));
                        Navigator.pop(context);
                      }
                    } else {
                      if (context.mounted) {
                        tratamentoDeErro.showErrorSnackbar(context,
                            'Erro ao adicionar veículo, tenta novamente');
                      }
                    }
                  }
                },
                child: const Text('Adicionar informações'),
              ),
            ],
          ),
        ),
      );
    });
  }
}
