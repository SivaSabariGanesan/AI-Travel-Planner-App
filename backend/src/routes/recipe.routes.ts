import { Router } from "express";
import { generateRecipe } from "../controllers/recipe.controller";
import { requireAuth } from "../middleware/auth";

const router = Router();

router.post("/generate", requireAuth, generateRecipe);

export { router as recipeRouter };
