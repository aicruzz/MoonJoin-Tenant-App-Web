import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/common/widgets/custom_text_field.dart';
import 'package:moonjoin_cloud/features/disputes/controllers/disputes_controller.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class DisputeCreateScreen extends StatefulWidget {
  /// Optional preset (e.g. opened from a delivery detail screen later).
  final int? presetOrderId;
  const DisputeCreateScreen({super.key, this.presetOrderId});

  @override
  State<DisputeCreateScreen> createState() => _DisputeCreateScreenState();
}

class _DisputeCreateScreenState extends State<DisputeCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _orderId = TextEditingController();
  final _description = TextEditingController();
  String _reason = _reasons.first.value;

  static const _reasons = <_Reason>[
    _Reason('not_delivered', 'Not delivered'),
    _Reason('wrong_item', 'Wrong item'),
    _Reason('damaged', 'Damaged on arrival'),
    _Reason('late', 'Late delivery'),
    _Reason('other', 'Other'),
  ];

  @override
  void initState() {
    super.initState();
    if (widget.presetOrderId != null) {
      _orderId.text = widget.presetOrderId!.toString();
    }
  }

  @override
  void dispose() {
    _orderId.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final orderId = int.tryParse(_orderId.text.trim());
    if (orderId == null) return;
    final dispute = await Get.find<DisputesController>().create(
      orderId: orderId,
      reason: _reason,
      description: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
    );
    if (dispute != null) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DisputesController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Open dispute',
              style: robotoBold.copyWith(
                  fontSize: Dimensions.fontSizeLarge)),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back), onPressed: Get.back),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
            children: [
              Text('Order',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomTextField(
                controller: _orderId,
                labelText: 'Order ID',
                hintText: '12345',
                inputType: TextInputType.number,
                prefixIcon: Icons.tag,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n <= 0) return 'Enter a valid order ID';
                  return null;
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text('Reason',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              RadioGroup<String>(
                groupValue: _reason,
                onChanged: (v) => setState(() => _reason = v ?? _reason),
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
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text('Description (optional)',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomTextField(
                controller: _description,
                hintText: 'Add any context that helps the admin resolve faster…',
                maxLines: 4,
                inputAction: TextInputAction.done,
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              CustomButton(
                buttonText: 'Open dispute',
                isLoading: controller.submitting,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Reason {
  final String value;
  final String label;
  const _Reason(this.value, this.label);
}
