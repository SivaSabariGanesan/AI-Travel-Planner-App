import swaggerJsdoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-express";
import type { Express } from "express";

const port = Number(process.env.PORT) || 5000;

const swaggerSpec = swaggerJsdoc({
  definition: {
    openapi: "3.0.3",
    info: {
      title: "AI Travel Planner API",
      version: "1.0.0",
      description:
        "Backend APIs for OTP auth, user preferences, dashboard, and AI itinerary generation.",
    },
    servers: [
      {
        url: `http://localhost:${port}`,
        description: "Local server",
      },
    ],
    tags: [
      { name: "Health" },
      { name: "Auth" },
      { name: "Users" },
      { name: "Dashboard" },
      { name: "Itinerary" },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: "http",
          scheme: "bearer",
          bearerFormat: "JWT",
        },
      },
      schemas: {
        ErrorResponse: {
          type: "object",
          properties: {
            message: { type: "string", example: "Unauthorized" },
          },
        },
      },
    },
    paths: {
      "/api/health": {
        get: {
          tags: ["Health"],
          summary: "Health check",
          responses: {
            "200": {
              description: "Server health",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      status: { type: "string", example: "ok" },
                      message: {
                        type: "string",
                        example: "Backend is running",
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
      "/api/auth/signup": {
        post: {
          tags: ["Auth"],
          summary: "Start signup with OTP",
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  required: ["name", "email"],
                  properties: {
                    name: { type: "string", example: "Rahul" },
                    email: {
                      type: "string",
                      format: "email",
                      example: "rahul@example.com",
                    },
                  },
                },
              },
            },
          },
          responses: {
            "200": {
              description: "OTP sent",
            },
            "400": { description: "Validation error" },
            "409": { description: "User already exists" },
          },
        },
      },
      "/api/auth/signin": {
        post: {
          tags: ["Auth"],
          summary: "Start signin with OTP",
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  required: ["email"],
                  properties: {
                    email: {
                      type: "string",
                      format: "email",
                      example: "rahul@example.com",
                    },
                  },
                },
              },
            },
          },
          responses: {
            "200": { description: "OTP sent" },
            "403": { description: "Not verified" },
            "404": { description: "User not found" },
          },
        },
      },
      "/api/auth/verify-otp": {
        post: {
          tags: ["Auth"],
          summary: "Verify OTP and receive access token",
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  required: ["email", "otp", "purpose"],
                  properties: {
                    email: {
                      type: "string",
                      format: "email",
                      example: "rahul@example.com",
                    },
                    otp: { type: "string", example: "123456" },
                    purpose: {
                      type: "string",
                      enum: ["signup", "signin"],
                      example: "signup",
                    },
                  },
                },
              },
            },
          },
          responses: {
            "200": { description: "OTP verified and token returned" },
            "401": { description: "Invalid OTP" },
          },
        },
      },
      "/api/users/me": {
        get: {
          tags: ["Users"],
          summary: "Get current user",
          security: [{ bearerAuth: [] }],
          responses: {
            "200": { description: "Current user" },
            "401": { description: "Unauthorized" },
          },
        },
      },
      "/api/users/preferences": {
        put: {
          tags: ["Users"],
          summary: "Update user preferences",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  properties: {
                    travelStyle: { type: "string", example: "adventure" },
                    budget: { type: "string", example: "medium" },
                    foodChoices: {
                      type: "array",
                      items: { type: "string" },
                      example: ["street food", "local cuisine"],
                    },
                    dietaryRestrictions: {
                      type: "array",
                      items: { type: "string" },
                    },
                    preferredDestinations: {
                      type: "array",
                      items: { type: "string" },
                    },
                    tripPace: { type: "string", example: "relaxed" },
                  },
                },
              },
            },
          },
          responses: {
            "200": { description: "Preferences updated" },
            "401": { description: "Unauthorized" },
          },
        },
      },
      "/api/dashboard": {
        get: {
          tags: ["Dashboard"],
          summary: "Get dashboard data",
          security: [{ bearerAuth: [] }],
          responses: {
            "200": { description: "Dashboard payload" },
            "401": { description: "Unauthorized" },
          },
        },
      },
      "/api/recipes/generate": {
        post: {
          tags: ["Itinerary"],
          summary: "Generate AI itinerary and save it",
          security: [{ bearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  required: ["fromLocation", "toLocation"],
                  properties: {
                    topic: {
                      type: "string",
                      example: "Goa summer trip",
                    },
                    fromLocation: { type: "string", example: "Mumbai" },
                    toLocation: { type: "string", example: "Goa" },
                    days: { type: "number", example: 4 },
                    startDate: { type: "string", example: "2026-05-20" },
                    endDate: { type: "string", example: "2026-05-24" },
                    interests: {
                      type: "array",
                      items: { type: "string" },
                      example: ["beaches", "food", "nightlife"],
                    },
                    budget: { type: "string", example: "medium" },
                    travelerCount: { type: "number", example: 2 },
                    extraNotes: {
                      type: "string",
                      example: "Prefer less crowded locations",
                    },
                  },
                },
              },
            },
          },
          responses: {
            "201": { description: "Itinerary generated and saved" },
            "400": {
              description:
                "Invalid request. Provide days or both startDate and endDate.",
            },
            "401": { description: "Unauthorized" },
          },
        },
      },
    },
  },
  apis: [],
});

export const setupSwagger = (app: Express): void => {
  app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));
  app.get("/api-docs.json", (_req, res) => {
    res.status(200).json(swaggerSpec);
  });
};
