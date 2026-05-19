import { Request, Response, NextFunction } from "express";
import {
  collectDefaultMetrics,
  register,
  Counter,
  Histogram,
  Gauge,
} from "prom-client";

// Initialize default metrics
collectDefaultMetrics({ register });

// HTTP request metrics
export const httpRequestsTotal = new Counter({
  name: "http_requests_total",
  help: "Total number of HTTP requests",
  labelNames: ["method", "path", "status"],
  registers: [register],
});

export const httpRequestDurationSeconds = new Histogram({
  name: "http_request_duration_seconds",
  help: "Duration of HTTP request in seconds",
  labelNames: ["method", "path", "status"],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.075, 0.1, 0.25, 0.5, 1, 2.5, 5, 10],
  registers: [register],
});

// Database connection metrics
export const mongoConnectionActive = new Gauge({
  name: "mongo_connection_active",
  help: "MongoDB connection status (1 = connected, 0 = disconnected)",
  registers: [register],
});

// API endpoint metrics
export const authRequests = new Counter({
  name: "auth_requests_total",
  help: "Total authentication requests",
  labelNames: ["endpoint", "status"],
  registers: [register],
});

export const aiRequests = new Counter({
  name: "ai_requests_total",
  help: "Total AI requests",
  labelNames: ["endpoint", "status"],
  registers: [register],
});

export const aiRequestDuration = new Histogram({
  name: "ai_request_duration_seconds",
  help: "Duration of AI requests in seconds",
  labelNames: ["endpoint"],
  buckets: [1, 5, 10, 30, 60, 120, 300],
  registers: [register],
});

// Middleware to measure HTTP request metrics
export const metricsMiddleware = (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const start = Date.now();
  const originalSend = res.send;

  res.send = function (data) {
    const duration = (Date.now() - start) / 1000;
    const method = req.method;
    const path = req.path;
    const status = res.statusCode;

    // Record metrics
    httpRequestsTotal.labels(method, path, status).inc();
    httpRequestDurationSeconds.labels(method, path, status).observe(duration);

    res.send = originalSend;
    return res.send(data);
  };

  next();
};

// Export register for /metrics endpoint
export { register };
