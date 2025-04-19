


//import 'package:eam/features/4_service_request/service_request_data/service_request.dart';
import 'package:eam/core/resources/data_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//import '../../../../8_location/presentation/bloc/location_bloc.dart';
import '../../../service_request_data/name.dart';
import '../../../service_request_domain/name_repo.dart';

part 'name_state.dart';

class NameBloc extends Cubit<NameState> {
  NameBloc() : super(NameLoadingState());

  Future<void> fetchName() async {
    final dataState = await NameRepo.getName();
    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(NameLoadedState(dataState.data!));
    }
    if (dataState is DataFailed) {
      emit(NameErrorState("Error Fetching Data"));
    }
  }
}
