import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/connection_service.dart';
import '../services/user_service.dart';

class DiscoveryProvider with ChangeNotifier {
  final ConnectionService _connectionService = ConnectionService();
  final UserService _userService = UserService();

  final List<String> _passedUsers = [];
  final List<String> _likedUsers = [];
  List<UserModel> _discoveredUsers = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<UserModel> get discoveredUsers => _discoveredUsers;
  List<String> get passedUsers => _passedUsers;
  List<String> get likedUsers => _likedUsers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDiscoveredUsers({
    String? currentUserId,
    String? city,
    List<String>? colleges,
    List<String>? companies,
    List<String>? interests,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final users = await _userService.discoverUsers(
        currentUserId: currentUserId,
        city: city,
        colleges: colleges,
        companies: companies,
        interests: interests,
      );

      _discoveredUsers = users;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> passUser(String userId, String currentUserId) async {
    try {
      _passedUsers.add(userId);
      _removeUserFromDiscovered(userId);
      // Record action for analytics (mock)
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> likeUser(String userId, String currentUserId) async {
    try {
      _likedUsers.add(userId);
      _removeUserFromDiscovered(userId);

      // Send connection request
      await _connectionService.sendConnectionRequest(currentUserId, userId);

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _removeUserFromDiscovered(String userId) {
    _discoveredUsers.removeWhere((user) => user.id == userId);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void resetDiscovery() {
    _discoveredUsers.clear();
    _passedUsers.clear();
    _likedUsers.clear();
    _clearError();
    notifyListeners();
  }
}
