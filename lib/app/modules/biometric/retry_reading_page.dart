import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/modules/biometric/widgets/biometric_onboarding_widgets.dart';
import 'package:idee_pet/app/modules/biometric/widgets/reading_examples_sheet.dart';

/// NF-04 · Nova leitura necessária: shown when the noseprint read fails.
/// Pops back to the scanning screen, which then resets for a new recording.
class RetryReadingPage extends StatelessWidget {
  const RetryReadingPage({super.key});

  static const _assets = 'assets/onboarding_biometric/retry_reading';

  Pet? get _pet => Get.arguments is Pet ? Get.arguments as Pet : null;

  @override
  Widget build(BuildContext context) {
    final pet = _pet;
    final copy = BiometricPetCopy(pet);
    return Scaffold(
      backgroundColor: biometricOnboardingBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(37, 8, 37, 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                // The close button sits 4px closer to the edge in the design.
                child: GestureDetector(
                  onTap: () =>
                      Get.offAllNamed(HomeRoutes.home, arguments: true),
                  child: Transform.translate(
                    offset: const Offset(4, 0),
                    child: SvgPicture.asset('$_assets/close.svg',
                        width: 48, height: 48),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ReadingExampleThumbnail(
                example: ReadingExample.ok,
                isCat: copy.isCat,
              ),
              const SizedBox(height: 8),
              Text(
                'Assim sim',
                textAlign: TextAlign.center,
                style: biometricPoppins(13, FontWeight.w600, AppColors.primary,
                    height: 18 / 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 234,
                child: Text(
                  'Vamos fazer uma nova leitura?',
                  textAlign: TextAlign.center,
                  style: biometricPoppins(
                      24, FontWeight.w700, AppColors.primary,
                      height: 29 / 24),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'A leitura do focinho ${copy.ofName} não deu certo desta vez. '
                'Acontece com muitos pets. A nova leitura leva só 5 segundos.',
                textAlign: TextAlign.center,
                style: biometricPoppins(
                    14, FontWeight.w500, biometricOnboardingSubtitle,
                    height: 20 / 14),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EDE4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Tip(
                      icon: copy.isCat
                          ? '$_assets/icon_cat_face.svg'
                          : '$_assets/icon_dog_face.svg',
                      text: 'Rosto inteiro, de frente, na moldura',
                    ),
                    SizedBox(height: 8),
                    _Tip(
                      icon: '$_assets/icon_sun.svg',
                      text: 'Lugar bem iluminado',
                    ),
                    SizedBox(height: 8),
                    _Tip(
                      icon: '$_assets/icon_phone.svg',
                      text: 'Celular firme até a moldura fechar',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 17),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset('$_assets/icon_check.svg',
                      width: 16, height: 16),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'O cadastro ${copy.ofName} continua salvo.',
                      style: biometricPoppins(
                          12, FontWeight.w500, biometricOnboardingSubtitle,
                          height: 18 / 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              BiometricPrimaryButton(
                title: 'Fazer nova leitura',
                onTap: () => Get.back(),
              ),
              const SizedBox(height: 12),
              BiometricSecondaryButton(
                title: 'Ver exemplos de leitura',
                onTap: () => showReadingExamplesSheet(context, pet),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final String icon;
  final String text;

  const _Tip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(icon, width: 18, height: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: biometricPoppins(13, FontWeight.w500, AppColors.primary,
                height: 20 / 13),
          ),
        ),
      ],
    );
  }
}
