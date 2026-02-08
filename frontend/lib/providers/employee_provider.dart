import 'package:flutter/material.dart';
import '../models/employee.dart';
import '../services/employee_service.dart';
import '../services/api_service.dart';

class EmployeeProvider extends ChangeNotifier {
  List<Employee> _employees = [];
  Employee? _selectedEmployee;
  bool _isLoading = false;
  String? _error;

  List<Employee> get employees => _employees;
  Employee? get selectedEmployee => _selectedEmployee;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all employees
  Future<void> fetchEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employees = await EmployeeService.getEmployees();
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load employees';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get employee by ID
  Future<void> getEmployee(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedEmployee = await EmployeeService.getEmployeeById(id);
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load employee';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add employee
  Future<bool> addEmployee(Employee employee) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await EmployeeService.addEmployee(employee);
      _isLoading = false;
      notifyListeners();
      // Refresh the list to get the correct data from server
      await fetchEmployees();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to add employee';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update employee
  Future<bool> updateEmployee(String id, Map<String, dynamic> data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedEmployee = await EmployeeService.updateEmployee(id, data);

      // Update local list
      final index = _employees.indexWhere((e) => e.id == id);
      if (index != -1) {
        _employees[index] = updatedEmployee;
      }

      // Update selected employee if it's the one being updated
      if (_selectedEmployee?.id == id) {
        _selectedEmployee = updatedEmployee;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to update employee';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Clear selection
  void clearSelection() {
    _selectedEmployee = null;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
