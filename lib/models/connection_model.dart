enum ConnectionStatus {
  pending,
  accepted,
  rejected,
  blocked,
}

class ConnectionModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final ConnectionStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ConnectionModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory ConnectionModel.fromMap(Map<String, dynamic> map) {
    return ConnectionModel(
      id: map['id'] ?? '',
      fromUserId: map['fromUserId'] ?? '',
      toUserId: map['toUserId'] ?? '',
      status: ConnectionStatus.values.firstWhere(
        (e) => e.toString() == 'ConnectionStatus.${map['status']}',
        orElse: () => ConnectionStatus.pending,
      ),
      createdAt:
          DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ConnectionModel copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    ConnectionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ConnectionModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'ConnectionModel(id: $id, fromUserId: $fromUserId, toUserId: $toUserId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectionModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
