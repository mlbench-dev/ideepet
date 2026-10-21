import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/modules/biometric/widgets/biometric_onboarding_widgets.dart';
import 'package:idee_pet/app/routes/biometric_routes.dart';

/// Explains why the noseprint matters before the user starts the capture.
class HowToDo extends StatefulWidget {
  const HowToDo({super.key});

  @override
  State<HowToDo> createState() => _HowToDoState();
}

class _HowToDoState extends State<HowToDo> {
  static const _assets = 'assets/onboarding_biometric/how_to_do';

  late final Pet? pet = Get.arguments is Pet ? Get.arguments as Pet : null;

  late final copy = BiometricPetCopy(pet);

  void _goToGuide() => Get.toNamed(BiometricRoutes.guide, arguments: pet);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: biometricOnboardingBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(37, 12, 37, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BiometricBackButton(onTap: () => Navigator.pop(context)),
              const SizedBox(height: 16),
              Text(
                'Por fim, a digital do focinho ${copy.ofName}',
                style: biometricPoppins(24, FontWeight.w700, AppColors.primary,
                    height: 29 / 24),
              ),
              const SizedBox(height: 12),
              Text(
                'Cada focinho é único, como uma impressão digital. Com a '
                'digital registrada, fica mais fácil reencontrar ${copy.theName} '
                'se um dia ${copy.pronoun} se perder.',
                style: biometricPoppins(
                    14, FontWeight.w500, biometricOnboardingSubtitle,
                    height: 20 / 14),
              ),
              const SizedBox(height: 16),
              const Center(child: _NoseprintEmblem()),
              const SizedBox(height: 12),
              const _InfoRow(
                icon: '$_assets/icon_sparkles.svg',
                text: 'Da sua parte, leva menos de 1 minuto',
              ),
              const SizedBox(height: 7),
              _InfoRow(
                icon: '$_assets/icon_paw.svg',
                text: 'Basta ter o celular e ${copy.theName} por perto',
              ),
              const SizedBox(height: 7),
              const _InfoRow(
                icon: '$_assets/icon_lock.svg',
                text: 'Os dados ficam protegidos no cofre iDee Pet',
              ),
              const SizedBox(height: 12),
              BiometricLinkText(
                'Como protegemos a leitura',
                // TODO: no destination defined yet for this explanation.
                onTap: () {},
              ),
              const SizedBox(height: 19),
              BiometricPrimaryButton(
                  title: 'Ver como fazer', onTap: _goToGuide),
              const SizedBox(height: 28),
              BiometricLinkText(
                'Fazer depois',
                onTap: () => Get.offAllNamed(HomeRoutes.home, arguments: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoseprintEmblem extends StatelessWidget {
  const _NoseprintEmblem();

  @override
  Widget build(BuildContext context) {
    const assets = _HowToDoState._assets;
    return SizedBox.square(
      dimension: 128,
      child: Stack(
        children: [
          SvgPicture.asset('$assets/emblem_background.svg',
              width: 128, height: 128),
          SvgPicture.asset('$assets/emblem_corners.svg',
              width: 128, height: 128),
          Positioned(
            left: 26,
            top: 34.4,
            child: SvgPicture.asset('$assets/emblem_logo.svg',
                width: 76, height: 59.3),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox.square(
          dimension: 32,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SvgPicture.asset('${_HowToDoState._assets}/icon_background.svg',
                  width: 32, height: 32),
              SvgPicture.asset(icon, width: 20, height: 20),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 206,
          child: Text(
            text,
            style: biometricPoppins(14, FontWeight.w500, AppColors.primary,
                height: 20 / 14),
          ),
        ),
      ],
    );
  }
}
