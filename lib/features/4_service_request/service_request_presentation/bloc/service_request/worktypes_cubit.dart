import 'package:bloc/bloc.dart';
import 'package:eam/core/resources/data_state.dart';
import 'package:eam/features/4_service_request/service_request_data/work_type.dart';
import 'package:eam/features/4_service_request/service_request_presentation/bloc/service_request/worktypes_repo.dart';
//import 'package:eam/features/4_service_request/service_request_presentation/bloc/service_request/worktype_state.dart';
import 'package:meta/meta.dart';
import 'package:eam/features/10_work_type/data/workType.dart';
import 'package:eam/features/10_work_type/domain/work_type_repo.dart';

//import '../../../../core/resources/data_state.dart';

part 'worktype_state.dart';

class WorkTypesBloc extends Cubit<WorkTypesState> {
  WorkTypesBloc() : super(WorkTypesLoadingState());

  Future<void> fetchWorkTypes() async {
    final dataState = await WorkTypesRepo.getWorkTypesList();

    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(WorkTypesLoadedState(dataState.data!.cast<WorkTypes>()));
    }
    if (dataState is DataFailed) {
      emit(WorkTypesErrorState("Error Fetching Data"));
    }
  }
}
