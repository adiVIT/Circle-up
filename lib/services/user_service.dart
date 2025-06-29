import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _usersCollection = 'users';

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc =
          await _firestore.collection(_usersCollection).doc(userId).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .set(user.toMap());
    } catch (e) {
      print('Error creating user: $e');
      throw Exception('Failed to create user');
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.id)
          .update(user.toMap());
    } catch (e) {
      print('Error updating user: $e');
      throw Exception('Failed to update user');
    }
  }

  Future<List<UserModel>> discoverUsers({
    String? currentUserId,
    String? city,
    List<String>? colleges,
    List<String>? companies,
    List<String>? interests,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore.collection(_usersCollection);

      // Filter out current user
      if (currentUserId != null) {
        query = query.where('id', isNotEqualTo: currentUserId);
      }

      // Apply city filter
      if (city != null && city.isNotEmpty) {
        query = query.where('city', isEqualTo: city);
      }

      // Firebase limitation: Only one array-contains-any filter per query
      // Priority: colleges > companies > interests
      if (colleges != null && colleges.isNotEmpty) {
        query = query.where('colleges', arrayContainsAny: colleges);
      } else if (companies != null && companies.isNotEmpty) {
        query = query.where('companies', arrayContainsAny: companies);
      } else if (interests != null && interests.isNotEmpty) {
        query = query.where('interests', arrayContainsAny: interests);
      }

      // Limit results
      query =
          query.limit(limit * 2); // Get more results for client-side filtering

      final snapshot = await query.get();

      var users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      // Apply additional filters client-side if needed
      if (companies != null &&
          companies.isNotEmpty &&
          (colleges == null || colleges.isEmpty)) {
        // Already filtered by companies in query
      } else if (companies != null && companies.isNotEmpty) {
        // Filter by companies client-side if colleges were used in query
        users = users
            .where((user) => user.companies.any((company) => companies.any(
                (filterCompany) => company
                    .toLowerCase()
                    .contains(filterCompany.toLowerCase()))))
            .toList();
      }

      if (interests != null &&
          interests.isNotEmpty &&
          (colleges == null || colleges.isEmpty) &&
          (companies == null || companies.isEmpty)) {
        // Already filtered by interests in query
      } else if (interests != null && interests.isNotEmpty) {
        // Filter by interests client-side if other filters were used in query
        users = users
            .where((user) => user.interests.any((interest) => interests.any(
                (filterInterest) => interest
                    .toLowerCase()
                    .contains(filterInterest.toLowerCase()))))
            .toList();
      }

      // Shuffle and limit results
      users.shuffle();
      return users.take(limit).toList();
    } catch (e) {
      print('Error discovering users: $e');
      return [];
    }
  }

  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    try {
      // Firebase doesn't support full-text search natively
      // For now, we'll get all users and filter client-side
      // In production, consider using Algolia or Elasticsearch
      final snapshot = await _firestore.collection(_usersCollection).get();

      final lowercaseQuery = query.toLowerCase();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) =>
              user.name.toLowerCase().contains(lowercaseQuery) ||
              user.bio?.toLowerCase().contains(lowercaseQuery) == true ||
              user.city?.toLowerCase().contains(lowercaseQuery) == true ||
              user.jobTitle?.toLowerCase().contains(lowercaseQuery) == true ||
              user.colleges.any((college) =>
                  college.toLowerCase().contains(lowercaseQuery)) ||
              user.companies.any((company) =>
                  company.toLowerCase().contains(lowercaseQuery)) ||
              user.interests.any((interest) =>
                  interest.toLowerCase().contains(lowercaseQuery)))
          .toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  Future<void> updateLastSeen(String userId) async {
    try {
      await _firestore.collection(_usersCollection).doc(userId).update({
        'lastSeen': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating last seen: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real app, this would delete the user from the database
  }
}
