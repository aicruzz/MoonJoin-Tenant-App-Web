import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/api_keys/domain/models/api_key_model.dart';
import 'package:moonjoin_cloud/features/api_keys/domain/services/api_key_service_interface.dart';

/// Holds the API key list per product. The detail screen owns one
/// ApiKeysController and re-loads on tab open + after mint/rotate/revoke.
class ApiKeysController extends GetxController implements GetxService {
  final ApiKeyServiceInterface apiKeyService;
  ApiKeysController({required this.apiKeyService});

  // productId → list state. Multiple products can be inspected, but we only
  // hold one at a time per controller instance — `lazyPut(fenix:true)` recycles.
  int? _productId;
  int? get productId => _productId;

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<ApiKeyModel> _keys = const [];
  List<ApiKeyModel> get keys => _keys;

  bool _mutating = false;
  bool get mutating => _mutating;

  Future<void> load(int productId) async {
    _productId = productId;
    _status = LoadingStatus.loading;
    _errorMessage = null;
    update();
    final result = await apiKeyService.list(productId);
    if (result.isSuccess && result.data is ApiKeyListPayload) {
      _keys = (result.data as ApiKeyListPayload).items;
      _status = _keys.isEmpty ? LoadingStatus.empty : LoadingStatus.content;
    } else {
      _errorMessage = result.message;
      _status = LoadingStatus.error;
    }
    update();
  }

  @override
  Future<void> refresh() async {
    final id = _productId;
    if (id != null) await load(id);
  }

  /// Returns the freshly minted credential (with plaintext) or null on failure.
  Future<ApiKeyRevealPayload?> mint() async {
    final id = _productId;
    if (id == null || _mutating) return null;
    _mutating = true;
    update();
    final result = await apiKeyService.mint(id);
    _mutating = false;
    update();
    if (result.isSuccess && result.data is ApiKeyRevealPayload) {
      final payload = result.data as ApiKeyRevealPayload;
      _keys = [payload.reveal.credential, ..._keys];
      _status = LoadingStatus.content;
      update();
      return payload;
    }
    showCustomSnackBar(result.message);
    return null;
  }

  Future<ApiKeyRevealPayload?> rotate() async {
    final id = _productId;
    if (id == null || _mutating) return null;
    _mutating = true;
    update();
    final result = await apiKeyService.rotate(id);
    _mutating = false;
    update();
    if (result.isSuccess && result.data is ApiKeyRevealPayload) {
      final payload = result.data as ApiKeyRevealPayload;
      // Refresh the list to pick up any newly-revoked previous credential.
      // ignore: discarded_futures
      refresh();
      return payload;
    }
    showCustomSnackBar(result.message);
    return null;
  }

  Future<bool> revoke(int credentialId) async {
    final id = _productId;
    if (id == null || _mutating) return false;
    _mutating = true;
    update();
    final result = await apiKeyService.revoke(id, credentialId);
    _mutating = false;
    update();
    if (result.isSuccess && result.data is ApiKeyPayload) {
      final updated = (result.data as ApiKeyPayload).credential;
      final idx = _keys.indexWhere((e) => e.id == updated.id);
      if (idx >= 0) {
        final list = [..._keys];
        list[idx] = updated;
        _keys = list;
      }
      update();
      showCustomSnackBar('API key revoked', isError: false);
      return true;
    }
    showCustomSnackBar(result.message);
    return false;
  }

  /// Tells the backend the merchant has finished viewing the plaintext secret.
  /// Safe to call repeatedly — the server returns 410 on subsequent reveals
  /// and the service surfaces that as a friendly message.
  Future<void> acknowledgeReveal(int credentialId) async {
    final id = _productId;
    if (id == null) return;
    final result = await apiKeyService.acknowledgeReveal(id, credentialId);
    if (result.isSuccess && result.data is ApiKeyPayload) {
      final cred = (result.data as ApiKeyPayload).credential;
      final idx = _keys.indexWhere((e) => e.id == cred.id);
      if (idx >= 0) {
        final list = [..._keys];
        list[idx] = cred;
        _keys = list;
        update();
      }
    }
    // 410 is benign here — the controller does not surface it.
  }
}
