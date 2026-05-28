import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_loader.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/common/widgets/webhook_status_pill.dart';
import 'package:moonjoin_cloud/features/api_products/controllers/api_products_controller.dart';
import 'package:moonjoin_cloud/features/api_products/domain/models/api_product_model.dart';
import 'package:moonjoin_cloud/features/webhooks/controllers/webhook_controller.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

/// Cross-product webhook activity overview. The user picks an API product
/// from the chip row at the top; deliveries for that product flow into the
/// list below. The product-detail screen owns the full webhook management
/// experience; this tab is purely an activity feed across the merchant's
/// portfolio.
class WebhooksScreen extends StatefulWidget {
  const WebhooksScreen({super.key});

  @override
  State<WebhooksScreen> createState() => _WebhooksScreenState();
}

class _WebhooksScreenState extends State<WebhooksScreen> {
  int? _activeProductId;
  bool _kicked = false;
  late final ScrollController _scroll =
      ScrollController()..addListener(_onScroll);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_kicked) return;
      _kicked = true;
      final products = Get.find<ApiProductsController>();
      if (products.status == LoadingStatus.idle) {
        // ignore: discarded_futures
        products.initialLoad();
      }
    });
  }

  void _onScroll() {
    final c = Get.find<WebhookController>();
    if (_scroll.position.pixels >=
            _scroll.position.maxScrollExtent - 320 &&
        !c.loadingMore &&
        c.meta.hasMore) {
      // ignore: discarded_futures
      c.loadMore();
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _selectProduct(ApiProductModel p) {
    if (_activeProductId == p.id) return;
    setState(() => _activeProductId = p.id);
    // ignore: discarded_futures
    Get.find<WebhookController>().load(p.id);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ApiProductsController>(builder: (productsCtrl) {
      if (productsCtrl.status == LoadingStatus.loading) {
        return const CustomLoader();
      }
      if (productsCtrl.status == LoadingStatus.error) {
        return LoadingState(
          status: LoadingStatus.error,
          errorMessage: productsCtrl.errorMessage,
          onRetry: productsCtrl.initialLoad,
          content: (_) => const SizedBox.shrink(),
        );
      }
      if (productsCtrl.items.isEmpty) {
        return _NoProductsEmpty();
      }

      // Auto-select the first product on first build with data.
      if (_activeProductId == null && productsCtrl.items.isNotEmpty) {
        _activeProductId = productsCtrl.items.first.id;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // ignore: discarded_futures
          Get.find<WebhookController>().load(_activeProductId!);
        });
      }

      return GetBuilder<WebhookController>(builder: (whCtrl) {
        return Column(children: [
          _ProductPicker(
            products: productsCtrl.items,
            activeId: _activeProductId,
            onSelect: _selectProduct,
          ),
          Expanded(child: _DeliveryFeed(controller: whCtrl, scroll: _scroll)),
        ]);
      });
    });
  }
}

class _ProductPicker extends StatelessWidget {
  final List<ApiProductModel> products;
  final int? activeId;
  final ValueChanged<ApiProductModel> onSelect;
  const _ProductPicker(
      {required this.products,
      required this.activeId,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeLarge,
          vertical: Dimensions.paddingSizeDefault),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Webhook activity',
              style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeExtraLarge)),
          const SizedBox(height: 4),
          Text(
            'Cross-product feed. Open a product\'s detail screen for config + retries.',
            style: robotoRegular.copyWith(
                color: Theme.of(context).hintColor,
                fontSize: Dimensions.fontSizeSmall),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final p = products[i];
                final selected = p.id == activeId;
                return ChoiceChip(
                  selected: selected,
                  onSelected: (_) => onSelect(p),
                  label: Text(p.name),
                  labelStyle: robotoMedium.copyWith(
                      color: selected ? Colors.white : null,
                      fontSize: Dimensions.fontSizeSmall),
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  showCheckmark: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryFeed extends StatelessWidget {
  final WebhookController controller;
  final ScrollController scroll;
  const _DeliveryFeed(
      {required this.controller, required this.scroll});

  @override
  Widget build(BuildContext context) {
    if (controller.status == LoadingStatus.loading ||
        controller.productId == null) {
      return const CustomLoader();
    }
    if (controller.status == LoadingStatus.error) {
      return LoadingState(
        status: LoadingStatus.error,
        errorMessage: controller.errorMessage,
        onRetry: () => controller.load(controller.productId!),
        content: (_) => const SizedBox.shrink(),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        controller: scroll,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        children: [
          _FilterBar(controller: controller),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          if (controller.deliveries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  controller.filterStatus == null
                      ? 'No webhook events yet for this product.'
                      : 'No events match this filter.',
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).hintColor),
                ),
              ),
            )
          else
            for (final d in controller.deliveries)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius:
                      BorderRadius.circular(Dimensions.radiusDefault),
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.eventType,
                            style: robotoMedium.copyWith(
                                fontSize: Dimensions.fontSizeDefault)),
                        const SizedBox(height: 2),
                        Text(
                          'Attempt #${d.attempts}'
                          '${d.lastResponseStatus != null ? " · HTTP ${d.lastResponseStatus}" : ""}'
                          '${d.orderId != null ? " · Order #${d.orderId}" : ""}',
                          style: robotoRegular.copyWith(
                              color: Theme.of(context).hintColor,
                              fontSize: Dimensions.fontSizeExtraSmall),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  WebhookStatusPill(status: d.status),
                  if (d.status == 'failed' || d.status == 'exhausted')
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 18),
                      tooltip: 'Retry',
                      onPressed: () => controller.retryDelivery(d.id),
                    ),
                ]),
              ),
          if (controller.loadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(
                  child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            ),
          if (!controller.meta.hasMore && controller.deliveries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('End of feed',
                    style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall)),
              ),
            ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          Center(
            child: TextButton.icon(
              onPressed: () => Get.toNamed(
                  '${RouteHelper.apiProductDetail}?id=${controller.productId}'),
              icon: const Icon(Icons.tune),
              label: const Text('Open product detail'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  final WebhookController controller;
  const _FilterBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      children: [
        _StatusChip(
          label: 'All',
          selected: controller.filterStatus == null,
          onTap: () => controller.setStatusFilter(null),
        ),
        for (final s in AppConstants.webhookStatuses)
          _StatusChip(
            label: s[0].toUpperCase() + s.substring(1),
            selected: controller.filterStatus == s,
            onTap: () => controller.setStatusFilter(s),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _StatusChip(
      {required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      label: Text(label),
      labelStyle: robotoMedium.copyWith(
          color: selected ? Colors.white : null,
          fontSize: Dimensions.fontSizeSmall),
      selectedColor: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      showCheckmark: false,
    );
  }
}

class _NoProductsEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.webhook_outlined,
                size: 56, color: Theme.of(context).disabledColor),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Text('No API products yet',
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge)),
            const SizedBox(height: 4),
            Text(
              'Create an API product to start receiving webhook events.',
              textAlign: TextAlign.center,
              style: robotoRegular.copyWith(
                  color: Theme.of(context).hintColor),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            FilledButton.icon(
              onPressed: () =>
                  Get.toNamed(RouteHelper.apiProductCreate),
              icon: const Icon(Icons.add),
              label: const Text('New API product'),
            ),
          ],
        ),
      ),
    );
  }
}
