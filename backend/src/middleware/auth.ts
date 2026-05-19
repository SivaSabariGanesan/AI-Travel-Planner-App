import type { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import { AppError } from "../utils/appError";

const isLocalAuthBypassEnabled = (): boolean => {
  const env = process.env.NODE_ENV || "development";
  const bypass = (process.env.DISABLE_AUTH_FOR_LOCAL || "false").toLowerCase();
  return env !== "production" && bypass === "true";
};

export const requireAuth = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  // Read JWT_SECRET at runtime (after dotenv.config() is called)
  const JWT_SECRET = process.env.JWT_SECRET;
  
  if (!JWT_SECRET) {
    next(new AppError("JWT_SECRET is not set", 500));
    return;
  }

  const authHeader = req.headers.authorization;
  const token = authHeader?.startsWith("Bearer ")
    ? authHeader.slice(7)
    : undefined;

  // In local bypass mode, allow requests without a token.
  // If a token is provided, always prefer validating the real token.
  if (!token && isLocalAuthBypassEnabled()) {
    req.user = {
      userId: String(process.env.LOCAL_TEST_USER_ID || "000000000000000000000000"),
      email: process.env.LOCAL_TEST_USER_EMAIL || "local@test.com",
    };
    next();
    return;
  }

  if (!token) {
    next(new AppError("Authorization token is required", 401));
    return;
  }

  try {
    const payload = jwt.verify(token, JWT_SECRET) as Express.UserPayload;
    req.user = payload;
    next();
  } catch {
    next(new AppError("Invalid or expired token", 401));
  }
};
