import 'package:intl/intl.dart';
import '../models/attendance.dart';
import 'api_service.dart';

class AttendanceService {
  // Mark attendance
  static Future<Attendance> markAttendance({
    required String employeeId,
    required DateTime date,
    required String status,
  }) async {
    final response = await ApiService.post('/attendance/mark', {
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'status': status,
    });
    return Attendance.fromJson(response['data']);
  }

  // Get attendance by employee
  static Future<List<Attendance>> getEmployeeAttendance(
    String employeeId,
  ) async {
    final response = await ApiService.get('/attendance/$employeeId');
    return (response['data'] as List)
        .map((e) => Attendance.fromJson(e))
        .toList();
  }

  // Get daily attendance (Admin/HR)
  static Future<List<Attendance>> getDailyAttendance(DateTime date) async {
    final dateStr = DateFormat('yyyy-MM-dd').format(date);
    final response = await ApiService.get('/attendance/daily?date=$dateStr');
    return (response['data'] as List)
        .map((e) => Attendance.fromJson(e))
        .toList();
  }

  // Self check-in
  static Future<Attendance> selfCheckIn() async {
    final response = await ApiService.post('/attendance/check-in', {});
    return Attendance.fromJson(response['data']);
  }
}
