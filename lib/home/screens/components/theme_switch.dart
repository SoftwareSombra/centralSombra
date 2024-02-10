import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../tema/event_bloc.dart';
import '../../../tema/state_bloc.dart';
import '../../../tema/tema_bloc.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Switch(
          value: state is DarkMode,
          onChanged: (value) {
            // Alternar o tema ao mudar o valor do switch
            BlocProvider.of<ThemeBloc>(context).add(ToggleTheme());
          },
        );
      },
    );
  }
}