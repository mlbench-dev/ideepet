import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/modules/biometric/camera_permission_page.dart';
import 'package:idee_pet/app/modules/biometric/widgets/biometric_onboarding_widgets.dart';
import 'package:idee_pet/app/modules/biometric/widgets/reading_examples_sheet.dart';

/// NF-01b · Como fazer a leitura: tips shown right before opening the camera.
class BiometricGuidePage extends StatefulWidget {
  const BiometricGuidePage({super.key});

  @override
  State<BiometricGuidePage> createState() => _BiometricGuidePageState();
}

class _BiometricGuidePageState extends State<BiometricGuidePage> {
  static const _assets = 'assets/onboarding_biometric/how_to_read';

  late final Pet? pet = Get.arguments is Pet ? Get.arguments as Pet : null;

  late final copy = BiometricPetCopy(pet);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: biometricOnboardingBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 37),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BiometricBackButton(onTap: () => Navigator.pop(context)),
                    const SizedBox(height: 16),
                    Text(
                      'Como fazer a leitura',
                      style: biometricPoppins(
                          24, FontWeight.w700, AppColors.primary,
                          height: 29 / 24),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Full-bleed illustration, 375 x 212 in the design.
              AspectRatio(
                aspectRatio: 375 / 212,
                child: SvgPicture.asset(
                    copy.isCat
                        ? '$_assets/illustration_cat.svg'
                        : '$_assets/illustration.svg',
                    fit: BoxFit.contain),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 37),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 22),
                    _TipRow(
                      icon: copy.isCat
                          ? '$_assets/icon_cat_face.svg'
                          : '$_assets/icon_dog_face.svg',
                      title: 'De frente, na altura ${copy.ofName}',
                      subtitle: 'Olhos e focinho juntos na moldura.',
                    ),
                    const SizedBox(height: 21),
                    const _TipRow(
                      icon: '$_assets/icon_sun.svg',
                      title: 'Boa luz',
                      subtitle: 'Perto da janela ou com a luz acesa.',
                    ),
                    const SizedBox(height: 21),
                    _TipRow(
                      icon: '$_assets/icon_hand.svg',
                      title: copy.isCat
                          ? 'Um carinho no queixo'
                          : 'Mão no queixo, com carinho',
                      subtitle: copy.isCat
                          ? 'Acalma ${copy.theName}. Sem cobrir o focinho.'
                          : 'Sem cobrir o focinho.',
                    ),
                    const SizedBox(height: 21),
                    const _TipRow(
                      icon: '$_assets/icon_tap.svg',
                      title: 'Toque uma vez e solte',
                      subtitle: 'Celular firme por 5 segundos.',
                    ),
                    const SizedBox(height: 21),
                    BiometricLinkText(
                      'Ver exemplos de leitura',
                      onTap: () => showReadingExamplesSheet(context, pet),
                    ),
                    const SizedBox(height: 24),
                    BiometricPrimaryButton(
                      title: 'Abrir a câmera',
                      onTap: () => openBiometricScanning(pet),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const _TipRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: SizedBox.square(
            dimension: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SvgPicture.asset(
                    '${_BiometricGuidePageState._assets}/icon_background.svg',
                    width: 36,
                    height: 36),
                SvgPicture.asset(icon, width: 20, height: 20),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: biometricPoppins(15, FontWeight.w600, AppColors.primary,
                    height: 20 / 15),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: biometricPoppins(
                    13, FontWeight.w500, biometricOnboardingSubtitle,
                    height: 18 / 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
