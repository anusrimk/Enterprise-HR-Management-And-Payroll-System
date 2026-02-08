import mongoose from "mongoose";

const salarySchema = new mongoose.Schema(
  {
    employeeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Employee",
      required: [true, "Employee is required"],
    },
    baseSalary: {
      type: Number,
      required: [true, "Base salary is required"],
      min: [0, "Salary cannot be negative"],
    },
    allowances: {
      type: Number,
      default: 0,
      min: 0,
    },
    deductions: {
      type: Number,
      default: 0,
      min: 0,
    },
    effectiveFrom: {
      type: Date,
      required: [true, "Effective from date is required"],
    },
    effectiveTo: {
      type: Date,
    },
    isCurrent: {
      type: Boolean,
      default: true,
    },
  },
  {
    timestamps: true,
  },
);

export default mongoose.model("Salary", salarySchema);
