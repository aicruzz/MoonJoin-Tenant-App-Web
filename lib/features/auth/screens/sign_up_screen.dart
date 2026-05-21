import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/common/widgets/custom_text_field.dart';
import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/features/auth/domain/models/sign_up_body_model.dart';
import 'package:moonjoin_cloud/features/auth/widgets/auth_layout.dart';
import 'package:moonjoin_cloud/helper/custom_validator.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _companyController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final body = SignUpBodyModel(
      companyName: _companyController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmController.text,
    );
    final ok = await Get.find<AuthController>().register(body);
    if (ok) {
      Get.toNamed(RouteHelper.getOtpRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (controller) {
      return AuthLayout(
        title: 'Create your workspace',
        subtitle: 'Get a sandbox API key and start dispatching in minutes.',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _companyController,
                labelText: 'Company name',
                prefixIcon: Icons.business_outlined,
                validator: (v) =>
                    (v ?? '').trim().length >= 2 ? null : 'Required',
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomTextField(
                controller: _emailController,
                labelText: 'Work email',
                inputType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
                validator: (v) => CustomValidator.isValidEmail(v ?? '')
                    ? null
                    : 'Enter a valid email',
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomTextField(
                controller: _phoneController,
                labelText: 'Phone',
                inputType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                validator: (v) => CustomValidator.isPhone(v ?? '')
                    ? null
                    : 'Enter a valid phone',
              ),
              const SizedBox(height: Dimensions.paddingSizeDefault),
              CustomTextField(
                controller: _passwordController,
                labelText: 'Password',
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
                validator: (v) => v == _passwordController.text
                    ? null
                    : 'Passwords do not match',
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              CustomButton(
                buttonText: 'Create account',
                isLoading: controller.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: Dimensions.paddingSizeLarge),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  children: [
                    Text('Already have an account? ',
                        style: robotoRegular.copyWith(
                            color: Theme.of(context).hintColor)),
                    InkWell(
                      onTap: () => Get.toNamed(RouteHelper.getSignInRoute()),
                      child: Text('Sign in',
                          style: robotoBold.copyWith(
                              color: Theme.of(context).primaryColor)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
