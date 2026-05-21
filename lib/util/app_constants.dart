class AppConstants {
  static const String appName = 'MoonJoin Cloud';
  static const double appVersion = 1.0;

  static const String fontFamily = 'Roboto';

  // Base URLs are resolved per-env in `lib/config/environment.dart`.
  // These constants only describe URI paths appended to the base URL.

  /// Merchant auth (existing on Laravel backend)
  static const String registerUri = '/api/merchant/register';
  static const String loginUri = '/api/merchant/login';
  static const String otpSendUri = '/api/merchant/otp/send';
  static const String otpVerifyUri = '/api/merchant/otp/verify';
  static const String googleAuthUri = '/api/merchant/auth/google';
  static const String forgotPasswordUri = '/api/merchant/forgot-password';
  static const String resetPasswordUri = '/api/merchant/reset-password';

  /// Merchant profile (BLOCKED on backend; client wired)
  static const String profileUri = '/api/merchant/profile';

  /// Wallet (BLOCKED on backend)
  static const String walletBalanceUri = '/api/merchant/wallet/balance';
  static const String walletTransactionsUri = '/api/merchant/wallet/transactions';
  static const String walletFundInitiateUri = '/api/merchant/wallet/fund/initiate';
  static const String walletVirtualAccountUri = '/api/merchant/wallet/virtual-account';

  /// API products & keys (BLOCKED on backend; logic exists as web routes)
  static const String apiProductsUri = '/api/merchant/api-products';
  static const String apiKeysUri = '/api/merchant/api-keys';
  static const String apiKeyRotateUri = '/api/merchant/api-keys/rotate';
  static const String apiKeyRevokeUri = '/api/merchant/api-keys/revoke';

  /// Webhook config (BLOCKED on backend)
  static const String webhookConfigUri = '/api/merchant/webhook-config';
  static const String webhookTestUri = '/api/merchant/webhooks/test';

  /// Partner delivery + webhook log (EXISTS on backend)
  static const String partnerOrdersUri = '/api/v1/partner/orders';
  static const String partnerWebhookDeliveriesUri =
      '/api/v1/partner/webhooks/deliveries';

  /// Deliveries (session-auth wrapper — BLOCKED on backend)
  static const String deliveriesUri = '/api/merchant/deliveries';

  /// Analytics (BLOCKED on backend)
  static const String analyticsSummaryUri = '/api/merchant/analytics/summary';
  static const String analyticsOrdersUri = '/api/merchant/analytics/orders';
  static const String analyticsSuccessRateUri =
      '/api/merchant/analytics/success-rate';
  static const String analyticsWebhooksUri =
      '/api/merchant/analytics/webhooks';

  /// Zones & branches (BLOCKED on backend)
  static const String zonesCheckUri = '/api/merchant/zones/check';
  static const String branchesUri = '/api/merchant/branches';

  /// Notifications (FCM token + listing)
  static const String notificationsUri = '/api/merchant/notifications';
  static const String fcmTokenUri = '/api/merchant/fcm-token';

  /// Shared-prefs keys (tenant-namespaced)
  static const String theme = 'mjcloud_theme';
  static const String token = 'mjcloud_token';
  static const String tokenType = 'mjcloud_token_type';
  static const String merchantId = 'mjcloud_merchant_id';
  static const String merchantEmail = 'mjcloud_merchant_email';
  static const String merchantName = 'mjcloud_merchant_name';
  static const String languageCode = 'mjcloud_language_code';
  static const String countryCode = 'mjcloud_country_code';
  static const String intro = 'mjcloud_intro_seen';
  static const String notification = 'mjcloud_notification';
  static const String notificationCount = 'mjcloud_notification_count';
  static const String acceptCookies = 'mjcloud_accept_cookies';
  static const String fcmToken = 'mjcloud_fcm_token';

  /// HTTP headers
  static const String localizationKey = 'X-localization';
  static const String authorization = 'Authorization';

  /// FCM topic
  static const String fcmTopic = 'mjcloud_tenants';

  /// MoonJoin Delivery API categories (single endpoint)
  static const List<String> moonjoinCategories = [
    'food',
    'grocery',
    'pharmacy',
    'fashion',
    'parcel',
  ];

  /// Modules Delivery API modules (separate endpoints)
  static const List<String> deliveryModules = [
    'fuel',
    'gas',
    'drink',
    'electronics',
    'market',
  ];

  /// Supported payment gateways for wallet funding.
  static const List<String> paymentProviders = [
    'paystack',
    'flutterwave',
    'monnify',
    '9psb',
  ];
}
