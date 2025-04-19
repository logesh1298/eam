part of 'work_order_files_bloc.dart';

//import 'package:flutter/cupertino.dart';

@immutable
abstract class WorkOrderFilesEvent {}

class WorkOrderFilesFetchEvent extends WorkOrderFilesEvent {
  final String workorderId;

  WorkOrderFilesFetchEvent(this.workorderId);
}
