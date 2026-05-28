import 'package:get/get.dart';

abstract class ApiKeyRepositoryInterface {
  /// `GET /api-products/{productId}/api-keys`
  Future<Response> list(int productId);

  /// `POST /api-products/{productId}/api-keys` — mint new credential.
  Future<Response> mint(int productId);

  /// `POST /api-products/{productId}/api-keys/rotate` — rotate the currently
  /// active credential (or mint a new one if none exists).
  Future<Response> rotate(int productId);

  /// `POST /api-products/{productId}/api-keys/{credentialId}/revoke`
  Future<Response> revoke(int productId, int credentialId);

  /// `POST /api-products/{productId}/api-keys/{credentialId}/reveal` —
  /// acknowledges the user has seen the secret (server marks the flag, no
  /// plaintext returned). 410 if already revealed.
  Future<Response> acknowledgeReveal(int productId, int credentialId);
}
