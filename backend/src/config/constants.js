export const PORT = process.env.PORT || 5000;
export const NODE_ENV = process.env.NODE_ENV || "development";

// Employee
export const EMPLOYEE_STATUS = ["ACTIVE", "INACTIVE", "RESIGNED"];

// Attendance
export const ATTENDANCE_STATUS = [
  "PRESENT",
  "ABSENT",
  "HALF_DAY",
  "LEAVE",
  "HOLIDAY",
  "WEEK_OFF",
];

// Payroll
export const PAYROLL_STATUS = ["GENERATED", "PAID"];
export const DEFAULT_WORKING_DAYS_PER_MONTH = 22;

// Leave
export const LEAVE_TYPES = [
  "SICK",
  "CASUAL",
  "ANNUAL",
  "UNPAID",
  "MATERNITY",
  "PATERNITY",
];
export const LEAVE_REQUEST_STATUS = [
  "PENDING",
  "APPROVED",
  "REJECTED",
  "CANCELLED",
];
