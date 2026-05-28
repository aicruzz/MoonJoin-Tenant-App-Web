/// Mirrors Phase A `DeliveryResource` (full detail) and the same shape on
/// list endpoints. Safe num/string coercion throughout.
class DeliveryModel {
  final int id;
  final int? apiProductId;
  final String orderStatus;
  final String? partnerReference;
  final String? moduleKey;

  final DeliveryPoint pickup;
  final DeliveryPoint delivery;
  final DeliveryCustomer customer;
  final DeliveryPricing pricing;
  final DeliveryEscrow? escrow;

  final int? deliveryManId;
  final bool needsManualDispatch;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeliveryModel({
    required this.id,
    required this.apiProductId,
    required this.orderStatus,
    required this.partnerReference,
    required this.moduleKey,
    required this.pickup,
    required this.delivery,
    required this.customer,
    required this.pricing,
    required this.escrow,
    required this.deliveryManId,
    required this.needsManualDispatch,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Terminal statuses — Phase A backend uses `delivered / canceled / refunded`;
  /// guard list for safety on `cancelled / failed` spelling drift.
  static const terminalStatuses = <String>{
    'delivered',
    'canceled',
    'cancelled',
    'refunded',
    'failed',
  };

  bool get isTerminal => terminalStatuses.contains(orderStatus);

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? sub(String k) {
      final v = json[k];
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return Map<String, dynamic>.from(v);
      return null;
    }

    return DeliveryModel(
      id: _toInt(json['id']),
      apiProductId: json['api_product_id'] != null
          ? _toInt(json['api_product_id'])
          : null,
      orderStatus: json['order_status']?.toString() ?? 'pending',
      partnerReference: json['partner_reference']?.toString(),
      moduleKey: json['module_key']?.toString(),
      pickup: DeliveryPoint.fromJson(sub('pickup')),
      delivery: DeliveryPoint.fromJson(sub('delivery')),
      customer: DeliveryCustomer.fromJson(sub('customer')),
      pricing: DeliveryPricing.fromJson(sub('pricing')),
      escrow: sub('escrow') != null
          ? DeliveryEscrow.fromJson(sub('escrow')!)
          : null,
      deliveryManId: json['delivery_man_id'] != null
          ? _toInt(json['delivery_man_id'])
          : null,
      needsManualDispatch: json['needs_manual_dispatch'] == true,
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

class DeliveryPoint {
  final String? address;
  final double? lat;
  final double? lng;
  const DeliveryPoint({this.address, this.lat, this.lng});

  factory DeliveryPoint.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DeliveryPoint();
    return DeliveryPoint(
      address: json['address']?.toString(),
      lat: json['lat'] != null ? DeliveryModel._toDouble(json['lat']) : null,
      lng: json['lng'] != null ? DeliveryModel._toDouble(json['lng']) : null,
    );
  }
}

class DeliveryCustomer {
  final String? name;
  final String? phone;
  const DeliveryCustomer({this.name, this.phone});

  factory DeliveryCustomer.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DeliveryCustomer();
    return DeliveryCustomer(
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
    );
  }
}

class DeliveryPricing {
  final double orderAmount;
  final double deliveryCharge;
  final double? distanceKm;
  final double? durationMin;

  const DeliveryPricing({
    required this.orderAmount,
    required this.deliveryCharge,
    required this.distanceKm,
    required this.durationMin,
  });

  factory DeliveryPricing.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DeliveryPricing(
          orderAmount: 0,
          deliveryCharge: 0,
          distanceKm: null,
          durationMin: null);
    }
    return DeliveryPricing(
      orderAmount: DeliveryModel._toDouble(json['order_amount']),
      deliveryCharge: DeliveryModel._toDouble(json['delivery_charge']),
      distanceKm: json['distance_km'] != null
          ? DeliveryModel._toDouble(json['distance_km'])
          : null,
      durationMin: json['duration_min'] != null
          ? DeliveryModel._toDouble(json['duration_min'])
          : null,
    );
  }
}

class DeliveryEscrow {
  final int? holdId;
  final String? status;
  final double amount;
  final DateTime? heldAt;
  final DateTime? releasedAt;

  const DeliveryEscrow({
    required this.holdId,
    required this.status,
    required this.amount,
    required this.heldAt,
    required this.releasedAt,
  });

  factory DeliveryEscrow.fromJson(Map<String, dynamic> json) {
    return DeliveryEscrow(
      holdId: json['hold_id'] != null
          ? DeliveryModel._toInt(json['hold_id'])
          : null,
      status: json['status']?.toString(),
      amount: DeliveryModel._toDouble(json['amount']),
      heldAt: DeliveryModel._parseDate(json['held_at']),
      releasedAt: DeliveryModel._parseDate(json['released_at']),
    );
  }
}
