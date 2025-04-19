import '../../../core/utils/dio_client.dart';
import '../service_request_data/work_type.dart';

class WorkTypeRepository {
  final DioManager dioManager;

  WorkTypeRepository({required this.dioManager});

  Future<List<WorkTypes>> getWorkTypes() async {
    try {
      final response = await dioManager.dio.get(
        'https://demoapi.orienseam.com/api/worktype/getall',

      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final result = data['result'] as List;
        return result.map((json) => WorkTypes.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load work types: $e');
    }
  }
}