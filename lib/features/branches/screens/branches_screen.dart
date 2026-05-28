import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/confirmation_dialog.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/branches/controllers/branches_controller.dart';
import 'package:moonjoin_cloud/features/branches/widgets/branch_card.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class BranchesScreen extends StatefulWidget {
  const BranchesScreen({super.key});

  @override
  State<BranchesScreen> createState() => _BranchesScreenState();
}

class _BranchesScreenState extends State<BranchesScreen> {
  late final ScrollController _scroll = ScrollController()..addListener(_onScroll);
  bool _kicked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_kicked) return;
      _kicked = true;
      final c = Get.find<BranchesController>();
      if (c.status == LoadingStatus.idle) {
        // ignore: discarded_futures
        c.initialLoad();
      }
    });
  }

  void _onScroll() {
    final c = Get.find<BranchesController>();
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
    return GetBuilder<BranchesController>(builder: (controller) {
      return Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => Get.toNamed(RouteHelper.branchEdit),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: const Text('New branch'),
        ),
        body: LoadingState(
          status: controller.status,
          errorMessage: controller.errorMessage,
          onRetry: controller.initialLoad,
          emptyText:
              'No branches yet. Add your first pickup location to start dispatching.',
          emptyIcon: Icons.store_outlined,
          content: (_) => RefreshIndicator(
            onRefresh: controller.refresh,
            child: ListView(
              controller: _scroll,
              padding:
                  const EdgeInsets.all(Dimensions.paddingSizeLarge),
              children: [
                Text('Branches',
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeOverLarge)),
                const SizedBox(height: 4),
                Text(
                  'Where you dispatch from. Each branch is matched to a delivery zone.',
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: Dimensions.paddingSizeDefault),
                for (final b in controller.items)
                  BranchCard(
                    branch: b,
                    onTap: () =>
                        Get.toNamed('${RouteHelper.branchEdit}?id=${b.id}'),
                    onDisable: () async {
                      final ok = await showConfirmationDialog(
                        title: 'Disable this branch?',
                        message:
                            'New orders will no longer be matched to this location. You can re-enable later by editing the branch.',
                        confirmLabel: 'Disable',
                        destructive: true,
                      );
                      if (ok == true) {
                        await controller.disable(b.id);
                      }
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
}
