import 'dart:async';

import 'package:get/get.dart';
import 'package:moonjoin_cloud/features/branches/domain/models/zone_check_model.dart';
import 'package:moonjoin_cloud/features/branches/domain/services/zone_service_interface.dart';

/// Debounced zone coverage check. Consumed by the branch edit form as the
/// marker moves on the map.
class ZoneCheckController extends GetxController implements GetxService {
  final ZoneServiceInterface zoneService;
  ZoneCheckController({required this.zoneService});

  Timer? _debounce;
  bool _checking = false;
  bool get checking => _checking;

  ZoneCheckModel? _result;
  ZoneCheckModel? get result => _result;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Schedules a check 300 ms after the last call with the same coords.
  void requestCheck(double lat, double lng) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      // ignore: discarded_futures
      _runCheck(lat, lng);
    });
  }

  /// Fires the check immediately, bypassing the debounce.
  Future<void> runNow(double lat, double lng) async {
    _debounce?.cancel();
    await _runCheck(lat, lng);
  }

  Future<void> _runCheck(double lat, double lng) async {
    _checking = true;
    _errorMessage = null;
    update();
    final result = await zoneService.check(lat, lng);
    _checking = false;
    if (result.isSuccess && result.data is ZoneCheckPayload) {
      _result = (result.data as ZoneCheckPayload).result;
    } else if (!result.isSuccess) {
      _errorMessage = result.message;
      _result = null;
    }
    update();
  }

  void clear() {
    _debounce?.cancel();
    _result = null;
    _errorMessage = null;
    _checking = false;
    update();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
