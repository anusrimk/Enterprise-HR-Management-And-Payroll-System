import { Router } from "express";
import * as controller from "../controllers/leave.controller.js";
import { authMiddleware, requireRole } from "../middlewares/auth.middleware.js";

const router = Router();

// All routes require authentication
router.use(authMiddleware);

// Any authenticated user can create a leave request (for themselves)
router.post("/", controller.createLeave);

// ADMIN and HR can view all leaves
router.get("/", requireRole("ADMIN", "HR"), controller.getAllLeaves);

// All authenticated users can view their own leaves (controller filters by role)
router.get("/employee/:employeeId", controller.getLeavesByEmployee);

// All authenticated users can view leave details
router.get("/:id", controller.getLeaveById);

// ADMIN and HR can approve/reject leaves
router.put("/:id", requireRole("ADMIN", "HR"), controller.updateLeave);

export default router;
