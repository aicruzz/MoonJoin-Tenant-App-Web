import 'package:get/get.dart';
import 'package:moonjoin_cloud/api/api_client.dart';
import 'package:moonjoin_cloud/features/auth/domain/models/sign_up_body_model.dart';
import 'package:moonjoin_cloud/features/auth/domain/models/social_login_body.dart';
import 'package:moonjoin_cloud/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:moonjoin_cloud/util/app_constants.dart';

class AuthRepository implements AuthRepositoryInterface {
  final ApiClient apiClient;
  AuthRepository({required this.apiClient});

  @override
  Future<Response> register(SignUpBodyModel body) =>
      apiClient.postData(AppConstants.registerUri, body.toJson(),
          handleError: false);

  @override
  Future<Response> login({required String email, required String password}) =>
      apiClient.postData(
        AppConstants.loginUri,
        {'email': email, 'password': password},
        handleError: false,
      );

  @override
  Future<Response> sendOtp(String emailOrPhone) =>
      apiClient.postData(AppConstants.otpSendUri, {'identifier': emailOrPhone},
          handleError: false);

  @override
  Future<Response> verifyOtp({
    required String emailOrPhone,
    required String otp,
  }) =>
      apiClient.postData(
        AppConstants.otpVerifyUri,
        {'identifier': emailOrPhone, 'otp': otp},
        handleError: false,
      );

  @override
  Future<Response> socialLogin(SocialLoginBody body) =>
      apiClient.postData(AppConstants.googleAuthUri, body.toJson(),
          handleError: false);

  @override
  Future<Response> forgotPassword(String email) => apiClient.postData(
        AppConstants.forgotPasswordUri,
        {'email': email},
        handleError: false,
      );

  @override
  Future<Response> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) =>
      apiClient.postData(
        AppConstants.resetPasswordUri,
        {
          'email': email,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
        handleError: false,
      );

  @override
  Future<Response> fetchProfile() =>
      apiClient.getData(AppConstants.profileUri, handleError: false);
}
