import '../models/payroll.dart';
import 'api_service.dart';

class PayrollService {
  // Generate payroll
  static Future<Payroll> generatePayroll({
    required String employeeId,
    required int month,
    required int year,
  }) async {
    final response = await ApiService.post('/payroll/generate', {
      'employeeId': employeeId,
      'month': month,
      'year': year,
    });
    return Payroll.fromJson(response['data'] ?? response);
  }

  // Get employee payroll
  static Future<List<Payroll>> getEmployeePayroll(String employeeId) async {
    final response = await ApiService.get('/payroll/$employeeId');
    final List<dynamic> data = response['data'] ?? response['payroll'] ?? [];
    return data.map((json) => Payroll.fromJson(json)).toList();
  }
}
