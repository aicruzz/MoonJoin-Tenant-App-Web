/// Mirrors the Phase A `WalletBalanceResource` envelope.
///
/// Wire format (inside `{data: ...}`):
/// ```
/// {"balance": 0, "pending_holds": 0, "total_equity": 0,
///  "currency": "NGN", "updated_at": "2026-05-22T00:00:00+00:00"}
/// ```
class WalletBalanceModel {
  final double balance;
  final double pendingHolds;
  final double totalEquity;
  final String currency;
  final DateTime? updatedAt;

  const WalletBalanceModel({
    required this.balance,
    required this.pendingHolds,
    required this.totalEquity,
    required this.currency,
    required this.updatedAt,
  });

  factory WalletBalanceModel.empty() => const WalletBalanceModel(
        balance: 0,
        pendingHolds: 0,
        totalEquity: 0,
        currency: 'NGN',
        updatedAt: null,
      );

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      balance: _toDouble(json['balance']),
      pendingHolds: _toDouble(json['pending_holds']),
      totalEquity:
          _toDouble(json['total_equity'] ?? json['balance']),
      currency: json['currency']?.toString() ?? 'NGN',
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }
}
