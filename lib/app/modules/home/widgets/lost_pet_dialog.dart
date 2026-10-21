import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';

/// Asks the owner to confirm sending the lost pet alert to nearby neighbors.
/// Returns `true` when the owner confirms.
Future<bool> showLostPetDialog(Pet pet) async {
  final confirmed = await Get.dialog<bool>(
    _LostPetDialog(pet: pet),
    barrierDismissible: true,
  );
  return confirmed ?? false;
}

class _LostPetDialog extends StatelessWidget {
  const _LostPetDialog({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircularImageWidget(
                  imageUrl: pet.avatarUrl,
                  size: 84,
                  borderColor: AppColors.errorColor,
                  borderWidth: 2,
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.errorColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.background, width: 2),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      size: 18,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Perdeu ${pet.name}?',
              textAlign: TextAlign.center,
              maxLines: 2,
              style: AppTextStyles.title(fontSize: 22).style,
            ),
            const SizedBox(height: 10),
            Text(
              'Vamos enviar um alerta para os vizinhos em um raio de '
              'aproximadamente 5 km, com a foto e os dados do seu pet.',
              textAlign: TextAlign.center,
              maxLines: 4,
              style: AppTextStyles.poppinsMedium(
                fontSize: 14,
                color: AppColors.grey,
              ).style,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.errorColor.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 20,
                    color: AppColors.errorColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Usaremos sua localização atual ou o endereço '
                      'cadastrado.',
                      maxLines: 3,
                      style: AppTextStyles.poppinsMedium(
                        fontSize: 12,
                        color: AppColors.primary,
                      ).style,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.errorColor,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Enviar alerta',
                  style: AppTextStyles.poppinsSemiBold(
                    fontSize: 15,
                    color: AppColors.white,
                  ).style,
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(result: false),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  'Cancelar',
                  style: AppTextStyles.poppinsSemiBold(
                    fontSize: 15,
                    color: AppColors.primary,
                  ).style,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
