import type { Request, Response } from "express";
import { Recipe } from "../models/Recipe";
import { User } from "../models/User";
import { AppError } from "../utils/appError";
import { asyncHandler } from "../utils/asyncHandler";

export const getDashboard = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.userId;

  if (!userId) {
    throw new AppError("Unauthorized", 401);
  }

  const [user, recentRecipes] = await Promise.all([
    User.findById(userId).select("name email preferences lastLoginAt createdAt"),
    Recipe.find({ userId })
      .sort({ createdAt: -1 })
      .limit(5)
      .select("topic days generatedContent.title createdAt"),
  ]);

  if (!user) {
    throw new AppError("User not found", 404);
  }

  res.status(200).json({
    dashboard: {
      user,
      recentRecipes,
    },
  });
});
