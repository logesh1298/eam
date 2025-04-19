import 'package:dio/dio.dart';
import 'package:eam/core/utils/dio_client.dart';
import 'package:eam/core/utils/enum/network_enums.dart';

class PartsApiService {
  final DioManager dioManager;

  PartsApiService({required this.dioManager});

  Future<dynamic> getparts() async {
    Response response = await dioManager.dio.get(NetworkEnums.allparts.path);
    return response;
  }

  // Future<dynamic> getAssetsById(String assetId) async {
  //   print(NetworkEnums.assetById.path + assetId);
  //   Response response = await dioManager.dio.get(NetworkEnums.assetById.path + assetId);
  //   return response;
  // }
  //
  // Future<dynamic> getSpecifyById(String assetId) async {
  //   print(NetworkEnums.specifyById.path + assetId);
  //   Response response = await dioManager.dio.get(NetworkEnums.specifyById.path + assetId);
  //   return response;
  // }
  //
  // Future<dynamic> getAssetPartsById(String assetId) async {
  //   print(NetworkEnums.assetPartsById.path + assetId);
  //   Response response = await dioManager.dio.get(NetworkEnums.assetPartsById.path + assetId);
  //   return response;
  // }
}
