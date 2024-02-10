import 'package:file_picker/file_picker.dart';

sealed class RgFrenteState {}

final class RgFrenteInitial extends RgFrenteState {}

final class SelectRgFrenteLoading extends RgFrenteState {}

final class SelectRgFrenteLoaded extends RgFrenteState {
  final PlatformFile foto;

  SelectRgFrenteLoaded(this.foto);
}

final class SelectRgFrenteError extends RgFrenteState {
  final String message;

  SelectRgFrenteError(this.message);
}
