/// Mirrors the Phase A `App\Http\Resources\Merchant\ApiProductResource`.
///
/// Wire format (inside `{data: ...}`):
/// ```
/// {
///   "id": 1, "name": "Acme Delivery", "slug": "acme-delivery",
///   "product_type": "moonjoin_delivery" | "modules_delivery",
///   "status": "draft" | "pending" | "active" | "suspended",
///   "supported_categories": ["food","parcel", ...]?,
///   "webhook_url": "https://..."?,
///   "rate_limit_per_minute": 60,
///   "modules": [{"id": ..., "module_key": "fuel", "is_active": true, "dm_vehicle_id": null}],
///   "active_credentials_count": 1,
///   "created_at": "...", "updated_at": "..."
/// }
/// ```
class ApiProductModel {
  final int id;
  final String name;
  final String? slug;
  final String productType;
  final String status;
  final List<String> supportedCategories;
  final String? webhookUrl;
  final int rateLimitPerMinute;
  final List<ApiProductModuleEntry> modules;
  final int activeCredentialsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ApiProductModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.productType,
    required this.status,
    required this.supportedCategories,
    required this.webhookUrl,
    required this.rateLimitPerMinute,
    required this.modules,
    required this.activeCredentialsCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ApiProductModel.fromJson(Map<String, dynamic> json) {
    final modulesRaw = json['modules'];
    final categoriesRaw = json['supported_categories'];
    return ApiProductModel(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      productType: json['product_type']?.toString() ?? 'moonjoin_delivery',
      status: json['status']?.toString() ?? 'draft',
      supportedCategories: categoriesRaw is List
          ? categoriesRaw.map((e) => e.toString()).toList(growable: false)
          : const [],
      webhookUrl: json['webhook_url']?.toString(),
      rateLimitPerMinute: _toInt(json['rate_limit_per_minute']),
      modules: modulesRaw is List
          ? modulesRaw
              .whereType<Map>()
              .map((e) =>
                  ApiProductModuleEntry.fromJson(Map<String, dynamic>.from(e)))
              .toList(growable: false)
          : const [],
      activeCredentialsCount: _toInt(json['active_credentials_count']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  bool get isModulesDelivery => productType == 'modules_delivery';

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

class ApiProductModuleEntry {
  final int id;
  final String moduleKey;
  final bool isActive;
  final int? dmVehicleId;

  const ApiProductModuleEntry({
    required this.id,
    required this.moduleKey,
    required this.isActive,
    required this.dmVehicleId,
  });

  factory ApiProductModuleEntry.fromJson(Map<String, dynamic> json) {
    return ApiProductModuleEntry(
      id: ApiProductModel._toInt(json['id']),
      moduleKey: json['module_key']?.toString() ?? '',
      isActive: json['is_active'] == true,
      dmVehicleId: json['dm_vehicle_id'] != null
          ? ApiProductModel._toInt(json['dm_vehicle_id'])
          : null,
    );
  }
}
