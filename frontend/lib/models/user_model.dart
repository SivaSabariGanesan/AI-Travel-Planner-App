class User {
  final String id;
  final String name;
  final String email;
  final bool isVerified;
  final String aiMode;
  final int usageCount;
  final DateTime? lastUsedAt;
  final UserPreferences preferences;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isVerified,
    required this.aiMode,
    required this.usageCount,
    this.lastUsedAt,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isVerified: json['isVerified'] ?? false,
      aiMode: json['aiMode'] ?? 'app',
      usageCount: json['usageCount'] ?? 0,
      lastUsedAt: json['lastUsedAt'] != null ? DateTime.parse(json['lastUsedAt']) : null,
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
      lastLoginAt: json['lastLoginAt'] != null ? DateTime.parse(json['lastLoginAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'isVerified': isVerified,
      'aiMode': aiMode,
      'usageCount': usageCount,
      'lastUsedAt': lastUsedAt?.toIso8601String(),
      'preferences': preferences.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? name,
    String? email,
    bool? isVerified,
    String? aiMode,
    int? usageCount,
    DateTime? lastUsedAt,
    UserPreferences? preferences,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      isVerified: isVerified ?? this.isVerified,
      aiMode: aiMode ?? this.aiMode,
      usageCount: usageCount ?? this.usageCount,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

class UserPreferences {
  final String? travelStyle;
  final String? budget;
  final List<String> foodChoices;
  final List<String> dietaryRestrictions;
  final List<String> preferredDestinations;
  final String? tripPace;

  UserPreferences({
    this.travelStyle,
    this.budget,
    this.foodChoices = const [],
    this.dietaryRestrictions = const [],
    this.preferredDestinations = const [],
    this.tripPace,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      travelStyle: json['travelStyle'],
      budget: json['budget'],
      foodChoices: List<String>.from(json['foodChoices'] ?? []),
      dietaryRestrictions: List<String>.from(json['dietaryRestrictions'] ?? []),
      preferredDestinations: List<String>.from(json['preferredDestinations'] ?? []),
      tripPace: json['tripPace'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'travelStyle': travelStyle,
      'budget': budget,
      'foodChoices': foodChoices,
      'dietaryRestrictions': dietaryRestrictions,
      'preferredDestinations': preferredDestinations,
      'tripPace': tripPace,
    };
  }

  UserPreferences copyWith({
    String? travelStyle,
    String? budget,
    List<String>? foodChoices,
    List<String>? dietaryRestrictions,
    List<String>? preferredDestinations,
    String? tripPace,
  }) {
    return UserPreferences(
      travelStyle: travelStyle ?? this.travelStyle,
      budget: budget ?? this.budget,
      foodChoices: foodChoices ?? this.foodChoices,
      dietaryRestrictions: dietaryRestrictions ?? this.dietaryRestrictions,
      preferredDestinations: preferredDestinations ?? this.preferredDestinations,
      tripPace: tripPace ?? this.tripPace,
    );
  }
}
