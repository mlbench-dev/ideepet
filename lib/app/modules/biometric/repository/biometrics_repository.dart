import 'package:idee_pet/app/core/base/base_response.dart';
import 'package:idee_pet/app/core/repositories/base_repository.dart';
import 'package:idee_pet/app/modules/biometric/repository/dtos/request/pet_biometry_video_request.dart';
import 'package:idee_pet/app/modules/biometric/repository/dtos/response/pet_biometry_video_response.dart';

class BiometricsRepository extends BaseRepository {
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
