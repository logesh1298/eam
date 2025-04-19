import 'package:dio/dio.dart';
import 'package:eam/core/utils/dio_client.dart';
import 'package:eam/core/utils/enum/network_enums.dart';

class WorkTypesApi {
  final DioManager dioManager;

  WorkTypesApi({required this.dioManager});

  Future<dynamic> getResults() async {
    Response response = await dioManager.dio.get(NetworkEnums.workTypes.path);
    return response;
  }
}
