import nodemailer from "nodemailer";
import { AppError } from "../utils/appError";
import { config } from "dotenv";

config();

const smtpPort = Number(process.env.SMTP_PORT || 587);
const smtpHost = process.env.SMTP_HOST;
const smtpConnectionTimeoutMs = Number(process.env.SMTP_CONNECTION_TIMEOUT_MS || 15000);
const smtpGreetingTimeoutMs = Number(process.env.SMTP_GREETING_TIMEOUT_MS || 10000);
const smtpSocketTimeoutMs = Number(process.env.SMTP_SOCKET_TIMEOUT_MS || 20000);
const otpEmailRetryCount = Number(process.env.OTP_EMAIL_RETRY_COUNT || 2);

const isProduction = (process.env.NODE_ENV || "development") === "production";

const hasSmtpConfig = (): boolean => {
  return Boolean(
    process.env.SMTP_HOST &&
      process.env.SMTP_USER &&
      process.env.SMTP_PASS &&
      process.env.SMTP_FROM,
  );
};

const maskEmail = (email: string): string => {
  const [localPart, domainPart] = email.split("@");

  if (!localPart || !domainPart) {
    return "invalid-email";
  }

  if (localPart.length <= 2) {
    return `${localPart[0] ?? "*"}*@${domainPart}`;
  }

  return `${localPart.slice(0, 2)}***@${domainPart}`;
};

const formatMailError = (error: unknown): string => {
  if (!(error instanceof Error)) {
    return String(error);
  }

  const nodemailerError = error as Error & {
    code?: string;
    responseCode?: number;
    response?: string;
    command?: string;
  };

  const parts = [
    `message=${nodemailerError.message}`,
    nodemailerError.code ? `code=${nodemailerError.code}` : null,
    nodemailerError.responseCode ? `responseCode=${nodemailerError.responseCode}` : null,
    nodemailerError.command ? `command=${nodemailerError.command}` : null,
  ].filter(Boolean);

  if (nodemailerError.response) {
    parts.push(`response=${nodemailerError.response}`);
  }

  return parts.join(" | ");
};


const transporter = nodemailer.createTransport({
  host: smtpHost,
  port: smtpPort,
  secure: smtpPort === 465,
  connectionTimeout: smtpConnectionTimeoutMs,
  greetingTimeout: smtpGreetingTimeoutMs,
  socketTimeout: smtpSocketTimeoutMs,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

const sleep = (ms: number): Promise<void> =>
  new Promise((resolve) => {
    setTimeout(resolve, ms);
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
  const maskedEmail = maskEmail(params.to);

  if (!hasSmtpConfig()) {
    if (isProduction) {
      console.error(
        `[OTP EMAIL FAILED] Missing SMTP config for ${maskedEmail} (${params.purpose})`,
      );
      throw new AppError(
        "SMTP config is incomplete. Set SMTP_HOST, SMTP_PORT, SMTP_USER, SMTP_PASS, SMTP_FROM.",
        500,
      );
    }

    console.warn(
      `[OTP EMAIL FALLBACK] SMTP config missing, using console OTP for ${maskedEmail} (${params.purpose})`,
    );
    console.log(
      `[DEV OTP FALLBACK] OTP for ${params.to} (${params.purpose}): ${params.otp} (expires in ${params.expiresInMinutes} min)`,
    );
    return;
  }

  const actionText =
    params.purpose === "signup" ? "complete your signup" : "sign in to your account";

  const maxAttempts = Math.max(1, otpEmailRetryCount + 1);

  for (let attempt = 1; attempt <= maxAttempts; attempt += 1) {
    try {
      await transporter.sendMail({
        from: getFromEmail(),
        to: params.to,
        subject: "Your AI Travel Planner OTP Code",
        text: `Your OTP is ${params.otp}. It expires in ${params.expiresInMinutes} minutes. Use it to ${actionText}.`,
        html: `<p>Your OTP is <strong>${params.otp}</strong>.</p><p>It expires in ${params.expiresInMinutes} minutes.</p><p>Use it to ${actionText}.</p>`,
      });

      console.info(
        `[OTP EMAIL SENT] to=${maskedEmail} purpose=${params.purpose} attempt=${attempt}/${maxAttempts}`,
      );
      return;
    } catch (error) {
      const failureReason = formatMailError(error);
      const isLastAttempt = attempt >= maxAttempts;

      console.error(
        `[OTP EMAIL ATTEMPT FAILED] to=${maskedEmail} purpose=${params.purpose} attempt=${attempt}/${maxAttempts} host=${smtpHost || "undefined"} port=${smtpPort} timeouts(connection=${smtpConnectionTimeoutMs},greeting=${smtpGreetingTimeoutMs},socket=${smtpSocketTimeoutMs}) reason=${failureReason}`,
      );

      if (!isLastAttempt) {
        await sleep(500 * attempt);
        continue;
      }

      console.error(
        `[OTP EMAIL FAILED] to=${maskedEmail} purpose=${params.purpose} reason=${failureReason}`,
      );

      if (isProduction) {
        throw new AppError("Failed to send OTP email", 500);
      }

      console.warn("SMTP send failed in non-production. Falling back to console OTP.", error);
      console.log(
        `[DEV OTP FALLBACK] OTP for ${params.to} (${params.purpose}): ${params.otp} (expires in ${params.expiresInMinutes} min)`,
      );
      return;
    }
  }
};
