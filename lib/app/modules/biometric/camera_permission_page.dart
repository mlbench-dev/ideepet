import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/modules/biometric/widgets/biometric_onboarding_widgets.dart';
import 'package:idee_pet/app/routes/biometric_routes.dart';
import 'package:permission_handler/permission_handler.dart';

/// Opens the noseprint camera, or NF-02a when camera access was refused.
Future<void> openBiometricScanning(Pet? pet) async {
  final status = await Permission.camera.request();
  if (status.isGranted || status.isLimited) {
    Get.toNamed(BiometricRoutes.scanning, arguments: pet);
  } else {
    Get.toNamed(BiometricRoutes.cameraPermission, arguments: pet);
  }
}

/// NF-02a · Acesso à câmera negado.
class CameraPermissionPage extends StatefulWidget {
  const CameraPermissionPage({super.key});

  @override
  State<CameraPermissionPage> createState() => _CameraPermissionPageState();
}

class _CameraPermissionPageState extends State<CameraPermissionPage>
    with WidgetsBindingObserver {
  static const _assets = 'assets/onboarding_biometric/camera_permission';

  late final Pet? pet = Get.arguments is Pet ? Get.arguments as Pet : null;
  bool _leaving = false;

  String get _petName {
    final name = pet?.name.trim() ?? '';
    return name.isEmpty ? 'seu pet' : name;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// The user may grant access in the system settings and come back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _openCameraIfGranted();
  }

  Future<void> _openCameraIfGranted() async {
    if (_leaving || !await Permission.camera.isGranted) return;
    _leaving = true;
    Get.offNamed(BiometricRoutes.scanning, arguments: pet);
  }

  Future<void> _openSettings() async {
    // Android can still show the system prompt until the user picks
    // "don't ask again"; iOS only allows changing it in Settings.
    if (GetPlatform.isAndroid && await Permission.camera.isDenied) {
      await Permission.camera.request();
      await _openCameraIfGranted();
      if (_leaving || !await Permission.camera.isPermanentlyDenied) return;
    }
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    final isIOS = GetPlatform.isIOS;
    final settingsName =
        isIOS ? 'Ajustes do iPhone' : 'Configurações do celular';
    final settingsPath = isIOS
        ? 'Ajustes > iDee Pet > Câmera'
        : 'Configurações > Apps > iDee Pet > Permissões';

    return Scaffold(
      backgroundColor: biometricOnboardingBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(37, 12, 37, 24),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: BiometricBackButton(
                            onTap: () => Navigator.pop(context)),
                      ),
                      const SizedBox(height: 44),
                      SizedBox.square(
                        dimension: 96,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SvgPicture.asset('$_assets/icon_circle.svg',
                                width: 96, height: 96),
                            SvgPicture.asset('$_assets/icon_camera_off.svg',
                                width: 40, height: 40),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: 200,
                        child: Text(
                          'Libere o acesso à câmera',
                          textAlign: TextAlign.center,
                          style: biometricPoppins(
                              24, FontWeight.w700, AppColors.primary,
                              height: 29 / 24),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 268,
                        child: Text(
                          'Para fazer a leitura do focinho do $_petName, '
                          'permita o acesso à câmera nos $settingsName.',
                          textAlign: TextAlign.center,
                          style: biometricPoppins(
                              14, FontWeight.w500, biometricOnboardingSubtitle,
                              height: 20 / 14),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1EDE4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset('$_assets/icon_settings.svg',
                                width: 16, height: 16),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                settingsPath,
                                style: biometricPoppins(
                                    13, FontWeight.w600, AppColors.primary,
                                    height: 16 / 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 32),
                      BiometricPrimaryButton(
                        title: isIOS ? 'Abrir Ajustes' : 'Abrir Configurações',
                        onTap: _openSettings,
                      ),
                      const SizedBox(height: 28),
                      BiometricLinkText(
                        'Fazer depois',
                        onTap: () =>
                            Get.offAllNamed(HomeRoutes.home, arguments: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
