import { Router } from "express";
import {
	getAiSettings,
	getCurrentUser,
	testGeminiKey,
	updateAiSettings,
	updatePreferences,
} from "../controllers/user.controller";
import { requireAuth } from "../middleware/auth";
import {
	validateAiSettingsBody,
	validateGeminiKeyBody,
} from "../middleware/aiValidation";
import { aiRateLimiter } from "../middleware/rateLimiter";

const router = Router();

router.get("/me", requireAuth, getCurrentUser);
router.put("/preferences", requireAuth, updatePreferences);
router.get("/ai-settings", requireAuth, getAiSettings);
router.put("/ai-settings", requireAuth, validateAiSettingsBody, updateAiSettings);
router.post(
	"/ai-settings/test-key",
	requireAuth,
	aiRateLimiter,
	validateGeminiKeyBody,
	testGeminiKey,
);

export { router as userRouter };
