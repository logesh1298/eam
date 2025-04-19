part of 'worktypes_cubit.dart';

//import 'package:flutter/cupertino.dart';

//import '../../../service_request_data/work_type.dart';

@immutable
abstract class WorkTypesState {}

class WorkTypesLoadingState extends WorkTypesState {}

class WorkTypesLoadedState extends WorkTypesState {
  final List<WorkTypes> workType;
  WorkTypesLoadedState(this.workType);
}

class WorkTypesErrorState extends WorkTypesState {
  final String error;
  WorkTypesErrorState(this.error);
}
