import Attendance from "../models/Attendance.js";

export const markAttendance = async (data) => {
  const { employeeId, date, status } = data;

  // Normalize input date to start of day
  const d = new Date(date);
  const startOfDay = new Date(d);
  startOfDay.setHours(0, 0, 0, 0);

  const endOfDay = new Date(d);
  endOfDay.setHours(23, 59, 59, 999);

  // Find ALL records for this employee on this day
  const records = await Attendance.find({
    employeeId,
    date: { $gte: startOfDay, $lte: endOfDay },
  });

  if (records.length > 0) {
    // Update the first record found
    const mainRecord = records[0];
    mainRecord.status = status;
    mainRecord.date = startOfDay; // Ensure it's normalized to midnight
    await mainRecord.save();

    // If there are duplicates (more than 1 record for this day), delete them
    if (records.length > 1) {
      const duplicateIds = records.slice(1).map((r) => r._id);
      await Attendance.deleteMany({ _id: { $in: duplicateIds } });
      console.log(
        `Cleaned up ${duplicateIds.length} duplicate attendance records for employee ${employeeId}`,
      );
    }

    return mainRecord;
  } else {
    // No record exists, create new one
    return await Attendance.create({
      employeeId,
      date: startOfDay,
      status,
    });
  }
};

export const getByEmployee = async (employeeId) => {
  return await Attendance.find({ employeeId }).sort({ date: -1 });
};
