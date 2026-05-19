import { Schema, model, type InferSchemaType } from "mongoose";

const preferenceSchema = new Schema(
  {
    travelStyle: { type: String },
    budget: { type: String },
    foodChoices: [{ type: String }],
    dietaryRestrictions: [{ type: String }],
    preferredDestinations: [{ type: String }],
    tripPace: { type: String },
  },
  { _id: false },
);

const userSchema = new Schema(
  {
    name: { type: String, required: true, trim: true },
    email: {
      type: String,
      required: true,
      trim: true,
      lowercase: true,
      unique: true,
      index: true,
    },
    isVerified: { type: Boolean, default: false },
    preferences: { type: preferenceSchema, default: {} },
    aiMode: {
      type: String,
      enum: ["app", "byok"],
      default: "app",
    },
    encryptedGeminiKey: { type: String },
    usageCount: { type: Number, default: 0 },
    lastUsedAt: { type: Date },
    lastLoginAt: { type: Date },
  },
  { timestamps: true },
);

export type UserDocument = InferSchemaType<typeof userSchema> & { _id: string };

export const User = model("User", userSchema);
