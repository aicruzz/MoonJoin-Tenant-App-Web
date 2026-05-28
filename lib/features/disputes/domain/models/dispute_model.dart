/// Mirrors Phase A `DisputeResource`.
///
/// Reason enum (Phase A controller validation): `not_delivered | wrong_item |
/// damaged | late | other`.
/// Status enum (Phase A `DeliveryDispute` constants): `open | investigating |
/// resolved_refund | resolved_no_refund | closed`.
class DisputeModel {
  final int id;
  final int orderId;
  final String openedBy;
  final String reason;
  final String? description;
  final String status;
  final List<dynamic>? attachments;
  final String? resolutionNotes;
  final DateTime? resolvedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DisputeModel({
    required this.id,
    required this.orderId,
    required this.openedBy,
    required this.reason,
    required this.description,
    required this.status,
    required this.attachments,
    required this.resolutionNotes,
    required this.resolvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: _toInt(json['id']),
      orderId: _toInt(json['order_id']),
      openedBy: json['opened_by']?.toString() ?? 'merchant',
      reason: json['reason']?.toString() ?? 'other',
      description: json['description']?.toString(),
      status: json['status']?.toString() ?? 'open',
      attachments: json['attachments'] is List ? json['attachments'] : null,
      resolutionNotes: json['resolution_notes']?.toString(),
      resolvedAt: _parseDate(json['resolved_at']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
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
