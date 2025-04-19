import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:eam/features/12_workorder_task/domain/workorder_task_repo.dart';

import '../../../../core/resources/data_state.dart';
import '../../../3_workorder_details/2_wod_data/workorder_per.dart';
import '../../data/workorder_task.dart';

part 'work_order_task_state.dart';

class WorkOrderTaskCubit extends Cubit<WorkOrderTaskState> {
  WorkOrderTaskCubit() : super(WorkOrderTaskLoadingState());

  Future<void> fetchWorkOrderTasks(String workOrderId) async {
    final dataState = await WorkOrderTaskRepo.getWorkOrderTasksList(workOrderId);
    print("Assetsss${dataState}");
    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(WorkOrderTaskLoadedState(dataState.data!));
    }
    if (dataState is DataFailed) {
      emit(WorkOrderTaskErrorState("Error Fetching Data"));
    }
  }
  // Add this to your WorkOrderTaskCubit

}
