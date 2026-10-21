import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomLogo extends StatelessWidget {
  final String logoPath;
  final double width;
  final double height;
  final BoxFit fit;
  final bool isPng;

  const CustomLogo._({
    required this.logoPath,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.isPng = false,
  });

  factory CustomLogo.logoIcon({double width = 120, double height = 120}) {
    return CustomLogo._(
      logoPath: 'assets/logo_icon.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.logoIconWhite({double width = 120, double height = 120}) {
    return CustomLogo._(
      logoPath: 'assets/logo_icon2.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.logoName({double width = 120, double height = 120}) {
    return CustomLogo._(
      logoPath: 'assets/logo_name.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.pets({double width = 180, double height = 180}) {
    return CustomLogo._(
      logoPath: 'assets/pets.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.wallpaperOnboarding(
      {double width = 180, double height = 180}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding/dog_wallpaper.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.dogCatOnboarding(
      {double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding/dog_cat.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.dogOnboarding({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding/dog.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.catOnboarding({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding/giant_cat.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.biometricDog1({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding_biometric/dog1.svg',
      width: width,
      height: height,
    );
  }
  factory CustomLogo.logoOutline({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/logo_outline.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.biometricCat1({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding_biometric/cat1.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.biometricDog2({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding_biometric/dog2.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.biometricCat2({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding_biometric/cat2.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.biometricDog3({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding_biometric/dog3.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.biometricCat3({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding_biometric/cat3.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.biometricDog4({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding_biometric/dog4.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.biometricDog5({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding_biometric/dog5.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.biometricCat4({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding_biometric/cat4.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.biometricCat5({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding_biometric/cat5.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.homePetHealth({
    double width = 260,
    double height = 144,
  }) {
    return CustomLogo._(
      logoPath: 'assets/home/pethealth.svg',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  factory CustomLogo.homePetHealthCircle(
      {double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/home/circlehealth.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.homePetHeart({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/home/heart.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.homeCalendar({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/home/calendar.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.homeFood({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/home/foodDog.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.homePersonality(
      {double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/home/customPersonality.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.healthDog({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/health/dog.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.healthTrash({double width = 260, double height = 144}) {
    return CustomLogo._(
      logoPath: 'assets/health/trash.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.cameraUnfocus({double width = 250, double height = 300}) {
    return CustomLogo._(
      logoPath: 'assets/onboarding_biometric/unfocus.svg',
      width: width,
      height: height,
    );
  }

  factory CustomLogo.newPasswordSuccess(
          {double width = 180, double height = 180}) =>
      CustomLogo._(
        logoPath: 'assets/new_password_success/success_image.png',
        width: width,
        height: height,
        isPng: true,
      );

  @override
  Widget build(BuildContext context) {
    if (isPng) {
      return Image.asset(
        logoPath,
        width: width,
        height: height,
      );
    }
    return SvgPicture.asset(
      logoPath,
      width: width,
      height: height,
    );
  }
}
