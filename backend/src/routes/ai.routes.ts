import { Router } from "express";
import {
  chatWithAi,
  getConversationById,
  getConversations,
  streamChatWithAi,
} from "../controllers/ai.controller";
import { requireAuth } from "../middleware/auth";
import { validateChatBody } from "../middleware/aiValidation";
import { aiRateLimiter } from "../middleware/rateLimiter";

const router = Router();

router.use(requireAuth, aiRateLimiter);
router.get("/conversations", getConversations);
router.get("/conversations/:conversationId", getConversationById);
router.post("/chat", validateChatBody, chatWithAi);
router.post("/chat/stream", validateChatBody, streamChatWithAi);

export { router as aiRouter };
