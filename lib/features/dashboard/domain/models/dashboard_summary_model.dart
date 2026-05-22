/// Mirrors the Phase A `App\Http\Controllers\Api\V1\Merchant\AnalyticsController::summary`
/// response envelope.
///
/// Wire format (inside `{data: ...}`):
/// ```
/// {
///   "range":  {"from": "2026-05-22", "to": "2026-05-22"},
///   "wallet": {"balance": 0, "pending_holds": 0, "currency": "NGN"},
///   "deliveries": {"orders_total": 0, "orders_delivered": 0, "orders_cancelled": 0},
///   "spending":   {"delivery_charges_sum": 0, "escrow_released_sum": 0},
///   "webhooks":   {"webhook_deliveries_total": 0, "webhook_failures": 0},
///   "module_breakdown": [{"module_id": 1, "count": 12}, ...]
/// }
/// ```
class DashboardSummaryModel {
  final DateTime? rangeFrom;
  final DateTime? rangeTo;

  final double walletBalance;
  final double walletPendingHolds;
  final String walletCurrency;

  final int ordersTotal;
  final int ordersDelivered;
  final int ordersCancelled;

  final double deliveryChargesSum;
  final double escrowReleasedSum;

  final int webhookDeliveriesTotal;
  final int webhookFailures;

  final List<ModuleBreakdownEntry> moduleBreakdown;

  const DashboardSummaryModel({
    required this.rangeFrom,
    required this.rangeTo,
    required this.walletBalance,
    required this.walletPendingHolds,
    required this.walletCurrency,
    required this.ordersTotal,
    required this.ordersDelivered,
    required this.ordersCancelled,
    required this.deliveryChargesSum,
    required this.escrowReleasedSum,
    required this.webhookDeliveriesTotal,
    required this.webhookFailures,
    required this.moduleBreakdown,
  });

  factory DashboardSummaryModel.empty() => const DashboardSummaryModel(
        rangeFrom: null,
        rangeTo: null,
        walletBalance: 0,
        walletPendingHolds: 0,
        walletCurrency: '',
        ordersTotal: 0,
        ordersDelivered: 0,
        ordersCancelled: 0,
        deliveryChargesSum: 0,
        escrowReleasedSum: 0,
        webhookDeliveriesTotal: 0,
        webhookFailures: 0,
        moduleBreakdown: [],
      );

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    final range = json['range'] is Map<String, dynamic>
        ? json['range'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final wallet = json['wallet'] is Map<String, dynamic>
        ? json['wallet'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final deliveries = json['deliveries'] is Map<String, dynamic>
        ? json['deliveries'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final spending = json['spending'] is Map<String, dynamic>
        ? json['spending'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final webhooks = json['webhooks'] is Map<String, dynamic>
        ? json['webhooks'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final breakdownRaw = json['module_breakdown'];
    final breakdown = (breakdownRaw is List)
        ? breakdownRaw
            .whereType<Map>()
            .map((e) => ModuleBreakdownEntry.fromJson(
                Map<String, dynamic>.from(e)))
            .toList(growable: false)
        : const <ModuleBreakdownEntry>[];

    return DashboardSummaryModel(
      rangeFrom: _parseDate(range['from']),
      rangeTo: _parseDate(range['to']),
      walletBalance: _toDouble(wallet['balance']),
      walletPendingHolds: _toDouble(wallet['pending_holds']),
      walletCurrency: wallet['currency']?.toString() ?? '',
      ordersTotal: _toInt(deliveries['orders_total']),
      ordersDelivered: _toInt(deliveries['orders_delivered']),
      ordersCancelled: _toInt(deliveries['orders_cancelled']),
      deliveryChargesSum: _toDouble(spending['delivery_charges_sum']),
      escrowReleasedSum: _toDouble(spending['escrow_released_sum']),
      webhookDeliveriesTotal: _toInt(webhooks['webhook_deliveries_total']),
      webhookFailures: _toInt(webhooks['webhook_failures']),
      moduleBreakdown: breakdown,
    );
  }

  /// Successful deliveries as a percentage of total. Returns null when there
  /// is no traffic yet so the UI can render an em-dash instead of `0%`.
  double? get successRatePercent {
    if (ordersTotal <= 0) return null;
    return (ordersDelivered / ordersTotal) * 100;
  }

  /// Webhook delivery health as a percentage. Null when no events yet.
  double? get webhookHealthPercent {
    if (webhookDeliveriesTotal <= 0) return null;
    final ok = webhookDeliveriesTotal - webhookFailures;
    return (ok / webhookDeliveriesTotal) * 100;
  }

  static DateTime? _parseDate(dynamic v) {
    if (v is String && v.isNotEmpty) {
      return DateTime.tryParse(v);
    }
    return null;
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

class ModuleBreakdownEntry {
  final int moduleId;
  final int count;
  const ModuleBreakdownEntry({required this.moduleId, required this.count});

  factory ModuleBreakdownEntry.fromJson(Map<String, dynamic> json) =>
      ModuleBreakdownEntry(
        moduleId: DashboardSummaryModel._toInt(json['module_id']),
        count: DashboardSummaryModel._toInt(json['count']),
      );
}
