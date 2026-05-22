/// Mirrors the Phase A `WalletTransactionResource` envelope.
///
/// Type values (from Phase A `MerchantWalletTransaction` constants):
/// funding | hold | charge | release | refund | reversal.
/// Direction: credit | debit.
class WalletTransactionModel {
  final int id;
  final String type;
  final String direction;
  final double amount;
  final double balanceAfter;
  final double pendingHoldsAfter;
  final String? reference;
  final String? gateway;
  final String? gatewayReference;
  final int? orderId;
  final int? escrowHoldId;
  final Map<String, dynamic>? metadata;
  final DateTime? createdAt;

  const WalletTransactionModel({
    required this.id,
    required this.type,
    required this.direction,
    required this.amount,
    required this.balanceAfter,
    required this.pendingHoldsAfter,
    required this.reference,
    required this.gateway,
    required this.gatewayReference,
    required this.orderId,
    required this.escrowHoldId,
    required this.metadata,
    required this.createdAt,
  });

  bool get isCredit => direction == 'credit';

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: _toInt(json['id']),
      type: json['type']?.toString() ?? 'unknown',
      direction: json['direction']?.toString() ?? 'debit',
      amount: _toDouble(json['amount']),
      balanceAfter: _toDouble(json['balance_after']),
      pendingHoldsAfter: _toDouble(json['pending_holds_after']),
      reference: json['reference']?.toString(),
      gateway: json['gateway']?.toString(),
      gatewayReference: json['gateway_reference']?.toString(),
      orderId: json['order_id'] != null ? _toInt(json['order_id']) : null,
      escrowHoldId:
          json['escrow_hold_id'] != null ? _toInt(json['escrow_hold_id']) : null,
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      createdAt: json['created_at'] is String && (json['created_at'] as String).isNotEmpty
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}
