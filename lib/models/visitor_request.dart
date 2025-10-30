import 'package:panda_garden/models/user.dart';

class VisitorRequest {
  final String id;
  final String visitorId;
  final String visitorName;
  final DateTime requestedAt;
  final GardenStatus? requestedStatus; // NEW: The status they want to change to
  RequestStatus status;
  final DateTime? respondedAt;

  VisitorRequest({
    required this.id,
    required this.visitorId,
    required this.visitorName,
    required this.requestedAt,
    this.requestedStatus, // NEW
    this.status = RequestStatus.pending,
    this.respondedAt,
  });

  factory VisitorRequest.fromJson(Map<String, dynamic> json) {
    return VisitorRequest(
      id: json['id'],
      visitorId: json['visitorId'],
      visitorName: json['visitorName'],
      requestedAt: DateTime.parse(json['requestedAt']),
      requestedStatus: json['requestedStatus'] != null // NEW
          ? GardenStatus.values.firstWhere(
            (e) => e.toString() == 'GardenStatus.${json['requestedStatus']}',
      )
          : null,
      status: RequestStatus.values.firstWhere(
            (e) => e.toString() == 'RequestStatus.${json['status']}',
      ),
      respondedAt: json['respondedAt'] != null
          ? DateTime.parse(json['respondedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visitorId': visitorId,
      'visitorName': visitorName,
      'requestedAt': requestedAt.toIso8601String(),
      'requestedStatus': requestedStatus?.toString().split('.').last, // NEW
      'status': status.toString().split('.').last,
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  VisitorRequest copyWith({
    String? id,
    String? visitorId,
    String? visitorName,
    DateTime? requestedAt,
    GardenStatus? requestedStatus, // NEW
    RequestStatus? status,
    DateTime? respondedAt,
  }) {
    return VisitorRequest(
      id: id ?? this.id,
      visitorId: visitorId ?? this.visitorId,
      visitorName: visitorName ?? this.visitorName,
      requestedAt: requestedAt ?? this.requestedAt,
      requestedStatus: requestedStatus ?? this.requestedStatus, // NEW
      status: status ?? this.status,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}

enum RequestStatus { pending, approved, denied }

extension RequestStatusExtension on RequestStatus {
  String get displayName {
    switch (this) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.approved:
        return 'Approved';
      case RequestStatus.denied:
        return 'Denied';
    }
  }

  String get emoji {
    switch (this) {
      case RequestStatus.pending:
        return '⏳';
      case RequestStatus.approved:
        return '✅';
      case RequestStatus.denied:
        return '❌';
    }
  }
}
