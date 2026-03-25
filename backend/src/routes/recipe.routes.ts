import { Router } from "express";
import {
	deleteRecipe,
	generateRecipe,
	getRecipes,
} from "../controllers/recipe.controller";
import { requireAuth } from "../middleware/auth";

const router = Router();

router.get("/", requireAuth, getRecipes);
router.post("/generate", requireAuth, generateRecipe);
router.delete("/:recipeId", requireAuth, deleteRecipe);

export { router as recipeRouter };
