import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/confirmation_dialog.dart' as confirm;
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/common/widgets/custom_loader.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/common/widgets/custom_text_field.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/common/widgets/module_badge.dart';
import 'package:moonjoin_cloud/common/widgets/reveal_secret_dialog.dart';
import 'package:moonjoin_cloud/common/widgets/webhook_status_pill.dart';
import 'package:moonjoin_cloud/features/api_keys/controllers/api_keys_controller.dart';
import 'package:moonjoin_cloud/features/api_keys/domain/models/api_key_model.dart';
import 'package:moonjoin_cloud/features/api_keys/domain/services/api_key_service_interface.dart';
import 'package:moonjoin_cloud/features/api_products/controllers/api_products_controller.dart';
import 'package:moonjoin_cloud/features/api_products/domain/models/api_product_model.dart';
import 'package:moonjoin_cloud/features/webhooks/controllers/webhook_controller.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class ApiProductDetailScreen extends StatefulWidget {
  final int productId;
  const ApiProductDetailScreen({super.key, required this.productId});

  @override
  State<ApiProductDetailScreen> createState() =>
      _ApiProductDetailScreenState();
}

class _ApiProductDetailScreenState extends State<ApiProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this);
  ApiProductModel? _product;
  bool _loadingProduct = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productsController = Get.find<ApiProductsController>();
      _product = productsController.cached(widget.productId);
      if (mounted) setState(() {});

      // ignore: discarded_futures
      Get.find<ApiKeysController>().load(widget.productId);
      // ignore: discarded_futures
      Get.find<WebhookController>().load(widget.productId);

      final refreshed = await productsController.loadDetail(widget.productId);
      if (!mounted) return;
      setState(() {
        if (refreshed != null) _product = refreshed;
        _loadingProduct = false;
      });
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_product?.name ?? 'API product',
            style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeLarge)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Keys'),
            Tab(text: 'Webhook'),
          ],
        ),
      ),
      body: _product == null
          ? (_loadingProduct
              ? const CustomLoader()
              : Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: Text(
                      'Product not found.',
                      style: robotoMedium.copyWith(
                          color: Theme.of(context).hintColor),
                    ),
                  ),
                ))
          : TabBarView(
              controller: _tabs,
              children: [
                _OverviewTab(product: _product!),
                _KeysTab(productId: widget.productId),
                _WebhookTab(productId: widget.productId),
              ],
            ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final ApiProductModel product;
  const _OverviewTab({required this.product});

  @override
  Widget build(BuildContext context) {
    final tags = product.productType == 'modules_delivery'
        ? product.modules.map((e) => e.moduleKey).toList()
        : product.supportedCategories;

    return GetBuilder<ApiProductsController>(builder: (controller) {
      return ListView(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        children: [
          _SectionCard(
            title: 'Status',
            child: Row(children: [
              _StatusChip(status: product.status),
              const SizedBox(width: Dimensions.paddingSizeDefault),
              if (product.status == 'draft')
                Expanded(
                  child: CustomButton(
                    buttonText: 'Submit for review',
                    isLoading: controller.submitting,
                    onPressed: () =>
                        controller.submitForApproval(product.id),
                  ),
                ),
              if (product.status == 'pending')
                Expanded(
                  child: Text(
                    'Waiting on admin approval. We\'ll notify you when it\'s ready.',
                    style: robotoMedium.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall),
                  ),
                ),
            ]),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _SectionCard(
            title: product.productType == 'modules_delivery'
                ? 'Modules'
                : 'Delivery categories',
            child: tags.isEmpty
                ? Text(
                    'No selections yet — edit this product to enable modules.',
                    style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall),
                  )
                : Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final t in tags) ModuleBadge(moduleKey: t),
                    ],
                  ),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _SectionCard(
            title: 'Rate limit',
            child: Text(
              '${product.rateLimitPerMinute} requests / minute',
              style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault),
            ),
          ),
        ],
      );
    });
  }
}

class _KeysTab extends StatelessWidget {
  final int productId;
  const _KeysTab({required this.productId});

  Future<void> _showReveal(ApiKeyRevealPayload payload) async {
    await RevealSecretDialog.show(
      composedCredential: payload.reveal.composedCredential,
      keyPrefix: payload.reveal.credential.keyPrefix,
      lastFour: payload.reveal.credential.lastFour,
      onAcknowledge: () => Get.find<ApiKeysController>()
          .acknowledgeReveal(payload.reveal.credential.id),
    );
  }

