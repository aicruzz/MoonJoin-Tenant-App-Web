import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:moonjoin_cloud/common/widgets/confirmation_dialog.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/common/widgets/loading_state.dart';
import 'package:moonjoin_cloud/common/widgets/module_badge.dart';
import 'package:moonjoin_cloud/features/deliveries/controllers/delivery_detail_controller.dart';
import 'package:moonjoin_cloud/features/deliveries/domain/models/delivery_model.dart';
import 'package:moonjoin_cloud/features/deliveries/widgets/delivery_status_pill.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class DeliveryDetailScreen extends StatefulWidget {
  final int orderId;
  const DeliveryDetailScreen({super.key, required this.orderId});

  @override
  State<DeliveryDetailScreen> createState() => _DeliveryDetailScreenState();
}

class _DeliveryDetailScreenState extends State<DeliveryDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = Get.find<DeliveryDetailController>();
      c.bindOrder(widget.orderId);
      // ignore: discarded_futures
      c.initialLoad();
    });
  }

  Future<void> _openReassignDialog() async {
    final ctrl = Get.find<DeliveryDetailController>();
    final reason = await Get.dialog<String>(
      const _ReassignReasonDialog(),
      barrierDismissible: true,
    );
    if (reason == null || reason.isEmpty) return;
    // Optional confirmation before firing.
    final confirmed = await showConfirmationDialog(
      title: 'Request reassignment?',
      message:
          'A MoonJoin admin will review and reassign this order to a fresh rider. The original rider, if any, will be unassigned.',
      confirmLabel: 'Request',
    );
    if (confirmed != true) return;
    await ctrl.requestReassignment(reason, null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${widget.orderId}',
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: Get.back),
      ),
      body: GetBuilder<DeliveryDetailController>(builder: (controller) {
        return LoadingState(
          status: controller.status,
          errorMessage: controller.errorMessage,
          onRetry: controller.initialLoad,
          content: (_) => _Content(
            delivery: controller.delivery!,
            reassigning: controller.reassigning,
            onReassign: _openReassignDialog,
          ),
        );
      }),
    );
  }
}

class _Content extends StatelessWidget {
  final DeliveryModel delivery;
  final bool reassigning;
  final VoidCallback onReassign;
  const _Content({
    required this.delivery,
    required this.reassigning,
    required this.onReassign,
  });

  @override
  Widget build(BuildContext context) {
    final ccy = NumberFormat.simpleCurrency(name: 'NGN', decimalDigits: 2);
    return ListView(
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      children: [
        Row(children: [
          DeliveryStatusPill(status: delivery.orderStatus),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          if (delivery.moduleKey != null && delivery.moduleKey!.isNotEmpty)
            ModuleBadge(moduleKey: delivery.moduleKey!, small: true),
          const Spacer(),
          if (delivery.needsManualDispatch)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFCEAEC),
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusLarge),
              ),
              child: Text('Manual dispatch flagged',
                  style: robotoMedium.copyWith(
                      color: const Color(0xFFB31E2A),
                      fontSize: Dimensions.fontSizeExtraSmall,
                      letterSpacing: 0.3)),
            ),
        ]),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        _Timeline(status: delivery.orderStatus),
        const SizedBox(height: Dimensions.paddingSizeLarge),
        _Section(
          title: 'Pickup',
          icon: Icons.store_outlined,
          child: _AddressBlock(point: delivery.pickup),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        _Section(
          title: 'Delivery',
          icon: Icons.location_on_outlined,
          child: _AddressBlock(point: delivery.delivery),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        _Section(
          title: 'Customer',
          icon: Icons.person_outline,
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(delivery.customer.name ?? '—',
                      style: robotoMedium.copyWith(
                          fontSize: Dimensions.fontSizeDefault)),
                  if (delivery.customer.phone != null &&
                      delivery.customer.phone!.isNotEmpty)
                    Text(delivery.customer.phone!,
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor,
                            fontSize: Dimensions.fontSizeSmall)),
                ],
              ),
            ),
            if (delivery.customer.phone != null &&
                delivery.customer.phone!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.copy_outlined, size: 18),
                tooltip: 'Copy phone',
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(
                      text: delivery.customer.phone!));
                  showCustomSnackBar('Phone copied', isError: false);
                },
              ),
          ]),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),
        _Section(
          title: 'Pricing',
          icon: Icons.payments_outlined,
          child: Column(
            children: [
              _kv(context, 'Order amount',
                  ccy.format(delivery.pricing.orderAmount)),
              _kv(context, 'Delivery charge',
                  ccy.format(delivery.pricing.deliveryCharge)),
              if (delivery.pricing.distanceKm != null)
                _kv(
                  context,
                  'Distance',
                  '${delivery.pricing.distanceKm!.toStringAsFixed(1)} km',
                ),
              if (delivery.pricing.durationMin != null)
                _kv(
                  context,
                  'ETA',
                  '${delivery.pricing.durationMin!.toStringAsFixed(0)} min',
                ),
            ],
          ),
        ),
        if (delivery.escrow != null) ...[
          const SizedBox(height: Dimensions.paddingSizeDefault),
          _EscrowRibbon(escrow: delivery.escrow!, ccy: ccy),
        ],
        const SizedBox(height: Dimensions.paddingSizeLarge),
        if (!delivery.isTerminal)
          CustomButton(
            buttonText: 'Request reassignment',
            isLoading: reassigning,
            onPressed: onReassign,
          ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _kv(BuildContext context, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        SizedBox(
          width: 110,
          child: Text(k,
              style: robotoMedium.copyWith(
                  color: Theme.of(context).hintColor,
                  fontSize: Dimensions.fontSizeSmall)),
        ),
        Expanded(
          child: Text(v,
              style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeDefault)),
        ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const _Section(
      {required this.title, required this.icon, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18, color: Theme.of(context).primaryColor),
            const SizedBox(width: 6),
            Text(title,
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault)),
          ]),
          const SizedBox(height: Dimensions.paddingSizeSmall),
          child,
        ],
      ),
    );
  }
}

