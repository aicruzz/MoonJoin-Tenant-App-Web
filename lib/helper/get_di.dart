import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/common/controllers/localization_controller.dart';
import 'package:moonjoin_cloud/common/controllers/splash_controller.dart';
import 'package:moonjoin_cloud/common/controllers/theme_controller.dart';
import 'package:moonjoin_cloud/config/environment.dart';
import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/features/auth/domain/repositories/auth_repository.dart';
import 'package:moonjoin_cloud/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:moonjoin_cloud/features/auth/domain/services/auth_service.dart';
import 'package:moonjoin_cloud/features/auth/domain/services/auth_service_interface.dart';
import 'package:moonjoin_cloud/features/dashboard/controllers/dashboard_controller.dart';
import 'package:moonjoin_cloud/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:moonjoin_cloud/features/dashboard/domain/repositories/dashboard_repository_interface.dart';
import 'package:moonjoin_cloud/features/dashboard/domain/services/dashboard_service.dart';
import 'package:moonjoin_cloud/features/dashboard/domain/services/dashboard_service_interface.dart';
import 'package:moonjoin_cloud/features/wallet/controllers/wallet_controller.dart';
import 'package:moonjoin_cloud/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:moonjoin_cloud/features/wallet/domain/repositories/wallet_repository_interface.dart';
import 'package:moonjoin_cloud/features/wallet/domain/services/wallet_service.dart';
import 'package:moonjoin_cloud/features/wallet/domain/services/wallet_service_interface.dart';
import 'package:moonjoin_cloud/features/api_products/controllers/api_products_controller.dart';
import 'package:moonjoin_cloud/features/api_products/domain/repositories/api_product_repository.dart';
import 'package:moonjoin_cloud/features/api_products/domain/repositories/api_product_repository_interface.dart';
import 'package:moonjoin_cloud/features/api_products/domain/services/api_product_service.dart';
import 'package:moonjoin_cloud/features/api_products/domain/services/api_product_service_interface.dart';
import 'package:moonjoin_cloud/features/api_keys/controllers/api_keys_controller.dart';
import 'package:moonjoin_cloud/features/api_keys/domain/repositories/api_key_repository.dart';
import 'package:moonjoin_cloud/features/api_keys/domain/repositories/api_key_repository_interface.dart';
import 'package:moonjoin_cloud/features/api_keys/domain/services/api_key_service.dart';
import 'package:moonjoin_cloud/features/api_keys/domain/services/api_key_service_interface.dart';
import 'package:moonjoin_cloud/features/webhooks/controllers/webhook_controller.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/repositories/webhook_repository.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/repositories/webhook_repository_interface.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/services/webhook_service.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/services/webhook_service_interface.dart';
import 'package:moonjoin_cloud/features/deliveries/controllers/deliveries_controller.dart';
import 'package:moonjoin_cloud/features/deliveries/controllers/delivery_detail_controller.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/repositories/delivery_repository.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/repositories/delivery_repository_interface.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/services/delivery_service.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/services/delivery_service_interface.dart';
import 'package:moonjoin_cloud/features/analytics/controllers/analytics_controller.dart';
import 'package:moonjoin_cloud/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:moonjoin_cloud/features/analytics/domain/repositories/analytics_repository_interface.dart';
import 'package:moonjoin_cloud/features/analytics/domain/services/analytics_service.dart';
import 'package:moonjoin_cloud/features/analytics/domain/services/analytics_service_interface.dart';
import 'package:moonjoin_cloud/features/branches/controllers/branches_controller.dart';
import 'package:moonjoin_cloud/features/branches/controllers/zone_check_controller.dart';
import 'package:moonjoin_cloud/features/branches/domain/repositories/branch_repository.dart';
import 'package:moonjoin_cloud/features/branches/domain/repositories/branch_repository_interface.dart';
import 'package:moonjoin_cloud/features/branches/domain/repositories/zone_repository.dart';
import 'package:moonjoin_cloud/features/branches/domain/repositories/zone_repository_interface.dart';
import 'package:moonjoin_cloud/features/branches/domain/services/branch_service.dart';
import 'package:moonjoin_cloud/features/branches/domain/services/branch_service_interface.dart';
import 'package:moonjoin_cloud/features/branches/domain/services/zone_service.dart';
import 'package:moonjoin_cloud/features/branches/domain/services/zone_service_interface.dart';
import 'package:moonjoin_cloud/features/disputes/controllers/disputes_controller.dart';
import 'package:moonjoin_cloud/features/disputes/domain/repositories/dispute_repository.dart';
import 'package:moonjoin_cloud/features/disputes/domain/repositories/dispute_repository_interface.dart';
import 'package:moonjoin_cloud/features/disputes/domain/services/dispute_service.dart';
import 'package:moonjoin_cloud/features/disputes/domain/services/dispute_service_interface.dart';
import 'package:moonjoin_cloud/features/notifications/controllers/notifications_controller.dart';
import 'package:moonjoin_cloud/features/notifications/domain/repositories/fcm_token_repository.dart';
import 'package:moonjoin_cloud/features/notifications/domain/repositories/fcm_token_repository_interface.dart';
import 'package:moonjoin_cloud/features/notifications/domain/repositories/notification_repository.dart';
import 'package:moonjoin_cloud/features/notifications/domain/repositories/notification_repository_interface.dart';
import 'package:moonjoin_cloud/features/notifications/domain/services/notification_service.dart';
import 'package:moonjoin_cloud/features/notifications/domain/services/notification_service_interface.dart';
import 'package:moonjoin_cloud/features/notifications/services/push_service.dart';
import 'package:moonjoin_cloud/helper/network_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<Map<String, Map<String, String>>> init() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  // Core platform services
  Get.lazyPut(() => sharedPreferences);
  Get.lazyPut(() => Connectivity());
  Get.lazyPut(() => NetworkInfo(Get.find()));
  Get.lazyPut(() => ApiClient(
        appBaseUrl: Environment.baseUrl,
        sharedPreferences: Get.find(),
      ));

  // App-wide controllers
  Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));
  Get.lazyPut(() => LocalizationController(sharedPreferences: Get.find()));
  Get.lazyPut(() => SplashController(sharedPreferences: Get.find()));

  // Auth feature
  Get.lazyPut<AuthRepositoryInterface>(
      () => AuthRepository(apiClient: Get.find()));
  Get.lazyPut<AuthServiceInterface>(() => AuthService(
        authRepo: Get.find<AuthRepositoryInterface>(),
        sharedPreferences: Get.find(),
      ));
  Get.lazyPut(() => AuthController(authService: Get.find()));

  // Dashboard feature (Phase C)
  Get.lazyPut<DashboardRepositoryInterface>(
      () => DashboardRepository(apiClient: Get.find()));
  Get.lazyPut<DashboardServiceInterface>(() => DashboardService(
        dashboardRepo: Get.find<DashboardRepositoryInterface>(),
      ));
  Get.lazyPut(
      () => DashboardController(dashboardService: Get.find()),
      fenix: true);

  // Wallet feature (Phase D)
  Get.lazyPut<WalletRepositoryInterface>(
      () => WalletRepository(apiClient: Get.find()));
  Get.lazyPut<WalletServiceInterface>(() => WalletService(
        walletRepo: Get.find<WalletRepositoryInterface>(),
      ));
  Get.lazyPut(
      () => WalletController(walletService: Get.find()),
      fenix: true);

  // API Products feature (Phase E)
  Get.lazyPut<ApiProductRepositoryInterface>(
      () => ApiProductRepository(apiClient: Get.find()));
  Get.lazyPut<ApiProductServiceInterface>(() => ApiProductService(
        apiProductRepo: Get.find<ApiProductRepositoryInterface>(),
      ));
  Get.lazyPut(
      () => ApiProductsController(apiProductService: Get.find()),
      fenix: true);

  // API Keys feature (Phase E)
  Get.lazyPut<ApiKeyRepositoryInterface>(
      () => ApiKeyRepository(apiClient: Get.find()));
  Get.lazyPut<ApiKeyServiceInterface>(() => ApiKeyService(
        apiKeyRepo: Get.find<ApiKeyRepositoryInterface>(),
      ));
  Get.lazyPut(
      () => ApiKeysController(apiKeyService: Get.find()),
      fenix: true);

  // Webhooks feature (Phase E)
  Get.lazyPut<WebhookRepositoryInterface>(
      () => WebhookRepository(apiClient: Get.find()));
  Get.lazyPut<WebhookServiceInterface>(() => WebhookService(
        webhookRepo: Get.find<WebhookRepositoryInterface>(),
      ));
  Get.lazyPut(
      () => WebhookController(webhookService: Get.find()),
      fenix: true);

  // Deliveries feature (Phase F)
  Get.lazyPut<DeliveryRepositoryInterface>(
      () => DeliveryRepository(apiClient: Get.find()));
  Get.lazyPut<DeliveryServiceInterface>(() => DeliveryService(
        deliveryRepo: Get.find<DeliveryRepositoryInterface>(),
      ));
  Get.lazyPut(
      () => DeliveriesController(deliveryService: Get.find()),
      fenix: true);
  Get.lazyPut(
      () => DeliveryDetailController(deliveryService: Get.find()),
      fenix: true);

  // Analytics feature (Phase F)
  Get.lazyPut<AnalyticsRepositoryInterface>(
      () => AnalyticsRepository(apiClient: Get.find()));
  Get.lazyPut<AnalyticsServiceInterface>(() => AnalyticsService(
        analyticsRepo: Get.find<AnalyticsRepositoryInterface>(),
      ));
  Get.lazyPut(
      () => AnalyticsController(analyticsService: Get.find()),
      fenix: true);

  // Branches + Zones (Phase F)
  Get.lazyPut<BranchRepositoryInterface>(
      () => BranchRepository(apiClient: Get.find()));
  Get.lazyPut<BranchServiceInterface>(() => BranchService(
        branchRepo: Get.find<BranchRepositoryInterface>(),
      ));
  Get.lazyPut(
      () => BranchesController(branchService: Get.find()),
      fenix: true);
  Get.lazyPut<ZoneRepositoryInterface>(
      () => ZoneRepository(apiClient: Get.find()));
  Get.lazyPut<ZoneServiceInterface>(() => ZoneService(
        zoneRepo: Get.find<ZoneRepositoryInterface>(),
      ));
  Get.lazyPut(
      () => ZoneCheckController(zoneService: Get.find()),
      fenix: true);

  // Disputes feature (Phase F)
  Get.lazyPut<DisputeRepositoryInterface>(
      () => DisputeRepository(apiClient: Get.find()));
  Get.lazyPut<DisputeServiceInterface>(() => DisputeService(
        disputeRepo: Get.find<DisputeRepositoryInterface>(),
      ));
  Get.lazyPut(
      () => DisputesController(disputeService: Get.find()),
      fenix: true);

  // Notifications + Push (Phase G)
  Get.lazyPut<NotificationRepositoryInterface>(
      () => NotificationRepository(apiClient: Get.find()));
  Get.lazyPut<NotificationServiceInterface>(() => NotificationService(
        notificationRepo: Get.find<NotificationRepositoryInterface>(),
      ));
  Get.lazyPut(
      () => NotificationsController(notificationService: Get.find()),
      fenix: true);
  Get.lazyPut<FcmTokenRepositoryInterface>(
      () => FcmTokenRepository(apiClient: Get.find()));
  Get.lazyPut(
      () => PushService(
            fcmTokenRepo: Get.find<FcmTokenRepositoryInterface>(),
            prefs: Get.find(),
          ),
      fenix: true);

  // Languages — load JSON from assets (currently English only).
  final Map<String, Map<String, String>> languages = {};
  try {
    final raw = await rootBundle.loadString('assets/language/en.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    languages['en_US'] = decoded.map((k, v) => MapEntry(k, v.toString()));
  } catch (_) {
    languages['en_US'] = {};
  }
  return languages;
}
