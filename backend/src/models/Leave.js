import mongoose from "mongoose";
import { LEAVE_TYPES, LEAVE_REQUEST_STATUS } from "../config/constants.js";

const leaveSchema = new mongoose.Schema(
  {
    employeeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Employee",
      required: [true, "Employee is required"],
    },
    leaveType: {
      type: String,
      required: [true, "Leave type is required"],
      enum: {
        values: LEAVE_TYPES,
        message:
          "Leave type must be one of: SICK, CASUAL, ANNUAL, UNPAID, MATERNITY, PATERNITY",
      },
    },
    startDate: {
      type: Date,
      required: [true, "Start date is required"],
    },
    endDate: {
      type: Date,
      required: [true, "End date is required"],
    },
    days: {
      type: Number,
      required: [true, "Number of days is required"],
      min: [1, "Leave must be at least 1 day"],
    },
    reason: {
      type: String,
      trim: true,
    },
    status: {
      type: String,
      enum: {
        values: LEAVE_REQUEST_STATUS,
        message: "Status must be PENDING, APPROVED, REJECTED, or CANCELLED",
      },
      default: "PENDING",
    },
    approvedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Employee",
    },
    approvedAt: {
      type: Date,
    },
  },
  {
    timestamps: true,
  },
);

export default mongoose.model("Leave", leaveSchema);
