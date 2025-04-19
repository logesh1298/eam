import 'package:dio/dio.dart';

import '../../../core/utils/dio_client.dart';
import '../../../core/utils/enum/network_enums.dart';

class NameApiService {
  final DioManager dioManager;

  NameApiService({required this.dioManager});

  Future<dynamic> getName() async {
    Response response = await dioManager.dio.get(NetworkEnums.allName.path);
    // if (response.statusCode == 200) {
    //   final Map<String, dynamic> body = jsonDecode(response.body);
    //   List<dynamic> results = body["result"];
    return response;
  }
}
