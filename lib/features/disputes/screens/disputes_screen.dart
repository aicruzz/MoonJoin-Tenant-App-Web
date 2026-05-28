import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/disputes/controllers/disputes_controller.dart';
import 'package:moonjoin_cloud/features/disputes/widgets/dispute_card.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class DisputesScreen extends StatefulWidget {
  const DisputesScreen({super.key});

  @override
  State<DisputesScreen> createState() => _DisputesScreenState();
}

class _DisputesScreenState extends State<DisputesScreen> {
  late final ScrollController _scroll = ScrollController()..addListener(_onScroll);
  bool _kicked = false;

  static const _statuses = <String>[
    'open',
    'investigating',
    'resolved_refund',
    'resolved_no_refund',
    'closed',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_kicked) return;
      _kicked = true;
      final c = Get.find<DisputesController>();
      if (c.status == LoadingStatus.idle) {
        // ignore: discarded_futures
        c.initialLoad();
      }
    });
  }

  void _onScroll() {
    final c = Get.find<DisputesController>();
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
    return GetBuilder<DisputesController>(builder: (controller) {
      return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(RouteHelper.disputeCreate),
          icon: const Icon(Icons.report_problem_outlined),
          label: const Text('New dispute'),
        ),
        body: LoadingState(
          status: controller.status,
          errorMessage: controller.errorMessage,
          onRetry: controller.initialLoad,
          emptyText:
              'No disputes yet. Open one for a problematic delivery and an admin will pick it up.',
          emptyIcon: Icons.report_problem_outlined,
          content: (_) => RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              controller: _scroll,
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              children: [
                Text('Disputes',
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeOverLarge)),
                const SizedBox(height: 4),
                Text(
                  'Tracking problematic deliveries. Resolved refunds credit your wallet automatically.',
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
                  for (final s in _statuses)
                    _FilterChip(
                      label: _label(s),
                      selected: controller.statusFilter == s,
                      onTap: () => controller.setStatusFilter(s),
                    ),
                ]),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                for (final d in controller.items)
                  DisputeCard(
                    dispute: d,
                    onTap: () {
                      // Detail screen is out of Phase F scope; the list row
                      // currently no-ops on tap aside from this snackbar to
                      // signal the action is reserved for a future iteration.
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('Dispute #${d.id} · ${d.status}'),
                      ));
                    },
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
          ),
        ),
      );
    });
  }

  String _label(String s) {
    switch (s) {
      case 'open':
        return 'Open';
      case 'investigating':
        return 'Investigating';
      case 'resolved_refund':
        return 'Refunded';
      case 'resolved_no_refund':
        return 'No refund';
      case 'closed':
        return 'Closed';
      default:
        return s;
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
