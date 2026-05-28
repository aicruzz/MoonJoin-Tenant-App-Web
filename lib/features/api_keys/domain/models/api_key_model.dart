/// Mirrors Phase A `App\Http\Resources\Merchant\ApiKeyResource`.
class ApiKeyModel {
  final int id;
  final String keyPrefix;
  final String lastFour;
  final String masked;
  final bool isActive;
  final bool plainSecretRevealed;
  final DateTime? lastUsedAt;
  final DateTime? revokedAt;
  final DateTime? createdAt;

  const ApiKeyModel({
    required this.id,
    required this.keyPrefix,
    required this.lastFour,
    required this.masked,
    required this.isActive,
    required this.plainSecretRevealed,
    required this.lastUsedAt,
    required this.revokedAt,
    required this.createdAt,
  });

  factory ApiKeyModel.fromJson(Map<String, dynamic> json) {
    return ApiKeyModel(
      id: _toInt(json['id']),
      keyPrefix: json['key_prefix']?.toString() ?? '',
      lastFour: json['last_four']?.toString() ?? '',
      masked: json['masked']?.toString() ?? '',
      isActive: json['is_active'] == true,
      plainSecretRevealed: json['plain_secret_revealed'] == true,
      lastUsedAt: _parseDate(json['last_used_at']),
      revokedAt: _parseDate(json['revoked_at']),
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

/// Returned only on POST `/api-keys` (mint) and POST `/api-keys/rotate`.
/// Contains the plaintext secret — shown once, never persisted.
class ApiKeyRevealModel {
  final ApiKeyModel credential;
  final String plainSecret;
  final String composedCredential;

  const ApiKeyRevealModel({
    required this.credential,
    required this.plainSecret,
    required this.composedCredential,
  });

  factory ApiKeyRevealModel.fromJson(Map<String, dynamic> json) {
    return ApiKeyRevealModel(
      credential: ApiKeyModel.fromJson(json),
      plainSecret: json['plain_secret']?.toString() ?? '',
      composedCredential: json['composed_credential']?.toString() ?? '',
    );
  }
}
