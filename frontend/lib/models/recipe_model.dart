String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  return value.toString();
}

String? _asNullableString(dynamic value) {
  if (value == null) return null;
  final text = value.toString();
  return text.isEmpty ? null : text;
}

int? _asNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

int _asInt(dynamic value, {int fallback = 0}) {
  return _asNullableInt(value) ?? fallback;
}

List<String> _asStringList(dynamic value) {
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return <String>[];
}

class Recipe {
  final String id;
  final String userId;
  final String topic;
  final int? days;
  final RecipeInput itineraryInput;
  final GeneratedContent generatedContent;
  final String rawText;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    required this.id,
    required this.userId,
    required this.topic,
    this.days,
    required this.itineraryInput,
    required this.generatedContent,
    required this.rawText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: _asString(json['_id'] ?? json['id']),
      userId: _asString(json['userId']),
      topic: _asString(json['topic']),
      days: _asNullableInt(json['days']),
      itineraryInput: RecipeInput.fromJson(json['itineraryInput'] ?? {}),
      generatedContent: GeneratedContent.fromJson(json['generatedContent'] ?? {}),
      rawText: _asString(json['rawText']),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'topic': topic,
      'days': days,
      'itineraryInput': itineraryInput.toJson(),
      'generatedContent': generatedContent.toJson(),
      'rawText': rawText,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class RecipeInput {
  final String fromLocation;
  final String toLocation;
  final String? startDate;
  final String? endDate;
  final List<String> interests;
  final String? budget;
  final int travelerCount;
  final String? extraNotes;

  RecipeInput({
    required this.fromLocation,
    required this.toLocation,
    this.startDate,
    this.endDate,
    this.interests = const [],
    this.budget,
    this.travelerCount = 1,
    this.extraNotes,
  });

  factory RecipeInput.fromJson(Map<String, dynamic> json) {
    return RecipeInput(
      fromLocation: _asString(json['fromLocation']),
      toLocation: _asString(json['toLocation']),
      startDate: _asNullableString(json['startDate']),
      endDate: _asNullableString(json['endDate']),
      interests: _asStringList(json['interests']),
      budget: _asNullableString(json['budget']),
      travelerCount: _asInt(json['travelerCount'], fallback: 1),
      extraNotes: _asNullableString(json['extraNotes']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'startDate': startDate,
      'endDate': endDate,
      'interests': interests,
      'budget': budget,
      'travelerCount': travelerCount,
      'extraNotes': extraNotes,
    };
  }
}

class GeneratedContent {
  final String? title;
  final String? summary;
  final String? route;
  final String? duration;
  final List<String> interests;
  final List<DayWisePlan> dayWisePlan;
  final List<String> localFoodIdeas;
  final List<String> packingChecklist;
  final String? transportTips;
  final String? estimatedBudget;

  GeneratedContent({
    this.title,
    this.summary,
    this.route,
    this.duration,
    this.interests = const [],
    this.dayWisePlan = const [],
    this.localFoodIdeas = const [],
    this.packingChecklist = const [],
    this.transportTips,
    this.estimatedBudget,
  });

  factory GeneratedContent.fromJson(Map<String, dynamic> json) {
    List<DayWisePlan> dayPlans = [];
    if (json['dayWisePlan'] is List) {
      dayPlans = (json['dayWisePlan'] as List)
          .map((e) => DayWisePlan.fromJson(e is Map<String, dynamic>
              ? e
              : e is String
                  ? {'plan': e}
                  : {'plan': e?.toString()}))
          .toList();
    } else if (json['dayWisePlan'] is Map) {
      final map = json['dayWisePlan'] as Map;
      dayPlans = map.entries
          .map((entry) => DayWisePlan.fromJson(
                entry.value is Map<String, dynamic>
                    ? {
                        'day': entry.key.toString(),
                        ...entry.value as Map<String, dynamic>,
                      }
                    : {
                        'day': entry.key.toString(),
                        'plan': entry.value?.toString(),
                      },
              ))
          .toList();
    }

    return GeneratedContent(
      title: _asNullableString(json['title']),
      summary: _asNullableString(json['summary']),
      route: _asNullableString(json['route']),
      duration: _asNullableString(json['duration']),
      interests: _asStringList(json['interests']),
      dayWisePlan: dayPlans,
      localFoodIdeas: _asStringList(json['localFoodIdeas']),
      packingChecklist: _asStringList(json['packingChecklist']),
      transportTips: _asNullableString(json['transportTips']),
      estimatedBudget: _asNullableString(json['estimatedBudget']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'route': route,
      'duration': duration,
      'interests': interests,
      'dayWisePlan': dayWisePlan.map((e) => e.toJson()).toList(),
      'localFoodIdeas': localFoodIdeas,
      'packingChecklist': packingChecklist,
      'transportTips': transportTips,
      'estimatedBudget': estimatedBudget,
    };
  }
}

class DayWisePlan {
  final String? day;
  final String? date;
  final String? plan;
  final List<String> activities;
  final List<String> meals;
  final String? morning;
  final String? afternoon;
  final String? evening;
  final List<String> food;
  final String? estimatedCost;

  DayWisePlan({
    this.day,
    this.date,
    this.plan,
    this.activities = const [],
    this.meals = const [],
    this.morning,
    this.afternoon,
    this.evening,
    this.food = const [],
    this.estimatedCost,
  });

  factory DayWisePlan.fromJson(Map<String, dynamic> json) {
    final foodItems = _asStringList(json['food']);
    final mealItems = _asStringList(json['meals']);

    return DayWisePlan(
      day: _asNullableString(json['day']),
      date: _asNullableString(json['date']),
      plan: _asNullableString(json['plan']),
      activities: _asStringList(json['activities']),
      meals: mealItems,
      morning: _asNullableString(json['morning']),
      afternoon: _asNullableString(json['afternoon']),
      evening: _asNullableString(json['evening']),
      food: foodItems,
      estimatedCost: _asNullableString(json['estimatedCost']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'date': date,
      'plan': plan,
      'activities': activities,
      'meals': meals,
      'morning': morning,
      'afternoon': afternoon,
      'evening': evening,
      'food': food,
      'estimatedCost': estimatedCost,
    };
  }
}
