class Employee {
  final String id;
  final String name;
  final String email;
  final String department;
  final String designation;
  final DateTime joiningDate;
  final double salary;
  final String status;

  Employee({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.designation,
    required this.joiningDate,
    required this.salary,
    required this.status,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'] ?? '',
      designation: json['designation'] ?? '',
      joiningDate: DateTime.parse(
        json['joiningDate'] ?? DateTime.now().toIso8601String(),
      ),
      salary: (json['salary'] ?? 0).toDouble(),
      status: json['status'] ?? 'ACTIVE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'department': department,
      'designation': designation,
      'joiningDate': joiningDate.toIso8601String(),
      'salary': salary,
      'status': status,
    };
  }
}
