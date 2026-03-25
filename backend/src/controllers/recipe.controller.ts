import type { Request, Response } from "express";
import { Recipe } from "../models/Recipe";
import { User } from "../models/User";
import { generateTravelRecipe } from "../services/gemini.service";
import { AppError } from "../utils/appError";
import { asyncHandler } from "../utils/asyncHandler";

export const getRecipes = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.userId;

  if (!userId) {
    throw new AppError("Unauthorized", 401);
  }

  const recipes = await Recipe.find({ userId }).sort({ createdAt: -1 });

  res.status(200).json({ recipes });
});

export const generateRecipe = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.userId;

  if (!userId) {
    throw new AppError("Unauthorized", 401);
  }

  const {
    topic,
    fromLocation,
    toLocation,
    days,
    startDate,
    endDate,
    interests,
    budget,
    travelerCount,
    extraNotes,
  } = req.body as {
    topic?: string;
    fromLocation?: string;
    toLocation?: string;
    days?: number;
    startDate?: string;
    endDate?: string;
    interests?: string[];
    budget?: string;
    travelerCount?: number;
    extraNotes?: string;
  };

  if (!fromLocation || !toLocation) {
    throw new AppError("fromLocation and toLocation are required", 400);
  }

  if (!days && (!startDate || !endDate)) {
    throw new AppError("Provide either days or both startDate and endDate", 400);
  }

  const normalizedTopic =
    topic || `${fromLocation} to ${toLocation} itinerary`;

  const user = await User.findById(userId).select("preferences");

  if (!user) {
    throw new AppError("User not found", 404);
  }

  const generated = await generateTravelRecipe({
    topic: normalizedTopic,
    fromLocation,
    toLocation,
    days,
    startDate,
    endDate,
    interests,
    budget,
    travelerCount,
    extraNotes,
    preferences: user.preferences,
  });

  const savedRecipe = await Recipe.create({
    userId,
    topic: normalizedTopic,
    days,
    itineraryInput: {
      fromLocation,
      toLocation,
      startDate,
      endDate,
      interests: interests || [],
      budget,
      travelerCount,
      extraNotes,
    },
    generatedContent: generated.generatedContent,
    rawText: generated.rawText,
  });

  res.status(201).json({
    message: "Itinerary generated and saved successfully",
    recipe: savedRecipe,
  });
});

export const deleteRecipe = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.userId;
  const { recipeId } = req.params;

  if (!userId) {
    throw new AppError("Unauthorized", 401);
  }

  if (!recipeId) {
    throw new AppError("Recipe id is required", 400);
  }

  const deleted = await Recipe.findOneAndDelete({ _id: recipeId, userId });

  if (!deleted) {
    throw new AppError("Itinerary not found", 404);
  }

  res.status(200).json({ message: "Itinerary deleted successfully" });
});
