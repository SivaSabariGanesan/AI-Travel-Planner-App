import { Schema, model } from "mongoose";

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
    generatedContent: { type: Schema.Types.Mixed, required: true },
    rawText: { type: String, required: true },
  },
  { timestamps: true },
);

export const Recipe = model("Recipe", recipeSchema);
