import { Router } from "express";
import { aiRouter } from "./ai.routes";
import { authRouter } from "./auth.routes";
import { dashboardRouter } from "./dashboard.routes";
import { recipeRouter } from "./recipe.routes";
import { userRouter } from "./user.routes";

const router = Router();

router.use("/auth", authRouter);
router.use("/users", userRouter);
router.use("/dashboard", dashboardRouter);
router.use("/recipes", recipeRouter);
router.use("/ai", aiRouter);

export { router as apiRouter };
