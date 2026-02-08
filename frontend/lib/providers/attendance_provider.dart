import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../models/employee.dart';
import '../services/attendance_service.dart';
import '../services/employee_service.dart';
import '../services/api_service.dart';

class AttendanceProvider extends ChangeNotifier {
  List<Employee> _employees = [];
  final Map<String, String> _todayAttendance = {}; // employeeId -> status
  List<Attendance> _attendanceHistory = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();
  bool _checkedInToday = false;

  List<Employee> get employees => _employees;
  Map<String, String> get todayAttendance => _todayAttendance;
  List<Attendance> get attendanceHistory => _attendanceHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;
  bool get checkedInToday => _checkedInToday;

  // Fetch employees for marking attendance (ADMIN/HR only)
  Future<void> fetchEmployees() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Parallel fetch: Employees AND Today's Attendance
      final employeeFuture = EmployeeService.getEmployees();
      final attendanceFuture = AttendanceService.getDailyAttendance(
        _selectedDate,
      );

      _employees = await employeeFuture;
      final attendance = await attendanceFuture;

      _todayAttendance.clear();
      for (var record in attendance) {
        // record.employeeId is a string ID? Or object?
        // Attendance model has employeeId.
        _todayAttendance[record.employeeId] = record.status;
      }

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

  // Fetch only daily attendance (e.g. when date changes)
  Future<void> fetchDailyAttendance() async {
    try {
      final records = await AttendanceService.getDailyAttendance(_selectedDate);
      _todayAttendance.clear();
      for (var record in records) {
        _todayAttendance[record.employeeId] = record.status;
      }
      notifyListeners();
    } catch (e) {
      // Non-blocking error
    }
  }

  // Mark attendance for an employee
  Future<bool> markAttendance({
    required String employeeId,
    required String status,
  }) async {
    try {
      await AttendanceService.markAttendance(
        employeeId: employeeId,
        date: _selectedDate,
        status: status,
      );
      _todayAttendance[employeeId] = status;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to mark attendance';
      notifyListeners();
      return false;
    }
  }

  // Self check-in for employees
  Future<bool> selfCheckIn() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AttendanceService.selfCheckIn();
      _checkedInToday = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Failed to check in';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get attendance history for an employee
  Future<void> fetchAttendanceHistory(String employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendanceHistory = await AttendanceService.getEmployeeAttendance(
        employeeId,
      );
      _isLoading = false;
      notifyListeners();
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load attendance history';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    fetchDailyAttendance(); // Fetch new data
    notifyListeners();
  }

  // Get attendance status for employee on selected date
  String? getAttendanceStatus(String employeeId) {
    return _todayAttendance[employeeId];
  }

  // Check if current user is checked in
  void checkCheckInStatus(String? employeeId) {
    if (employeeId == null) {
      _checkedInToday = false;
      notifyListeners();
      return;
    }
    final status = _todayAttendance[employeeId];
    // Consider checked in if status is PRESENT or HALF_DAY
    _checkedInToday = status == 'PRESENT' || status == 'HALF_DAY';
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
