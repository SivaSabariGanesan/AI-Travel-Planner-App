import rateLimit from "express-rate-limit";

const aiWindowMs = Number(process.env.AI_RATE_LIMIT_WINDOW_MS || 60_000);
const aiMaxRequests = Number(process.env.AI_RATE_LIMIT_MAX || 20);

export const aiRateLimiter = rateLimit({
  windowMs: aiWindowMs,
  max: aiMaxRequests,
  standardHeaders: true,
  legacyHeaders: false,
  message: {
    message: "Too many AI requests. Please wait and try again.",
  },
});
