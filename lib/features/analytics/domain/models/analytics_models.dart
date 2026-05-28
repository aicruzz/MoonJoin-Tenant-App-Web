// Models for the Phase A analytics endpoints (orders, success-rate, webhooks).
// The summary endpoint is already consumed by `DashboardController`; the
// analytics screen reads from there for the module-mix donut.

class AnalyticsRange {
  final DateTime from;
  final DateTime to;
  const AnalyticsRange({required this.from, required this.to});

  factory AnalyticsRange.fromJson(Map<String, dynamic>? json) {
    final now = DateTime.now();
    if (json == null) {
      return AnalyticsRange(from: now.subtract(const Duration(days: 6)), to: now);
    }
    return AnalyticsRange(
      from: DateTime.tryParse(json['from']?.toString() ?? '') ??
          now.subtract(const Duration(days: 6)),
      to: DateTime.tryParse(json['to']?.toString() ?? '') ?? now,
    );
  }
}

class OrdersSeriesPoint {
  final DateTime date;
  final int ordersTotal;
  final int ordersDelivered;
  final int ordersCancelled;
  final double deliveryChargesSum;

  const OrdersSeriesPoint({
    required this.date,
    required this.ordersTotal,
    required this.ordersDelivered,
    required this.ordersCancelled,
    required this.deliveryChargesSum,
  });

  factory OrdersSeriesPoint.fromJson(Map<String, dynamic> json) {
    return OrdersSeriesPoint(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      ordersTotal: _toInt(json['orders_total']),
      ordersDelivered: _toInt(json['orders_delivered']),
      ordersCancelled: _toInt(json['orders_cancelled']),
      deliveryChargesSum: _toDouble(json['delivery_charges_sum']),
    );
  }
}

class AnalyticsOrdersSeries {
  final AnalyticsRange range;
  final List<OrdersSeriesPoint> points;
  const AnalyticsOrdersSeries({required this.range, required this.points});

  factory AnalyticsOrdersSeries.fromJson(Map<String, dynamic> json) {
    final range = json['range'] is Map
        ? AnalyticsRange.fromJson(Map<String, dynamic>.from(json['range'] as Map))
        : AnalyticsRange.fromJson(null);
    final series = json['series'];
    final points = series is List
        ? series
            .whereType<Map>()
            .map((e) => OrdersSeriesPoint.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false)
        : const <OrdersSeriesPoint>[];
    return AnalyticsOrdersSeries(range: range, points: points);
  }
}

class AnalyticsSuccessRate {
  final AnalyticsRange range;
  final int ordersTotal;
  final int ordersDelivered;
  final int ordersCancelled;
  final double successRatePercent;

  const AnalyticsSuccessRate({
    required this.range,
    required this.ordersTotal,
    required this.ordersDelivered,
    required this.ordersCancelled,
    required this.successRatePercent,
  });

  factory AnalyticsSuccessRate.fromJson(Map<String, dynamic> json) {
    final range = json['range'] is Map
        ? AnalyticsRange.fromJson(Map<String, dynamic>.from(json['range'] as Map))
        : AnalyticsRange.fromJson(null);
    return AnalyticsSuccessRate(
      range: range,
      ordersTotal: _toInt(json['orders_total']),
      ordersDelivered: _toInt(json['orders_delivered']),
      ordersCancelled: _toInt(json['orders_cancelled']),
      successRatePercent: _toDouble(json['success_rate_percent']),
    );
  }
}

class WebhookSeriesPoint {
  final DateTime date;
  final int deliveriesTotal;
  final int failures;
  const WebhookSeriesPoint({
    required this.date,
    required this.deliveriesTotal,
    required this.failures,
  });

  factory WebhookSeriesPoint.fromJson(Map<String, dynamic> json) {
    return WebhookSeriesPoint(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      deliveriesTotal: _toInt(json['webhook_deliveries_total']),
      failures: _toInt(json['webhook_failures']),
    );
  }
}

class WebhookStatusEntry {
  final String status;
  final int count;
  const WebhookStatusEntry({required this.status, required this.count});

  factory WebhookStatusEntry.fromJson(Map<String, dynamic> json) {
    return WebhookStatusEntry(
      status: json['status']?.toString() ?? 'unknown',
      count: _toInt(json['count']),
    );
  }
}

class AnalyticsWebhookSeries {
  final AnalyticsRange range;
  final List<WebhookSeriesPoint> series;
  final List<WebhookStatusEntry> statusBreakdown;

  const AnalyticsWebhookSeries({
    required this.range,
    required this.series,
    required this.statusBreakdown,
  });

  factory AnalyticsWebhookSeries.fromJson(Map<String, dynamic> json) {
    final range = json['range'] is Map
        ? AnalyticsRange.fromJson(Map<String, dynamic>.from(json['range'] as Map))
        : AnalyticsRange.fromJson(null);
    final rawSeries = json['series'];
    final rawBreakdown = json['status_breakdown'];
    return AnalyticsWebhookSeries(
      range: range,
      series: rawSeries is List
          ? rawSeries
              .whereType<Map>()
              .map((e) =>
                  WebhookSeriesPoint.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const [],
      statusBreakdown: rawBreakdown is List
          ? rawBreakdown
              .whereType<Map>()
              .map((e) =>
                  WebhookStatusEntry.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const [],
    );
  }
}

int _toInt(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? 0;
  return 0;
}

double _toDouble(dynamic v) {
  if (v is double) return v;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0;
  return 0;
}
