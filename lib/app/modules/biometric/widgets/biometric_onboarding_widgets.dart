import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idee_pet/app/app.dart';

/// Shared pieces of the noseprint onboarding screens (NF-01 / NF-01b).
const biometricOnboardingBackground = Color(0xFFF9F8F4);
const biometricOnboardingSubtitle = Color(0xFF5B6377);

TextStyle biometricPoppins(double size, FontWeight weight, Color color,
        {double? height}) =>
    TextStyle(
      fontFamily: 'Poppins',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
    );

class BiometricBackButton extends StatelessWidget {
  final VoidCallback onTap;

  const BiometricBackButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox.square(
          dimension: 40,
          child: Center(
            child: SvgPicture.asset(
                'assets/onboarding_biometric/how_to_do/arrow_left.svg'),
          ),
        ),
      ),
    );
  }
}

class BiometricLinkText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const BiometricLinkText(this.text, {super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style:
              biometricPoppins(15, FontWeight.w600, AppColors.primary).copyWith(
            decoration: TextDecoration.underline,
            decorationColor: AppColors.primary,
          ),
        ),
      ),
    );
  }
}

class BiometricPrimaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const BiometricPrimaryButton(
      {super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFCBD6FF),
            offset: Offset(0, 10),
            blurRadius: 10,
          ),
        ],
      ),
      child: Material(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: biometricPoppins(20, FontWeight.w600, Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class BiometricSecondaryButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const BiometricSecondaryButton(
      {super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: AppColors.primary),
    );
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFCBD6FF),
            offset: Offset(0, 10),
            blurRadius: 20,
          ),
        ],
      ),
      child: Material(
        color: biometricOnboardingBackground,
        shape: shape,
        child: InkWell(
          onTap: onTap,
          customBorder: shape,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: biometricPoppins(20, FontWeight.w600, AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pet-specific wording for the noseprint screens: cat vs dog content and
/// Portuguese articles by sex ("do Caju" / "da Nina").
class BiometricPetCopy {
  final Pet? pet;

  const BiometricPetCopy(this.pet);

  bool get isCat => pet?.type == PetType.cat;

  String get name {
    final name = pet?.name.trim() ?? '';
    return name.isEmpty ? 'seu pet' : name;
  }

  bool get _isFemale =>
      (pet?.name.trim() ?? '').isNotEmpty && pet?.petSex == PetSex.femea;

  /// "do Caju" / "da Nina"
  String get ofName => '${_isFemale ? 'da' : 'do'} $name';

  /// "o Caju" / "a Nina"
  String get theName => '${_isFemale ? 'a' : 'o'} $name';

  /// "ele" / "ela"
  String get pronoun => _isFemale ? 'ela' : 'ele';
}
