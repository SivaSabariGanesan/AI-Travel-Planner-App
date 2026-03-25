import type { NextFunction, Request, Response } from "express";
import { AppError } from "../utils/appError";

export const notFoundHandler = (
  req: Request,
  _res: Response,
  next: NextFunction,
): void => {
  next(new AppError(`Route not found: ${req.method} ${req.originalUrl}`, 404));
};

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response,
  _next: NextFunction,
): void => {
  const statusCode = err instanceof AppError ? err.statusCode : 500;

  console.error(
    `[API ERROR] ${req.method} ${req.originalUrl} status=${statusCode} message=${err.message}`,
    err,
  );

  res.status(statusCode).json({
    message: err.message || "Internal server error",
  });
};
