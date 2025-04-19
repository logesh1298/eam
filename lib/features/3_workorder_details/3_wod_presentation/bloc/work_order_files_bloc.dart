import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../2_wod_data/workorder_file.dart';


part 'workorder_file_event.dart';
part 'workorder_file_state.dart';

class WorkOrderFilesBloc extends Bloc<WorkOrderFilesEvent, WorkOrderFilesState> {
  WorkOrderFilesBloc() : super(WorkOrderFilesInitial()) {
    on<WorkOrderFilesFetchEvent>(onGetWorkOrderFiles);
  }

  FutureOr<void> onGetWorkOrderFiles(
      WorkOrderFilesEvent event, Emitter<WorkOrderFilesState> emit) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? baseURL = prefs.getString('eamAPIBaseURL');
    if (event is WorkOrderFilesFetchEvent) {
      try {
        final response = await http.get(
            Uri.parse("$baseURL/workorder/getdocumentbyworkorderid/${event.workorderId}"));

        print(
            Uri.parse("$baseURL/workorder/getdocumentbyworkorderid/${event.workorderId}"));

        print(
            "AssetID is ${jsonEncode(event.workorderId)}, status Code : ${response.statusCode}");

        if (response.statusCode == 200) {
          final Map<String, dynamic> body = jsonDecode(response.body);

          List<dynamic> results = body["result"];

          final List<WorkOrderFile> workorderFiles =
          results.map((json) => WorkOrderFile.fromJson(json)).toList();
          print(workorderFiles.length);

          emit(WorkOrderFilesLoadedState(workorderFiles));
        } else {
          emit(WorkOrderFilesErrorState(
              "Failed to Fetch Asset Files Data. Status code: ${response.statusCode}"));
        }
      } catch (e) {
        emit(WorkOrderFilesErrorState(e.toString()));
        throw Exception(e);
      }
    }
  }
}
