import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';

class HomePage extends BasePage<HomeController> {
  const HomePage({super.key});

  @override
  Widget body(BuildContext context) {
    return Obx(
      () => controller.isLoading.isTrue
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                // TextButton(
                //     onPressed: () {
                //       Get.offAllNamed(BiometricsRoutes.biometrics,
                //           arguments: controller.appStateService.pet());
                //     },
                //     child: Text('Biometria')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Ola ${controller.appStateService.profile().name}!',
                        style: AppTextStyles.title(fontSize: 18).style),
                    Row(
                      children: [
                        Obx(() {
                          return InkWell(
                            onTap: () async {
                              await controller.goToNotifications();
                              controller.getIntNotifications();
                            },
                            borderRadius: BorderRadius.circular(15),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 6),
                              child: Stack(
                                children: [
                                  SvgPicture.asset(
                                    controller.notifications.value == 0
                                        ? 'assets/base/bell_inactive.svg'
                                        : 'assets/base/bell_ative.svg',
                                    width: 20,
                                    height: 20,
                                  ),
                                  if (controller.notifications > 0)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: AppColors.errorColor,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Text(
                                            controller.notifications.string,
                                            style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(width: 10),
                        InkWell(
                          radius: 15,
                          onTap: controller.goToProfile,
                          child: CircularImageWidget(
                            imageUrl:
                                controller.appStateService.profile().imageUrl,
                            size: 38,
                            borderColor: AppColors.primary,
                            borderWidth: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CardProfileWidget(
                  pet: controller.appStateService.pet(),
                  setPet: controller.setPet,
                  elevation: 0,
                  profile: controller.appStateService.profile(),
                  pets: controller.appStateService.pets,
                  addNewPet: controller.goToOnboardingCreatePet,
                  editPet: controller.goToEditDetails,
                  goToBiometricScanning: controller.goToBiometricScanning,
                ),
                const SizedBox(height: 10),
                CardHealthWidget(
                  elevation: 0,
                  onTap: controller.goToHealth,
                ),
                const SizedBox(height: 10),
                CardDetailsWidget(
                  pet: controller.appStateService.pet(),
                  elevation: 0,
                  // goToEditDetails: controller.goToEditDetails,
                  // goToEditSize: controller.goToEditSize,
                ),
                const SizedBox(height: 10),
                CardPersonalityWidget(
                  pet: controller.appStateService.pet(),
                  elevation: 0,
                  goToEditPersonality: controller.goToPersonality,
                ),
                const SizedBox(height: 10),
                CardFoodWidget(
                  pet: controller.appStateService.pet(),
                  elevation: 0,
                  goToEditFood: controller.goToEditFoodPet,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Obx(() => ElevatedButton.icon(
                        onPressed: controller.isSendingLostAlert.isTrue
                            ? null
                            : controller.sendLostPetAlert,
                        icon: controller.isSendingLostAlert.isTrue
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.pets, color: Colors.white),
                        label: Text(
                          'I lost my pet',
                          style: AppTextStyles.title(fontSize: 16)
                              .style
                              .copyWith(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.errorColor,
                          disabledBackgroundColor:
                              AppColors.errorColor.withAlpha(150),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      )),
                ),
                const SizedBox(height: 150),
              ],
            ),
    );
  }
}