  Future<void> _confirmRevoke(int credentialId) async {
    final ok = await confirm.showConfirmationDialog(
      title: 'Revoke this key?',
      message:
          'Apps using this key will start receiving 401. You can issue or rotate to get a fresh one.',
      confirmLabel: 'Revoke',
      destructive: true,
    );
    if (ok != true) return;
    await Get.find<ApiKeysController>().revoke(credentialId);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ApiKeysController>(builder: (controller) {
      Widget content;
      if (controller.status == LoadingStatus.loading) {
        content = const CustomLoader();
      } else if (controller.status == LoadingStatus.error) {
        content = Center(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.errorMessage ?? 'Could not load API keys',
                    style: robotoMedium.copyWith(
                        color: Theme.of(context).hintColor)),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                OutlinedButton.icon(
                  onPressed: () =>
                      Get.find<ApiKeysController>().load(productId),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        );
      } else if (controller.keys.isEmpty) {
        content = _EmptyKeys(
          onIssue: () async {
            final payload = await controller.mint();
            if (payload != null) await _showReveal(payload);
          },
          submitting: controller.mutating,
        );
      } else {
        content = RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            children: [
              for (final k in controller.keys)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ApiKeyRow(
                    keyModel: k,
                    onRevoke: () => _confirmRevoke(k.id),
                  ),
                ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Issue new key'),
                    onPressed: controller.mutating
                        ? null
                        : () async {
                            final payload = await controller.mint();
                            if (payload != null) await _showReveal(payload);
                          },
                  ),
                ),
                const SizedBox(width: Dimensions.paddingSizeSmall),
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Rotate key'),
                    onPressed: controller.mutating
                        ? null
                        : () async {
                            final payload = await controller.rotate();
                            if (payload != null) await _showReveal(payload);
                          },
                  ),
                ),
              ]),
            ],
          ),
        );
      }
      return content;
    });
  }
}

class _EmptyKeys extends StatelessWidget {
  final VoidCallback onIssue;
  final bool submitting;
  const _EmptyKeys({required this.onIssue, required this.submitting});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.vpn_key_outlined,
                size: 56, color: Theme.of(context).disabledColor),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text(
              'No keys yet',
              style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge),
            ),
            const SizedBox(height: 4),
            Text(
              'Issue your first key to start calling the Partner API.',
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            FilledButton.icon(
              onPressed: submitting ? null : onIssue,
              icon: const Icon(Icons.add),
              label: const Text('Issue API key'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApiKeyRow extends StatelessWidget {
  final ApiKeyModel keyModel;
  final VoidCallback onRevoke;
  const _ApiKeyRow({required this.keyModel, required this.onRevoke});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
            color: Theme.of(context)
                .hintColor
                .withValues(alpha: keyModel.isActive ? 0.2 : 0.12)),
      ),
      child: Row(children: [
        Icon(
          keyModel.isActive
              ? Icons.vpn_key_outlined
              : Icons.lock_outline,
          color: keyModel.isActive
              ? Theme.of(context).primaryColor
              : Theme.of(context).hintColor,
        ),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(keyModel.masked,
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault,
                      letterSpacing: 0.4)),
              const SizedBox(height: 2),
              Text(
                keyModel.lastUsedAt != null
                    ? 'Last used ${_relative(keyModel.lastUsedAt!)}'
                    : keyModel.isActive
                        ? 'Never used yet'
                        : 'Revoked',
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall),
              ),
            ],
          ),
        ),
        if (keyModel.isActive)
          IconButton(
            icon: const Icon(Icons.block, size: 20),
            tooltip: 'Revoke',
            onPressed: onRevoke,
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text('Revoked',
                style: robotoMedium.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeExtraSmall)),
          ),
      ]),
    );
  }

  String _relative(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}

class _WebhookTab extends StatefulWidget {
  final int productId;
  const _WebhookTab({required this.productId});

  @override
  State<_WebhookTab> createState() => _WebhookTabState();
}

