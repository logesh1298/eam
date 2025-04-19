import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:eam/core/utils/dio_client.dart';
import 'package:eam/features/13_parts/presentation/domain/parts_api.dart';

import '../../../../core/resources/data_state.dart';
import '../../../7_assets/domain/asset_api.dart';

import '../data/parts.dart';
import 'parts_api.dart';

class PartsRepo {
  static Future<DataState<List<Part>>> getparts() async {
    try {
      final response = await PartsApiService(dioManager: DioManager.instance).getparts();
      if (response.statusCode == HttpStatus.ok) {
        final Map<String, dynamic> jsonResponse = response.data;
        final List<dynamic> result = jsonResponse["result"];
        final List<Part> parts = result.map((json) => Part.fromJson(json)).toList();
        return DataSuccess(parts);
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

  // static Future<DataState<AssetDetails>> getAssetsById(String assetId) async {
  //   try {
  //     final response =
  //     await AssetApiService(dioManager: DioManager.instance).getAssetsById(assetId);
  //     if (response.statusCode == HttpStatus.ok) {
  //       final Map<String, dynamic> jsonResponse = response.data;
  //
  //       final AssetDetails asset = AssetDetails.fromJson(jsonResponse);
  //
  //       return DataSuccess(asset);
  //     } else {
  //       return DataFailed(
  //         DioException(
  //             error: response.response.statusMessage,
  //             response: response.response,
  //             type: DioExceptionType.badResponse,
  //             requestOptions: response.response.requestOptions),
  //       );
  //     }
  //   } on DioException catch (e) {
  //     return DataFailed(e);
  //   }
  // }


  // static Future<DataState<List<AssetPartsModel>>> getAssetsPartsById(String assetId) async {
  //   try {
  //     final response =
  //     await AssetApiService(dioManager: DioManager.instance).getAssetPartsById(assetId);
  //     if (response.statusCode == HttpStatus.ok) {
  //       final Map<String, dynamic> jsonResponse = response.data;
  //       List<AssetPartsModel> assetParts = [];
  //
  //       if(jsonResponse["message"] != ""){
  //         final Map<String, dynamic> body = jsonDecode(response.data);
  //         List<dynamic> results = body["result"];
  //         assetParts = results.map((json) => AssetPartsModel.fromJson(json)).toList();
  //         print(assetParts.length);
  //         return DataSuccess(assetParts);
  //       }else{
  //         return DataSuccess(assetParts);
  //       }
  //     } else {
  //       return DataFailed(
  //         DioException(
  //             error: response.response.statusMessage,
  //             response: response.response,
  //             type: DioExceptionType.badResponse,
  //             requestOptions: response.response.requestOptions),
  //       );
  //     }
  //   } on DioException catch (e) {
  //     return DataFailed(e);
  //   }
  // }
  //
  //
  //
  // static Future<DataState<AssetDetails>> getSpecifyById(String assetId) async {
  //   try {
  //     final response =
  //     await AssetApiService(dioManager: DioManager.instance).getSpecifyById(assetId);
  //     if (response.statusCode == HttpStatus.ok) {
  //       final Map<String, dynamic> jsonResponse = response.data;
  //
  //       final AssetDetails asset = AssetDetails.fromJson(jsonResponse);
  //
  //       return DataSuccess(asset);
  //     } else {
  //       return DataFailed(
  //         DioException(
  //             error: response.response.statusMessage,
  //             response: response.response,
  //             type: DioExceptionType.badResponse,
  //             requestOptions: response.response.requestOptions),
  //       );
  //     }
  //   } on DioException catch (e) {
  //     return DataFailed(e);
  //   }
  // }


// static Future<Asset> getAssetsById(String assetId) async {
//   Map<String, dynamic> response =
//       await AssetApiService.getAssetsById("$eamAPIBaseURL/assets/getbyid/$assetId");
//   final Asset asset = Asset.fromJson(response);
//   // response.entries.map((e) => Asset.fromJson({e.key: e.value})).toList();
//   return asset;
// }
}
