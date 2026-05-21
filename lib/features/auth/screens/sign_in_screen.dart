import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/common/widgets/custom_text_field.dart';
import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/features/auth/widgets/auth_layout.dart';
import 'package:moonjoin_cloud/helper/custom_validator.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await Get.find<AuthController>()
        .login(_emailController.text.trim(), _passwordController.text);
    if (ok) {
      Get.offAllNamed(RouteHelper.getMainRoute('dashboard'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (controller) {
      return AuthLayout(
        title: 'Welcome back',
        subtitle: 'Sign in to your MoonJoin Cloud workspace.',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _emailController,
                labelText: 'Work email',
                hintText: 'you@company.com',
                inputType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (v) => CustomValidator.isValidEmail(v ?? '')
                    ? null
                    : 'Enter a valid email',
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
                isPassword: true,
                inputAction: TextInputAction.done,
                prefixIcon: Icons.lock_outline,
                validator: (v) =>
                    (v ?? '').length >= 6 ? null : 'Password too short',
                onSubmit: (_) => _submit(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () =>
                      Get.toNamed(RouteHelper.getForgotPasswordRoute()),
                  child: const Text('Forgot password?'),
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeSmall),
              CustomButton(
                buttonText: 'Sign in',
                isLoading: controller.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text("Don't have an account? ",
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor)),
                    InkWell(
                      onTap: () =>
                          Get.toNamed(RouteHelper.getSignUpRoute()),
                      child: Text('Create one',
                          style: robotoBold.copyWith(
                              color: Theme.of(context).primaryColor)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              OutlinedButton.icon(
                onPressed: () => showCustomSnackBar(
                    'Google sign-in: configure client ID before enabling'),
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text('Continue with Google'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
