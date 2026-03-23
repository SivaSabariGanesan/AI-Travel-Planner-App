import { Schema, model } from "mongoose";

export type OtpPurpose = "signup" | "signin";

const otpSchema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    purpose: {
      type: String,
      required: true,
      enum: ["signup", "signin"],
      index: true,
    },
    otpHash: { type: String, required: true },
    expiresAt: { type: Date, required: true, index: true },
    consumedAt: { type: Date, default: null },
  },
  { timestamps: true },
);

export const Otp = model("Otp", otpSchema);
