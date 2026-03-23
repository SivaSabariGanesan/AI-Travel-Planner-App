import type { Request, Response } from "express";
import { Otp } from "../models/Otp";
import { User } from "../models/User";
import { issueOtp, verifyOtp } from "../services/otp.service";
import { createAccessToken } from "../services/token.service";
import { AppError } from "../utils/appError";
import { asyncHandler } from "../utils/asyncHandler";

const normalizeEmail = (email: string): string => email.trim().toLowerCase();

export const signupWithOtp = asyncHandler(async (req: Request, res: Response) => {
  const { name, email } = req.body as { name?: string; email?: string };

  if (!name || !email) {
    throw new AppError("Name and email are required", 400);
  }

  const normalizedEmail = normalizeEmail(email);
  let user = await User.findOne({ email: normalizedEmail });

  if (user?.isVerified) {
    throw new AppError("User already exists. Use signin.", 409);
  }

  if (!user) {
    user = await User.create({
      name: name.trim(),
      email: normalizedEmail,
      isVerified: false,
    });
  }

  await issueOtp(user.id, "signup", user.email);

  res.status(200).json({
    message: "OTP sent for signup verification",
    email: user.email,
  });
});

export const signinWithOtp = asyncHandler(async (req: Request, res: Response) => {
  const { email } = req.body as { email?: string };

  if (!email) {
    throw new AppError("Email is required", 400);
  }

  const normalizedEmail = normalizeEmail(email);
  const user = await User.findOne({ email: normalizedEmail });

  if (!user) {
    throw new AppError("User not found. Complete signup first.", 404);
  }

  if (!user.isVerified) {
    throw new AppError("User is not verified. Complete signup OTP verification.", 403);
  }

  await issueOtp(user.id, "signin", user.email);

  res.status(200).json({
    message: "OTP sent for signin verification",
    email: user.email,
  });
});

export const verifyAuthOtp = asyncHandler(async (req: Request, res: Response) => {
  const { email, otp, purpose } = req.body as {
    email?: string;
    otp?: string;
    purpose?: "signup" | "signin";
  };

  if (!email || !otp || !purpose) {
    throw new AppError("Email, OTP and purpose are required", 400);
  }

  if (!["signup", "signin"].includes(purpose)) {
    throw new AppError("Purpose must be either signup or signin", 400);
  }

  const normalizedEmail = normalizeEmail(email);
  const user = await User.findOne({ email: normalizedEmail });

  if (!user) {
    throw new AppError("User not found", 404);
  }

  const isOtpValid = await verifyOtp(user.id, purpose, otp);

  if (!isOtpValid) {
    throw new AppError("Invalid or expired OTP", 401);
  }

  if (purpose === "signup") {
    user.isVerified = true;
  }

  user.lastLoginAt = new Date();
  await user.save();

  await Otp.updateMany(
    { userId: user.id, purpose, consumedAt: null },
    { $set: { consumedAt: new Date() } },
  );

  const token = createAccessToken({
    userId: user.id,
    email: user.email,
  });

  res.status(200).json({
    message: "OTP verified successfully",
    token,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      isVerified: user.isVerified,
      preferences: user.preferences,
    },
  });
});
