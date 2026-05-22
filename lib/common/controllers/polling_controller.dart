import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// Base GetX controller for screens that long-poll a Phase A REST endpoint.
///
/// - Calls [initialLoad] once on `onInit`.
/// - Starts a periodic timer with [pollInterval]; each tick calls [poll].
/// - Pauses polling when the app is backgrounded; resumes on foreground.
/// - Stops polling when [shouldStopPolling] returns true (e.g. terminal status).
///
/// Subclasses must call `update()` (NOT `Rx`) to notify `GetBuilder` listeners,
/// matching the existing User App pattern.
abstract class PollingController extends GetxController
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _paused = false;

  /// Override per screen. Recommend 5–10 s for active orders,
  /// 30–60 s for dashboard summaries.
  Duration get pollInterval;

  /// First request after the controller mounts. Subclasses must call
  /// `update()` on completion / error.
  Future<void> initialLoad();

  /// Subsequent ticks. Should be a lightweight payload (smallest range,
  /// cursor-resumable, etc.) per the long-polling efficiency goal.
  Future<void> poll();

  /// When true, the timer is cancelled and never restarts.
  /// Default: never stops. Override for terminal-state screens.
  bool shouldStopPolling() => false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // ignore: discarded_futures
    initialLoad().then((_) => _startTimer());
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timer = null;
    super.onClose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (shouldStopPolling()) return;
    _timer = Timer.periodic(pollInterval, (_) async {
      if (_paused) return;
      if (shouldStopPolling()) {
        _timer?.cancel();
        _timer = null;
        return;
      }
      try {
        await poll();
      } catch (_) {
        // Poll errors must never crash the screen — they surface via
        // the screen's LoadingState via `update()` instead.
      }
      if (shouldStopPolling()) {
        _timer?.cancel();
        _timer = null;
      }
    });
  }

  /// Manual refresh entry point — usable from pull-to-refresh / refresh button.
  Future<void> refreshNow() async {
    try {
      await poll();
    } catch (_) {
      // Same swallowing rule as the timer path.
    }
  }

  void pausePolling() => _paused = true;
  void resumePolling() => _paused = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _paused = true;
        break;
      case AppLifecycleState.resumed:
        _paused = false;
        // Refresh immediately on resume so the user sees fresh data.
        // ignore: discarded_futures
        refreshNow();
        break;
    }
  }
}
