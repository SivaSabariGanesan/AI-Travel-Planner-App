import { Schema, model } from "mongoose";

const aiMessageSchema = new Schema(
  {
    role: {
      type: String,
      enum: ["user", "assistant", "system"],
      required: true,
    },
    content: { type: String, required: true, trim: true },
    createdAt: { type: Date, default: Date.now },
  },
  { _id: false },
);

const aiConversationSchema = new Schema(
  {
    userId: {
      type: Schema.Types.ObjectId,
      ref: "User",
      required: true,
      index: true,
    },
    title: { type: String, trim: true },
    messages: { type: [aiMessageSchema], default: [] },
  },
  { timestamps: true },
);

export const AiConversation = model("AiConversation", aiConversationSchema);
