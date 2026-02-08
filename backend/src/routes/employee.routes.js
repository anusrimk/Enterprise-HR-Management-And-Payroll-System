import { Router } from "express";
import * as controller from "../controllers/employee.controller.js";
import { authMiddleware, requireRole } from "../middlewares/auth.middleware.js";

const router = Router();

// All routes require authentication
router.use(authMiddleware);

// ADMIN and HR can add employees
router.post("/", requireRole("ADMIN", "HR"), controller.addEmployee);

// All authenticated users can view employees list
router.get("/", controller.getEmployees);

// All authenticated users can view employee details
router.get("/:id", controller.getEmployeeById);

// ADMIN and HR can update employee details
router.put("/:id", requireRole("ADMIN", "HR"), controller.updateEmployee);

export default router;
