class User {
  final String id;
  final String name;
  final String email;
  final UserType type;
  final DateTime createdAt;
  GardenStatus? status;
  DateTime? statusUpdatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.createdAt,
    this.status,
    this.statusUpdatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      type: UserType.values.firstWhere(
            (e) => e.toString() == 'UserType.${json['type']}',
      ),
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'] != null
          ? GardenStatus.values.firstWhere(
            (e) => e.toString() == 'GardenStatus.${json['status']}',
      )
          : null,
      statusUpdatedAt: json['statusUpdatedAt'] != null
          ? DateTime.parse(json['statusUpdatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'type': type.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'status': status?.toString().split('.').last,
      'statusUpdatedAt': statusUpdatedAt?.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    UserType? type,
    DateTime? createdAt,
    GardenStatus? status,
    DateTime? statusUpdatedAt,
    bool clearStatus = false,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      status: clearStatus ? null : (status ?? this.status),
      statusUpdatedAt: clearStatus ? null : (statusUpdatedAt ?? this.statusUpdatedAt),
    );
  }
}

enum UserType { panda, visitor }

enum GardenStatus { notInGarden, goingToGarden, inGarden }

extension GardenStatusExtension on GardenStatus {
  String get displayName {
    switch (this) {
      case GardenStatus.notInGarden:
        return 'Not in Garden';
      case GardenStatus.goingToGarden:
        return 'Going to Garden';
      case GardenStatus.inGarden:
        return 'In Garden';
    }
  }

  String get emoji {
    switch (this) {
      case GardenStatus.notInGarden:
        return '🏠';
      case GardenStatus.goingToGarden:
        return '🚶';
      case GardenStatus.inGarden:
        return '🌳';
    }
  }
}