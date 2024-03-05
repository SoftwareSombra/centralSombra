import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sombra_testes/autenticacao/screens/tratamento/error_snackbar.dart';
import 'package:sombra_testes/autenticacao/screens/tratamento/success_snackbar.dart';
import 'package:sombra_testes/conta_bancaria/services/conta_bancaria_services.dart';
import 'package:sombra_testes/widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc.dart';
import 'package:sombra_testes/widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_state.dart';
import '../../../perfil_user/bloc/conta_bancaria/conta_bancaria_bloc.dart';
import '../../../perfil_user/bloc/conta_bancaria/events.dart';
import '../../../perfil_user/bloc/conta_bancaria/states.dart';
import '../../../widgets_comuns/elevated_button/bloc/bloc/elevated_button_bloc_event.dart';

class FormAddConta extends StatelessWidget {
  final TextEditingController titular;
  final TextEditingController numero;
  final TextEditingController agencia;
  final TextEditingController chavePix;
  final GlobalKey<FormState> formKey;
  FormAddConta(
      {super.key,
      required this.titular,
      required this.numero,
      required this.agencia,
      required this.chavePix,
      required this.formKey});

  final ContaBancariaServices contaBancariaServices = ContaBancariaServices();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final TratamentoDeErros tratamentoDeErros = TratamentoDeErros();
  final MensagemDeSucesso mensagemDeSucesso = MensagemDeSucesso();