class _WebhookTabState extends State<_WebhookTab> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _url = TextEditingController();
  bool _rotateSecret = false;
  bool _formInitialized = false;

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  void _hydrateFromController(WebhookController c) {
    if (_formInitialized) return;
    _url.text = c.config?.webhookUrl ?? '';
    _formInitialized = true;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await Get.find<WebhookController>().updateConfig(
      webhookUrl: _url.text.trim(),
      rotateSecret: _rotateSecret,
    );
    if (ok) setState(() => _rotateSecret = false);
  }

  Future<void> _sendTest() async {
    final webhookCtrl = Get.find<WebhookController>();
    if (webhookCtrl.config?.webhookUrl == null ||
        webhookCtrl.config!.webhookUrl!.isEmpty) {
      showCustomSnackBar('Save a webhook URL first');
      return;
    }
    await webhookCtrl.sendTestPing();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WebhookController>(builder: (controller) {
      _hydrateFromController(controller);

      if (controller.status == LoadingStatus.loading) {
        return const CustomLoader();
      }
      if (controller.status == LoadingStatus.error) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(controller.errorMessage ?? 'Could not load webhook',
                    style: robotoMedium.copyWith(
                        color: Theme.of(context).hintColor)),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                OutlinedButton.icon(
                  onPressed: () => controller.load(widget.productId),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refresh,
        child: ListView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          children: [
            _SectionCard(
              title: 'Webhook endpoint',
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _url,
                      labelText: 'URL',
                      hintText: 'https://example.com/webhooks/mj',
                      inputType: TextInputType.url,
                      prefixIcon: Icons.link,
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'Required';
                        final uri = Uri.tryParse(value);
                        if (uri == null ||
                            !uri.hasScheme ||
                            !uri.hasAuthority) {
                          return 'Enter a valid URL';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: Dimensions.paddingSizeDefault),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Rotate signing secret on save',
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeDefault),
                      ),
                      subtitle: Text(
                        controller.config?.webhookSecretPresent == true
                            ? 'A secret is set — rotate to invalidate the previous one.'
                            : 'A new signing secret will be generated automatically.',
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall),
                      ),
                      value: _rotateSecret,
                      onChanged: (v) => setState(() => _rotateSecret = v),
                    ),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.send_outlined),
                          label: Text(controller.testing
                              ? 'Sending…'
                              : 'Send test ping'),
                          onPressed:
                              controller.testing ? null : _sendTest,
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      Expanded(
                        child: FilledButton.icon(
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Save'),
                          onPressed: controller.saving ? null : _save,
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            _DeliveriesCard(controller: controller),
          ],
        ),
      );
    });
  }
}

class _DeliveriesCard extends StatelessWidget {
  final WebhookController controller;
  const _DeliveriesCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Recent deliveries',
      child: controller.deliveries.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No webhook events yet. They\'ll appear here once a delivery fires.',
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall),
              ),
            )
          : Column(
              children: [
                for (final d in controller.deliveries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.eventType,
                                style: robotoMedium.copyWith(
                                    fontSize:
                                        Dimensions.fontSizeDefault)),
                            const SizedBox(height: 2),
                            Text(
                              'Attempt #${d.attempts}'
                              '${d.lastResponseStatus != null ? " · HTTP ${d.lastResponseStatus}" : ""}',
                              style: robotoRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize:
                                      Dimensions.fontSizeExtraSmall),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Dimensions.paddingSizeSmall),
                      WebhookStatusPill(status: d.status),
                      if (!d.isTerminal || d.status == 'failed' ||
                          d.status == 'exhausted')
                        IconButton(
                          icon: const Icon(Icons.refresh, size: 18),
                          tooltip: 'Retry',
                          onPressed: () =>
                              controller.retryDelivery(d.id),
                        ),
                    ]),
                  ),
                if (controller.meta.hasMore)
                  TextButton(
                    onPressed:
                        controller.loadingMore ? null : controller.loadMore,
                    child: Text(controller.loadingMore
                        ? 'Loading…'
                        : 'Load more'),
                  ),
              ],
            ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          child,
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final tone = _toneFor(status);
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tone.$1,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: Text(status.toUpperCase(),
          style: robotoMedium.copyWith(
              color: tone.$2,
              fontSize: Dimensions.fontSizeSmall,
              letterSpacing: 0.4)),
    );
  }

  (Color, Color) _toneFor(String status) {
    switch (status) {
      case 'active':
        return (const Color(0xFFE6F8EE), const Color(0xFF137C36));
      case 'pending':
        return (const Color(0xFFFFF6E0), const Color(0xFFA66B00));
      case 'suspended':
        return (const Color(0xFFFCEAEC), const Color(0xFFB31E2A));
      case 'draft':
      default:
        return (const Color(0xFFEDF0F5), const Color(0xFF3F4855));
    }
  }
}
