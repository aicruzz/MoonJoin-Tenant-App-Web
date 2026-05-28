import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/models/page_meta.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/models/webhook_config_model.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/models/webhook_delivery_model.dart';
import 'package:moonjoin_cloud/features/webhooks/domain/services/webhook_service_interface.dart';

/// Holds webhook config + paginated delivery log for one API product at a time.
/// The detail screen and the cross-product Webhooks tab both consume this
/// controller; the latter passes a productId from its product picker.
class WebhookController extends GetxController implements GetxService {
  final WebhookServiceInterface webhookService;
  WebhookController({required this.webhookService});

  int? _productId;
  int? get productId => _productId;

  LoadingStatus _status = LoadingStatus.idle;
  LoadingStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  WebhookConfigModel? _config;
  WebhookConfigModel? get config => _config;

  final List<WebhookDeliveryModel> _deliveries = [];
  List<WebhookDeliveryModel> get deliveries => List.unmodifiable(_deliveries);

  PageMeta _meta = const PageMeta(offset: 0, limit: 20, total: 0);
  PageMeta get meta => _meta;

  bool _loadingMore = false;
  bool get loadingMore => _loadingMore;

  bool _saving = false;
  bool get saving => _saving;

  bool _testing = false;
  bool get testing => _testing;

  String? _filterStatus;
  String? get filterStatus => _filterStatus;

  /// Loads config + first page of deliveries for the given product.
  /// Cheap: small payloads. Caller is expected to invoke this once per
  /// product, then again on pull-to-refresh.
  Future<void> load(int productId) async {
    _productId = productId;
    _status = LoadingStatus.loading;
    _errorMessage = null;
    _deliveries.clear();
    _meta = const PageMeta(offset: 0, limit: 20, total: 0);
    update();

    final results = await Future.wait([
      webhookService.getConfig(productId),
      webhookService.getDeliveries(productId, offset: 0, limit: 20),
    ]);
    final cfgResult = results[0];
    final delResult = results[1];

    if (cfgResult.isSuccess && cfgResult.data is WebhookConfigPayload) {
      _config = (cfgResult.data as WebhookConfigPayload).config;
    } else if (!cfgResult.isSuccess) {
      _errorMessage = cfgResult.message;
      _status = LoadingStatus.error;
      update();
      return;
    }

    if (delResult.isSuccess && delResult.data is WebhookDeliveryListPayload) {
      final p = delResult.data as WebhookDeliveryListPayload;
      _deliveries.addAll(p.items);
      _meta = p.meta;
    }

    _status = LoadingStatus.content;
    update();
  }

  @override
  Future<void> refresh() async {
    final id = _productId;
    if (id != null) await load(id);
  }

  Future<void> loadMore() async {
    final id = _productId;
    if (id == null || _loadingMore || !_meta.hasMore) return;
    _loadingMore = true;
    update();

    final result = await webhookService.getDeliveries(
      id,
      offset: _meta.nextOffset,
      limit: _meta.limit == 0 ? 20 : _meta.limit,
      status: _filterStatus,
    );
    if (result.isSuccess && result.data is WebhookDeliveryListPayload) {
      final p = result.data as WebhookDeliveryListPayload;
      _deliveries.addAll(p.items);
      _meta = p.meta;
    } else if (!result.isSuccess) {
      showCustomSnackBar(result.message);
    }
    _loadingMore = false;
    update();
  }

  void setStatusFilter(String? value) {
    if (_filterStatus == value) return;
    _filterStatus = value;
    _deliveries.clear();
    _meta = const PageMeta(offset: 0, limit: 20, total: 0);
    update();
    // ignore: discarded_futures
    _reloadDeliveriesHead();
  }

  Future<void> _reloadDeliveriesHead() async {
    final id = _productId;
    if (id == null) return;
    final result = await webhookService.getDeliveries(
      id,
      offset: 0,
      limit: 20,
      status: _filterStatus,
    );
    if (result.isSuccess && result.data is WebhookDeliveryListPayload) {
      final p = result.data as WebhookDeliveryListPayload;
      _deliveries
        ..clear()
        ..addAll(p.items);
      _meta = p.meta;
      update();
    }
  }

  Future<bool> updateConfig({
    required String webhookUrl,
    bool rotateSecret = false,
  }) async {
    final id = _productId;
    if (id == null || _saving) return false;
    _saving = true;
    update();
    final result = await webhookService.updateConfig(
      id,
      webhookUrl: webhookUrl,
      rotateSecret: rotateSecret,
    );
    _saving = false;
    update();
    if (result.isSuccess && result.data is WebhookConfigPayload) {
      _config = (result.data as WebhookConfigPayload).config;
      update();
      showCustomSnackBar(
        rotateSecret
            ? 'Webhook saved · signing secret rotated'
            : 'Webhook saved',
        isError: false,
      );
      return true;
    }
    showCustomSnackBar(result.message);
    return false;
  }

  Future<bool> sendTestPing() async {
    final id = _productId;
    if (id == null || _testing) return false;
    _testing = true;
    update();
    final result = await webhookService.sendTestPing(id);
    _testing = false;
    update();
    if (result.isSuccess && result.data is WebhookDeliveryPayload) {
      final delivery = (result.data as WebhookDeliveryPayload).delivery;
      _deliveries.insert(0, delivery);
      _meta = PageMeta(
        offset: _meta.offset,
        limit: _meta.limit,
        total: _meta.total + 1,
      );
      update();
      showCustomSnackBar(
        'Test ping queued · refresh in a moment to see status',
        isError: false,
      );
      return true;
    }
    showCustomSnackBar(result.message);
    return false;
  }

  Future<bool> retryDelivery(int deliveryId) async {
    final id = _productId;
    if (id == null) return false;
    final result = await webhookService.retry(id, deliveryId);
    if (result.isSuccess && result.data is WebhookDeliveryPayload) {
      final delivery = (result.data as WebhookDeliveryPayload).delivery;
      final idx = _deliveries.indexWhere((e) => e.id == delivery.id);
      if (idx >= 0) _deliveries[idx] = delivery;
      update();
      showCustomSnackBar('Retry queued', isError: false);
      return true;
    }
    showCustomSnackBar(result.message);
    return false;
  }
}
