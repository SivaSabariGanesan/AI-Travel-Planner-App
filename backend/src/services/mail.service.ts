import nodemailer from "nodemailer";
import { AppError } from "../utils/appError";
import { config } from "dotenv";

config();

const smtpPort = Number(process.env.SMTP_PORT || 587);

const isProduction = (process.env.NODE_ENV || "development") === "production";

const hasSmtpConfig = (): boolean => {
  return Boolean(
    process.env.SMTP_HOST &&
      process.env.SMTP_USER &&
      process.env.SMTP_PASS &&
      process.env.SMTP_FROM,
  );
};


const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: smtpPort,
  secure: smtpPort === 465,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

const getFromEmail = (): string => {
  const fromEmail = process.env.SMTP_FROM;

  if (!fromEmail) {
    throw new AppError("SMTP_FROM is not set", 500);
  }

  return fromEmail;
};

export const sendOtpEmail = async (params: {
  to: string;
  otp: string;
  purpose: "signup" | "signin";
  expiresInMinutes: number;
}): Promise<void> => {
  if (!hasSmtpConfig()) {
    if (isProduction) {
      throw new AppError(
        "SMTP config is incomplete. Set SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM.",
        500,
      );
    }

    console.log(
      `[DEV OTP FALLBACK] OTP for ${params.to} (${params.purpose}): ${params.otp} (expires in ${params.expiresInMinutes} min)`,
    );
    return;
  }

  const actionText =
    params.purpose === "signup" ? "complete your signup" : "sign in to your account";

  try {
    await transporter.sendMail({
      from: getFromEmail(),
      to: params.to,
      subject: "Your AI Travel Planner OTP Code",
      text: `Your OTP is ${params.otp}. It expires in ${params.expiresInMinutes} minutes. Use it to ${actionText}.`,
      html: `<p>Your OTP is <strong>${params.otp}</strong>.</p><p>It expires in ${params.expiresInMinutes} minutes.</p><p>Use it to ${actionText}.</p>`,
    });
  } catch (error) {
    if (isProduction) {
      throw new AppError("Failed to send OTP email", 500);
    }

    console.warn("SMTP send failed in non-production. Falling back to console OTP.", error);
    console.log(
      `[DEV OTP FALLBACK] OTP for ${params.to} (${params.purpose}): ${params.otp} (expires in ${params.expiresInMinutes} min)`,
    );
  }
};
