import 'package:file_picker/file_picker.dart';

abstract class SelectFotoState {}

class SelectFotoInitial extends SelectFotoState {}

class SelectFotoLoading extends SelectFotoState {}

class SelectFotoLoaded extends SelectFotoState {
  final Map<String, PlatformFile> fotos;
  SelectFotoLoaded(this.fotos);
}

class SelectFotoError extends SelectFotoState {
  final String message;

  SelectFotoError(this.message);
}
