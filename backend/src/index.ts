import cors from "cors";
import dotenv from "dotenv";
import path from "path";
import express from "express";
import { connectDB } from "./config/db";
import { setupSwagger } from "./config/swagger";
import { errorHandler, notFoundHandler } from "./middleware/errorHandler";
import { metricsMiddleware, register } from "./middleware/metrics";
import { apiRouter } from "./routes/index";

// Load environment variables from .env file in backend root directory
const envPath = path.resolve(__dirname, "../.env");
console.log(`[ENV] Loading .env from: ${envPath}`);
dotenv.config({ path: envPath });

// Verify critical environment variables are set
const requiredEnvVars = ["JWT_SECRET", "OTP_SECRET", "MONGODB_URI"];
const missingVars = requiredEnvVars.filter((v) => !process.env[v]);
if (missingVars.length > 0) {
  console.error(`[ENV ERROR] Missing required environment variables: ${missingVars.join(", ")}`);
  console.error(`[ENV] JWT_SECRET: ${process.env.JWT_SECRET ? "SET" : "NOT SET"}`);
  console.error(`[ENV] OTP_SECRET: ${process.env.OTP_SECRET ? "SET" : "NOT SET"}`);
  console.error(`[ENV] MONGODB_URI: ${process.env.MONGODB_URI ? "SET" : "NOT SET"}`);
}

const app = express();
const port = Number(process.env.PORT) || 5000;

app.use(cors());
app.use(express.json());
app.use(metricsMiddleware);
setupSwagger(app);

// Provide a simple root route and handle favicon to reduce noisy 404 logs
app.get("/", (_req, res) => {
  res.redirect("/api/health");
});

app.get('/favicon.ico', (_req, res) => res.sendStatus(204));

app.get("/api/health", (_req, res) => {
  res.status(200).json({ status: "ok", message: "Backend is running" });
});

// Prometheus metrics endpoint
app.get("/metrics", async (_req, res) => {
  res.set("Content-Type", register.contentType);
  res.end(await register.metrics());
});

app.use("/api", apiRouter);
app.use(notFoundHandler);
app.use(errorHandler);

const startServer = async (): Promise<void> => {
  try {
    await connectDB();

    app.listen(port, "0.0.0.0", () => {
      console.log(`Server listening on http://0.0.0.0:${port}`);
    });
  } catch (error) {
    console.error("Failed to start server", error);
    process.exit(1);
  }
};

void startServer();