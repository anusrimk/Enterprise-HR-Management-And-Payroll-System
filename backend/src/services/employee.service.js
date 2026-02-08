import Employee from "../models/Employee.js";

export const createEmployee = async (data) => {
  return await Employee.create(data);
};

export const getAllEmployees = async () => {
  return await Employee.find();
};

export const getEmployeeById = async (id) => {
  return await Employee.findById(id);
};

export const updateEmployee = async (id, data) => {
  return await Employee.findByIdAndUpdate(id, data, { new: true });
};
