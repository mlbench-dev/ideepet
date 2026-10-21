import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/modules/find_pet/pet_type_dialog.dart';
import 'package:idee_pet/app/routes/find_pet_routes.dart';

class InitialController extends GetxController {
  final NavigationService _navigationService;
  InitialController(this._navigationService);

  void goToLogin() => _navigationService.offAllNamed(LoginRoutes.login);
  void goToOnboarding() =>
      _navigationService.toNamed(OnboardingRoutes.onboarding);

  Future<void> goToFindPet() async {
    final petType = await showPetTypeDialog();
    if (petType == null) return;
    _navigationService.toNamed(
      FindPetRoutes.guide,
      arguments: {'pet': petType.value},
    );
  }
}
