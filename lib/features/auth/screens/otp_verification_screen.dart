import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_button.dart';
import 'package:moonjoin_cloud/features/auth/controllers/auth_controller.dart';
import 'package:moonjoin_cloud/features/auth/widgets/auth_layout.dart';
import 'package:moonjoin_cloud/helper/route_helper.dart';
import 'package:moonjoin_cloud/util/dimensions.dart';
import 'package:moonjoin_cloud/util/styles.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _otp = '';

  Future<void> _submit() async {
    if (_otp.length < 4) return;
    final ok = await Get.find<AuthController>().verifyOtp(_otp);
    if (ok) {
      Get.offAllNamed(RouteHelper.getMainRoute('dashboard'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AuthController>(builder: (controller) {
      final identifier = controller.pendingIdentifier ?? 'your email';
      return AuthLayout(
        title: 'Verify your email',
        subtitle: 'Enter the code we sent to $identifier.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PinCodeTextField(
              appContext: context,
              length: 6,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              pinTheme: PinTheme(
                shape: PinCodeFieldShape.box,
                borderRadius:
                    BorderRadius.circular(Dimensions.radiusDefault),
                fieldHeight: 52,
                fieldWidth: 44,
                activeFillColor: Theme.of(context).cardColor,
                inactiveFillColor: Theme.of(context).cardColor,
                selectedFillColor: Theme.of(context).cardColor,
                activeColor: Theme.of(context).primaryColor,
                inactiveColor:
                    Theme.of(context).hintColor.withValues(alpha: 0.3),
                selectedColor: Theme.of(context).primaryColor,
              ),
              enableActiveFill: true,
              onChanged: (v) => _otp = v,
              onCompleted: (v) => _otp = v,
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            CustomButton(
              buttonText: 'Verify',
              isLoading: controller.isLoading,
              onPressed: _submit,
            ),
            const SizedBox(height: Dimensions.paddingSizeDefault),
            Center(
              child: TextButton(
                onPressed: controller.pendingIdentifier == null
                    ? null
                    : () => controller
                        .sendOtp(controller.pendingIdentifier!),
                child: Text('Resend code',
                    style: robotoBold.copyWith(
                        color: Theme.of(context).primaryColor)),
              ),
            ),
          ],
        ),
      );
    });
  }
}
