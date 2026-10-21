import 'dart:io';

import 'package:easy_image_cropper/easy_image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/core/core_old/colors.dart';
import 'package:idee_pet/app/core/core_old/widgets/buttons.dart';
import 'package:idee_pet/app/core/core_old/widgets/text_styles.dart';
import 'package:idee_pet/app/modules/biometric/biometric_controller.dart';
import 'package:image_picker/image_picker.dart';

/// First step after creating a pet: add its profile picture, then continue
/// to the biometric guide / scanning.
class BiometricPetImagePage extends GetView<BiometricController> {
  const BiometricPetImagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cropKey = GlobalKey<ImgCropState>();
    Future<void> handlePickImage(ImageSource source) async {
      File? image;

      if (source == ImageSource.gallery) {
        image = await controller.pickImage(source);
      } else {
        await controller.goToCaptureImage(
          onImageCaptured: (String path) {
            Get.back(result: image = File(path));
          },
        );
      }

      if (image != null) {
        File? croppedImage;

        await Get.bottomSheet(
          backgroundColor: AppColors.background,
          isScrollControlled: true,
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: ImgCrop(
                      key: cropKey,
                      chipShape: ChipShape.circle,
                      maximumScale: 4,
                      image: FileImage(image!),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                CustomButton.filled(
                  title: Text(
                    'Concluir',
                    style: AppTextStyles.poppinsSemiBold(
                      color: AppColors.white,
                    ).style,
                  ),
                  action: () async {
                    croppedImage = await cropKey.currentState!
                        .cropCompleted(image!, pictureQuality: 900);

                    if (croppedImage != null) {
                      controller.updatePetProfile(croppedImage);
                      Get.back();
                    }
                  },
                ),
                SizedBox(height: 10),
                CustomButton.transparent(
                  action: Get.back,
                  title: Text(
                    'Cancelar',
                    style: AppTextStyles.poppinsSemiBold(
                      color: AppColors.primary,
                    ).style,
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 60),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    'Agora vamos adicionar\numa foto do seu pet',
                    style: AppTextStyles.title(fontSize: 24).style,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ClipOval(
                      child: Obx(
                        () {
                          return Container(
                            width: MediaQuery.of(context).size.width - 50,
                            height: MediaQuery.of(context).size.width - 50,
                            color: AppColors.greyWhite,
                            child: controller.petProfile() != null
                                ? Image.file(controller.petProfile()!,
                                    fit: BoxFit.cover)
                                : Icon(
                                    Icons.camera_alt,
                                    size: 50,
                                    color: AppColors.primary,
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
              Obx(
                () {
                  return controller.loadingPetProfile.value
                      ? LinearProgressIndicator(
                          backgroundColor: AppColors.greyWhite,
                          color: AppColors.primary)
                      : CustomButton.filled(
                          action: () {
                            if (controller.petProfile() == null) {
                              handlePickImage(ImageSource.camera);
                            } else {
                              controller.sendPetProfile();
                            }
                          },
                          title: Text(
                            controller.petProfile() == null
                                ? 'Tirar foto'
                                : 'Continuar',
                            style: AppTextStyles.poppinsSemiBold(
                              color: AppColors.background,
                            ).style,
                          ),
                        );
                },
              ),
              SizedBox(height: 10),
              Obx(
                () {
                  return CustomButton.transparent(
                    action: controller.loadingPetProfile()
                        ? null
                        : () {
                            if (controller.petProfile() == null) {
                              handlePickImage(ImageSource.gallery);
                            } else {
                              handlePickImage(ImageSource.camera);
                            }
                          },
                    title: Text(
                      controller.petProfile() == null
                          ? 'Escolher da galeria'
                          : 'Tirar outra',
                      style: AppTextStyles.poppinsSemiBold(
                        color: AppColors.primary,
                      ).style,
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
