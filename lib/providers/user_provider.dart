import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _discoveryUsers = [];
  List<UserModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<UserModel> get discoveryUsers => _discoveryUsers;
  List<UserModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadDiscoveryUsers({
    required String currentUserId,
    String? city,
    List<String>? colleges,
    List<String>? companies,
    List<String>? interests,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _discoveryUsers = await _userService.discoverUsers(
        currentUserId: currentUserId,
        city: city,
        colleges: colleges,
        companies: companies,
        interests: interests,
        limit: 10,
      );
    } catch (e) {
      _setError('Failed to load users: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchUsers({
    required String query,
    String? currentUserId,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _searchResults = await _userService.searchUsers(query);
    } catch (e) {
      _setError('Search failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  void removeUserFromDiscovery(String userId) {
    _discoveryUsers.removeWhere((user) => user.id == userId);
    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults.clear();
    notifyListeners();
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
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}
