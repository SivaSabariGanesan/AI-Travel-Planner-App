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
      travelExpense: {
        currency: "",
        transport: "Not specified",
        stay: "Not specified",
        food: "Not specified",
        activities: "Not specified",
        localTravel: "Not specified",
        miscellaneous: "Not specified",
        total: params.budget || params.preferences?.budget || "Not specified",
        notes: "Detailed travel expense is unavailable because AI generation is not configured.",
      },
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
- dayWisePlan (array of { day, date, daySummary, morning, afternoon, evening, food, estimatedCost })
- localFoodIdeas (array)
- packingChecklist (array)
- transportTips (string)
- travelExpense: { currency, transport, stay, food, activities, localTravel, miscellaneous, total, notes }
- estimatedBudget

Day-wise rules (IMPORTANT):
- For each day, include a concise daySummary (4-5 lines) that captures the main plan of the day.
- Keep morning/afternoon/evening practical and specific.
- food should be an array of destination-relevant meal ideas.
- estimatedCost should be per-day cost in destination currency.

Budget rules (IMPORTANT):
- Always estimate costs in the destination local currency (for "To" location).
- Include currency code and symbol in both day-wise estimatedCost and estimatedBudget.
- Example formats: "INR 45,000 (₹)", "JPY 120,000 (¥)", "EUR 1,250 (€)".
- If budget input is qualitative (Budget/Moderate/Luxury), convert it to a realistic numeric range in destination currency.
- Keep estimatedBudget concise as a readable string.

Travel expense rules (IMPORTANT):
- Always populate travelExpense with realistic destination-local costs.
- travelExpense.total must match or align closely with estimatedBudget.
- transport should cover intercity travel (flight/train/bus as applicable).
- stay should cover accommodation for the full trip.
- food should cover meals/snacks.
- activities should cover tickets/experiences.
- localTravel should cover taxis/metro/rental/local commute.
- miscellaneous should cover permits/tips/emergency buffer.
- notes should mention assumptions used for pricing (season, mid-range options, etc.).

Output rules:
- Return JSON only. Do not include markdown code fences or extra commentary.
- Ensure all keys exist even if values are empty strings/arrays.`;

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
        travelExpense: {
          currency: "",
          transport: "",
          stay: "",
          food: "",
          activities: "",
          localTravel: "",
          miscellaneous: "",
          total: params.budget || params.preferences?.budget || "Not specified",
          notes: "",
        },
        estimatedBudget:
          params.budget || params.preferences?.budget || "Not specified",
      } as Record<string, unknown>),
    rawText: text,
  };
};
