import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:eam/core/utils/dio_client.dart';
import 'package:eam/core/utils/enum/network_enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddServiceRequestApi {
  final DioManager dioManager;

  AddServiceRequestApi({required this.dioManager});

  // static Future<void> addServiceRequest(ServiceRequest serviceRequest) async {
  //   final response = await http.post(
  //     Uri.parse("https://eamapi.s2tsoft.com/api/servicerequest/create"),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(serviceRequest.toJson()),
  //   );
  //
  //   if (response.statusCode == 201) {
  //     print('Service Request Added successfully!');
  //   } else {
  //     throw Exception('Failed to post service request');
  //   }
  // }

  Future<void> addServiceRequest(Map<String, dynamic> serviceRequest) async {
    final response = await dioManager.dio.post(
      NetworkEnums.createServiceRequest.path,
      data: serviceRequest,
    );
    final responseBody = response.data;
    print("ResponseBody: $responseBody");
    if (response.statusCode == 200) {
      print('Service Request Added successfully!');
    } else {
      throw Exception('Failed to post service request');
    }

  }

  Future<void> updateServiceRequest(Map<String, dynamic> serviceRequest) async {
    final response = await dioManager.dio.put(
      NetworkEnums.updateServiceRequest.path,
      data: serviceRequest,
    );
    final responseBody = response.data;
    print("ResponseBody: $responseBody");
    if (response.statusCode == 200) {
      print('Service Request Added successfully!');
    } else {
      throw Exception('Failed to post service request');
    }

  }


  // Future<void> addServiceRequest(Map<String, dynamic> serviceRequest) async {
  //   try {
  //     final response = await dioManager.dio.post(
  //       NetworkEnums.createServiceRequest.path,
  //       data: serviceRequest,
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('✅ Service Request Added Successfully!');
  //       print("📩 Response Data: ${response.data}");
  //     } else {
  //       print('❌ Failed to add service request. Status Code: ${response.statusCode}');
  //       print("📌 Response: ${response.data}");
  //       throw Exception('Failed to post service request');
  //     }
  //   } catch (e) {
  //     print('🔥 Error occurred while posting service request: $e');
  //   }
  // }


  Future<void> addServiceRequestdoc(Map<String, dynamic> serviceRequest) async {
    final response = await dioManager.dio.post(
      NetworkEnums.createServiceDocument.path,
      data: serviceRequest,
    );
    final responseBody = response.data;
    print("ResponseBody: $responseBody");
    if (response.statusCode == 200) {
      print('Service Request Added successfully!');
    } else {
      throw Exception('Failed to post service request');
    }
  }

  static Future<String> createservicerequestdoc(String id, File file) async {
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
      Uri.parse('$baseURL/servicerequest/uploaddocument'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      },
      body: jsonEncode(<String, dynamic>{
        "serviceRequestId": id,
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
