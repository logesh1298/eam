import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

import '../../2_wod_data/workorder_task_parts.dart';

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
