import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/common/widgets/custom_text_field.dart';
import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/features/auth/widgets/auth_layout.dart';
import 'package:moonjoin_cloud/helper/custom_validator.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await Get.find<AuthController>().resetPassword(
      _otpController.text.trim(),
      _passwordController.text,
      _confirmController.text,
    );
    if (ok) {
      Get.offAllNamed(RouteHelper.getSignInRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (controller) {
      return AuthLayout(
        title: 'Choose a new password',
        subtitle: 'Enter the code from your inbox and pick a strong password.',
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomTextField(
              controller: _otpController,
              labelText: 'Reset code',
              prefixIcon: Icons.numbers,
              inputType: TextInputType.number,
              validator: (v) =>
                  (v ?? '').length >= 4 ? null : 'Enter the code',
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            CustomTextField(
              controller: _passwordController,
              labelText: 'New password',
              isPassword: true,
              prefixIcon: Icons.lock_outline,
              validator: (v) => CustomValidator.isStrongPassword(v ?? '')
                  ? null
                  : '8+ chars with letters & numbers',
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            CustomTextField(
              controller: _confirmController,
              labelText: 'Confirm password',
              isPassword: true,
              inputAction: TextInputAction.done,
              prefixIcon: Icons.lock_outline,
              validator: (v) =>
                  v == _passwordController.text ? null : 'Passwords do not match',
              onSubmit: (_) => _submit(),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            CustomButton(
              buttonText: 'Update password',
              isLoading: controller.isLoading,
              onPressed: _submit,
            ),
          ]),
        ),
      );
    });
  }
}
