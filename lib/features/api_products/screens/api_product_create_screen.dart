import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/common/widgets/custom_text_field.dart';
import 'package:moonjoin_cloud/common/widgets/module_badge.dart';
import 'package:moonjoin_cloud/features/api_products/controllers/api_products_controller.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class ApiProductCreateScreen extends StatefulWidget {
  const ApiProductCreateScreen({super.key});

  @override
  State<ApiProductCreateScreen> createState() =>
      _ApiProductCreateScreenState();
}

class _ApiProductCreateScreenState extends State<ApiProductCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _webhookUrl = TextEditingController();
  final _rateLimit = TextEditingController(text: '60');
  String _productType = AppConstants.apiProductTypes.first;
  final Set<String> _selected = <String>{};

  @override
  void dispose() {
    _name.dispose();
    _webhookUrl.dispose();
    _rateLimit.dispose();
    super.dispose();
  }

  List<String> get _availableKeys => _productType == 'modules_delivery'
      ? AppConstants.deliveryModules
      : AppConstants.moonjoinCategories;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_productType == 'modules_delivery'
            ? 'Pick at least one module'
            : 'Pick at least one delivery category'),
      ));
      return;
    }

    final controller = Get.find<ApiProductsController>();
    final created = await controller.create(
      name: _name.text.trim(),
      productType: _productType,
      categories: _productType == 'moonjoin_delivery'
          ? _selected.toList()
          : const [],
      modules: _productType == 'modules_delivery' ? _selected.toList() : const [],
      webhookUrl: _webhookUrl.text.trim().isEmpty
          ? null
          : _webhookUrl.text.trim(),
      rateLimitPerMinute: int.tryParse(_rateLimit.text.trim()),
    );

    if (created != null) {
      // Replace this screen with the detail view.
      Get.offNamed('${RouteHelper.apiProductDetail}?id=${created.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ApiProductsController>(builder: (controller) {
      return Scaffold(
        appBar: AppBar(
          title: Text('New API product',
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
              Text('Name',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomTextField(
                controller: _name,
                hintText: 'Acme Delivery API',
                prefixIcon: Icons.label_outline,
                validator: (v) =>
                    (v ?? '').trim().length >= 2 ? null : 'Name is required',
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text('Product type',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              _ProductTypePicker(
                value: _productType,
                onChanged: (v) {
                  setState(() {
                    _productType = v;
                    _selected.clear();
                  });
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text(
                _productType == 'modules_delivery'
                    ? 'Modules to enable'
                    : 'Delivery categories',
                style:
                    robotoBold.copyWith(fontSize: Dimensions.fontSizeDefault),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final key in _availableKeys)
                    _SelectableBadge(
                      moduleKey: key,
                      selected: _selected.contains(key),
                      onTap: () => setState(() {
                        if (!_selected.add(key)) _selected.remove(key);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text('Webhook URL (optional)',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomTextField(
                controller: _webhookUrl,
                hintText: 'https://example.com/webhooks/mj',
                inputType: TextInputType.url,
                prefixIcon: Icons.webhook_outlined,
                validator: (v) {
                  final value = (v ?? '').trim();
                  if (value.isEmpty) return null;
                  final uri = Uri.tryParse(value);
                  if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
                    return 'Enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text('Rate limit (requests / minute)',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomTextField(
                controller: _rateLimit,
                inputType: TextInputType.number,
                prefixIcon: Icons.speed,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n < 1 || n > 6000) {
                    return 'Between 1 and 6000';
                  }
                  return null;
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeExtraLarge),
              CustomButton(
                buttonText: 'Create API product',
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

class _ProductTypePicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _ProductTypePicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
          child: _TypeChoice(
        title: 'MoonJoin Delivery',
        subtitle: 'Food, grocery, pharmacy, fashion, parcel.',
        selected: value == 'moonjoin_delivery',
        onTap: () => onChanged('moonjoin_delivery'),
      )),
      const SizedBox(width: Dimensions.paddingSizeSmall),
      Expanded(
          child: _TypeChoice(
        title: 'Modules Delivery',
        subtitle: 'Fuel, gas, drink, electronics, market.',
        selected: value == 'modules_delivery',
        onTap: () => onChanged('modules_delivery'),
      )),
    ]);
  }
}

class _TypeChoice extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  const _TypeChoice(
      {required this.title,
      required this.subtitle,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.08)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
          border: Border.all(
            color: selected
                ? Theme.of(context).primaryColor
                : Theme.of(context).hintColor.withValues(alpha: 0.25),
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 18,
                color: selected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).hintColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(title,
                    style: robotoBold.copyWith(
                        fontSize: Dimensions.fontSizeDefault)),
              ),
            ]),
            const SizedBox(height: 4),
            Text(subtitle,
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall)),
          ],
        ),
      ),
    );
  }
}

class _SelectableBadge extends StatelessWidget {
  final String moduleKey;
  final bool selected;
  final VoidCallback onTap;
  const _SelectableBadge(
      {required this.moduleKey,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      child: Opacity(
        opacity: selected ? 1 : 0.55,
        child: Stack(children: [
          ModuleBadge(moduleKey: moduleKey),
          if (selected)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Theme.of(context).cardColor, width: 1.5),
                ),
              ),
            ),
        ]),
      ),
    );
  }
}
