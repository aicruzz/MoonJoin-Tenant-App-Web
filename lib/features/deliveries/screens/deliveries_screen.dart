import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/deliveries/controllers/deliveries_controller.dart';
import 'package:moonjoin_cloud/features/deliveries/widgets/delivery_row_widget.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  late final ScrollController _scroll =
      ScrollController()..addListener(_onScroll);
  bool _kicked = false;

  static const _statuses = <String>[
    'pending',
    'accepted',
    'picked_up',
    'delivered',
    'canceled',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_kicked) return;
      _kicked = true;
      final c = Get.find<DeliveriesController>();
      if (c.status == LoadingStatus.idle) {
        // ignore: discarded_futures
        c.initialLoad();
      }
    });
  }

  void _onScroll() {
    final c = Get.find<DeliveriesController>();
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 320 &&
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
    return GetBuilder<DeliveriesController>(builder: (controller) {
      return LoadingState(
        status: controller.status,
        errorMessage: controller.errorMessage,
        onRetry: controller.initialLoad,
        emptyText:
            'No deliveries yet. Once your API products dispatch orders they\'ll show up here.',
        emptyIcon: Icons.local_shipping_outlined,
        content: (ctx) => _Content(
          controller: controller,
          scroll: _scroll,
          statuses: _statuses,
        ),
      );
    });
  }
}

class _Content extends StatelessWidget {
  final DeliveriesController controller;
  final ScrollController scroll;
  final List<String> statuses;
  const _Content({
    required this.controller,
    required this.scroll,
    required this.statuses,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: ListView(
        controller: scroll,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        children: [
          Text('Deliveries',
              style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeOverLarge)),
          const SizedBox(height: 4),
          Text(
            'Live across all your API products. Active orders refresh every 8 seconds.',
            style: robotoRegular.copyWith(
                color: Theme.of(context).hintColor),
          ),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          Wrap(spacing: 6, runSpacing: 6, children: [
            _FilterChip(
              label: 'All',
              selected: controller.statusFilter == null,
              onTap: () => controller.setStatusFilter(null),
            ),
            for (final s in statuses)
              _FilterChip(
                label: _label(s),
                selected: controller.statusFilter == s,
                onTap: () => controller.setStatusFilter(s),
              ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeDefault),
          for (final d in controller.items)
            DeliveryRowWidget(
              delivery: d,
              onTap: () =>
                  Get.toNamed('${RouteHelper.deliveryDetail}?id=${d.id}'),
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
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  String _label(String s) {
    switch (s) {
      case 'picked_up':
        return 'Picked up';
      case 'canceled':
        return 'Cancelled';
      default:
        return s[0].toUpperCase() + s.substring(1);
    }
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
