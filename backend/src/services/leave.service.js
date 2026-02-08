import Leave from "../models/Leave.js";

export const create = async (data) => {
  return Leave.create(data);
};

export const findAll = async (filter = {}) => {
  return Leave.find(filter)
    .populate("employeeId", "name email department")
    .sort({ createdAt: -1 })
    .lean();
};

export const findByEmployee = async (employeeId) => {
  return Leave.find({ employeeId }).sort({ startDate: -1 }).lean();
};

export const findById = async (id) => {
  return Leave.findById(id).populate("employeeId").lean();
};

export const updateById = async (id, data) => {
  return Leave.findByIdAndUpdate(id, data, { new: true }).lean();
};

export const getLeaveDaysInMonth = async (employeeId, year, month) => {
  const start = new Date(year, month - 1, 1);
  const end = new Date(year, month, 0);
  const leaves = await Leave.find({
    employeeId,
    status: "APPROVED",
    startDate: { $lte: end },
    endDate: { $gte: start },
  }).lean();
  let totalDays = 0;
  for (const leave of leaves) {
    const overlapStart = new Date(
      Math.max(leave.startDate.getTime(), start.getTime()),
    );
    const overlapEnd = new Date(
      Math.min(leave.endDate.getTime(), end.getTime()),
    );
    const days =
      Math.ceil((overlapEnd - overlapStart) / (1000 * 60 * 60 * 24)) + 1;
    totalDays += Math.max(0, days);
  }
  return totalDays;
};
