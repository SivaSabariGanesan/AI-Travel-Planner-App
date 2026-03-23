import { Schema, model } from "mongoose";

const itineraryInputSchema = new Schema(
  {
    fromLocation: { type: String, required: true, trim: true },
    toLocation: { type: String, required: true, trim: true },
    startDate: { type: String, trim: true },
    endDate: { type: String, trim: true },
    interests: [{ type: String }],
    budget: { type: String, trim: true },
    travelerCount: { type: Number, min: 1 },
    extraNotes: { type: String, trim: true },
  },
  { _id: false },
);

const recipeSchema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    topic: { type: String, required: true, trim: true },
    days: { type: Number, min: 1, max: 30 },
    itineraryInput: { type: itineraryInputSchema },
    generatedContent: { type: Schema.Types.Mixed, required: true },
    rawText: { type: String, required: true },
  },
  { timestamps: true },
);

export const Recipe = model("Recipe", recipeSchema);
