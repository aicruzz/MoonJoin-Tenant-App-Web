# MoonJoin Cloud — Tenant App & Web

Production-grade Flutter codebase that ships as **iOS, Android, and responsive web** from a single `lib/`. It mirrors the architecture of the existing MoonJoin User App & Web and integrates with the existing `admin.moonjoin.com` Laravel backend.

## What this app does

A B2B logistics dashboard for third-party businesses to:

- Sign up with OTP / Google
- Generate API keys for **MoonJoin Delivery** (food / grocery / pharmacy / fashion / parcel) and **Modules Delivery** (fuel / gas / drink / electronics / market)
- Fund a wallet via **Paystack / Flutterwave / Monnify / 9PSB**
- Configure and monitor webhooks
- Dispatch deliveries through the existing `POST /api/v1/partner/orders` partner API
- View premium analytics (orders, success rate, webhook health, module mix)
- Manage branches with a Google Maps picker
- Receive push / in-app notifications

## Architecture

Mirrors `/Users/francisadediran/Desktop/admin.moonjoin.com/User app and web/`:

- **State management**: GetX 4.6.6 (`Get.lazyPut` + `update()` + `GetBuilder<C>`)
- **DI**: manual, in `lib/helper/get_di.dart`
- **Routing**: `lib/helper/route_helper.dart` with `GetPage(transition: Transition.fadeIn)`
- **Layout per feature**: `lib/features/<name>/{controllers, domain/{models,services,repositories}, screens, widgets}`
- **Responsive breakpoints**: 650 (tablet) / 1300 (desktop) via `lib/helper/responsive_helper.dart`
- **Theme**: light + dark, MoonJoin green `#039D55`

## Running

```bash
flutter pub get

# Local dev (defaults to ENV=dev)
flutter run -d chrome
flutter run -d ios
flutter run -d android

# Environment selection
flutter run --dart-define=ENV=staging --dart-define=BASE_URL=https://staging.admin.moonjoin.com
flutter run --dart-define=ENV=prod    --dart-define=BASE_URL=https://admin.moonjoin.com

# Maps key (per-env, do not commit)
flutter build web --dart-define=ENV=prod --dart-define=MAPS_KEY=...
```

## Firebase

A **new dedicated Firebase project** is required for MoonJoin Cloud — separate from the User App. Drop:

- `firebase/{dev,staging,prod}/google-services.json` (Android)
- `firebase/{dev,staging,prod}/GoogleService-Info.plist` (iOS)

These paths are in `.gitignore` — never commit. iOS will need an Xcode build phase script to copy the right `GoogleService-Info.plist` based on `ENV`.

## Google Maps

A **dedicated Maps API key** per env, restricted by HTTP referrer (web), package + SHA-1 (Android), bundle ID (iOS). Inject via `--dart-define=MAPS_KEY=...` at build time and stamp into `web/index.html` in CI.

## Backend integration

Base URL → `admin.moonjoin.com` (existing Laravel app). Endpoint inventory lives in `lib/util/app_constants.dart`. Some endpoints are marked BLOCKED — they exist as web routes today and need a thin REST wrapper before those screens can leave their placeholders. See `/Users/francisadediran/.claude/plans/you-are-a-senior-polymorphic-fern.md` for the gap action plan.

## Phases (status)

- Phase 0 ✅ Scaffold + responsive shell + theme + DI + routing + auth screens
- Phase 1 🔄 Auth wiring (controllers + repository + service done; final smoke once backend reachable)
- Phase 2 ⏳ Dashboard + Wallet (blocked on REST endpoints)
- Phase 3 ⏳ API Products + Keys + Webhooks (blocked on REST endpoints)
- Phase 4 ⏳ Deliveries + Analytics + Maps + Branches
- Phase 5 ⏳ Profile + Notifications + polish

## Verify

```bash
flutter analyze        # clean
flutter build web      # web bundle
flutter test           # tests
```
