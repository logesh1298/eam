import 'package:eam/features/13_parts/presentation/domain/parts_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../core/resources/data_state.dart';
import '../data/parts.dart';
//import '../../data/model/asset.dart';

part 'parts_state.dart';

class PartsBloc extends Cubit<PartsState> {
  PartsBloc() : super(PartsLoadingState());

  Future<void> fetchParts() async {
    final dataState = await PartsRepo.getparts();
    if (dataState is DataSuccess && dataState.data!.isNotEmpty) {
      emit(PartsLoadedState(dataState.data!));
    }
    if (dataState is DataFailed) {
      emit(PartsErrorState("Error Fetching Data"));
    }
  }
}
