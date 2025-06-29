import '../models/connection_model.dart';

class ConnectionService {
  // Mock connection data
  static final List<ConnectionModel> _mockConnections = [];
  static int _connectionCounter = 0;

  Future<void> sendConnectionRequest(String fromUserId, String toUserId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final connection = ConnectionModel(
      id: 'connection_${++_connectionCounter}',
      fromUserId: fromUserId,
      toUserId: toUserId,
      status: ConnectionStatus.pending,
      createdAt: DateTime.now(),
    );

    _mockConnections.add(connection);
  }

  Future<void> respondToConnectionRequest(
    String connectionId,
    ConnectionStatus status,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final connectionIndex = _mockConnections.indexWhere(
      (connection) => connection.id == connectionId,
    );

    if (connectionIndex != -1) {
      final connection = _mockConnections[connectionIndex];
      final updatedConnection = connection.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
      _mockConnections[connectionIndex] = updatedConnection;
    }
  }

  Future<List<ConnectionModel>> getUserConnections(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    return _mockConnections
        .where((connection) =>
            connection.fromUserId == userId || connection.toUserId == userId)
        .toList();
  }

  Future<List<ConnectionModel>> getPendingRequests(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockConnections
        .where((connection) =>
            connection.toUserId == userId &&
            connection.status == ConnectionStatus.pending)
        .toList();
  }

  Future<List<ConnectionModel>> getAcceptedConnections(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return _mockConnections
        .where((connection) =>
            (connection.fromUserId == userId ||
                connection.toUserId == userId) &&
            connection.status == ConnectionStatus.accepted)
        .toList();
  }

  Future<ConnectionModel?> getConnectionBetweenUsers(
    String userId1,
    String userId2,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      return _mockConnections.firstWhere((connection) =>
          (connection.fromUserId == userId1 &&
              connection.toUserId == userId2) ||
          (connection.fromUserId == userId2 && connection.toUserId == userId1));
    } catch (e) {
      return null;
    }
  }

  Future<bool> hasConnectionBetweenUsers(String userId1, String userId2) async {
    final connection = await getConnectionBetweenUsers(userId1, userId2);
    return connection != null;
  }

  Future<void> blockUser(String fromUserId, String toUserId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final existingConnection =
        await getConnectionBetweenUsers(fromUserId, toUserId);

    if (existingConnection != null) {
      final connectionIndex = _mockConnections.indexWhere(
        (connection) => connection.id == existingConnection.id,
      );

      if (connectionIndex != -1) {
        final updatedConnection = existingConnection.copyWith(
          status: ConnectionStatus.blocked,
          updatedAt: DateTime.now(),
        );
        _mockConnections[connectionIndex] = updatedConnection;
      }
    } else {
      // Create new blocked connection
      final connection = ConnectionModel(
        id: 'connection_${++_connectionCounter}',
        fromUserId: fromUserId,
        toUserId: toUserId,
        status: ConnectionStatus.blocked,
        createdAt: DateTime.now(),
      );

      _mockConnections.add(connection);
    }
  }

  Future<void> unblockUser(String fromUserId, String toUserId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 600));

    final connection = await getConnectionBetweenUsers(fromUserId, toUserId);
    if (connection != null && connection.status == ConnectionStatus.blocked) {
      final connectionIndex = _mockConnections.indexWhere(
        (c) => c.id == connection.id,
      );

      if (connectionIndex != -1) {
        _mockConnections.removeAt(connectionIndex);
      }
    }
  }

  Future<void> removeConnection(String connectionId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    _mockConnections.removeWhere((connection) => connection.id == connectionId);
  }

  // Get connection statistics
  Future<Map<String, int>> getConnectionStats(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));

    final userConnections = await getUserConnections(userId);

    return {
      'total': userConnections.length,
      'accepted': userConnections
          .where((c) => c.status == ConnectionStatus.accepted)
          .length,
      'pending': userConnections
          .where((c) => c.status == ConnectionStatus.pending)
          .length,
      'blocked': userConnections
          .where((c) => c.status == ConnectionStatus.blocked)
          .length,
    };
  }
}
