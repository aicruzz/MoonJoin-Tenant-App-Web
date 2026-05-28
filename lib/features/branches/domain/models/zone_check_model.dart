/// Mirrors Phase A `ZoneController::check` response (inside `{data: ...}`):
/// ```
/// {"ok": true, "zone_id": 7, "zone_name": "Lekki", "lat": ..., "lng": ...}
/// // or
/// {"ok": false, "reason": "unsupported_zone", "lat": ..., "lng": ...}
/// ```
class ZoneCheckModel {
  final bool ok;
  final int? zoneId;
  final String? zoneName;
  final String? reason;
  final double lat;
  final double lng;

  const ZoneCheckModel({
    required this.ok,
    required this.zoneId,
    required this.zoneName,
    required this.reason,
    required this.lat,
    required this.lng,
  });

  factory ZoneCheckModel.fromJson(Map<String, dynamic> json) {
    return ZoneCheckModel(
      ok: json['ok'] == true,
      zoneId: json['zone_id'] != null
          ? (json['zone_id'] is num
              ? (json['zone_id'] as num).toInt()
              : int.tryParse('${json['zone_id']}'))
          : null,
      zoneName: json['zone_name']?.toString(),
      reason: json['reason']?.toString(),
      lat: _toDouble(json['lat']),
      lng: _toDouble(json['lng']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0;
    return 0;
  }
}
