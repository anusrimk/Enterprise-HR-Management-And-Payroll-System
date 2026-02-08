import { Router } from "express";
import * as controller from "../controllers/attendance.controller.js";
import { authMiddleware } from "../middlewares/auth.middleware.js";

const router = Router();

// All routes require authentication
router.use(authMiddleware);

// Get DAILY attendance (Admin/HR) - MUST be defined before /:employeeId because it's a specific route
// Example: /api/attendance/daily?date=2026-02-09
router.get("/daily", controller.getDailyAttendance);

// Any authenticated user can mark attendance
// Controller will validate: employees can only mark their own, ADMIN/HR can mark anyone's
router.post("/mark", controller.markAttendance);

// Self check-in endpoint for employees
router.post("/check-in", controller.selfCheckIn);

// All authenticated users can view attendance
// Note: This catches /:employeeId so ensure other specific GET routes are above this
router.get("/:employeeId", controller.getEmployeeAttendance);

export default router;
