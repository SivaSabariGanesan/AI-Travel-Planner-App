import mongoose from "mongoose";

export const connectDB = async (): Promise<void> => {
  const mongoURI = process.env.MONGODB_URI;

  if (!mongoURI) {
    throw new Error("MONGODB_URI is not set in environment variables");
  }

  await mongoose.connect(mongoURI);
  console.log("MongoDB connected");
};