  @override
  Widget build(BuildContext context) {
    final user = firebaseAuth.currentUser;
    final uid = user?.uid;
    return BlocBuilder<ContaBancariaBloc, ContaBancariaState>(
      builder: (context, state) {
        if (state is ContaBancariaLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is AgenteSemCadastro) {
          return const Center(
            child: Text('Você não possui cadastro'),
          );
        } else if (state is ContaBancariaAguardandoAprovacao) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 50,
                    color: Colors.yellow,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Os dados da sua conta bancária estão sendo analisados, aguarde.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        } else if (state is ContaBancariaInfosRejected) {
          final titularAceito = state.titularAceito;
          final numeroAceito = state.numeroAceito;
          final agenciaAceita = state.agenciaAceita;
          final chavePixAceita = state.chavePixAceita;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  state.dados.containsKey('titular')
                      ? TextFormField(
                          controller: titular,
                          keyboardType: TextInputType.name,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp("[a-zA-Z]"),
                            ),
                            //limite de caracteres
                            LengthLimitingTextInputFormatter(40),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Nome do titular',
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
                              return 'Por favor, insira o nome do titular da conta';
                            }
                            if (value.length < 3) {
                              return 'Por favor, insira um nome válido';
                            }
                            return null;
                          },
                        )
                      : const SizedBox.shrink(),
                  state.dados.containsKey('titular')
                      ? const SizedBox(
                          height: 10,
                        )
                      : const SizedBox.shrink(),
                  state.dados.containsKey('numero')
                      ? TextFormField(
                          controller: numero,
                          keyboardType: TextInputType
                              .number, // Define o teclado como numérico
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            //limite de caracteres
                            LengthLimitingTextInputFormatter(20),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Número da conta',
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
                              return 'Por favor, insira o numero da conta';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Por favor, insira apenas números';
                            }
                            return null;
                          },
                        )
                      : const SizedBox.shrink(),
                  state.dados.containsKey('numero')
                      ? const SizedBox(
                          height: 10,
                        )
                      : const SizedBox.shrink(),
                  state.dados.containsKey('agencia')
                      ? TextFormField(
                          controller: agencia,
                          keyboardType: TextInputType
                              .number, // Define o teclado como numérico
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly,
                            //limite de caracteres
                            LengthLimitingTextInputFormatter(20),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Número da agência',
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
                              return 'Por favor, insira o número da agência';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Por favor, insira apenas números';
                            }
                            return null;
                          },
                        )
                      : const SizedBox.shrink(),
                  state.dados.containsKey('agencia')
                      ? const SizedBox(
                          height: 10,
                        )
                      : const SizedBox.shrink(),
                  state.dados.containsKey('chavePix')
                      ? TextFormField(
                          controller: chavePix,
                          inputFormatters: <TextInputFormatter>[
                            //limite de caracteres
                            LengthLimitingTextInputFormatter(40),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Chave pix',
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
                              return 'Por favor, insira a chave pix da conta';
                            }
                            return null;
                          },
                        )
                      : const SizedBox.shrink(),
                  state.dados.containsKey('chavePix')
                      ? const SizedBox(
                          height: 10,
                        )
                      : const SizedBox.shrink(),
                  BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
                    builder: (context, state) {
                      if (state is ElevatedButtonBlocLoading) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      } else {
                        return ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              final titularValor = titular.text.trim() != ''
                                  ? titular.text.trim()
                                  : titularAceito != ''
                                      ? titularAceito
                                      : null;
                              final numeroValor = numero.text.trim() != ''
                                  ? numero.text.trim()
                                  : numeroAceito != ''
                                      ? numeroAceito
                                      : null;
                              final agenciaValor = agencia.text.trim() != ''
                                  ? agencia.text.trim()
                                  : agenciaAceita != ''
                                      ? agenciaAceita
                                      : null;
                              final chavePixValor = chavePix.text.trim() != ''
                                  ? chavePix.text.trim()
                                  : chavePixAceita != ''
                                      ? chavePixAceita
                                      : null;
                              context
                                  .read<ElevatedButtonBloc>()
                                  .add(ElevatedButtonPressed());
                              if (titularValor != null &&
                                  numeroValor != null &&
                                  agenciaValor != null &&
                                  chavePixValor != null) {
                                bool success =
                                    await contaBancariaServices.preAddConta(
                                  uid!,
                                  titularValor,
                                  numeroValor,
                                  agenciaValor,
                                  chavePixValor,
                                );
                                if (success) {
                                  await contaBancariaServices
                                      .excluirAprovacaoParcial(uid);
                                  await contaBancariaServices
                                      .excluirRejeicaoParcial(uid);
                                  if (context.mounted) {
                                    context
                                        .read<ElevatedButtonBloc>()
                                        .add(ElevatedButtonActionCompleted());
                                  } else {}
                                  titular.clear();
                                  numero.clear();
                                  agencia.clear();
                                  chavePix.clear();
                                  if (context.mounted) {
                                    context
                                        .read<ContaBancariaBloc>()
                                        .add(FetchContaBancariaInfo(uid));
                                    mensagemDeSucesso.showSuccessSnackbar(
                                        context,
                                        'Solicitação adicionada com sucesso');
                                    Navigator.pop(context);
                                  }
                                }
                              } else {
                                if (context.mounted) {
                                  context
                                      .read<ElevatedButtonBloc>()
                                      .add(ElevatedButtonActionCompleted());
                                  tratamentoDeErros.showErrorSnackbar(context,
                                      'Erro ao adicionar conta bancária');
                                }
                              }
                            }
                          },
                          child: const Text('Adicionar conta'),
                        );
                      }
                    },
                  )
                ],
              ),
            ),
          );
        } else if (state is ContaBancariaLoaded) {
          return const Center(
            child: Text('Você já possui uma conta bancária'),
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
                  controller: titular,
                  keyboardType: TextInputType.name,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                      RegExp("[a-zA-Z]"),
                    ),
                    //limite de caracteres
                    LengthLimitingTextInputFormatter(40),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Nome do titular',
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
                      return 'Por favor, insira o nome do titular da conta';
                    }
                    if (value.length < 3) {
                      return 'Por favor, insira um nome válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: numero,
                  keyboardType:
                      TextInputType.number, // Define o teclado como numérico
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    //limite de caracteres
                    LengthLimitingTextInputFormatter(20),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Número da conta',
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
                      return 'Por favor, insira o numero da conta';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Por favor, insira apenas números';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: agencia,
                  keyboardType:
                      TextInputType.number, // Define o teclado como numérico
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    //limite de caracteres
                    LengthLimitingTextInputFormatter(20),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Número da agência',
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
                      return 'Por favor, insira o número da agência';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Por favor, insira apenas números';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: chavePix,
                  inputFormatters: <TextInputFormatter>[
                    //limite de caracteres
                    LengthLimitingTextInputFormatter(40),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Chave pix',
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
                      return 'Por favor, insira a chave pix da conta';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                BlocBuilder<ElevatedButtonBloc, ElevatedButtonBlocState>(
                  builder: (context, state) {
                    if (state is ElevatedButtonBlocLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            context
                                .read<ElevatedButtonBloc>()
                                .add(ElevatedButtonPressed());
                            bool success =
                                await contaBancariaServices.preAddConta(
                              uid!,
                              titular.text.trim(),
                              numero.text.trim(),
                              agencia.text.trim(),
                              chavePix.text.trim(),
                            );
                            if (success) {
                              if (context.mounted) {
                                context
                                    .read<ElevatedButtonBloc>()
                                    .add(ElevatedButtonActionCompleted());
                              } else {}
                              titular.clear();
                              numero.clear();
                              agencia.clear();
                              chavePix.clear();
                              if (context.mounted) {
                                context
                                    .read<ContaBancariaBloc>()
                                    .add(FetchContaBancariaInfo(uid));
                                mensagemDeSucesso.showSuccessSnackbar(context,
                                    'Conta bancária adicionada com sucesso');
                                Navigator.pop(context);
                              }
                            } else {
                              if (context.mounted) {
                                context
                                    .read<ElevatedButtonBloc>()
                                    .add(ElevatedButtonActionCompleted());
                                tratamentoDeErros.showErrorSnackbar(context,
                                    'Erro ao adicionar conta bancária');
                              }
                            }
                          }
                        },
                        child: const Text('Adicionar conta'),
                      );
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
