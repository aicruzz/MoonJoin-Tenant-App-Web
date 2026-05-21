import 'package:get/get.dart';
import 'package:moonjoin_cloud/features/auth/domain/models/sign_up_body_model.dart';
import 'package:moonjoin_cloud/features/auth/domain/models/social_login_body.dart';

abstract class AuthRepositoryInterface {
  Future<Response> register(SignUpBodyModel body);
  Future<Response> login({required String email, required String password});
  Future<Response> sendOtp(String emailOrPhone);
  Future<Response> verifyOtp({required String emailOrPhone, required String otp});
  Future<Response> socialLogin(SocialLoginBody body);
  Future<Response> forgotPassword(String email);
  Future<Response> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  });
  Future<Response> fetchProfile();
}
