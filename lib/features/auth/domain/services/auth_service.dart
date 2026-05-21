import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/common/models/response_model.dart';
import 'package:moonjoin_cloud/features/auth/domain/models/sign_up_body_model.dart';
import 'package:moonjoin_cloud/features/auth/domain/models/social_login_body.dart';
import 'package:moonjoin_cloud/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:moonjoin_cloud/features/auth/domain/services/auth_service_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService implements AuthServiceInterface {
  final AuthRepositoryInterface authRepo;
  final SharedPreferences sharedPreferences;
  AuthService({required this.authRepo, required this.sharedPreferences});

  ResponseModel _toResponseModel(Response response,
      {String successMessage = ''}) {
    if (response.statusCode == 200) {
      return ResponseModel(true, successMessage, response.body);
    }
    final body = response.body;
    String message = response.statusText ?? 'Something went wrong';
    if (body is Map && body['message'] != null) {
      message = body['message'].toString();
    } else if (body is Map && body['errors'] is Map) {
      final firstKey = (body['errors'] as Map).keys.first;
      final firstVal = (body['errors'] as Map)[firstKey];
      if (firstVal is List && firstVal.isNotEmpty) {
        message = firstVal.first.toString();
      }
    }
    return ResponseModel(false, message, body);
  }

  @override
  Future<ResponseModel> register(SignUpBodyModel body) async {
    final response = await authRepo.register(body);
    final model = _toResponseModel(response, successMessage: 'Account created');
    if (model.isSuccess && model.data is Map) {
      final token = model.data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await persistSession(token,
            merchantEmail: body.email,
            merchantId: model.data['merchant']?['id']?.toString());
      }
    }
    return model;
  }

  @override
  Future<ResponseModel> login(String email, String password) async {
    final response = await authRepo.login(email: email, password: password);
    final model = _toResponseModel(response, successMessage: 'Welcome back');
    if (model.isSuccess && model.data is Map) {
      final token = model.data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await persistSession(token,
            merchantEmail: email,
            merchantId: model.data['merchant']?['id']?.toString());
      }
    }
    return model;
  }

  @override
  Future<ResponseModel> sendOtp(String identifier) async {
    final response = await authRepo.sendOtp(identifier);
    return _toResponseModel(response, successMessage: 'OTP sent');
  }

  @override
  Future<ResponseModel> verifyOtp(String identifier, String otp) async {
    final response = await authRepo.verifyOtp(emailOrPhone: identifier, otp: otp);
    final model = _toResponseModel(response, successMessage: 'Verified');
    if (model.isSuccess && model.data is Map) {
      final token = model.data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await persistSession(token,
            merchantEmail: identifier,
            merchantId: model.data['merchant']?['id']?.toString());
      }
    }
    return model;
  }

  @override
  Future<ResponseModel> socialLogin(SocialLoginBody body) async {
    final response = await authRepo.socialLogin(body);
    final model = _toResponseModel(response, successMessage: 'Signed in');
    if (model.isSuccess && model.data is Map) {
      final token = model.data['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await persistSession(token,
            merchantEmail: body.email,
            merchantId: model.data['merchant']?['id']?.toString());
      }
    }
    return model;
  }

  @override
  Future<ResponseModel> forgotPassword(String email) async {
    final response = await authRepo.forgotPassword(email);
    return _toResponseModel(response, successMessage: 'Reset code sent');
  }

  @override
  Future<ResponseModel> resetPassword(
      String email, String otp, String password, String confirm) async {
    final response = await authRepo.resetPassword(
      email: email,
      otp: otp,
      password: password,
      passwordConfirmation: confirm,
    );
    return _toResponseModel(response, successMessage: 'Password updated');
  }

  @override
  Future<ResponseModel> fetchProfile() async {
    final response = await authRepo.fetchProfile();
    return _toResponseModel(response);
  }

  @override
  String? getMerchantToken() =>
      sharedPreferences.getString(AppConstants.token);

  @override
  Future<void> persistSession(String token,
      {String? merchantId, String? merchantEmail}) async {
    await sharedPreferences.setString(AppConstants.token, token);
    if (merchantId != null) {
      await sharedPreferences.setString(AppConstants.merchantId, merchantId);
    }
    if (merchantEmail != null) {
      await sharedPreferences.setString(
          AppConstants.merchantEmail, merchantEmail);
    }
    // Refresh ApiClient headers immediately so subsequent calls are authenticated.
    Get.find<ApiClient>().updateHeader(
      token,
      sharedPreferences.getString(AppConstants.languageCode),
    );
  }

  @override
  Future<void> clearSession() async {
    await sharedPreferences.remove(AppConstants.token);
    await sharedPreferences.remove(AppConstants.merchantId);
    await sharedPreferences.remove(AppConstants.merchantEmail);
    await sharedPreferences.remove(AppConstants.merchantName);
    Get.find<ApiClient>().updateHeader(
        null, sharedPreferences.getString(AppConstants.languageCode));
  }

  @override
  bool isLoggedIn() {
    final token = sharedPreferences.getString(AppConstants.token);
    return token != null && token.isNotEmpty;
  }
}
