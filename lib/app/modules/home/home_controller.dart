import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/modules/biometric/camera_permission_page.dart';

class HomeController extends GetxController {
  final AuthService _authService;
  final HomeRepository _repository;
  final AppStateService appStateService;
  final NavigationService _navigationService;

  HomeController(
    this._authService,
    this._repository,
    this.appStateService,
    this._navigationService,
  );

  final isLoading = false.obs;
  late final bool reload;

  void goToBiometry() => _navigationService.toNamed(BiometricsRoutes.biometrics,
      arguments: appStateService.pet());

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is bool) {
      reload = Get.arguments;
    } else {
      reload = false;
    }
    getIntNotifications();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    isLoading(true);
    if (appStateService.pets.isEmpty || reload) {
      await Future.wait([_getProfile(), _getPets()]);
    }
    if (appStateService.pets.isEmpty) {
      await Get.offAllNamed(NewPetRoutes.newPet);
    }
    isLoading(false);
    // One after the other so the two permission dialogs don't overlap.
    await _syncUserLocation();
    PushNotificationService.syncToken();
  }

  /// If the user has no saved location yet, asks for location permission and
  /// saves the coordinates on the backend. Does nothing if the user denies it.
  Future<void> _syncUserLocation() async {
    // Profile.empty() has id '---', meaning /users/me was not loaded yet.
    if (appStateService.profile().id == '---') await _getProfile();

    final profile = appStateService.profile();
    if (profile.id == '---' || _hasValue(profile.addressLat) &&
        _hasValue(profile.addressLong)) {
      return;
    }

    final position = await _getCurrentPositionOrNull();
    if (position == null) return;

    final response = await Get.find<UserRepository>()
        .updateLocation(position.latitude, position.longitude);
    if (response.success) {
      appStateService.profile.update((profile) {
        profile?.addressLat = position.latitude.toString();
        profile?.addressLong = position.longitude.toString();
      });
    }
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;

  Future<void> _getPets() async {
    final response = await _repository.getPets();
    if (response.result != null) {
      appStateService.pets(response.result);
      if (appStateService.pets.isNotEmpty) {
        setPet(response.result!.first);
      }
    }
  }

  Future<void> _getProfile() async {
    final response = await _authService.getProfile();
    if (response != null) {
      appStateService.profile(response);
      BugTracking().identify(response);
    }
  }

  void setPet(Pet newPet) {
    appStateService.setPet(newPet);
  }

  void setProfile(Profile newProfile) {
    appStateService.setProfile(newProfile);
  }

  void goToHealth() {
    _navigationService.offAllNamed(HealthRoutes.health);
  }

  void openDrawer() {
    appStateService.scaffoldKey.currentState?.openDrawer();
  }

  void goToOnboardingCreatePet() {
    _navigationService
      ..back()
      ..toNamed(NewPetRoutes.newPet);
  }

  void goToEditFoodPet() {
    _navigationService.toNamed(EditPetRoutes.editFood,
        arguments: appStateService.pet());
  }

  void goToPersonality() {
    _navigationService.toNamed(EditPetRoutes.editPersonality,
        arguments: appStateService.pet());
  }

  void goToHealthDetails() {
    _navigationService.toNamed(HealthRoutes.healthCondition);
  }

  void goToEditDetails() {
    _navigationService.toNamed(EditPetRoutes.editDetails,
        arguments: appStateService.pet());
  }

  void goToEditSize() {
    _navigationService.toNamed(EditPetRoutes.editSize,
        arguments: appStateService.pet());
  }

  void goToBiometricScanning() {
    openBiometricScanning(appStateService.pet());
  }

  Future<void> goToNotifications() async {
    await _navigationService.toNamed(NotificationsRoutes.notifications);
  }

  void goToProfile() {
    _navigationService.toNamed(HomeRoutes.profile);
  }

  final isSendingLostAlert = false.obs;

  Future<void> sendLostPetAlert() async {
    if (isSendingLostAlert.isTrue) return;

    final pet = appStateService.pet();
    if (!await showLostPetDialog(pet)) return;

    isSendingLostAlert(true);
    final position = await _getCurrentPositionOrNull();
    final response = await _repository.sendLostPetAlert(
      pet.id,
      lat: position?.latitude,
      long: position?.longitude,
    );
    isSendingLostAlert(false);

    if (response.success) {
      showSuccess(
        message: response.result?.isNotEmpty == true
            ? response.result!
            : 'Alerta enviado para a vizinhança.',
      );
    } else {
      showError(
        message: response.errorMessages.isNotEmpty
            ? response.errorMessages.first.toString()
            : 'Não foi possível enviar o alerta',
      );
    }
  }

  /// Returns the device location when available. On any failure it returns
  /// null and the backend falls back to the owner's saved address.
  Future<Position?> _getCurrentPositionOrNull() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      try {
        return await Geolocator.getLastKnownPosition();
      } catch (_) {
        return null;
      }
    }
  }

  RxInt notifications = 0.obs;

  void getIntNotifications() async {
    final response = await _repository.getIntNotifications();

    if (response.result != null) {
      notifications.value = response.result!;
    } else {
      showError(message: response.errorMessages?.first ?? 'Algo deu errado');
    }
  }
}
