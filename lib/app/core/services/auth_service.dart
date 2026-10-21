import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';

class AuthService extends GetxService {
  AuthService(this._navigationService);

  final NavigationService _navigationService;

  final AuthRepository _authRepository = Get.find();
  late final TokenService _tokenStorage;
  late final UserRepository _userRepository;

  @override
  Future<void> onInit() async {
    super.onInit();
    _tokenStorage = await Get.putAsync(() async => TokenService(this));
    _userRepository = await Get.putAsync(() async => UserRepository());
  }

  Future<LoginResult> login(final SignInRequest request) async {
    final response = await _authRepository.signIn(request);

    if (response.result != null && response.success) {
      if (response.result?.code == null) {
        await makeLogin(response.result!);
        return LoginResult(LoginStatus.success);
      } else {
        return LoginResult(LoginStatus.otpRequired,
            otpCode: response.result?.code);
      }
    }

    return LoginResult(LoginStatus.error);
  }

  Future<void> makeLogin(SignInResponse response) async {
    await _tokenStorage.saveTokens(response);
    if (kDebugMode) {
      print('@@@ Token: ${response.accessToken}');
    }
  }

  Future<void> logout() async {
    await PushNotificationService.clearToken();
    await _tokenStorage.clearTokens();
    final appStateService = Get.find<AppStateService>();
    appStateService.cleanAllData();
    _navigationService.offAllNamed(SplashRoutes.splash);
  }

  Future<bool> refreshToken(final RefreshTokenRequest request) async {
    final refreshToken = await _tokenStorage.getRefreshToken();

    if (refreshToken != null) {
      final request = RefreshTokenRequest(refreshToken: refreshToken);
      final response = await _authRepository.refreshToken(request);
      if (response.result != null && response.success) {
        final SignInResponse signInResponse = SignInResponse(
          accessToken: response.result!.accessToken,
          refreshToken: refreshToken,
        );

        await _tokenStorage.saveTokens(signInResponse);
        return true;
      }
    }
    return false;
  }

  Future<Profile?> getProfile() async {
    final response = await _userRepository.getProfile();
    if (response.result != null && response.success) {
      return response.result!;
    }
    return null;
  }

  Future<bool> resenCodeToChangePassword({required String email}) async {
    final response = await _authRepository.sendResetEmail(email: email);
    if (response.success) {
      return true;
    }
    return false;
  }

  Future<Profile?> updateUserData(UpdateUserRequest request) async {
    final response = await _userRepository.updateUser(request);
    if (response.success) {
      return response.result!;
    }
    return null;
  }

  Future<Profile?> getProfileWithoutRedirect() async {
    final response = await _userRepository.getProfileWithoutRedirect();
    if (response.result != null && response.success) {
      return response.result!;
    }
    return null;
  }
}