class _AddressBlock extends StatelessWidget {
  final DeliveryPoint point;
  const _AddressBlock({required this.point});

  @override
  Widget build(BuildContext context) {
    final hasCoords = point.lat != null && point.lng != null;
    final hasAddress = point.address != null && point.address!.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(hasAddress ? point.address! : '—',
                  style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeDefault)),
              if (hasCoords)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${point.lat!.toStringAsFixed(5)}, ${point.lng!.toStringAsFixed(5)}',
                    style: robotoRegular.copyWith(
                        color: Theme.of(context).hintColor,
                        fontSize: Dimensions.fontSizeExtraSmall),
                  ),
                ),
            ],
          ),
        ),
        if (hasAddress)
          IconButton(
            icon: const Icon(Icons.copy_outlined, size: 18),
            tooltip: 'Copy address',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: point.address!));
              showCustomSnackBar('Address copied', isError: false);
            },
          ),
      ],
    );
  }
}

class _Timeline extends StatelessWidget {
  final String status;
  const _Timeline({required this.status});

  static const _stages = <String>[
    'pending',
    'accepted',
    'picked_up',
    'delivered',
  ];

  @override
  Widget build(BuildContext context) {
    if (status == 'canceled' ||
        status == 'cancelled' ||
        status == 'failed' ||
        status == 'refunded') {
      return _TerminalBanner(status: status);
    }
    final activeIndex = _stages.indexOf(status).clamp(0, _stages.length - 1);
    return Row(children: [
      for (int i = 0; i < _stages.length; i++) ...[
        _Dot(
            label: _label(_stages[i]),
            done: i <= activeIndex,
            current: i == activeIndex),
        if (i < _stages.length - 1)
          Expanded(
            child: Container(
              height: 2,
              color: i < activeIndex
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).hintColor.withValues(alpha: 0.2),
            ),
          ),
      ],
    ]);
  }

  String _label(String s) =>
      s == 'picked_up' ? 'Picked up' : s[0].toUpperCase() + s.substring(1);
}

class _Dot extends StatelessWidget {
  final String label;
  final bool done;
  final bool current;
  const _Dot({required this.label, required this.done, required this.current});

  @override
  Widget build(BuildContext context) {
    final color = done
        ? Theme.of(context).primaryColor
        : Theme.of(context).hintColor.withValues(alpha: 0.4);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: current ? 18 : 14,
        height: current ? 18 : 14,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: current
              ? Border.all(color: Theme.of(context).primaryColor, width: 3)
              : null,
        ),
      ),
      const SizedBox(height: 4),
      Text(label,
          style: robotoMedium.copyWith(
              color: done
                  ? Theme.of(context).colorScheme.onSurface
                  : Theme.of(context).hintColor,
              fontSize: Dimensions.fontSizeExtraSmall)),
    ]);
  }
}

class _TerminalBanner extends StatelessWidget {
  final String status;
  const _TerminalBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    final ok = status == 'delivered';
    final bg = ok ? const Color(0xFFE6F8EE) : const Color(0xFFFCEAEC);
    final fg = ok ? const Color(0xFF137C36) : const Color(0xFFB31E2A);
    final icon = ok ? Icons.check_circle_outline : Icons.cancel_outlined;
    final text = ok
        ? 'Order delivered.'
        : status == 'refunded'
            ? 'Order refunded.'
            : 'Order cancelled.';
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: Row(children: [
        Icon(icon, color: fg),
        const SizedBox(width: 8),
        Text(text,
            style: robotoMedium.copyWith(
                color: fg, fontSize: Dimensions.fontSizeDefault)),
      ]),
    );
  }
}

class _EscrowRibbon extends StatelessWidget {
  final DeliveryEscrow escrow;
  final NumberFormat ccy;
  const _EscrowRibbon({required this.escrow, required this.ccy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          Theme.of(context).primaryColor.withValues(alpha: 0.12),
          Theme.of(context).primaryColor.withValues(alpha: 0.06),
        ]),
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
        border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
        const SizedBox(width: Dimensions.paddingSizeDefault),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Escrow ${escrow.status ?? 'unknown'} · ${ccy.format(escrow.amount)}',
                style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeDefault),
              ),
              const SizedBox(height: 2),
              Text(
                escrow.releasedAt != null
                    ? 'Released to rider'
                    : escrow.heldAt != null
                        ? 'Held — releases on delivery confirmation'
                        : 'Reserved from wallet',
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

class _ReassignReasonDialog extends StatefulWidget {
  const _ReassignReasonDialog();
  @override
  State<_ReassignReasonDialog> createState() => _ReassignReasonDialogState();
}

class _ReassignReasonDialogState extends State<_ReassignReasonDialog> {
  String _value = _reasons.first.value;

  static const _reasons = <_Reason>[
    _Reason('no_rider_accepted', 'No rider accepted'),
    _Reason('rider_unresponsive', 'Rider unresponsive'),
    _Reason('wrong_route', 'Wrong route'),
    _Reason('unsafe_area', 'Unsafe pickup area'),
    _Reason('other', 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pick a reason',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge)),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              RadioGroup<String>(
                groupValue: _value,
                onChanged: (v) => setState(() => _value = v ?? _value),
                child: Column(
                  children: [
                    for (final r in _reasons)
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text(r.label),
                        value: r.value,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => Get.back(result: _value),
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Reason {
  final String value;
  final String label;
  const _Reason(this.value, this.label);
}
