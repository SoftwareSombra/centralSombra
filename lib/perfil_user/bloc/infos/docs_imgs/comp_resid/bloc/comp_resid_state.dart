import 'package:file_picker/file_picker.dart';

sealed class CompResidState {}

final class CompResidInitial extends CompResidState {}

final class SelectCompResidLoading extends CompResidState {}

final class SelectCompResidLoaded extends CompResidState {
  final PlatformFile foto;

  SelectCompResidLoaded(this.foto);
}

final class SelectCompResidError extends CompResidState {
  final String message;

  SelectCompResidError(this.message);
}
