import mongoose from "mongoose";
import { ATTENDANCE_STATUS } from "../config/constants.js";

const attendanceSchema = new mongoose.Schema(
  {
    employeeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Employee",
      required: [true, "Employee is required"],
    },
    date: {
      type: Date,
      required: [true, "Attendance date is required"],
    },
    status: {
      type: String,
      required: [true, "Attendance status is required"],
      enum: {
        values: ATTENDANCE_STATUS,
        message:
          "Status must be one of: PRESENT, ABSENT, HALF_DAY, LEAVE, HOLIDAY, WEEK_OFF",
      },
    },
  },
  {
    timestamps: true,
  },
);

// One attendance record per employee per day
attendanceSchema.index({ employeeId: 1, date: 1 }, { unique: true });

export default mongoose.model("Attendance", attendanceSchema);
