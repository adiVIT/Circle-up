import '../models/user_model.dart';

class UserService {
  // Mock user data for discovery
  static final List<UserModel> _mockUsers = [
    UserModel(
      id: 'user_1',
      email: 'alice@example.com',
      name: 'Alice Johnson',
      profileImageUrl: 'https://via.placeholder.com/150/FF6B6B/FFFFFF?text=AJ',
      bio: 'Product Manager who loves hiking and coffee ☕',
      city: 'San Francisco',
      colleges: ['UC Berkeley'],
      companies: ['Apple', 'Airbnb'],
      interests: ['Hiking', 'Coffee', 'Design'],
      age: 26,
      jobTitle: 'Senior Product Manager',
      isOnline: true,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    UserModel(
      id: 'user_2',
      email: 'bob@example.com',
      name: 'Bob Chen',
      profileImageUrl: 'https://via.placeholder.com/150/4ECDC4/FFFFFF?text=BC',
      bio: 'Software Engineer building the future 🚀',
      city: 'San Francisco',
      colleges: ['Stanford University'],
      companies: ['Google', 'Meta'],
      interests: ['Technology', 'Basketball', 'Travel'],
      age: 29,
      jobTitle: 'Staff Software Engineer',
      isOnline: false,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    UserModel(
      id: 'user_3',
      email: 'sarah@example.com',
      name: 'Sarah Wilson',
      profileImageUrl: 'https://via.placeholder.com/150/45B7D1/FFFFFF?text=SW',
      bio: 'Designer passionate about creating beautiful experiences ✨',
      city: 'New York',
      colleges: ['NYU'],
      companies: ['Netflix', 'Spotify'],
      interests: ['Design', 'Art', 'Music'],
      age: 27,
      jobTitle: 'Senior UX Designer',
      isOnline: true,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    UserModel(
      id: 'user_4',
      email: 'mike@example.com',
      name: 'Mike Rodriguez',
      profileImageUrl: 'https://via.placeholder.com/150/96CEB4/FFFFFF?text=MR',
      bio: 'Marketing lead who loves exploring new cities 🌎',
      city: 'Los Angeles',
      colleges: ['UCLA'],
      companies: ['Tesla', 'SpaceX'],
      interests: ['Marketing', 'Travel', 'Photography'],
      age: 31,
      jobTitle: 'Marketing Director',
      isOnline: true,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    UserModel(
      id: 'user_5',
      email: 'emma@example.com',
      name: 'Emma Davis',
      profileImageUrl: 'https://via.placeholder.com/150/FFEAA7/FFFFFF?text=ED',
      bio: 'Data Scientist turning data into insights 📊',
      city: 'Seattle',
      colleges: ['University of Washington'],
      companies: ['Microsoft', 'Amazon'],
      interests: ['Data Science', 'Running', 'Books'],
      age: 25,
      jobTitle: 'Senior Data Scientist',
      isOnline: false,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  Future<UserModel?> getUserById(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      return _mockUsers.firstWhere((user) => user.id == userId);
    } catch (e) {
      return null;
    }
  }

  Future<void> createUser(UserModel user) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would save to a database
    // For now, we'll just simulate success
  }

  Future<void> updateUser(UserModel user) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would update the database
    // For now, we'll just simulate success
  }

  Future<List<UserModel>> discoverUsers({
    String? currentUserId,
    String? city,
    List<String>? colleges,
    List<String>? companies,
    List<String>? interests,
    int limit = 10,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    var users = List<UserModel>.from(_mockUsers);

    // Filter out current user
    if (currentUserId != null) {
      users = users.where((user) => user.id != currentUserId).toList();
    }

    // Apply filters
    if (city != null && city.isNotEmpty) {
      users = users
          .where((user) =>
              user.city?.toLowerCase().contains(city.toLowerCase()) ?? false)
          .toList();
    }

    if (colleges != null && colleges.isNotEmpty) {
      users = users
          .where((user) => user.colleges.any((college) => colleges.any(
              (filterCollege) =>
                  college.toLowerCase().contains(filterCollege.toLowerCase()))))
          .toList();
    }

    if (companies != null && companies.isNotEmpty) {
      users = users
          .where((user) => user.companies.any((company) => companies.any(
              (filterCompany) =>
                  company.toLowerCase().contains(filterCompany.toLowerCase()))))
          .toList();
    }

    if (interests != null && interests.isNotEmpty) {
      users = users
          .where((user) => user.interests.any((interest) => interests.any(
              (filterInterest) => interest
                  .toLowerCase()
                  .contains(filterInterest.toLowerCase()))))
          .toList();
    }

    // Shuffle for variety
    users.shuffle();

    // Limit results
    return users.take(limit).toList();
  }

  Future<List<UserModel>> searchUsers(String query) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    if (query.isEmpty) return [];

    final lowercaseQuery = query.toLowerCase();

    return _mockUsers
        .where((user) =>
            user.name.toLowerCase().contains(lowercaseQuery) ||
            user.bio?.toLowerCase().contains(lowercaseQuery) == true ||
            user.city?.toLowerCase().contains(lowercaseQuery) == true ||
            user.jobTitle?.toLowerCase().contains(lowercaseQuery) == true ||
            user.colleges.any(
                (college) => college.toLowerCase().contains(lowercaseQuery)) ||
            user.companies.any(
                (company) => company.toLowerCase().contains(lowercaseQuery)) ||
            user.interests.any(
                (interest) => interest.toLowerCase().contains(lowercaseQuery)))
        .toList();
  }

  Future<void> updateLastSeen(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 200));

    // In a real app, this would update the user's last seen timestamp
  }

  Future<void> deleteUser(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would delete the user from the database
  }
}
