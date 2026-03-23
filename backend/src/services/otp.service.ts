import crypto from "crypto";
import { Otp, type OtpPurpose } from "../models/Otp";
import { sendOtpEmail } from "./mail.service";

const OTP_EXPIRY_MINUTES = Number(process.env.OTP_EXPIRY_MINUTES) || 10;
const OTP_SECRET = process.env.OTP_SECRET || "dev-otp-secret";

const hashOtp = (otp: string): string => {
  return crypto.createHash("sha256").update(`${otp}.${OTP_SECRET}`).digest("hex");
};

const generateOtp = (): string => {
  return crypto.randomInt(100000, 999999).toString();
};

export const issueOtp = async (
  userId: string,
  purpose: OtpPurpose,
  email: string,
): Promise<void> => {
  const otp = generateOtp();
  const expiresAt = new Date(Date.now() + OTP_EXPIRY_MINUTES * 60 * 1000);

  await Otp.updateMany(
    { userId, purpose, consumedAt: null },
    { $set: { consumedAt: new Date() } },
  );

  await Otp.create({
    userId,
    purpose,
    otpHash: hashOtp(otp),
    expiresAt,
  });

  await sendOtpEmail({
    to: email,
    otp,
    purpose,
    expiresInMinutes: OTP_EXPIRY_MINUTES,
  });
};

export const verifyOtp = async (
  userId: string,
  purpose: OtpPurpose,
  otpCode: string,
): Promise<boolean> => {
  const latestOtp = await Otp.findOne({
    userId,
    purpose,
    consumedAt: null,
  }).sort({ createdAt: -1 });

  if (!latestOtp) {
    return false;
  }

  if (latestOtp.expiresAt.getTime() < Date.now()) {
    return false;
  }

  const incomingHash = hashOtp(otpCode);
  const isValid = crypto.timingSafeEqual(
    Buffer.from(latestOtp.otpHash),
    Buffer.from(incomingHash),
  );

  if (!isValid) {
    return false;
  }

  latestOtp.consumedAt = new Date();
  await latestOtp.save();

  return true;
};
