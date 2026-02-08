import mongoose from "mongoose";

const payrollSchema = new mongoose.Schema(
  {
    employeeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Employee",
      required: true,
    },
    month: Number,
    year: Number,

    workingDays: Number,
    presentDays: Number,
    absentDays: Number,

    perDaySalary: Number,
    payableSalary: Number,

    status: {
      type: String,
      default: "GENERATED", // GENERATED | PAID
    },
  },
  { timestamps: true },
);

export default mongoose.model("Payroll", payrollSchema);
