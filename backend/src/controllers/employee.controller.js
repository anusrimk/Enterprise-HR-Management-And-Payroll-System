import * as employeeService from "../services/employee.service.js";
import User from "../models/User.js";
import Employee from "../models/Employee.js";

// Add employee - also creates a User account with default credentials
export const addEmployee = async (req, res) => {
  try {
    const {
      name,
      email,
      department,
      designation,
      joiningDate,
      salary,
      status,
    } = req.body;

    // Check if employee with this email already exists
    const existingEmployee = await Employee.findOne({ email });
    if (existingEmployee) {
      return res
        .status(400)
        .json({ message: "Employee with this email already exists" });
    }

    // Create default email if not provided
    const employeeEmail =
      email || `${name.toLowerCase().replace(/\s+/g, ".")}@company.in`;

    // Create employee record
    const employee = await Employee.create({
      name,
      email: employeeEmail,
      department,
      designation,
      joiningDate: joiningDate || new Date(),
      salary: salary || 0,
      status: status || "INACTIVE",
    });

    // Check if user with this email already exists
    const existingUser = await User.findOne({ email: employeeEmail });

    if (!existingUser) {
      // Create user account with default password
      const user = await User.create({
        name,
        email: employeeEmail,
        password: "default_password",
        role: "EMPLOYEE",
        employeeId: employee._id,
      });

      // Update employee with userId reference
      await Employee.findByIdAndUpdate(employee._id, { userId: user._id });
    } else {
      // Link existing user to employee if not already linked
      if (!existingUser.employeeId) {
        await User.findByIdAndUpdate(existingUser._id, {
          employeeId: employee._id,
        });
        await Employee.findByIdAndUpdate(employee._id, {
          userId: existingUser._id,
        });
      }
    }

    res.json({
      message: "Employee added successfully",
      data: employee,
    });
  } catch (error) {
    console.error("Error adding employee:", error);
    res
      .status(500)
      .json({ message: error.message || "Failed to add employee" });
  }
};

export const getEmployees = async (req, res) => {
  const employees = await employeeService.getAllEmployees();
  res.json({ data: employees });
};

export const getEmployeeById = async (req, res) => {
  const employee = await employeeService.getEmployeeById(req.params.id);
  if (!employee) {
    return res.status(404).json({ message: "Employee not found" });
  }
  res.json({ data: employee });
};

export const updateEmployee = async (req, res) => {
  try {
    const updatedEmployee = await employeeService.updateEmployee(
      req.params.id,
      req.body,
    );
    if (!updatedEmployee) {
      return res.status(404).json({ message: "Employee not found" });
    }
    res.json({
      message: "Employee updated successfully",
      data: updatedEmployee,
    });
  } catch (error) {
    res
      .status(500)
      .json({ message: error.message || "Failed to update employee" });
  }
};
