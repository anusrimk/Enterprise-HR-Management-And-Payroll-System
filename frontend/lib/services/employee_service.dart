import '../models/employee.dart';
import 'api_service.dart';

class EmployeeService {
  // Get all employees
  static Future<List<Employee>> getEmployees() async {
    final response = await ApiService.get('/employees');
    final List<dynamic> data = response['data'] ?? response['employees'] ?? [];
    return data.map((json) => Employee.fromJson(json)).toList();
  }

  // Get employee by ID
  static Future<Employee> getEmployeeById(String id) async {
    final response = await ApiService.get('/employees/$id');
    return Employee.fromJson(response['data'] ?? response);
  }

  // Add employee
  static Future<Employee> addEmployee(Employee employee) async {
    final response = await ApiService.post('/employees', employee.toJson());
    return Employee.fromJson(response['data'] ?? response);
  }

  // Update employee
  static Future<Employee> updateEmployee(
    String id,
    Map<String, dynamic> data,
  ) async {
    final response = await ApiService.put('/employees/$id', data);
    return Employee.fromJson(response['data'] ?? response);
  }
}
