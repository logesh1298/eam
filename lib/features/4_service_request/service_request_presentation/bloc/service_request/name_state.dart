part of 'name_bloc.dart';

@immutable
abstract class NameState {}

class NameLoadingState extends NameState {}

class NameLoadedState extends NameState {
  final List<ServiceRequestName> name;

  NameLoadedState(this.name);
}

class NameErrorState extends NameState {
  final String error;

  NameErrorState(this.error);
}
