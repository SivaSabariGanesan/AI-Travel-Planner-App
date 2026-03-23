import type { Request, Response } from "express";
import { User } from "../models/User";
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
