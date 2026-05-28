import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/common/widgets/custom_text_field.dart';
import 'package:moonjoin_cloud/features/wallet/controllers/wallet_controller.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

/// Modal bottom sheet: pick provider + amount → call initiateFund → push the
/// fund WebView with the returned session. Pops itself before the WebView so
/// the user lands back on the wallet screen on completion.
class FundWalletSheet extends StatefulWidget {
  const FundWalletSheet({super.key});

  @override
  State<FundWalletSheet> createState() => _FundWalletSheetState();
}

class _FundWalletSheetState extends State<FundWalletSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  String _provider = AppConstants.paymentProviders.first;
  bool _submitting = false;

  static const _minAmount = 100;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = double.tryParse(_amount.text.replaceAll(',', '').trim());
    if (amount == null) return;

    setState(() => _submitting = true);
    final session = await Get.find<WalletController>()
        .initiateFund(provider: _provider, amount: amount);
    if (!mounted) return;
    setState(() => _submitting = false);

    if (session == null) return; // error surfaced via controller snackbar

    Navigator.of(context).pop();
    Get.toNamed<bool>(
      RouteHelper.fundWalletWebView,
      arguments: session,
    );
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: Dimensions.paddingSizeLarge,
          right: Dimensions.paddingSizeLarge,
          top: Dimensions.paddingSizeLarge,
          bottom: Dimensions.paddingSizeLarge + insets.bottom,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .hintColor
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text('Fund wallet',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge)),
              const SizedBox(height: 4),
              Text(
                'Minimum ₦$_minAmount. Funds settle to your MoonJoin Cloud wallet immediately after payment confirmation.',
                style: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              CustomTextField(
                controller: _amount,
                labelText: 'Amount',
                hintText: '5000',
                inputType: const TextInputType.numberWithOptions(decimal: true),
                inputAction: TextInputAction.done,
                prefixIcon: Icons.attach_money,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                validator: (v) {
                  final raw = (v ?? '').replaceAll(',', '').trim();
                  final parsed = double.tryParse(raw);
                  if (parsed == null) return 'Enter a valid amount';
                  if (parsed < _minAmount) return 'Minimum is ₦$_minAmount';
                  return null;
                },
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Text('Payment provider',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeDefault)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Wrap(
                spacing: Dimensions.paddingSizeSmall,
                runSpacing: Dimensions.paddingSizeSmall,
                children: AppConstants.paymentProviders
                    .map((p) => _ProviderChip(
                          provider: p,
                          selected: p == _provider,
                          onTap: () => setState(() => _provider = p),
                        ))
                    .toList(),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              CustomButton(
                buttonText: 'Continue',
                isLoading: _submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Center(
                child: TextButton(
                  onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProviderChip extends StatelessWidget {
  final String provider;
  final bool selected;
  final VoidCallback onTap;
  const _ProviderChip({
    required this.provider,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).primaryColor
        : Theme.of(context).hintColor.withValues(alpha: 0.3);
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      label: Text(_label(provider)),
      avatar: Icon(_icon(provider),
          size: 18,
          color: selected ? Colors.white : Theme.of(context).primaryColor),
      labelStyle: robotoMedium.copyWith(
          color: selected ? Colors.white : null,
          fontSize: Dimensions.fontSizeSmall),
      selectedColor: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).cardColor,
      side: BorderSide(color: color),
      showCheckmark: false,
    );
  }

  String _label(String key) {
    switch (key) {
      case 'paystack':
        return 'Paystack';
      case 'flutterwave':
        return 'Flutterwave';
      case 'monnify':
        return 'Monnify';
      case '9psb':
        return '9PSB';
      default:
        return key;
    }
  }

  IconData _icon(String key) {
    switch (key) {
      case '9psb':
        return Icons.account_balance_outlined;
      default:
        return Icons.credit_card;
    }
  }
}
