import Employee from "../models/Employee.js";
import * as payrollService from "../services/payroll.service.js";

export const generatePayroll = async (req, res) => {
  const { employeeId, month, year } = req.body;

  const employee = await Employee.findById(employeeId);

  if (!employee) {
    return res.status(404).json({ message: "Employee not found" });
  }

  const payroll = await payrollService.runPayroll(employee, month, year);

  res.json({
    message: "Payroll generated successfully",
    payroll,
  });
};

export const getEmployeePayroll = async (req, res) => {
  const payrolls = await payrollService.getEmployeePayroll(
    req.params.employeeId,
  );
  res.json(payrolls);
};
