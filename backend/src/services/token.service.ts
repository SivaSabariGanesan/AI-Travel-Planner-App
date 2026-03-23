import jwt from "jsonwebtoken";
import type { SignOptions } from "jsonwebtoken";
import { AppError } from "../utils/appError";

const getJwtSecret = (): string => {
  const secret = process.env.JWT_SECRET;

  if (!secret) {
    throw new AppError("JWT_SECRET is not set", 500);
  }

  return secret;
};

export const createAccessToken = (payload: {
  userId: string;
  email: string;
}): string => {
  const jwtSecret = getJwtSecret();
  const expiresIn =
    (process.env.JWT_EXPIRES_IN as SignOptions["expiresIn"]) || "7d";

  return jwt.sign(payload, jwtSecret, {
    expiresIn,
  });
};
