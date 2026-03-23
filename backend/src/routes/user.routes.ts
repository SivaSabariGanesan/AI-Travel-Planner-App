import { Router } from "express";
import { getCurrentUser, updatePreferences } from "../controllers/user.controller";
import { requireAuth } from "../middleware/auth";

const router = Router();

router.get("/me", requireAuth, getCurrentUser);
router.put("/preferences", requireAuth, updatePreferences);

export { router as userRouter };
