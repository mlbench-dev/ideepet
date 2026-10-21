import 'dart:io';

import 'package:easy_image_cropper/easy_image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/core/core_old/colors.dart';
import 'package:idee_pet/app/core/core_old/widgets/buttons.dart';
import 'package:idee_pet/app/core/core_old/widgets/text_styles.dart';
import 'package:idee_pet/app/modules/edit_pet/edit_pet_controller.dart';
import 'package:image_picker/image_picker.dart';

class EditImagePage extends GetView<EditPetController> {
  const EditImagePage({
    super.key,
  });

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
        late File? croppedImage;

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
                      image: FileImage(image!), // Passa a imagem para o ImgCrop
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
                    // Realiza o corte da imagem
                    croppedImage = await cropKey.currentState!
                        .cropCompleted(image!, pictureQuality: 900);

                    // Se a imagem cortada não for nula, atualiza o perfil do pet
                    if (croppedImage != null) {
                      controller.updatePetProfile(croppedImage);
                      Get.back(); // Fecha o bottom sheet
                    }
                  },
                ),
                SizedBox(height: 10),
                CustomButton.transparent(
                  action: Get.back, // Fecha o bottom sheet
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
      body: Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 60),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    icon: CircleAvatar(
                      backgroundColor: AppColors.greyWhite,
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.primary,
                      ),
                    ),
                    onPressed: () {
                      controller.navigatorPop();
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Agora vamos alterar\na foto do seu pet',
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
                                // 📸 imagem nova (File)
                                ? Image.file(
                                    controller.petProfile()!,
                                    fit: BoxFit.cover,
                                  )
                                // 🌐 imagem já salva (URL)
                                : controller.pet.avatarUrl != null &&
                                        controller.pet.avatarUrl!.isNotEmpty
                                    ? Image.network(
                                        controller.pet.avatarUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                          Icons.camera_alt,
                                          size: 50,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    // 👤 placeholder
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
                          action: controller.loadingPetProfile()
                              ? null
                              : () {
                                  if (controller.petProfile() == null) {
                                    handlePickImage(ImageSource.camera);
                                  } else {
                                    controller.sendPetProfile();
                                    //controller.nextPage();
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
