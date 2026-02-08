import 'api_service.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getOverview() async {
    final response = await ApiService.get('/dashboard/overview');
    return response;
  }
}
