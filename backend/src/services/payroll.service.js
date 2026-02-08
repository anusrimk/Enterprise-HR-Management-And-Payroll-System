import Payroll from "../models/Payroll.js";
import Attendance from "../models/Attendance.js";
import { calculatePayroll } from "../utils/payrollCalculator.js";
import { DEFAULT_WORKING_DAYS_PER_MONTH } from "../config/constants.js";

export const runPayroll = async (employee, month, year) => {
  const workingDays = DEFAULT_WORKING_DAYS_PER_MONTH;

  const attendanceRecords = await Attendance.find({
    employeeId: employee._id,
  });

  const presentDays = attendanceRecords.filter(
    (a) => a.status === "PRESENT",
  ).length;

  const absentDays = workingDays - presentDays;

  const { perDaySalary, payableSalary } = calculatePayroll(
    employee.salary,
    workingDays,
    presentDays,
  );

  const payroll = await Payroll.create({
    employeeId: employee._id,
    month,
    year,
    workingDays,
    presentDays,
    absentDays,
    perDaySalary,
    payableSalary,
  });

  return payroll;
};

export const getEmployeePayroll = async (employeeId) => {
  return await Payroll.find({ employeeId }).sort({ year: -1, month: -1 });
};
