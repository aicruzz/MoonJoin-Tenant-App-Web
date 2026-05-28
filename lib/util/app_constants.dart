class AppConstants {
  static const String appName = 'MoonJoin Cloud';
  static const double appVersion = 1.0;

  static const String fontFamily = 'Roboto';

  // Base URLs are resolved per-env in `lib/config/environment.dart`.
  // These constants describe URI paths appended to the base URL.
  //
  // All merchant REST endpoints live under `/api/v1/merchant/*` per the
  // Phase A controllers in `app/Http/Controllers/Api/V1/Merchant/`.

  /// Merchant auth (Phase A — EXISTS).
  static const String registerUri = '/api/v1/merchant/register';
  static const String loginUri = '/api/v1/merchant/login';
  static const String otpSendUri = '/api/v1/merchant/otp/send';
  static const String otpVerifyUri = '/api/v1/merchant/otp/verify';
  static const String googleAuthUri = '/api/v1/merchant/auth/google';
  static const String forgotPasswordUri = '/api/v1/merchant/forgot-password';
  static const String resetPasswordUri = '/api/v1/merchant/reset-password';

  /// Merchant profile.
  static const String profileUri = '/api/v1/merchant/profile';

  /// Wallet.
  static const String walletBalanceUri = '/api/v1/merchant/wallet/balance';
  static const String walletTransactionsUri =
      '/api/v1/merchant/wallet/transactions';
  static const String walletFundInitiateUri =
      '/api/v1/merchant/wallet/fund/initiate';
  static const String walletVirtualAccountUri =
      '/api/v1/merchant/wallet/virtual-account';

  /// API products. Per-product sub-paths are composed inline by the repository
  /// (`<apiProductsUri>/{id}/...`) since they all require an interpolated id.
  static const String apiProductsUri = '/api/v1/merchant/api-products';

  /// Partner delivery + webhook log (EXISTS, partner-key auth).
  static const String partnerOrdersUri = '/api/v1/partner/orders';
  static const String partnerWebhookDeliveriesUri =
      '/api/v1/partner/webhooks/deliveries';

  /// Deliveries (session-auth wrapper).
  static const String deliveriesUri = '/api/v1/merchant/deliveries';

  /// Analytics.
  static const String analyticsSummaryUri =
      '/api/v1/merchant/analytics/summary';
  static const String analyticsOrdersUri =
      '/api/v1/merchant/analytics/orders';
  static const String analyticsSuccessRateUri =
      '/api/v1/merchant/analytics/success-rate';
  static const String analyticsWebhooksUri =
      '/api/v1/merchant/analytics/webhooks';

  /// Zones & branches.
  static const String zonesCheckUri = '/api/v1/merchant/zones/check';
  static const String branchesUri = '/api/v1/merchant/branches';

  /// Notifications + FCM.
  static const String notificationsUri = '/api/v1/merchant/notifications';
  static const String fcmTokenUri = '/api/v1/merchant/fcm-token';

  /// Disputes + tenant-initiated reassignment.
  static const String disputesUri = '/api/v1/merchant/disputes';
  static const String orderReassignmentUri =
      '/api/v1/merchant/orders'; // composed: $orderReassignmentUri/{id}/reassign-request

  /// Shared-prefs keys (tenant-namespaced).
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

  /// HTTP headers.
  static const String localizationKey = 'X-localization';
  static const String authorization = 'Authorization';

  /// FCM topic.
  static const String fcmTopic = 'mjcloud_tenants';

  /// MoonJoin Delivery API categories (single endpoint).
  static const List<String> moonjoinCategories = [
    'food',
    'grocery',
    'pharmacy',
    'fashion',
    'parcel',
  ];

  /// Modules Delivery API modules (separate endpoints).
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

  /// Supported API product types per Phase A controller validation.
  static const List<String> apiProductTypes = [
    'moonjoin_delivery',
    'modules_delivery',
  ];

  /// API product status values (Phase A `ApiProductService` lifecycle).
  static const List<String> apiProductStatuses = [
    'draft',
    'pending',
    'active',
    'suspended',
  ];

  /// Webhook delivery statuses (Phase A `ApiProductWebhookDelivery` constants).
  static const List<String> webhookStatuses = [
    'pending',
    'delivered',
    'failed',
    'exhausted',
  ];
}
