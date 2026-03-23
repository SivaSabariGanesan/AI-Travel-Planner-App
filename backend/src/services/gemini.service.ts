import { GoogleGenerativeAI } from "@google/generative-ai";

type Preferences = {
  travelStyle?: string | null;
  budget?: string | null;
  foodChoices?: string[];
  dietaryRestrictions?: string[];
  preferredDestinations?: string[];
  tripPace?: string | null;
};

const parseGeneratedJson = (text: string): Record<string, unknown> | null => {
  const clean = text.trim();
  const fenced = clean.match(/```json\s*([\s\S]*?)\s*```/i);
  const jsonPayload = fenced ? fenced[1] : clean;

  try {
    return JSON.parse(jsonPayload);
  } catch {
    return null;
  }
};

export const generateTravelRecipe = async (params: {
  topic: string;
  days?: number;
  extraNotes?: string;
  preferences?: Preferences;
}): Promise<{ generatedContent: Record<string, unknown>; rawText: string }> => {
  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey) {
    const fallback = {
      title: `Trip recipe for ${params.topic}`,
      summary: "Gemini API key missing. Configure GEMINI_API_KEY to generate AI content.",
      dayWisePlan: [],
      localFoodIdeas: [],
      packingChecklist: [],
      estimatedBudget: params.preferences?.budget || "Not specified",
    };

    return {
      generatedContent: fallback,
      rawText: JSON.stringify(fallback),
    };
  }

  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({
    model: process.env.GEMINI_MODEL || "gemini-1.5-flash",
  });

  const prompt = `You are an expert travel planner. Build a structured travel recipe as strict JSON only.\n
Topic: ${params.topic}\n
Days: ${params.days ?? "not specified"}\n
Extra notes: ${params.extraNotes || "none"}\n
User preferences (JSON): ${JSON.stringify(params.preferences || {})}\n
Return JSON with keys: title, summary, dayWisePlan (array), localFoodIdeas (array), packingChecklist (array), estimatedBudget.`;

  const result = await model.generateContent(prompt);
  const text = result.response.text();
  const parsed = parseGeneratedJson(text);

  return {
    generatedContent:
      parsed ||
      ({
        title: `Trip recipe for ${params.topic}`,
        summary: text,
        dayWisePlan: [],
        localFoodIdeas: [],
        packingChecklist: [],
        estimatedBudget: params.preferences?.budget || "Not specified",
      } as Record<string, unknown>),
    rawText: text,
  };
};
