/// Mirrors Phase A `WebhookDeliveryResource`:
/// ```
/// {
///   "id": 1, "api_product_id": 1, "order_id": 42, "event_type": "delivery.created",
///   "status": "pending" | "delivered" | "failed" | "exhausted",
///   "attempts": 1, "last_response_status": 200,
///   "next_retry_at": "...", "delivered_at": "...", "created_at": "..."
/// }
/// ```
class WebhookDeliveryModel {
  final int id;
  final int apiProductId;
  final int? orderId;
  final String eventType;
  final String status;
  final int attempts;
  final int? lastResponseStatus;
  final DateTime? nextRetryAt;
  final DateTime? deliveredAt;
  final DateTime? createdAt;

  const WebhookDeliveryModel({
    required this.id,
    required this.apiProductId,
    required this.orderId,
    required this.eventType,
    required this.status,
    required this.attempts,
    required this.lastResponseStatus,
    required this.nextRetryAt,
    required this.deliveredAt,
    required this.createdAt,
  });

  bool get isTerminal =>
      status == 'delivered' || status == 'exhausted';

  factory WebhookDeliveryModel.fromJson(Map<String, dynamic> json) {
    return WebhookDeliveryModel(
      id: _toInt(json['id']),
      apiProductId: _toInt(json['api_product_id']),
      orderId: json['order_id'] != null ? _toInt(json['order_id']) : null,
      eventType: json['event_type']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      attempts: _toInt(json['attempts']),
      lastResponseStatus: json['last_response_status'] != null
          ? _toInt(json['last_response_status'])
          : null,
      nextRetryAt: _parseDate(json['next_retry_at']),
      deliveredAt: _parseDate(json['delivered_at']),
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
