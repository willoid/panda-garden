import 'user.dart';

class VisitorRequest {
  final String id;
  final String visitorId;
  final String visitorName;
  final DateTime requestedAt;
  RequestStatus status;
  final DateTime? respondedAt;

  VisitorRequest({
    required this.id,
    required this.visitorId,
    required this.visitorName,
    required this.requestedAt,
    this.status = RequestStatus.pending,
    this.respondedAt,
  });

  factory VisitorRequest.fromJson(Map<String, dynamic> json) {
    return VisitorRequest(
      id: json['id'],
      visitorId: json['visitorId'],
      visitorName: json['visitorName'],
      requestedAt: DateTime.parse(json['requestedAt']),
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
      'status': status.toString().split('.').last,
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  VisitorRequest copyWith({
    String? id,
    String? visitorId,
    String? visitorName,
    DateTime? requestedAt,
    RequestStatus? status,
    DateTime? respondedAt,
  }) {
    return VisitorRequest(
      id: id ?? this.id,
      visitorId: visitorId ?? this.visitorId,
      visitorName: visitorName ?? this.visitorName,
      requestedAt: requestedAt ?? this.requestedAt,
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
