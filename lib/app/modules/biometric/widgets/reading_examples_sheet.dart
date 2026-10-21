import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/modules/biometric/widgets/biometric_onboarding_widgets.dart';

const _assets = 'assets/onboarding_biometric/reading_examples';

/// NF-01c · Exemplos de leitura: what helps and what hurts the noseprint read.
/// Shows the cat version (NF-01c gato) when the pet is a cat.
Future<void> showReadingExamplesSheet(BuildContext context, Pet? pet) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.primary.withValues(alpha: 0.4),
    builder: (_) => _ReadingExamplesSheet(copy: BiometricPetCopy(pet)),
  );
}

class _ReadingExamplesSheet extends StatelessWidget {
  final BiometricPetCopy copy;

  const _ReadingExamplesSheet({required this.copy});

  @override
  Widget build(BuildContext context) {
    final isCat = copy.isCat;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x2E0A1730),
            offset: Offset(0, -4),
            blurRadius: 24,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(37, 12, 37, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE4E2DA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Exemplos de leitura',
                style: biometricPoppins(22, FontWeight.w700, AppColors.primary,
                    height: 27 / 22),
              ),
              const SizedBox(height: 6),
              Text(
                'Veja o que ajuda e o que atrapalha.',
                style: biometricPoppins(
                    14, FontWeight.w500, biometricOnboardingSubtitle,
                    height: 20 / 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ExampleCard(
                    example: ReadingExample.ok,
                    isCat: isCat,
                    label: 'Assim sim',
                    detail: ': rosto inteiro, de frente',
                  ),
                  _ExampleCard(
                    example: ReadingExample.tooClose,
                    isCat: isCat,
                    label: 'Perto demais',
                    detail: ': os olhos ficam de fora',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ExampleCard(
                    example: ReadingExample.side,
                    isCat: isCat,
                    label: 'De lado',
                    detail: ': o focinho aparece pela metade',
                  ),
                  _ExampleCard(
                    example: ReadingExample.dark,
                    isCat: isCat,
                    label: 'Escuro ou tremido',
                    detail: ': os detalhes somem',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1EDE4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset('$_assets/icon_treat.svg',
                        width: 20, height: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${isCat ? 'Um brinquedo' : 'Um petisco'} acima do '
                        'celular ajuda ${copy.theName} a olhar para a frente.',
                        style: biometricPoppins(
                            13, FontWeight.w500, AppColors.primary,
                            height: 18 / 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              BiometricPrimaryButton(
                title: 'Entendi',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExampleCard extends StatelessWidget {
  final ReadingExample example;
  final bool isCat;
  final String label;
  final String detail;

  const _ExampleCard({
    required this.example,
    required this.isCat,
    required this.label,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 144,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReadingExampleThumbnail(example: example, isCat: isCat),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: biometricPoppins(13, FontWeight.w500, AppColors.primary,
                  height: 18 / 13),
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: detail),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum ReadingExample { ok, tooClose, side, dark }

/// Where an exported SVG sits inside the 144 x 144 card, as in Figma.
class _Art {
  final String asset;
  final double left;
  final double top;
  final double width;
  final double height;

  const _Art(this.asset, this.left, this.top, this.width, this.height);
}

/// 144 x 144 example picture with the ✓ / ✗ badge in the top-right corner.
class ReadingExampleThumbnail extends StatelessWidget {
  final ReadingExample example;
  final bool isCat;

  const ReadingExampleThumbnail({
    super.key,
    required this.example,
    required this.isCat,
  });

  // Dog art is 156.22 wide, shifted 11px left. The dark exports include the
  // blur's bleed area around the art.
  static const _dogArt = {
    ReadingExample.ok: _Art('$_assets/example_ok.svg', -11, 0, 156.278, 144),
    ReadingExample.tooClose:
        _Art('$_assets/example_too_close.svg', -11, 0, 156.279, 144),
    ReadingExample.side: _Art('$_assets/example_side.svg', -11, 0, 156.22, 144),
    ReadingExample.dark:
        _Art('$_assets/example_dark.svg', -14.33, -3.33, 162.944, 150.665),
  };

  static const _catArt = {
    ReadingExample.ok:
        _Art('$_assets/cat_example_ok.svg', -0.22, 0, 144.219, 144.141),
    ReadingExample.tooClose: _Art(
        '$_assets/cat_example_too_close.svg', -0.14, -0.14, 144.281, 144.176),
    ReadingExample.side:
        _Art('$_assets/cat_example_side.svg', 0, 0, 144, 144.035),
    ReadingExample.dark:
        _Art('$_assets/cat_example_dark.svg', -3.1, -3.1, 150.406, 150.328),
  };

  // Blur of the "Escuro ou tremido" art, from the SVG filters.
  static const _dogBlur = 1.66635;
  static const _catBlur = 1.54688;

  @override
  Widget build(BuildContext context) {
    final art = (isCat ? _catArt : _dogArt)[example]!;
    final good = example == ReadingExample.ok;

    Widget picture = SvgPicture.asset(art.asset,
        width: art.width, height: art.height, fit: BoxFit.fill);
    if (example == ReadingExample.dark) {
      // flutter_svg ignores SVG filters, so the blur and the multiply tint
      // from the design are applied here.
      final sigma = isCat ? _catBlur : _dogBlur;
      picture = ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: picture,
      );
    }

    final badgeSize = isCat ? 32.2594 : 34.9933;
    final badge = good
        ? (isCat ? 'cat_badge_ok' : 'badge_ok')
        : (isCat ? 'cat_badge_avoid' : 'badge_avoid');

    Widget content = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: art.left,
          top: art.top,
          width: art.width,
          height: art.height,
          child: picture,
        ),
      ],
    );
    if (example == ReadingExample.dark) {
      content = ColorFiltered(
        colorFilter:
            const ColorFilter.mode(Color(0xFF918A85), BlendMode.multiply),
        child: content,
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox.square(
        dimension: 144,
        child: Stack(
          children: [
            Positioned.fill(child: content),
            Positioned(
              left: isCat ? 144 * 0.742 : -11 + 156.22 * 0.7418,
              top: isCat ? 144 * 0.056 : 144 * 0.0463,
              child: SvgPicture.asset('$_assets/$badge.svg',
                  width: badgeSize, height: badgeSize),
            ),
          ],
        ),
      ),
    );
  }
}
