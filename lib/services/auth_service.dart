import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'user_service.dart';
import 'linkedin_oauth_service.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Real LinkedIn OAuth authentication
  Future<UserModel?> signInWithLinkedIn(BuildContext context) async {
    try {
      print('Starting LinkedIn OAuth flow...');

      // Start LinkedIn OAuth flow - this will redirect to LinkedIn's website
      final linkedInData =
          await LinkedInOAuthService.signInWithLinkedIn(context);

      if (linkedInData != null) {
        print('LinkedIn OAuth successful, processing user data...');

        // Create a unique user ID based on LinkedIn ID
        final linkedInId = linkedInData['id'] ?? 'unknown';
        final userId = 'linkedin_$linkedInId';

        print('LinkedIn user ID: $linkedInId');
        print('Generated user ID: $userId');

        // Check if user profile already exists
        UserModel? existingUser = await _userService.getUserById(userId);

        if (existingUser != null) {
          print('Existing user found, signing in...');
          await _saveUser(existingUser);
          await _setLoggedIn(true);
          return existingUser;
        } else {
          print('New user, creating profile...');

          // Create comprehensive user profile from LinkedIn data
          final newUser = UserModel.fromLinkedInData(linkedInData).copyWith(
            id: userId,
          );

          print('Created user model: ${newUser.name}');

          // Save to Firestore (skip Firebase Auth for LinkedIn users)
          try {
            await _userService.createUser(newUser);
            await _saveUser(newUser);
            await _setLoggedIn(true);

            print('User successfully created and saved');
            return newUser;
          } catch (e) {
            print('Error saving user to Firestore: $e');
            // Even if Firestore fails, we can still save locally
            await _saveUser(newUser);
            await _setLoggedIn(true);
            return newUser;
          }
        }
      } else {
        print('LinkedIn OAuth returned null data');
      }

      return null;
    } catch (e) {
      print('LinkedIn authentication error: $e');
      print('Error type: ${e.runtimeType}');
      return null;
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      // Check Firebase Auth first
      final firebaseUser = _auth.currentUser;

      if (firebaseUser != null) {
        // Try to get user from Firestore
        final user = await _userService.getUserById(firebaseUser.uid);
        if (user != null) {
          await _saveUser(user);
          await _setLoggedIn(true);
          return user;
        }
      }

      // Fallback to local storage
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (!isLoggedIn) return null;

      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromMap(userMap);
      }

      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
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
    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      print('Error signing out: $e');
    }
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
