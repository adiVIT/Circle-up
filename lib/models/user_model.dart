class UserModel {
  final String id;
  final String email;
  final String name;
  final String? profileImageUrl;
  final String? bio;
  final String? city;
  final List<String> colleges;
  final List<String> companies;
  final List<String> interests;
  final int age;
  final String? jobTitle;
  final bool isOnline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastSeen;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.profileImageUrl,
    this.bio,
    this.city,
    this.colleges = const [],
    this.companies = const [],
    this.interests = const [],
    required this.age,
    this.jobTitle,
    this.isOnline = false,
    required this.createdAt,
    required this.updatedAt,
    this.lastSeen,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      bio: map['bio'],
      city: map['city'],
      colleges: List<String>.from(map['colleges'] ?? []),
      companies: List<String>.from(map['companies'] ?? []),
      interests: List<String>.from(map['interests'] ?? []),
      age: map['age'] ?? 0,
      jobTitle: map['jobTitle'],
      isOnline: map['isOnline'] ?? false,
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
      lastSeen:
          map['lastSeen'] != null ? DateTime.parse(map['lastSeen']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'city': city,
      'colleges': colleges,
      'companies': companies,
      'interests': interests,
      'age': age,
      'jobTitle': jobTitle,
      'isOnline': isOnline,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastSeen': lastSeen?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? profileImageUrl,
    String? bio,
    String? city,
    List<String>? colleges,
    List<String>? companies,
    List<String>? interests,
    int? age,
    String? jobTitle,
    bool? isOnline,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeen,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      city: city ?? this.city,
      colleges: colleges ?? this.colleges,
      companies: companies ?? this.companies,
      interests: interests ?? this.interests,
      age: age ?? this.age,
      jobTitle: jobTitle ?? this.jobTitle,
      isOnline: isOnline ?? this.isOnline,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, city: $city)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
