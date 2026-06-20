// Runtime smoke test for MoonJoin Cloud.
//
// Drives the real app against a running backend and asserts the core merchant
// journey works end to end: app launch -> login (real form + button) ->
// dashboard renders and loads -> every primary screen's data loads (Wallet,
// API Products, Deliveries, Analytics, Branches, Notifications) -> logout.
//
// Runs headless in CI with no manual interaction. Point it at any environment
// via --dart-define; for a local Laravel backend:
//
//   flutter drive \
//     --driver=test_driver/integration_test.dart \
//     --target=integration_test/runtime_smoke_test.dart \
//     -d web-server --browser-name=chrome --driver-port=4444 \
//     --browser-dimension=1600x1000 --profile \
//     --dart-define=ENV=dev --dart-define=BASE_URL=http://127.0.0.1:8000
//
// Requires a seeded, approved merchant matching the credentials below.
//
// NOTE on screen coverage: the dashboard is verified through the fully rendered
// screen. The other tabs are GetX long-polling screens (Timer.periodic); when
// rendered under the headless web webdriver their timers stall the renderer, so
// they cannot be tab-walked reliably in CI. Instead each one's data load is
// verified by calling the exact authenticated endpoint that screen fetches,
// through the app's own ApiClient (same network path the screen uses).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/common/controllers/polling_controller.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/main.dart' as app;

import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/features/dashboard/controllers/dashboard_controller.dart';

const String kEmail = 'merchant.test@moonjoin.local';
const String kPassword = 'Password123!';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Dispose GetX after the test so polling Timer.periodic instances are
  // cancelled (PollingController.onClose) and the page can go idle.
  tearDown(() {
    try {
      Get.reset();
    } catch (_) {}
  });

  // Polling screens never settle, so pumpAndSettle would hang. Pump one frame
  // then yield REAL time via Future.delayed — in the live browser binding
  // tester.pump(Duration) returns immediately, so a tight pump loop would peg
  // the renderer and trip the webdriver timeout.
  Future<void> tick(WidgetTester tester) async {
    await tester.pump();
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  Future<void> pumpFor(WidgetTester tester, int seconds) async {
    final end = DateTime.now().add(Duration(seconds: seconds));
    while (DateTime.now().isBefore(end)) {
      await tick(tester);
    }
  }

  Future<bool> waitUntil(
    WidgetTester tester,
    bool Function() cond, {
    int timeoutSeconds = 15,
  }) async {
    final end = DateTime.now().add(Duration(seconds: timeoutSeconds));
    while (DateTime.now().isBefore(end)) {
      if (cond()) return true;
      await tick(tester);
    }
    return cond();
  }

  bool isLoaded(LoadingStatus s) =>
      s == LoadingStatus.content || s == LoadingStatus.empty;

  testWidgets('merchant can log in, load every screen, and log out',
      (tester) async {
    // 1. App launch.
    app.main();
    await pumpFor(tester, 3);

    // Land on sign-in deterministically (independent of splash/onboarding state).
    Get.offAllNamed(RouteHelper.signIn);
    await pumpFor(tester, 2);

    // 2. Merchant login through the real sign-in form + button.
    final fields = find.byType(EditableText);
    expect(fields, findsNWidgets(2),
        reason: 'sign-in screen should show email + password fields');
    // enterText is unreliable on headless Flutter web (browser text-input
    // limitation in integration tests), so set the field controllers directly
    // — equivalent to a user typing — then tap the real button, which runs the
    // genuine form validation -> AuthController.login -> navigation path.
    tester.widget<EditableText>(fields.at(0)).controller.text = kEmail;
    tester.widget<EditableText>(fields.at(1)).controller.text = kPassword;
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('Sign in'));
    await tester.pump();

    final loggedIn = await waitUntil(
      tester,
      () => Get.currentRoute.startsWith(RouteHelper.main),
      timeoutSeconds: 30,
    );
    expect(loggedIn, isTrue,
        reason:
            'login did not navigate to the main screen (route=${Get.currentRoute})');

    // 3. Dashboard renders and loads.
    final dashboardLoaded = await waitUntil(
      tester,
      () =>
          Get.isRegistered<DashboardController>() &&
          isLoaded(Get.find<DashboardController>().status),
    );
    expect(dashboardLoaded, isTrue, reason: 'dashboard did not load');
    // Stop dashboard polling so the page stays idle for the rest of the test.
    final dashboard = Get.find<DashboardController>();
    if (dashboard is PollingController) dashboard.pausePolling();

    // 4. Every primary screen's data loads (same endpoints the screens fetch,
    // through the now-authenticated ApiClient).
    final api = Get.find<ApiClient>();
    Future<void> verifyScreenData(
      String label,
      String uri, [
      Map<String, dynamic>? query,
    ]) async {
      final res = await api.getData(uri, query: query, handleError: false);
      expect(res.statusCode, 200,
          reason: '$label data did not load (http=${res.statusCode})');
    }

    await verifyScreenData('Wallet', '/api/v1/merchant/wallet/balance');
    await verifyScreenData('API Products', '/api/v1/merchant/api-products',
        {'offset': 0, 'limit': 20});
    await verifyScreenData('Deliveries', '/api/v1/merchant/deliveries',
        {'offset': 0, 'limit': 20});
    await verifyScreenData(
        'Analytics', '/api/v1/merchant/analytics/orders', {'range': '7d'});
    await verifyScreenData(
        'Branches', '/api/v1/merchant/branches', {'offset': 0, 'limit': 20});
    await verifyScreenData('Notifications', '/api/v1/merchant/notifications',
        {'offset': 0, 'limit': 20});

    // 5. Logout via the real UI control returns to sign-in and clears the session.
    final logoutButton = find.byIcon(Icons.logout);
    expect(logoutButton, findsWidgets, reason: 'logout control should be present');
    await tester.tap(logoutButton.first);

    // logout() clears the session then navigates; wait for the route change so
    // we don't assert before Get.offAllNamed(signIn) has completed.
    final returnedToSignIn = await waitUntil(
      tester,
      () => Get.currentRoute == RouteHelper.signIn,
      timeoutSeconds: 10,
    );
    expect(returnedToSignIn, isTrue,
        reason: 'logout did not return to sign-in (route=${Get.currentRoute})');
    expect(Get.find<AuthController>().isLoggedIn(), isFalse,
        reason: 'logout should clear the session');
  });
}
