import 'dart:io';

import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';

class PetBiometryVideoRequest {
  final String id;
  final File video;

  PetBiometryVideoRequest({
    required this.id,
    required this.video,
  });

  FormData toFormData() {
    return FormData({
      'video': MultipartFile(video, filename: video.path.split('/').last),
    });
  }
}
