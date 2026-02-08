// API Configuration
const String apiBaseUrl = 'http://localhost:8080/api';

// Employee Status
enum EmployeeStatus { active, inactive, resigned }

// Attendance Status
enum AttendanceStatus { present, absent, halfDay, leave, holiday, weekOff }

// Leave Types
enum LeaveType { sick, casual, annual, unpaid, maternity, paternity }

// Leave Request Status
enum LeaveRequestStatus { pending, approved, rejected, cancelled }

// Payroll Status
enum PayrollStatus { generated, paid }

// User Roles
enum UserRole { admin, hr, employee }
