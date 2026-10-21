import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';

/// Pet species sent to POST /pets/identify_pet/ as the `pet` field.
enum PetType {
  dog('dog', 'Cachorro', Icons.pets),
  cat('cat', 'Gato', Icons.pets);

  const PetType(this.value, this.label, this.icon);

  final String value;
  final String label;
  final IconData icon;
}

/// Asks the user whether the pet being searched is a dog or a cat.
/// Returns `null` if the dialog is dismissed without a choice.
Future<PetType?> showPetTypeDialog() {
  return Get.dialog<PetType>(
    const _PetTypeDialog(),
    barrierDismissible: true,
  );
}

class _PetTypeDialog extends StatelessWidget {
  const _PetTypeDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Qual é o tipo do pet?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecione se o pet encontrado é um cachorro ou um gato.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                for (final type in PetType.values) ...[
                  if (type != PetType.values.first) const SizedBox(width: 12),
                  Expanded(child: _PetTypeOption(type: type)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PetTypeOption extends StatelessWidget {
  const _PetTypeOption({required this.type});

  final PetType type;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Get.back(result: type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(type.icon, size: 36, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              type.label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
