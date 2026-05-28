import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/features/wallet/controllers/wallet_controller.dart';
import 'package:moonjoin_cloud/features/wallet/widgets/fund_wallet_sheet.dart';
import 'package:moonjoin_cloud/features/wallet/widgets/transaction_row_widget.dart';
import 'package:moonjoin_cloud/features/wallet/widgets/virtual_account_card.dart';
import 'package:moonjoin_cloud/features/wallet/widgets/wallet_balance_card.dart';
import 'package:moonjoin_cloud/helper/responsive_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (controller) {
      return LoadingState(
        status: controller.status,
        errorMessage: controller.errorMessage,
        onRetry: controller.initialLoad,
        emptyText: 'No wallet activity yet',
        content: (ctx) => _WalletContent(controller: controller),
      );
    });
  }
}

class _WalletContent extends StatefulWidget {
  final WalletController controller;
  const _WalletContent({required this.controller});

  @override
  State<_WalletContent> createState() => _WalletContentState();
}

class _WalletContentState extends State<_WalletContent> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final pos = _scroll.position;
    if (pos.pixels >= pos.maxScrollExtent - 320) {
      // ignore: discarded_futures
      widget.controller.loadMore();
    }
  }

  void _openFundSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radiusLarge)),
      ),
      builder: (_) => const FundWalletSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    final isWide = ResponsiveHelper.isDesktop(context) ||
        ResponsiveHelper.isTab(context);

    return RefreshIndicator(
      onRefresh: c.refreshAll,
      child: ListView(
        controller: _scroll,
        padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
        children: [
          // Hero balance card
          WalletBalanceCard(
            balance: c.balance,
            onFund: _openFundSheet,
            fundDisabled: c.fundInFlight,
          ),

          if (c.virtualAccounts.isNotEmpty) ...[
            const SizedBox(height: Dimensions.paddingSizeLarge),
            const _SectionHeader(
              title: 'Virtual accounts',
              hint: 'Auto-funded by bank transfer',
            ),
            const SizedBox(height: Dimensions.paddingSizeSmall),
            if (isWide)
              Wrap(
                spacing: Dimensions.paddingSizeDefault,
                runSpacing: Dimensions.paddingSizeDefault,
                children: c.virtualAccounts
                    .map((a) => SizedBox(
                          width: 320,
                          child: VirtualAccountCard(account: a),
                        ))
                    .toList(),
              )
            else
              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: c.virtualAccounts.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: Dimensions.paddingSizeDefault),
                  itemBuilder: (_, i) => SizedBox(
                    width: 320,
                    child: VirtualAccountCard(account: c.virtualAccounts[i]),
                  ),
                ),
              ),
          ],

          const SizedBox(height: Dimensions.paddingSizeLarge),
          Row(children: [
            Expanded(
              child: _SectionHeader(
                title: 'Recent transactions',
                hint: '${c.transactionsMeta.total} total',
              ),
            ),
            _FilterMenu(
              current: c.filterType,
              onChanged: c.setFilterType,
            ),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),

          if (c.transactions.isEmpty)
            Container(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(children: [
                Icon(Icons.receipt_long_outlined,
                    size: 48, color: Theme.of(context).disabledColor),
                const SizedBox(height: Dimensions.paddingSizeSmall),
                Text(
                  c.filterType == null
                      ? 'No transactions yet. Fund your wallet to get started.'
                      : 'No ${c.filterType} transactions in this range.',
                  textAlign: TextAlign.center,
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).hintColor),
                ),
              ]),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeDefault,
                vertical: Dimensions.paddingSizeSmall,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusDefault),
              ),
              child: Column(
                children: [
                  ...List.generate(c.transactions.length, (i) {
                    final t = c.transactions[i];
                    final isLast = i == c.transactions.length - 1;
                    return Column(children: [
                      TransactionRowWidget(
                        transaction: t,
                        currencyCode: c.balance.currency,
                      ),
                      if (!isLast)
                        Divider(
                          height: 1,
                          color: Theme.of(context)
                              .hintColor
                              .withValues(alpha: 0.12),
                        ),
                    ]);
                  }),
                  if (c.loadingMore)
                    const Padding(
                      padding:
                          EdgeInsets.all(Dimensions.paddingSizeDefault),
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else if (!c.transactionsMeta.hasMore &&
                      c.transactions.isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                      child: Text(
                        'End of transactions',
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? hint;
  const _SectionHeader({required this.title, this.hint});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(title,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      if (hint != null)
        Text(hint!,
            style: robotoRegular.copyWith(
                color: Theme.of(context).hintColor,
                fontSize: Dimensions.fontSizeSmall)),
    ]);
  }
}

class _FilterMenu extends StatelessWidget {
  final String? current;
  final ValueChanged<String?> onChanged;
  const _FilterMenu({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String?>(
      tooltip: 'Filter by type',
      initialValue: current,
      onSelected: onChanged,
      itemBuilder: (_) => const [
        PopupMenuItem<String?>(value: null, child: Text('All transactions')),
        PopupMenuDivider(),
        PopupMenuItem(value: 'funding', child: Text('Funding')),
        PopupMenuItem(value: 'hold', child: Text('Holds')),
        PopupMenuItem(value: 'charge', child: Text('Charges')),
        PopupMenuItem(value: 'release', child: Text('Released to rider')),
        PopupMenuItem(value: 'refund', child: Text('Refunds')),
        PopupMenuItem(value: 'reversal', child: Text('Reversals')),
      ],
      child: Chip(
        avatar: const Icon(Icons.filter_list, size: 16),
        label: Text(current ?? 'ALL'),
      ),
    );
  }
}
