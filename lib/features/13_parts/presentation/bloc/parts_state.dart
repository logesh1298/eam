part of 'parts_cubit.dart';



@immutable
abstract class PartsState {}

class PartsLoadingState extends PartsState {}

class PartsLoadedState extends PartsState {
  final List<Part> parts;
  PartsLoadedState(this.parts);
}

class PartsErrorState extends  PartsState {
  final String error;
  PartsErrorState(this.error);
}
