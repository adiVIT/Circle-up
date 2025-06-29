class WorkExperience {
  final String companyName;
  final String title;
  final String? startDate;
  final String? endDate;
  final bool isCurrent;
  final String? location;
  final String? summary;

  WorkExperience({
    required this.companyName,
    required this.title,
    this.startDate,
    this.endDate,
    this.isCurrent = false,
    this.location,
    this.summary,
  });

  factory WorkExperience.fromMap(Map<String, dynamic> map) {
    return WorkExperience(
      companyName: map['name'] ?? '',
      title: map['title'] ?? '',
      startDate: map['startDate'],
      endDate: map['endDate'],
      isCurrent: map['current'] ?? false,
      location: map['location'],
      summary: map['summary'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': companyName,
      'title': title,
      'startDate': startDate,
      'endDate': endDate,
      'current': isCurrent,
      'location': location,
      'summary': summary,
    };
  }
}

class Education {
  final String schoolName;
  final String? degree;
  final String? fieldOfStudy;
  final String? startDate;
  final String? endDate;

  Education({
    required this.schoolName,
    this.degree,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
  });

  factory Education.fromMap(Map<String, dynamic> map) {
    return Education(
      schoolName: map['name'] ?? '',
      degree: map['degree'],
      fieldOfStudy: map['field'],
      startDate: map['startDate'],
      endDate: map['endDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': schoolName,
      'degree': degree,
      'field': fieldOfStudy,
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

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

  // Enhanced LinkedIn data
  final List<WorkExperience> workExperience;
  final List<Education> education;
  final List<String> skills;
  final String? industry;
  final String? location;
  final String? summary;

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
    this.workExperience = const [],
    this.education = const [],
    this.skills = const [],
    this.industry,
    this.location,
    this.summary,
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
      workExperience: (map['workExperience'] as List<dynamic>? ?? [])
          .map((exp) => WorkExperience.fromMap(exp as Map<String, dynamic>))
          .toList(),
      education: (map['education'] as List<dynamic>? ?? [])
          .map((edu) => Education.fromMap(edu as Map<String, dynamic>))
          .toList(),
      skills: List<String>.from(map['skills'] ?? []),
      industry: map['industry'],
      location: map['location'],
      summary: map['summary'],
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
      'workExperience': workExperience.map((exp) => exp.toMap()).toList(),
      'education': education.map((edu) => edu.toMap()).toList(),
      'skills': skills,
      'industry': industry,
      'location': location,
      'summary': summary,
    };
  }

  // Factory method to create UserModel from LinkedIn data
  factory UserModel.fromLinkedInData(Map<String, dynamic> linkedInData) {
    final now = DateTime.now();

    // Extract work experience
    final workExp = (linkedInData['companies'] as List<dynamic>? ?? [])
        .map((company) =>
            WorkExperience.fromMap(company as Map<String, dynamic>))
        .toList();

    // Extract education
    final edu = (linkedInData['colleges'] as List<dynamic>? ?? [])
        .map((college) => Education.fromMap(college as Map<String, dynamic>))
        .toList();

    // Extract company names for the companies list
    final companyNames = workExp.map((exp) => exp.companyName).toList();

    // Extract college names for the colleges list
    final collegeNames = edu.map((edu) => edu.schoolName).toList();

    return UserModel(
      id: linkedInData['id'] ?? '',
      email: linkedInData['email'] ?? '',
      name:
          '${linkedInData['firstName'] ?? ''} ${linkedInData['lastName'] ?? ''}'
              .trim(),
      profileImageUrl: linkedInData['profilePicture'],
      bio: linkedInData['summary'],
      city: linkedInData['location'],
      colleges: collegeNames,
      companies: companyNames,
      interests: List<String>.from(linkedInData['skills'] ?? []),
      age: 25, // Default age, could be calculated from education dates
      jobTitle: workExp.isNotEmpty ? workExp.first.title : null,
      isOnline: true,
      createdAt: now,
      updatedAt: now,
      workExperience: workExp,
      education: edu,
      skills: List<String>.from(linkedInData['skills'] ?? []),
      industry: linkedInData['industry'],
      location: linkedInData['location'],
      summary: linkedInData['summary'],
    );
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
    List<WorkExperience>? workExperience,
    List<Education>? education,
    List<String>? skills,
    String? industry,
    String? location,
    String? summary,
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
      workExperience: workExperience ?? this.workExperience,
      education: education ?? this.education,
      skills: skills ?? this.skills,
      industry: industry ?? this.industry,
      location: location ?? this.location,
      summary: summary ?? this.summary,
    );
  }

  // Helper methods for better segmentation
  List<String> get currentCompanies {
    return workExperience
        .where((exp) => exp.isCurrent)
        .map((exp) => exp.companyName)
        .toList();
  }

  List<String> get previousCompanies {
    return workExperience
        .where((exp) => !exp.isCurrent)
        .map((exp) => exp.companyName)
        .toList();
  }

  List<String> get allCompanies {
    return workExperience.map((exp) => exp.companyName).toList();
  }

  List<String> get allColleges {
    return education.map((edu) => edu.schoolName).toList();
  }

  String? get currentJobTitle {
    final currentJob = workExperience.firstWhere(
      (exp) => exp.isCurrent,
      orElse: () => workExperience.isNotEmpty
          ? workExperience.first
          : WorkExperience(companyName: '', title: ''),
    );
    return currentJob.title.isNotEmpty ? currentJob.title : null;
  }

  String? get currentCompany {
    final currentJob = workExperience.firstWhere(
      (exp) => exp.isCurrent,
      orElse: () => workExperience.isNotEmpty
          ? workExperience.first
          : WorkExperience(companyName: '', title: ''),
    );
    return currentJob.companyName.isNotEmpty ? currentJob.companyName : null;
  }

  @override
  String toString() {
    return 'UserModel(id: $id, name: $name, email: $email, city: $city, industry: $industry)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
