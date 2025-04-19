import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/preference_manager.dart';
import 'package:intl/intl.dart';

import '../../2_workorder/domain/entities/workorder.dart';

class WorkOrderStatusUpdateApi {
  // Update Status Method
  static Future<String> updateWorkOrderStatus(String id, String status) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bearerToken = prefs.getString('bearer_token');
    String baseURL = "https://demoapi.orienseam.com/api";
    if (bearerToken == null) {
      throw Exception('Bearer token not found.');
    }
    print(id);
    print(status);
    final response = await http.put(
      Uri.parse('$baseURL/workorder/updatestatus'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
      body: jsonEncode(<String, dynamic>{
        'id': id,
        "status": status,
        "notes": "Test",
        "reasontoCancel": "string",
        "currentReading": 0
      }),
    );

    if (response.statusCode == 200) {
      dynamic body = jsonDecode(response.body);
      return body["message"];
    } else {
      throw Exception('Failed to update WorkOrder.');
    }
  }

  static Future<String> updateWorkOrderTaskStatus(String id, String status,
      String workOrderId, int currentReading, String meterId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bearerToken = prefs.getString('bearer_token');
    String baseURL = "https://demoapi.orienseam.com/api";

    if (bearerToken == null) {
      throw Exception('Bearer token not found.');
    }

    List<Map<String, dynamic>> body = [
      {
        'id': id,
        'taskStatus': status,
      }
    ];

    DateTime currentDateTime = DateTime.now();
    String formattedDateTime =
        DateFormat('yyyy-MM-dd – kk:mm').format(currentDateTime);

    print("testttttttt${body}");
    final response = await http.post(
      Uri.parse('$baseURL/workordertask/bulkstatusupdate'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      dynamic body = jsonDecode(response.body);
      return body["message"];
    } else {
      print(response.body);
      throw Exception('Failed to update WorkOrder.');
    }
  }

  static Future<String> updateWorkOrder(
      String id, String status, String assetId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bearerToken = prefs.getString('bearer_token');

    String baseURL = "https://demoapi.orienseam.com/api";

    if (bearerToken == null) {
      throw Exception('Bearer token not found.');
    }

    Map<String, dynamic> body = {
      'id': id,
      'workedHours': status,
      'assetId': assetId
    };

    final response = await http.put(
      Uri.parse('$baseURL/workorder/update'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      dynamic body = jsonDecode(response.body);
      return body["message"];
    } else {
      print(response.body);
      throw Exception('Failed to update WorkOrder.');
    }
  }

  static Future<List<Map<String, dynamic>>> getFavorite() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bearerToken = prefs.getString('bearer_token');

    String baseURL = "https://demoapi.orienseam.com/api";

    if (bearerToken == null) {
      throw Exception('Bearer token not found.');
    }

    final response = await http.get(
      Uri.parse('$baseURL/workorder/getwolistbyisfavourite'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body["result"] != null && body["result"] is List) {
        return List<Map<String, dynamic>>.from(body["result"]);
      } else {
        throw Exception('No work orders found');
      }
    } else {
      print('Error response: ${response.body}');
      throw Exception('Failed to fetch favorite work orders.');
    }
  }

  static Future<String> saveWorkOrder(
      String id, bool status, String assetId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bearerToken = prefs.getString('bearer_token');
    String baseURL = "https://demoapi.orienseam.com/api";

    if (bearerToken == null) {
      throw Exception('Bearer token not found.');
    }

    Map<String, dynamic> body = {
      'id': id,
      'isFavouriteWO': status,
      'assetId': assetId
    };

    final response = await http.put(
      Uri.parse('$baseURL/workorder/update'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
      body: jsonEncode(body),
    );
    print("isSelectedData${response.statusCode}");

    if (response.statusCode == 200) {
      dynamic body = jsonDecode(response.body);
      return body["message"];
    } else {
      print(response.body);
      throw Exception('Failed to update WorkOrder.');
    }
  }

  // static Future<String> createworkorderdoc(String id, File file) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String? bearerToken = prefs.getString('bearer_token');
  //   String baseURL = "https://demoapi.orienseam.com/api";
  //
  //   if (bearerToken == null) {
  //     throw Exception('Bearer token not found.');
  //   }
  //
  //   // Convert file to Base64
  //   List<int> fileBytes = await file.readAsBytes();
  //   String base64File = base64Encode(fileBytes);
  //
  //   final response = await http.put(
  //     Uri.parse('$baseURL/workorder/uploaddocument'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $bearerToken',
  //     },
  //     body: jsonEncode(<String, dynamic>{
  //       'id': id,
  //       "documentName": file.path.split('/').last, // Extracting filename
  //       "documentData": base64File, // Sending Base64 data
  //       "documentcategory": "TechnicalSpecification",
  //       "documenttype": "Image"
  //     }),
  //   );
  //
  //   if (response.statusCode == 200) {
  //     dynamic body = jsonDecode(response.body);
  //     return body["message"];
  //   } else {
  //     throw Exception('Failed to update document.');
  //   }
  // }

  static Future<String> createworkorderdoc(String id, File file) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? bearerToken = prefs.getString('bearer_token');
    String baseURL = "https://demoapi.orienseam.com/api";

    if (bearerToken == null) {
      throw Exception('Bearer token not found.');
    }

    // Convert file to Base64
    List<int> fileBytes = await file.readAsBytes();
    String base64File = base64Encode(fileBytes);

    // Determine file type based on extension
    String fileName = file.path.split('/').last;
    String fileExtension = fileName.split('.').last.toLowerCase();
    String documentType = (fileExtension == "pdf") ? "PDF" : "Image";

    final response = await http.post(
      Uri.parse('$baseURL/workorder/uploaddocument'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
      body: jsonEncode(<String, dynamic>{
        "workOrderId": id,
        "documentName": fileName, // Extracting filename
        "documentData": base64File, // Sending Base64 data
        "documentcategory": "TechnicalSpecification",
        "documenttype": documentType // Dynamic document type
      }),
    );

    if (response.statusCode == 200) {
      dynamic body = jsonDecode(response.body);
      return body["message"];
    } else {
      throw Exception('Failed to update document: ${response.body}');
    }
  }



}

