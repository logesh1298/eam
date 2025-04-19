import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eam/core/utils/dio_client.dart';
import 'package:eam/features/10_work_type/domain/work_type_api.dart';
import 'package:eam/features/4_service_request/service_request_presentation/bloc/service_request/worktype_api.dart';

import '../../../../../core/resources/data_state.dart';
//import '../../../core/resources/data_state.dart';
import '../../../service_request_data/work_type.dart';
//import '../data/workType.dart';

class WorkTypesRepo {
  // static Future<List<WorkType>> getWorkTypeList() async {
  //   List<dynamic> response = await WorkTypeApi(dioManager: DioManager.instance).getResults();
  //   final List<WorkType> workType = response.map((json) => WorkType.fromJson(json)).toList();
  //   return workType;
  // }
  static Future<DataState<List<WorkTypes>>> getWorkTypesList() async {
    try {
      final response = await WorkTypesApi(dioManager: DioManager.instance).getResults();
      if (response.statusCode == HttpStatus.ok) {
        final List<dynamic> jsonResponse = response.data;
        final List<WorkTypes> workTypes = jsonResponse.map((e) => WorkTypes.fromJson(e)).toList();
        return DataSuccess(workTypes);
      } else {
        return DataFailed(
          DioException(
              error: response.response.statusMessage,
              response: response.response,
              type: DioExceptionType.badResponse,
              requestOptions: response.response.requestOptions),
        );
      }
    } on DioException catch (e) {
      return DataFailed(e);
    }
  }
}
