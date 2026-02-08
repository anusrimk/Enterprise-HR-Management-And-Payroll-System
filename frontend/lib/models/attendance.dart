class Attendance {
  final String id;
  final String employeeId;
  final DateTime date;
  final String status;

  Attendance({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.status,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['_id'] ?? json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? 'ABSENT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'date': date.toIso8601String(),
      'status': status,
    };
  }
}
