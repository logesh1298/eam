import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:eam/features/3_workorder_details/2_wod_data/workorder_task_parts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/dio_client.dart';
import '../../../core/utils/enum/network_enums.dart';

class WorkOrderStatusApiService {
  final DioManager dioManager;

  WorkOrderStatusApiService({required this.dioManager});

  Future<dynamic> getWorkOrderStatus() async {
    Response response =
        await dioManager.dio.get(NetworkEnums.workOrderStatus.path);

    print("response${response}");
    return response;
  }

  Future<List<WorkOrderTaskPart>> fetchTaskParts(String taskId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bearerToken = prefs.getString('bearer_token');

    try {
      final response = await http.get(
        Uri.parse('https://demoapi.orienseam.com/api/workordertaskparts/getall/$taskId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> partsData = data['result'] ?? [];
        return partsData.map((part) => WorkOrderTaskPart.fromJson(part)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching task parts: $e');
      return [];
    }
  }

  Future<List<WorkOrderTaskPart>> fetchWorkOrderTaskParts(String workOrderId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bearerToken = prefs.getString('bearer_token');

    try {
      final response = await http.get(
        Uri.parse('https://demoapi.orienseam.com/api/workorder/getcompletedetails/$workOrderId'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final partsList = data['result']['workOrderTaskPartsList'] as List;
        return partsList.map((part) => WorkOrderTaskPart.fromJson(part)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching work order task parts: $e');
      return [];
    }
  }

}

// class WorkOrderStatusApi {
//   static Future<dynamic> fetchStatus(String url) async {
//     final response = await http.get(Uri.parse(url));
//     if (response.statusCode == 200) {
//       final List<dynamic> jsonResponse = json.decode(response.body);
//
//       return jsonResponse;
//     }
//   }
// }
