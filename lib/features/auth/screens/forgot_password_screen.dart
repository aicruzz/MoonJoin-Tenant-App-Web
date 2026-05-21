import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/common/widgets/custom_text_field.dart';
import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/features/auth/widgets/auth_layout.dart';
import 'package:moonjoin_cloud/helper/custom_validator.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await Get.find<AuthController>()
        .forgotPassword(_emailController.text.trim());
    if (ok) {
      Get.toNamed(RouteHelper.getResetPasswordRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (controller) {
      return AuthLayout(
        title: 'Reset password',
        subtitle: 'Send a reset code to your work email.',
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CustomTextField(
              controller: _emailController,
              labelText: 'Work email',
              inputType: TextInputType.emailAddress,
              prefixIcon: Icons.email_outlined,
              validator: (v) => CustomValidator.isValidEmail(v ?? '')
                  ? null
                  : 'Enter a valid email',
              onSubmit: (_) => _submit(),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            CustomButton(
              buttonText: 'Send reset code',
              isLoading: controller.isLoading,
              onPressed: _submit,
            ),
          ]),
        ),
      );
    });
  }
}
