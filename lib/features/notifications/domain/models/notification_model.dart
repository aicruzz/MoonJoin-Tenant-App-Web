/// Mirrors Phase A `NotificationResource`.
class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String? body;
  final String? actionUrl;
  final Map<String, dynamic>? payload;
  final bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.actionUrl,
    required this.payload,
    required this.isRead,
    required this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: _toInt(json['id']),
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString(),
      actionUrl: json['action_url']?.toString(),
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : null,
      isRead: json['is_read'] == true,
      readAt: _parseDate(json['read_at']),
      createdAt: _parseDate(json['created_at']),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
