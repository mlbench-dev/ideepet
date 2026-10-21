import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/routes/find_pet_routes.dart';

/// Guide screen shown before [PetFindScanning] so the user knows how to
/// position the camera on the pet's muzzle before the 5-second recording
/// starts.
class FindPetGuide extends StatelessWidget {
  const FindPetGuide({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).height;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: CircleAvatar(
            backgroundColor: AppColors.greyWhite,
            child: Icon(Icons.arrow_back, color: AppColors.primary),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(
                "Como capturar o focinho",
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 50),
            Center(
              child: _GuideCameraFrame(
                child: Image.asset(
                  "assets/find_pet/dog.png",
                  width: 196,
                  height: 250,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: Text(
                textAlign: TextAlign.center,
                "Aproxime a câmera do focinho, com boa luz. Depois, segure firme por 5 segundos.",
                style: TextStyle(color: AppColors.grey),
              ),
            ),
            SizedBox(height: size * 0.05),
            CustomButton.filled(
              title: Text(
                'Entendi, começar',
                style: TextStyle(color: AppColors.background, fontSize: 20),
              ),
              action: () => Get.toNamed(
                FindPetRoutes.findPet,
                // Forward the pet type chosen in the dog/cat dialog.
                arguments: Get.arguments,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuideCameraFrame extends StatelessWidget {
  const _GuideCameraFrame({
    required this.child,
    this.cornerLength = 28,
    this.strokeWidth = 2.0,
    this.padding = 16,
  });

  final Widget child;
  final double cornerLength;
  final double strokeWidth;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GuideCornerFramePainter(
        cornerLength: cornerLength,
        strokeWidth: strokeWidth,
        color: AppColors.primary,
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: child,
      ),
    );
  }
}

class _GuideCornerFramePainter extends CustomPainter {
  _GuideCornerFramePainter({
    required this.cornerLength,
    required this.strokeWidth,
    required this.color,
  });

  final double cornerLength;
  final double strokeWidth;
  final Color color;

  static const double cornerRadius = 17;

  @override
  bool shouldRepaint(covariant _GuideCornerFramePainter oldDelegate) {
    return oldDelegate.cornerLength != cornerLength ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final r = cornerRadius;

    final path = Path();

    // Top-left
    path.moveTo(0, cornerLength);
    path.lineTo(0, r);
    path.quadraticBezierTo(0, 0, r, 0);
    path.lineTo(cornerLength, 0);

    // Top-right
    path.moveTo(size.width - cornerLength, 0);
    path.lineTo(size.width - r, 0);
    path.quadraticBezierTo(size.width, 0, size.width, r);
    path.lineTo(size.width, cornerLength);

    // Bottom-left
    path.moveTo(0, size.height - cornerLength);
    path.lineTo(0, size.height - r);
    path.quadraticBezierTo(0, size.height, r, size.height);
    path.lineTo(cornerLength, size.height);

    // Bottom-right
    path.moveTo(size.width - cornerLength, size.height);
    path.lineTo(size.width - r, size.height);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width,
      size.height - r,
    );
    path.lineTo(size.width, size.height - cornerLength);

    canvas.drawPath(path, paint);
  }
}
