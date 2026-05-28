import 'package:get/get.dart';

abstract class FcmTokenRepositoryInterface {
  /// `POST /api/v1/merchant/fcm-token`
  Future<Response> register({
    required String token,
    String? platform,
    String? deviceId,
  });

  /// `DELETE /api/v1/merchant/fcm-token`
  Future<Response> unregister(String token);
}
