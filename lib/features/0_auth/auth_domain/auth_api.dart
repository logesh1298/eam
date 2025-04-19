import 'dart:convert';
import 'package:dio/dio.dart';

class AuthApi {
  static Future<dynamic> getToken(
      String url,
      ) async {
    final data = {"email": "SiteAdmin@Orienseam", "password": "123@EAMADmin"};
    try {
      final response = await Dio().post(
        url,
        data: jsonEncode(data),
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = response.data;
        final Map<String, dynamic> results = jsonResponse['result'];
        return results;
      } else {
        throw Exception('Failed to fetch token. Status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print('Dio error: ${e.response?.data}');
      } else {
        print('Dio error: ${e.message}');
      }
      return null;
    } catch (e) {
      // Handle other exceptions
      print('Unexpected error: $e');
      return null;
    }
  }
}
