import { Router } from "express";
import * as controller from "../controllers/dashboard.controller.js";
import { authMiddleware, requireRole } from "../middlewares/auth.middleware.js";

const router = Router();

// All routes require authentication
router.use(authMiddleware);

// Only ADMIN and HR can view company-wide dashboard
router.get("/overview", requireRole("ADMIN", "HR"), controller.getOverview);

export default router;
