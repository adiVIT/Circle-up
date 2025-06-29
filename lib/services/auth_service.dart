import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  // Mock LinkedIn authentication
  Future<UserModel?> signInWithLinkedIn() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock LinkedIn user data
    final mockUser = UserModel(
      id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      email: 'john.doe@example.com',
      name: 'John Doe',
      profileImageUrl: 'https://via.placeholder.com/150',
      bio: 'Software Engineer passionate about mobile development',
      city: 'San Francisco',
      colleges: ['Stanford University'],
      companies: ['Google', 'Meta'],
      interests: ['Technology', 'Travel', 'Photography'],
      age: 28,
      jobTitle: 'Senior Software Engineer',
      isOnline: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Save to local storage
    await _saveUser(mockUser);
    await _setLoggedIn(true);

    return mockUser;
  }

  Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    if (!isLoggedIn) return null;

    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromMap(userMap);
    }

    return null;
  }

  Future<UserModel?> createUserProfile(UserModel user) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final updatedUser = user.copyWith(
      updatedAt: DateTime.now(),
    );

    await _saveUser(updatedUser);
    return updatedUser;
  }

  Future<UserModel?> updateUserProfile(UserModel user) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final updatedUser = user.copyWith(
      updatedAt: DateTime.now(),
    );

    await _saveUser(updatedUser);
    return updatedUser;
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toMap());
    await prefs.setString(_userKey, userJson);
  }

  Future<void> _setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }
}
