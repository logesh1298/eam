import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eam/features/4_service_request/service_request_data/service_request.dart';

import '../../../core/resources/data_state.dart';
import '../../../core/utils/dio_client.dart';
import '../service_request_data/name.dart';
import 'name_api.dart';

class NameRepo {
  static Future<DataState<List<ServiceRequestName>>> getName() async {
    try {
      final response = await NameApiService(dioManager: DioManager.instance).getName();
      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> jsonResponse = response.data;
        final List<dynamic> result = jsonResponse["result"];
        final List<ServiceRequestName> name = result.map((json) => ServiceRequestName.fromJson(json)).toList();
        return DataSuccess(name);
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
