import type { Request, Response } from "express";
import { User } from "../models/User";
import { geminiService } from "../services/gemini.service";
import { encryptText } from "../utils/encryption";
import { AppError } from "../utils/appError";
import { asyncHandler } from "../utils/asyncHandler";

export const getCurrentUser = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.userId;

  if (!userId) {
    throw new AppError("Unauthorized", 401);
  }

  const user = await User.findById(userId).select("-__v");

  if (!user) {
    throw new AppError("User not found", 404);
  }

  res.status(200).json({ user });
});

export const getAiSettings = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.userId;

  if (!userId) {
    throw new AppError("Unauthorized", 401);
  }

  const user = await User.findById(userId).select("aiMode usageCount lastUsedAt");

  if (!user) {
    throw new AppError("User not found", 404);
  }

  res.status(200).json({
    success: true,
    aiSettings: {
      aiMode: user.aiMode || "app",
      usageCount: user.usageCount || 0,
      lastUsedAt: user.lastUsedAt || null,
      hasPersonalKey: Boolean((user as any).encryptedGeminiKey),
    },
  });
});

export const updateAiSettings = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.userId;

  if (!userId) {
    throw new AppError("Unauthorized", 401);
  }

  const { aiMode, geminiApiKey } = req.body as {
    aiMode: "app" | "byok";
    geminiApiKey?: string;
  };

  const user = await User.findById(userId).select("aiMode encryptedGeminiKey");

  if (!user) {
    throw new AppError("User not found", 404);
  }

  if (aiMode === "byok") {
    if (geminiApiKey) {
      const isValid = await geminiService.validateApiKey(geminiApiKey);
      if (!isValid) {
        throw new AppError("Invalid Gemini API key", 400);
      }
      user.encryptedGeminiKey = encryptText(geminiApiKey);
    } else if (!user.encryptedGeminiKey) {
      throw new AppError(
        "Provide geminiApiKey when enabling BYOK for the first time",
        400,
      );
    }
  }

  if (aiMode === "app") {
    geminiService.getCompanyApiKey();
  }

  user.aiMode = aiMode;
  await user.save();

  res.status(200).json({
    success: true,
    message: "AI settings updated successfully",
    aiSettings: {
      aiMode: user.aiMode,
      hasPersonalKey: Boolean(user.encryptedGeminiKey),
    },
  });
});

export const testGeminiKey = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.userId;

  if (!userId) {
    throw new AppError("Unauthorized", 401);
  }

  const { geminiApiKey } = req.body as { geminiApiKey: string };
  const isValid = await geminiService.validateApiKey(geminiApiKey);

  if (!isValid) {
    throw new AppError("Gemini API key validation failed", 400);
  }

  res.status(200).json({
    success: true,
    message: "Gemini API key is valid",
  });
});

export const updatePreferences = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user?.userId;

    if (!userId) {
      throw new AppError("Unauthorized", 401);
    }

    const {
      travelStyle,
      budget,
      foodChoices,
      dietaryRestrictions,
      preferredDestinations,
      tripPace,
    } = req.body as {
      travelStyle?: string;
      budget?: string;
      foodChoices?: string[];
      dietaryRestrictions?: string[];
      preferredDestinations?: string[];
      tripPace?: string;
    };

    const user = await User.findByIdAndUpdate(
      userId,
      {
        $set: {
          "preferences.travelStyle": travelStyle,
          "preferences.budget": budget,
          "preferences.foodChoices": foodChoices,
          "preferences.dietaryRestrictions": dietaryRestrictions,
          "preferences.preferredDestinations": preferredDestinations,
          "preferences.tripPace": tripPace,
        },
      },
      { new: true, runValidators: true },
    ).select("name email preferences");

    if (!user) {
      throw new AppError("User not found", 404);
    }

    res.status(200).json({
      message: "Preferences updated successfully",
      preferences: user.preferences,
    });
  },
);
