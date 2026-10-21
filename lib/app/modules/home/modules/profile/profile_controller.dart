import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/core/core_old/handler/handler.dart';
import 'package:idee_pet/app/modules/home/modules/profile/repository/profile_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class ProfileController extends GetxController {
  final AppStateService appStateService;
  final NavigationService _navigationService;
  final AuthService _authService;
  final ProfileRepository profileRepository;
  ProfileController(
    this.appStateService,
    this._navigationService,
    this._authService,
    this.profileRepository,
  );

  final loadingMap = true.obs;

  late final latitude = 0.0.obs;
  late final longitude = 0.0.obs;

  final mapController = MapController(
    initPosition: GeoPoint(
      latitude: 0,
      longitude: 0,
    ),
  ).obs;

  @override
  void onInit() {
    if (appStateService.profile().addressLat != null &&
        appStateService.profile().addressLat != '' &&
        appStateService.profile().addressLong != null &&
        appStateService.profile().addressLong != '') {
      latitude.value = double.parse(appStateService.profile().addressLat!);
      longitude.value = double.parse(appStateService.profile().addressLong!);
    } else {
      requestLocationPermission();
      return;
    }
    mapController(MapController(
      initPosition: GeoPoint(
        latitude: latitude(),
        longitude: longitude(),
      ),
    ));
    _setMarker();
    loadingMap(false);
    super.onInit();
  }

  Future<void> requestLocationPermission() async {
    final permission = await requestPermission(Permission.location);
    if (permission) {
      await getCurrentPosition();
    }
  }

  Future<GeoPoint?> getCurrentPosition() async {
    loadingMap(true);
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showError(
        message: 'Ative o GPS do seu dispositivo',
      );
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showError(
          message: 'Permissão de localização negada',
        );
        loadingMap(false);
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      showError(
        message: 'Permissão de localização negada permanentemente',
      );
      loadingMap(false);
      return null;
    }
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    ).catchError((error) {
      showError(
        message: 'Erro ao obter localização',
      );
      loadingMap(false);
      return null;
    });
    if (position == null) {
      showError(
        message: 'Erro ao obter localização',
      );
      loadingMap(false);
      return null;
    }
    latitude.value = position.latitude;
    longitude.value = position.longitude;
    mapController(
      MapController(
        initPosition: GeoPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      ),
    );
    loadingMap(false);
    _setMarker();
    return GeoPoint(
      latitude: latitude(),
      longitude: longitude(),
    );
  }

  Future<void> _setMarker() async {
    await Future.delayed(Duration(seconds: 2));
    if (isClosed) return;
    try {
      await mapController().addMarker(
        GeoPoint(latitude: latitude(), longitude: longitude()),
        markerIcon: MarkerIcon(
          iconWidget: CircularImageWidget(
            imageUrl: appStateService.pet().avatarUrl,
            size: 40,
            borderColor: AppColors.successColor,
          ),
        ),
      );
    } catch (_) {
      // flutter_osm_plugin screenshots the marker widget to render it;
      // if the user navigated away before this delayed call fired, the
      // map's repaint boundary is off-stage and the capture throws.
    }
    if (!isClosed) loadingMap(false);
  }

  void gotoEditPersonalInfo() {
    _navigationService.toNamed(OnboardingRoutes.onboarding, arguments: true);
  }

  void gotoEditPersonalInfoPhoto() {
    _navigationService.toNamed(
      OnboardingRoutes.onboarding,
      arguments: {
        'isChanging': true,
        'initialPage': 1, // página 2 (index 0-based)
      },
    );
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  RxBool loadingDeleteAccount = false.obs;

  Future<void> deleteAccount() async {
    loadingDeleteAccount(true);
    final response =
        await profileRepository.deleteUser(appStateService.profile().id);
    loadingDeleteAccount(false);
    if (response.success) {
      await _authService.logout();
    } else {
      showError(message: 'Erro ao deletar conta');
    }
  }
}
