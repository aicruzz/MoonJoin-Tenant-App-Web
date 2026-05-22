/// Page metadata returned by Phase A merchant REST collection endpoints.
///
/// Wire format: `{"data": [...], "meta": {"offset": 0, "limit": 20, "total": 123}}`.
class PageMeta {
  final int offset;
  final int limit;
  final int total;

  const PageMeta({
    required this.offset,
    required this.limit,
    required this.total,
  });

  factory PageMeta.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const PageMeta(offset: 0, limit: 0, total: 0);
    }
    return PageMeta(
      offset: _toInt(json['offset']),
      limit: _toInt(json['limit']),
      total: _toInt(json['total']),
    );
  }

  bool get hasMore => offset + limit < total;
  int get nextOffset => offset + limit;

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }
}

/// Parsed envelope for a paginated REST response.
class PageEnvelope<T> {
  final List<T> data;
  final PageMeta meta;
  const PageEnvelope({required this.data, required this.meta});
}
