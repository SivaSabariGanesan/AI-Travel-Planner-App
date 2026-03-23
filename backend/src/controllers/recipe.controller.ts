import type { Request, Response } from "express";
import { Recipe } from "../models/Recipe";
import { User } from "../models/User";
import { generateTravelRecipe } from "../services/gemini.service";
import { AppError } from "../utils/appError";
import { asyncHandler } from "../utils/asyncHandler";

export const generateRecipe = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.userId;

  if (!userId) {
    throw new AppError("Unauthorized", 401);
  }

  const { topic, days, extraNotes } = req.body as {
    topic?: string;
    days?: number;
    extraNotes?: string;
  };

  if (!topic) {
    throw new AppError("Topic is required", 400);
  }

  const user = await User.findById(userId).select("preferences");

  if (!user) {
    throw new AppError("User not found", 404);
  }

  const generated = await generateTravelRecipe({
    topic,
    days,
    extraNotes,
    preferences: user.preferences,
  });

  const savedRecipe = await Recipe.create({
    userId,
    topic,
    days,
    generatedContent: generated.generatedContent,
    rawText: generated.rawText,
  });

  res.status(201).json({
    message: "Recipe generated and saved successfully",
    recipe: savedRecipe,
  });
});
