import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/api_products/controllers/api_products_controller.dart';
import 'package:moonjoin_cloud/features/api_products/widgets/api_product_card.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class ApiProductsScreen extends StatefulWidget {
  const ApiProductsScreen({super.key});

  @override
  State<ApiProductsScreen> createState() => _ApiProductsScreenState();
}

class _ApiProductsScreenState extends State<ApiProductsScreen> {
  late final ScrollController _scroll =
      ScrollController()..addListener(_onScroll);
  bool _initialLoadKicked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_initialLoadKicked) return;
      _initialLoadKicked = true;
      final c = Get.find<ApiProductsController>();
      if (c.status == LoadingStatus.idle) {
        // ignore: discarded_futures
        c.initialLoad();
      }
    });
  }

  void _onScroll() {
    final c = Get.find<ApiProductsController>();
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

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ApiProductsController>(builder: (controller) {
      return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () =>
              Get.toNamed<bool>(RouteHelper.apiProductCreate),
          icon: const Icon(Icons.add),
          label: const Text('New product'),
        ),
        body: LoadingState(
          status: controller.status,
          errorMessage: controller.errorMessage,
          onRetry: controller.initialLoad,
          emptyText:
              'Create your first API product to start dispatching deliveries.',
          emptyIcon: Icons.api_outlined,
          content: (ctx) =>
              _Content(controller: controller, scroll: _scroll),
        ),
      );
    });
  }
}

class _Content extends StatelessWidget {
  final ApiProductsController controller;
  final ScrollController scroll;
  const _Content({required this.controller, required this.scroll});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        controller: scroll,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        children: [
          _Header(controller: controller),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          for (final p in controller.items)
            Padding(
              padding: const EdgeInsets.only(
                  bottom: Dimensions.paddingSizeDefault),
              child: ApiProductCard(
                product: p,
                onTap: () => Get.toNamed(
                    '${RouteHelper.apiProductDetail}?id=${p.id}'),
              ),
            ),
          if (controller.loadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                  child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            ),
          if (!controller.meta.hasMore && controller.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text('End of list',
                    style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeSmall)),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ApiProductsController controller;
  const _Header({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('API products',
            style: robotoBold.copyWith(
                fontSize: Dimensions.fontSizeOverLarge)),
        const SizedBox(height: 4),
        Text(
          'Each product gets its own credentials, modules, and webhook destination.',
          style: robotoRegular.copyWith(
              color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        Wrap(spacing: 6, children: [
          _FilterChip(
            label: 'All',
            selected: controller.filterStatus == null,
            onTap: () => controller.setStatusFilter(null),
          ),
          for (final s in AppConstants.apiProductStatuses)
            _FilterChip(
              label: s[0].toUpperCase() + s.substring(1),
              selected: controller.filterStatus == s,
              onTap: () => controller.setStatusFilter(s),
            ),
        ]),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _FilterChip(
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
