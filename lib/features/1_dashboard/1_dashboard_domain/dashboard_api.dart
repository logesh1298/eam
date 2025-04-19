import 'package:dio/dio.dart';

import '../../../core/utils/dio_client.dart';



class DashBoardWorkOrderApiService {
  final DioManager dioManager;

  DashBoardWorkOrderApiService({required this.dioManager});

  Future<dynamic> getWorkOrders(String path, String status) async {
    Response response = await dioManager.dio.post(
      path,
      data: {
        "workOrderStatus": status,
      },
    );
    return response;
  }
}
