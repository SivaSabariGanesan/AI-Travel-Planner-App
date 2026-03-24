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
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      topic: json['topic'] ?? '',
      days: json['days'],
      itineraryInput: RecipeInput.fromJson(json['itineraryInput'] ?? {}),
      generatedContent: GeneratedContent.fromJson(json['generatedContent'] ?? {}),
      rawText: json['rawText'] ?? '',
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
      fromLocation: json['fromLocation'] ?? '',
      toLocation: json['toLocation'] ?? '',
      startDate: json['startDate'],
      endDate: json['endDate'],
      interests: List<String>.from(json['interests'] ?? []),
      budget: json['budget'],
      travelerCount: json['travelerCount'] ?? 1,
      extraNotes: json['extraNotes'],
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
          .map((e) => DayWisePlan.fromJson(e is String ? {'plan': e} : e ?? {}))
          .toList();
    }

    return GeneratedContent(
      title: json['title'],
      summary: json['summary'],
      route: json['route'],
      duration: json['duration'],
      interests: List<String>.from(json['interests'] ?? []),
      dayWisePlan: dayPlans,
      localFoodIdeas: List<String>.from(json['localFoodIdeas'] ?? []),
      packingChecklist: List<String>.from(json['packingChecklist'] ?? []),
      transportTips: json['transportTips'],
      estimatedBudget: json['estimatedBudget'],
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
  final String? plan;
  final List<String> activities;
  final List<String> meals;

  DayWisePlan({
    this.day,
    this.plan,
    this.activities = const [],
    this.meals = const [],
  });

  factory DayWisePlan.fromJson(Map<String, dynamic> json) {
    return DayWisePlan(
      day: json['day'],
      plan: json['plan'],
      activities: List<String>.from(json['activities'] ?? []),
      meals: List<String>.from(json['meals'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'plan': plan,
      'activities': activities,
      'meals': meals,
    };
  }
}
