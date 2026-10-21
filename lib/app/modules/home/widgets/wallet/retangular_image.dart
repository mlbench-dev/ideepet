import 'package:flutter/material.dart';

class RetangularImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const RetangularImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return const SizedBox(); // Retorna um widget vazio se a URL for inválida
    }

    return Image.network(
      imageUrl!,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('@@@ RetangularImage failed to load $imageUrl: $error');
        return const SizedBox(); // Se a URL não carregar, retorna vazio
      },
    );
  }
}
