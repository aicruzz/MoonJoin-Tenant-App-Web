import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/common/widgets/custom_text_field.dart';
import 'package:moonjoin_cloud/features/wallet/controllers/wallet_controller.dart';
import 'package:moonjoin_cloud/features/wallet/domain/models/fund_session_model.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class _ProviderOption {
  final String key;
  final String label;
  final IconData icon;
  final bool redirect;
  const _ProviderOption(this.key, this.label, this.icon,
      {this.redirect = true});
}

const _providers = <_ProviderOption>[
  _ProviderOption('paystack', 'Paystack', Icons.payments_outlined),
  _ProviderOption('flutterwave', 'Flutterwave', Icons.bolt_outlined),
  _ProviderOption('monnify', 'Monnify', Icons.payment_outlined),
  _ProviderOption('9psb', '9PSB (Virtual Account)', Icons.account_balance,
      redirect: false),
];

/// Bottom sheet for the fund-wallet flow. Returns a [FundSessionModel] for
/// providers that support redirect funding so the caller can open the WebView.
/// Returns `null` if the user picked the 9PSB virtual account path (where
/// the user just transfers to the existing virtual account) or cancelled.
class FundWalletSheet extends StatefulWidget {
  const FundWalletSheet({super.key});

  @override
  State<FundWalletSheet> createState() => _FundWalletSheetState();
}

class _FundWalletSheetState extends State<FundWalletSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  String _provider = 'paystack';

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  bool get _isRedirectProvider =>
      _providers.firstWhere((p) => p.key == _provider).redirect;

  Future<void> _submit() async {
    if (!_isRedirectProvider) {
      // 9PSB / virtual-account path — no redirect; just close so the wallet
      // screen reveals the saved virtual account.
      Get.back();
      return;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final session = await Get.find<WalletController>().initiateFund(
      provider: _provider,
      amount: amount,
    );
    if (session != null) {
      Get.back<FundSessionModel>(result: session);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WalletController>(builder: (controller) {
      return Padding(
        padding: EdgeInsets.only(
          left: Dimensions.paddingSizeLarge,
          right: Dimensions.paddingSizeLarge,
          top: Dimensions.paddingSizeDefault,
          bottom: MediaQuery.of(context).viewInsets.bottom +
              Dimensions.paddingSizeLarge,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).hintColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              Text('Fund wallet',
                  style: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeExtraLarge)),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              Text('Pick a provider. Successful funding is reflected on the next refresh.',
                  style: robotoRegular.copyWith(
                      color: Theme.of(context).hintColor)),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Wrap(
                spacing: Dimensions.paddingSizeSmall,
                runSpacing: Dimensions.paddingSizeSmall,
                children: _providers.map((p) {
                  final selected = _provider == p.key;
                  return ChoiceChip(
                    avatar: Icon(p.icon,
                        size: 18,
                        color: selected
                            ? Colors.white
                            : Theme.of(context).primaryColor),
                    label: Text(p.label),
                    selected: selected,
                    selectedColor: Theme.of(context).primaryColor,
                    labelStyle: TextStyle(
                        color: selected ? Colors.white : null,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal),
                    onSelected: (_) => setState(() => _provider = p.key),
                  );
                }).toList(),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              if (_isRedirectProvider) ...[
                CustomTextField(
                  controller: _amount,
                  labelText: 'Amount',
                  hintText: 'e.g. 5000',
                  inputType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                  ],
                  prefixIcon: Icons.payments_outlined,
                  validator: (v) {
                    final n = double.tryParse((v ?? '').trim());
                    if (n == null || n < 100) {
                      return 'Enter at least 100';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: Dimensions.paddingSizeLarge),
              ] else
                Container(
                  padding:
                      const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .primaryColor
                        .withValues(alpha: 0.08),
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                  child: Text(
                    'Transfer any amount to your saved 9PSB virtual account below. The wallet is credited automatically once the bank confirms the transfer.',
                    style: robotoRegular.copyWith(
                        color: Theme.of(context).primaryColor),
                  ),
                ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              CustomButton(
                buttonText:
                    _isRedirectProvider ? 'Continue to $_provider' : 'Got it',
                isLoading: controller.fundInFlight,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      );
    });
  }
}
