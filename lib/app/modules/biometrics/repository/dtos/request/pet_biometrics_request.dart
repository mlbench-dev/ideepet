import 'dart:io';

import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';

class PetBiometryRequest {
  final String id;
  final List<File> images;

  PetBiometryRequest({
    required this.id,
    required this.images,
  });

  FormData toFormData() {
    return FormData({
      "files": images
          .map((file) =>
              MultipartFile(file, filename: file.path.split('/').last))
          .toList(),
    });
  }
}
