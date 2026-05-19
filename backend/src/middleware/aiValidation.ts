import type { NextFunction, Request, Response } from "express";
import { AppError } from "../utils/appError";

const ensureString = (value: unknown): string =>
  typeof value === "string" ? value.trim() : "";

export const validateAiSettingsBody = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  const aiMode = ensureString((req.body as { aiMode?: unknown }).aiMode);
  const geminiApiKey = ensureString(
    (req.body as { geminiApiKey?: unknown }).geminiApiKey,
  );

  if (!["app", "byok"].includes(aiMode)) {
    next(new AppError("aiMode must be either 'app' or 'byok'", 400));
    return;
  }

  if (aiMode === "byok" && geminiApiKey && geminiApiKey.length < 20) {
    next(new AppError("geminiApiKey is invalid", 400));
    return;
  }

  next();
};

export const validateGeminiKeyBody = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  const geminiApiKey = ensureString(
    (req.body as { geminiApiKey?: unknown }).geminiApiKey,
  );

  if (!geminiApiKey || geminiApiKey.length < 20) {
    next(new AppError("A valid geminiApiKey is required", 400));
    return;
  }

  next();
};

export const validateChatBody = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  const body = req.body as {
    message?: unknown;
    conversationId?: unknown;
    retries?: unknown;
  };

  const message = ensureString(body.message);

  if (!message || message.length < 2) {
    next(new AppError("message is required", 400));
    return;
  }

  if (message.length > 4000) {
    next(new AppError("message must be under 4000 characters", 400));
    return;
  }

  const retries = Number(body.retries ?? 0);
  if (!Number.isFinite(retries) || retries < 0 || retries > 2) {
    next(new AppError("retries must be a number between 0 and 2", 400));
    return;
  }

  if (body.conversationId && typeof body.conversationId !== "string") {
    next(new AppError("conversationId must be a string", 400));
    return;
  }

  next();
};
