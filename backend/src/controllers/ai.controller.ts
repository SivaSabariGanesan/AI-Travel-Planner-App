import type { Request, Response } from "express";
import { Types } from "mongoose";
import { AiConversation } from "../models/AiConversation";
import { User } from "../models/User";
import { geminiService, type ChatMessage } from "../services/gemini.service";
import { decryptText } from "../utils/encryption";
import { AppError } from "../utils/appError";
import { asyncHandler } from "../utils/asyncHandler";

const resolveUserApiKey = (user: {
  aiMode?: string;
  encryptedGeminiKey?: string;
}): string => {
  if (user.aiMode === "byok") {
    if (!user.encryptedGeminiKey) {
      throw new AppError("No personal Gemini API key configured", 400);
    }
    return decryptText(user.encryptedGeminiKey);
  }

  return geminiService.getCompanyApiKey();
};

const toChatHistory = (
  messages: Array<{ role: string; content: string }>,
): ChatMessage[] => {
  return messages
    .filter((message) =>
      ["user", "assistant", "system"].includes(message.role),
    )
    .map((message) => ({
      role: message.role as "user" | "assistant" | "system",
      content: message.content,
    }));
};

const updateUsage = async (userId: string): Promise<void> => {
  await User.findByIdAndUpdate(userId, {
    $inc: { usageCount: 1 },
    $set: { lastUsedAt: new Date() },
  });
};

export const chatWithAi = asyncHandler(async (req: Request, res: Response) => {
  const userId = req.user?.userId;
  if (!userId) {
    throw new AppError("Unauthorized", 401);
  }

  const {
    message,
    conversationId,
    retries = 1,
  } = req.body as {
    message: string;
    conversationId?: string;
    retries?: number;
  };

  const user = await User.findById(userId).select(
    "aiMode encryptedGeminiKey usageCount",
  );
  if (!user) {
    throw new AppError("User not found", 404);
  }

  let conversation = conversationId
    ? await AiConversation.findOne({ _id: conversationId, userId })
    : null;

  if (conversationId && !conversation) {
    throw new AppError("Conversation not found", 404);
  }

  const apiKey = resolveUserApiKey(user);
  const history = toChatHistory(
    (conversation?.messages as Array<{ role: string; content: string }>) || [],
  );

  let lastError: unknown;
  let responseText = "";
  let estimatedTokens = 0;

  for (let attempt = 0; attempt <= retries; attempt += 1) {
    try {
      const generated = await geminiService.generateChatReply({
        apiKey,
        message,
        history,
      });
      responseText = generated.answer;
      estimatedTokens = generated.estimatedTokens;
      lastError = null;
      break;
    } catch (error) {
      lastError = error;
    }
  }

  if (lastError) {
    throw new AppError("Failed to generate AI response. Please try again.", 502);
  }

  if (!conversation) {
    conversation = await AiConversation.create({
      userId: new Types.ObjectId(userId),
      title: message.slice(0, 80),
      messages: [],
    });
  }

  conversation.messages.push(
    { role: "user", content: message, createdAt: new Date() },
    { role: "assistant", content: responseText, createdAt: new Date() },
  );
  await conversation.save();
  await updateUsage(userId);

  res.status(200).json({
    success: true,
    data: {
      conversationId: conversation.id,
      message: {
        role: "assistant",
        content: responseText,
      },
      usage: {
        requestsUsed: (user.usageCount || 0) + 1,
        estimatedTokens,
      },
    },
  });
});

export const streamChatWithAi = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      throw new AppError("Unauthorized", 401);
    }

    const { message, conversationId } = req.body as {
      message: string;
      conversationId?: string;
    };

    const user = await User.findById(userId).select(
      "aiMode encryptedGeminiKey usageCount",
    );
    if (!user) {
      throw new AppError("User not found", 404);
    }

    let conversation = conversationId
      ? await AiConversation.findOne({ _id: conversationId, userId })
      : null;

    if (conversationId && !conversation) {
      throw new AppError("Conversation not found", 404);
    }

    const history = toChatHistory(
      (conversation?.messages as Array<{ role: string; content: string }>) || [],
    );
    const apiKey = resolveUserApiKey(user);

    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.setHeader("Connection", "keep-alive");

    let fullResponse = "";
    const result = await geminiService.streamChatReply({
      apiKey,
      message,
      history,
      onChunk: (chunk) => {
        fullResponse += chunk;
        res.write(`data: ${JSON.stringify({ type: "chunk", chunk })}\n\n`);
      },
    });

    if (!conversation) {
      conversation = await AiConversation.create({
        userId: new Types.ObjectId(userId),
        title: message.slice(0, 80),
        messages: [],
      });
    }

    conversation.messages.push(
      { role: "user", content: message, createdAt: new Date() },
      { role: "assistant", content: fullResponse, createdAt: new Date() },
    );
    await conversation.save();
    await updateUsage(userId);

    res.write(
      `data: ${JSON.stringify({
        type: "done",
        conversationId: conversation.id,
        estimatedTokens: result.estimatedTokens,
      })}\n\n`,
    );
    res.end();
  },
);

export const getConversations = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user?.userId;
    if (!userId) {
      throw new AppError("Unauthorized", 401);
    }

    const conversations = await AiConversation.find({ userId })
      .sort({ updatedAt: -1 })
      .select("title updatedAt createdAt");

    res.status(200).json({
      success: true,
      data: conversations,
    });
  },
);

export const getConversationById = asyncHandler(
  async (req: Request, res: Response) => {
    const userId = req.user?.userId;
    const { conversationId } = req.params;

    if (!userId) {
      throw new AppError("Unauthorized", 401);
    }

    const conversation = await AiConversation.findOne({
      _id: conversationId,
      userId,
    });

    if (!conversation) {
      throw new AppError("Conversation not found", 404);
    }

    res.status(200).json({
      success: true,
      data: conversation,
    });
  },
);
