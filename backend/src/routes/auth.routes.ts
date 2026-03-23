import { Router } from "express";
import {
  signinWithOtp,
  signupWithOtp,
  verifyAuthOtp,
} from "../controllers/auth.controller";

const router = Router();

router.post("/signup", signupWithOtp);
router.post("/signin", signinWithOtp);
router.post("/verify-otp", verifyAuthOtp);

export { router as authRouter };
