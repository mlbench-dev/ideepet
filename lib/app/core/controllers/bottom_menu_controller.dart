import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/modules/find_pet/pet_type_dialog.dart';
import 'package:idee_pet/app/routes/find_pet_routes.dart';

class BottomMenuController extends GetxController {
  BottomMenuController(this.navigationService, this.appStateService);
  final AppStateService appStateService;
  final NavigationService navigationService;

  var tabIndex = 0.obs;
  void changeTabIndex(int index) {
    appStateService.activePageIndex(index);

    tabIndex.value = index;

    switch (index) {
      case 0:
        _goToHome();
        break;
      case 1:
        _goToHealth();
        break;
      // case 2:
      //   _goToNotifications();
      //   break;
      case 3:
        _goToProfile();
        break;
      default:
        _goToHome();
    }
  }

  void updateTabIndex(String route) {
    int newIndex;

    if (route == HomeRoutes.home) {
      newIndex = 0;
    } else if (route == HealthRoutes.health) {
      newIndex = 1;
    } else if (route == NotificationsRoutes.notifications) {
      newIndex = 2;
    }
    // else
    // if (route == ProfileRoutes.profile) {
    //   newIndex = 3;
    // }
    else {
      return; // Se não for uma rota válida, sai sem fazer nada
    }

    // Atualiza tanto o estado local quanto o global
    tabIndex.value = newIndex;
    appStateService.activePageIndex(newIndex);
  }

  void _goToHome() {
    navigationService.offAllNamed(HomeRoutes.home);
  }

  void _goToHealth() {
    navigationService.offAllNamed(HealthRoutes.health);
  }

  // void _goToNotifications() {
  //   navigationService.offAllNamed(NotificationsRoutes.notifications);
  // }

  void _goToProfile() {
    // navigationService.offAllNamed(ProfileRoutes.profile);
  }

  Future<void> goToFindPet() async {
    final petType = await showPetTypeDialog();
    if (petType == null) return;
    navigationService.toNamed(
      FindPetRoutes.guide,
      arguments: {'pet': petType.value},
    );
  }
}
