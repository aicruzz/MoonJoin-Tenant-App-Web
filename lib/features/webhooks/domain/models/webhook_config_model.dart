/// Mirrors Phase A `WebhookController::show` response (inside `{data: ...}`):
/// ```
/// {"webhook_url": "https://...", "webhook_secret_present": true,
///  "rate_limit_per_minute": 60}
/// ```
class WebhookConfigModel {
  final String? webhookUrl;
  final bool webhookSecretPresent;
  final int rateLimitPerMinute;
  final bool webhookSecretRotated; // only set after PUT

  const WebhookConfigModel({
    required this.webhookUrl,
    required this.webhookSecretPresent,
    required this.rateLimitPerMinute,
    this.webhookSecretRotated = false,
  });

  factory WebhookConfigModel.fromJson(Map<String, dynamic> json) {
    return WebhookConfigModel(
      webhookUrl: json['webhook_url']?.toString(),
      webhookSecretPresent: json['webhook_secret_present'] == true,
      rateLimitPerMinute: json['rate_limit_per_minute'] is num
          ? (json['rate_limit_per_minute'] as num).toInt()
          : int.tryParse('${json['rate_limit_per_minute']}') ?? 60,
      webhookSecretRotated: json['webhook_secret_rotated'] == true,
    );
  }
}
