import 'package:equatable/equatable.dart';

/// Notification Model
///
/// Represents a notification from Laravel's notifications system
class NotificationModel extends Equatable {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final String? readAt;
  final String createdAt;
  final String updatedAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.data,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Check if notification is read
  bool get isRead => readAt != null;

  /// Check if notification is unread
  bool get isUnread => readAt == null;

  /// Get notification title from data
  String get title => data['title'] as String? ?? 'Notification';

  /// Get notification message from data
  String get message => data['message'] as String? ?? '';

  /// Get notification icon from data
  String? get icon => data['icon'] as String?;

  /// Get notification action type from data
  String? get actionType => data['action_type'] as String?;

  /// Get notification action data from data
  Map<String, dynamic>? get actionData =>
      data['action_data'] as Map<String, dynamic>?;

  /// Get short type name (last part after \\)
  String get shortType {
    final parts = type.split('\\');
    return parts.last;
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      type: json['type'] as String,
      data: json['data'] as Map<String, dynamic>? ?? {},
      readAt: json['read_at'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'read_at': readAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Copy with
  NotificationModel copyWith({
    String? id,
    String? type,
    Map<String, dynamic>? data,
    String? readAt,
    String? createdAt,
    String? updatedAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      type: type ?? this.type,
      data: data ?? this.data,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        data,
        readAt,
        createdAt,
        updatedAt,
      ];
}
