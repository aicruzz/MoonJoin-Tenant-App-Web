import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/auth/domain/models/sign_up_body_model.dart';
import 'package:moonjoin_cloud/features/auth/domain/models/social_login_body.dart';

abstract class AuthServiceInterface {
  Future<ResponseModel> register(SignUpBodyModel body);
  Future<ResponseModel> login(String email, String password);
  Future<ResponseModel> sendOtp(String identifier);
  Future<ResponseModel> verifyOtp(String identifier, String otp);
  Future<ResponseModel> socialLogin(SocialLoginBody body);
  Future<ResponseModel> forgotPassword(String email);
  Future<ResponseModel> resetPassword(
      String email, String otp, String password, String confirm);
  Future<ResponseModel> fetchProfile();

  String? getMerchantToken();
  Future<void> persistSession(String token, {String? merchantId, String? merchantEmail});
  Future<void> clearSession();
  bool isLoggedIn();
}
