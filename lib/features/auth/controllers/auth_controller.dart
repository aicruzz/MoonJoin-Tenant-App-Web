import 'package:get/get.dart';
import 'package:moonjoin_cloud/common/widgets/custom_snackbar.dart';
import 'package:moonjoin_cloud/features/auth/domain/models/merchant_model.dart';
import 'package:moonjoin_cloud/features/auth/domain/models/sign_up_body_model.dart';
import 'package:moonjoin_cloud/features/auth/domain/models/social_login_body.dart';
import 'package:moonjoin_cloud/features/auth/domain/services/auth_service_interface.dart';

class AuthController extends GetxController implements GetxService {
  final AuthServiceInterface authService;
  AuthController({required this.authService});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _rememberMe = true;
  bool get rememberMe => _rememberMe;

  MerchantModel? _merchant;
  MerchantModel? get merchant => _merchant;

  String? _pendingIdentifier;
  String? get pendingIdentifier => _pendingIdentifier;

  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    update();
  }

  bool isLoggedIn() => authService.isLoggedIn();

  void clearSharedData() {
    authService.clearSession();
  }

  void setPendingIdentifier(String? value) {
    _pendingIdentifier = value;
  }

  Future<bool> register(SignUpBodyModel body) async {
    _isLoading = true;
    update();
    final result = await authService.register(body);
    _isLoading = false;
    update();
    if (result.isSuccess) {
      _pendingIdentifier = body.email;
      showCustomSnackBar(result.message, isError: false);
    } else {
      showCustomSnackBar(result.message);
    }
    return result.isSuccess;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    update();
    final result = await authService.login(email, password);
    _isLoading = false;
    update();
    if (result.isSuccess) {
      showCustomSnackBar(result.message, isError: false);
      await fetchProfile();
    } else {
      showCustomSnackBar(result.message);
    }
    return result.isSuccess;
  }

  Future<bool> sendOtp(String identifier) async {
    _isLoading = true;
    update();
    final result = await authService.sendOtp(identifier);
    _isLoading = false;
    update();
    if (result.isSuccess) {
      _pendingIdentifier = identifier;
      showCustomSnackBar(result.message, isError: false);
    } else {
      showCustomSnackBar(result.message);
    }
    return result.isSuccess;
  }

  Future<bool> verifyOtp(String otp) async {
    if (_pendingIdentifier == null) return false;
    _isLoading = true;
    update();
    final result = await authService.verifyOtp(_pendingIdentifier!, otp);
    _isLoading = false;
    update();
    if (result.isSuccess) {
      showCustomSnackBar(result.message, isError: false);
    } else {
      showCustomSnackBar(result.message);
    }
    return result.isSuccess;
  }

  Future<bool> socialLogin(SocialLoginBody body) async {
    _isLoading = true;
    update();
    final result = await authService.socialLogin(body);
    _isLoading = false;
    update();
    if (result.isSuccess) {
      showCustomSnackBar(result.message, isError: false);
    } else {
      showCustomSnackBar(result.message);
    }
    return result.isSuccess;
  }

  Future<bool> forgotPassword(String email) async {
    _isLoading = true;
    update();
    final result = await authService.forgotPassword(email);
    _isLoading = false;
    update();
    if (result.isSuccess) {
      _pendingIdentifier = email;
      showCustomSnackBar(result.message, isError: false);
    } else {
      showCustomSnackBar(result.message);
    }
    return result.isSuccess;
  }

  Future<bool> resetPassword(
      String otp, String password, String confirm) async {
    if (_pendingIdentifier == null) return false;
    _isLoading = true;
    update();
    final result = await authService.resetPassword(
        _pendingIdentifier!, otp, password, confirm);
    _isLoading = false;
    update();
    if (result.isSuccess) {
      showCustomSnackBar(result.message, isError: false);
    } else {
      showCustomSnackBar(result.message);
    }
    return result.isSuccess;
  }

  Future<void> fetchProfile() async {
    final result = await authService.fetchProfile();
    if (result.isSuccess && result.data is Map) {
      try {
        final raw = result.data['merchant'] ?? result.data['data'] ?? result.data;
        _merchant = MerchantModel.fromJson(Map<String, dynamic>.from(raw));
        update();
      } catch (_) {}
    }
  }

  Future<void> logout() async {
    await authService.clearSession();
    _merchant = null;
    _pendingIdentifier = null;
    update();
  }
}
