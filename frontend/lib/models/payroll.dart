class Payroll {
  final String id;
  final String employeeId;
  final int month;
  final int year;
  final int workingDays;
  final int presentDays;
  final int absentDays;
  final double perDaySalary;
  final double payableSalary;
  final String status;

  Payroll({
    required this.id,
    required this.employeeId,
    required this.month,
    required this.year,
    required this.workingDays,
    required this.presentDays,
    required this.absentDays,
    required this.perDaySalary,
    required this.payableSalary,
    required this.status,
  });

  factory Payroll.fromJson(Map<String, dynamic> json) {
    return Payroll(
      id: json['_id'] ?? json['id'] ?? '',
      employeeId: json['employeeId'] ?? '',
      month: json['month'] ?? 1,
      year: json['year'] ?? DateTime.now().year,
      workingDays: json['workingDays'] ?? 0,
      presentDays: json['presentDays'] ?? 0,
      absentDays: json['absentDays'] ?? 0,
      perDaySalary: (json['perDaySalary'] ?? 0).toDouble(),
      payableSalary: (json['payableSalary'] ?? 0).toDouble(),
      status: json['status'] ?? 'GENERATED',
    );
  }
}
