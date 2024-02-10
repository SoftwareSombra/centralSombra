import 'package:file_picker/file_picker.dart';

sealed class RgVersoState {}

final class RgVersoInitial extends RgVersoState {}

final class SelectRgVersoLoading extends RgVersoState {}

final class SelectRgVersoLoaded extends RgVersoState {
  final PlatformFile foto;

  SelectRgVersoLoaded(this.foto);
}

final class SelectRgVersoError extends RgVersoState {
  final String message;

  SelectRgVersoError(this.message);
}
