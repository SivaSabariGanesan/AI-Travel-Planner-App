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
  fromLocation: string;
  toLocation: string;
  days?: number;
  startDate?: string;
  endDate?: string;
  interests?: string[];
  budget?: string;
  travelerCount?: number;
  extraNotes?: string;
  preferences?: Preferences;
}): Promise<{ generatedContent: Record<string, unknown>; rawText: string }> => {
  const apiKey = process.env.GEMINI_API_KEY;

  if (!apiKey) {
    const fallback = {
      title: `${params.fromLocation} to ${params.toLocation} itinerary`,
      summary: "Gemini API key missing. Configure GEMINI_API_KEY to generate AI content.",
      dayWisePlan: [],
      route: {
        from: params.fromLocation,
        to: params.toLocation,
      },
      interests: params.interests || [],
      localFoodIdeas: [],
      packingChecklist: [],
      estimatedBudget:
        params.budget || params.preferences?.budget || "Not specified",
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

  const prompt = `You are an expert travel planner. Build a structured travel itinerary as strict JSON only.

Trip title/topic: ${params.topic}
From: ${params.fromLocation}
To: ${params.toLocation}
Days: ${params.days ?? "not specified"}
Start date: ${params.startDate || "not specified"}
End date: ${params.endDate || "not specified"}
Interests: ${(params.interests || []).join(", ") || "not specified"}
Budget: ${params.budget || params.preferences?.budget || "not specified"}
Traveler count: ${params.travelerCount ?? "not specified"}
Extra notes: ${params.extraNotes || "none"}
User preferences (JSON): ${JSON.stringify(params.preferences || {})}

Return valid JSON only with keys:
- title
- summary
- route: { from, to }
- duration: { days, startDate, endDate }
- interests (array)
- dayWisePlan (array of { day, date, morning, afternoon, evening, food, estimatedCost })
- localFoodIdeas (array)
- packingChecklist (array)
- transportTips (array)
- estimatedBudget`;

  const result = await model.generateContent(prompt);
  const text = result.response.text();
  const parsed = parseGeneratedJson(text);

  return {
    generatedContent:
      parsed ||
      ({
        title: `${params.fromLocation} to ${params.toLocation} itinerary`,
        summary: text,
        route: {
          from: params.fromLocation,
          to: params.toLocation,
        },
        duration: {
          days: params.days || null,
          startDate: params.startDate || null,
          endDate: params.endDate || null,
        },
        interests: params.interests || [],
        dayWisePlan: [],
        localFoodIdeas: [],
        packingChecklist: [],
        transportTips: [],
        estimatedBudget:
          params.budget || params.preferences?.budget || "Not specified",
      } as Record<string, unknown>),
    rawText: text,
  };
};
