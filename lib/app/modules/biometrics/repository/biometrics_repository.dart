import 'package:flutter/foundation.dart';
import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/modules/biometrics/repository/dtos/response/pet_biometry_video_response.dart';

class BiometricsRepository extends BaseRepository {
  Future<BaseResponse<void>> sendPetProfile(PetProfileRequest request) async {
    final formData = FormData(request.toMap());
    final response = await post(
      '/pets/${request.id}/petAvatar',
      formData,
      uploadProgress: (progress) {
        request.onProgress(progress);
      },
    );
    return BaseResponse.create(
      response: response,
    );
  }

  Future<BaseResponse<void>> sendBiometry(PetBiometryRequest request) async {
    final formData = request.toFormData();
    final response = await post('/pets/${request.id}/biometry', formData);

    if ((response.statusCode ?? 500) < 400) {
      showSuccess(message: 'Biometria enviada com sucesso!');
    } else {
      showError(message: 'Erro ao enviar biometria!');
    }

    return BaseResponse.create(
      response: response,
    );
  }

  /// Pings the CV server so it starts up (cold start) before the biometry
  /// video is submitted.
  Future<bool> wakeUpCvServer() async {
    final response = await get('/cv/health');
    return (response.statusCode ?? 500) < 400;
  }

  Future<BaseResponse<PetBiometryVideoResponse>> sendBiometryVideo(
    PetBiometryVideoRequest request, {
    void Function(double)? onProgress,
  }) async {
    final formData = request.toFormData();
    final response = await post(
      '/pets/${request.id}/biometry',
      formData,
      uploadProgress: onProgress,
    );

    debugPrint(
        '@@@ sendBiometryVideo response statusCode: ${response.statusCode}');
    debugPrint('@@@ sendBiometryVideo response body: ${response.body}');

    final isSuccess = (response.statusCode ?? 500) < 400;
    final body = response.body;

    if (isSuccess) {
      return BaseResponse.createCustom(
        success: true,
        statusCode: response.statusCode,
        result: body is Map<String, dynamic>
            ? PetBiometryVideoResponse.fromJson(body)
            : null,
      );
    }

    final message = body is Map ? body['message']?.toString() : null;
    return BaseResponse.createCustom(
      success: false,
      statusCode: response.statusCode,
      errorMessages: [message ?? 'Erro ao enviar biometria.'],
    );
  }
}
