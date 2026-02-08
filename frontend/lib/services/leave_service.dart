import '../models/leave.dart';
import 'api_service.dart';

class LeaveService {
  // Create leave request
  static Future<Leave> createLeave(Leave leave) async {
    final response = await ApiService.post('/leaves', leave.toJson());
    return Leave.fromJson(response['data'] ?? response);
  }

  // Get all leaves
  static Future<List<Leave>> getAllLeaves() async {
    final response = await ApiService.get('/leaves');
    final List<dynamic> data = response['data'] ?? response['leaves'] ?? [];
    return data.map((json) => Leave.fromJson(json)).toList();
  }

  // Get leaves by employee
  static Future<List<Leave>> getLeavesByEmployee(String employeeId) async {
    final response = await ApiService.get('/leaves/employee/$employeeId');
    final List<dynamic> data = response['data'] ?? response['leaves'] ?? [];
    return data.map((json) => Leave.fromJson(json)).toList();
  }

  // Update leave (approve/reject)
  static Future<Leave> updateLeave(String id, String status) async {
    final response = await ApiService.put('/leaves/$id', {'status': status});
    return Leave.fromJson(response['data'] ?? response);
  }
}
