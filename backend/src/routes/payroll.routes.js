import { Router } from "express";
import * as controller from "../controllers/payroll.controller.js";
import { authMiddleware, requireRole } from "../middlewares/auth.middleware.js";

const router = Router();

// All routes require authentication
router.use(authMiddleware);

// Only ADMIN and HR can generate payroll
router.post(
  "/generate",
  requireRole("ADMIN", "HR"),
  controller.generatePayroll,
);

// All authenticated users can view payroll (controller filters by role)
router.get("/:employeeId", controller.getEmployeePayroll);

export default router;
