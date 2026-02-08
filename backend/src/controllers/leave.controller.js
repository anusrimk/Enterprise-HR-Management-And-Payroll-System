import * as leaveService from "../services/leave.service.js";

export const createLeave = async (req, res) => {
  const leave = await leaveService.create(req.body);
  res.json({
    message: "Leave request submitted successfully",
    leave,
  });
};

export const getAllLeaves = async (req, res) => {
  const { status, employeeId } = req.query;
  const filter = {};
  if (status) filter.status = status;
  if (employeeId) filter.employeeId = employeeId;
  const leaves = await leaveService.findAll(filter);
  res.json(leaves);
};

export const getLeavesByEmployee = async (req, res) => {
  const leaves = await leaveService.findByEmployee(req.params.employeeId);
  res.json(leaves);
};

export const getLeaveById = async (req, res) => {
  const leave = await leaveService.findById(req.params.id);
  if (!leave) {
    return res.status(404).json({ message: "Leave not found" });
  }
  res.json(leave);
};

export const updateLeave = async (req, res) => {
  const leave = await leaveService.updateById(req.params.id, req.body);
  if (!leave) {
    return res.status(404).json({ message: "Leave not found" });
  }
  res.json(leave);
};
