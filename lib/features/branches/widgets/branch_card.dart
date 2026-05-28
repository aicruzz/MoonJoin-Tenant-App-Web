import 'package:flutter/material.dart';
import 'package:moonjoin_cloud/features/branches/domain/models/branch_model.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class BranchCard extends StatelessWidget {
  final BranchModel branch;
  final VoidCallback onTap;
  final VoidCallback? onDisable;
  const BranchCard({
    super.key,
    required this.branch,
    required this.onTap,
    this.onDisable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
          child: Row(children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.12),
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Icon(Icons.store_outlined,
                  color: Theme.of(context).primaryColor),
            ),
            const SizedBox(width: Dimensions.paddingSizeDefault),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(branch.name,
                          style: robotoBold.copyWith(
                              fontSize: Dimensions.fontSizeDefault),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (!branch.isActive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .hintColor
                              .withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(Dimensions.radiusLarge),
                        ),
                        child: Text('Disabled',
                            style: robotoMedium.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: Dimensions.fontSizeExtraSmall,
                                letterSpacing: 0.3)),
                      ),
                  ]),
                  const SizedBox(height: 2),
                  Text(branch.address,
                      style: robotoRegular.copyWith(
                          color: Theme.of(context).hintColor,
                          fontSize: Dimensions.fontSizeSmall),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2),
                ],
              ),
            ),
            if (branch.isActive && onDisable != null)
              IconButton(
                icon: const Icon(Icons.block, size: 18),
                tooltip: 'Disable',
                onPressed: onDisable,
              ),
            Icon(Icons.chevron_right, color: Theme.of(context).hintColor),
          ]),
        ),
      ),
    );
  }
}
