import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:idee_pet/app/app.dart';
import 'package:idee_pet/app/modules/find_pet_result/repository/find_pet_entity.dart';
import 'package:idee_pet/app/modules/find_pet_result/repository/sent_data_pet.dart';

class FindPetResultRepository extends BaseRepository {
  // Uploading a video (and the backend's identification processing) takes
  // longer than the base 30s timeout meant for regular JSON/image calls,
  // so this repository uses a more generous one.
  FindPetResultRepository({super.timeOut = const Duration(seconds: 90)});

  Future<BaseResponse<FindPetResult>> findPet(
      List<File> images, void Function(double progress)? onProgress) async {
    redirect = false;
    final totalBytes = images.fold<int>(
      0,
      (sum, file) => sum + file.lengthSync(),
    );
    final formData = FormData({
      "files": images
          .map((file) =>
              MultipartFile(file, filename: file.path.split('/').last))
          .toList(),
    });
    final response = await post(
      '/pets/identify_pet/',
      formData,
      uploadProgress: (double sent) {
        if (onProgress != null && totalBytes > 0) {
          double progress = sent / totalBytes;
          if (progress > 1) progress = 1;
          onProgress(progress);
        }
      },
    );

    if ((response.statusCode ?? 500) < 400) {
      //showSuccess(message: 'Biometria enviada com sucesso!');
    } else {
      showError(message: 'Erro ao enviar biometria!');
    }
    redirect = true;

    return BaseResponse.create(
      response: response,
      fromMap: (data) => FindPetResult.fromJson(data),
    );
  }

  Future<BaseResponse<void>> sendDataPet(SentDataPet request) async {
    redirect = false;
    final response = await post('/pets/found_pet/', request.toJson());
    redirect = true;
    return BaseResponse.create(response: response);
  }

  /// Identifies a pet from a nose video (public "found pet" scan flow).
  /// Uploads the recorded video directly as multipart form-data to
  /// POST /pets/identify_pet/, mirroring [findPet] but for the video-based
  /// biometry flow used by the muzzle scanning screen.
  ///
  /// Uses `dio` instead of the GetConnect-based [post]: GetConnect encodes
  /// every request body (including multipart uploads) as a byte-by-byte
  /// stream, which for a multi-MB video keeps the UI isolate busy for a
  /// long time and made the upload spinner appear frozen. GetConnect's
  /// `httpClient.timeout` also only bounds the connection + body-write
  /// phase, not a stalled server response, so a bad connection could leave
  /// the spinner spinning well past the intended timeout. dio streams the
  /// file straight from disk and enforces real send/receive timeouts.
  Future<BaseResponse<FindPetResult>> identifyPetByVideo(
    File video, {
    String? pet,
    void Function(double progress)? onProgress,
  }) async {
    final token = await Get.find<TokenService>().getToken();

    final client = dio.Dio(dio.BaseOptions(
      baseUrl: httpClient.baseUrl!,
      connectTimeout: const Duration(seconds: 30),
      sendTimeout: timeOut,
      receiveTimeout: timeOut,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': '*/*',
      },
    ));

    try {
      final formData = dio.FormData.fromMap({
        'video': await dio.MultipartFile.fromFile(
          video.path,
          filename: video.path.split('/').last,
        ),
        if (pet != null) 'pet': pet,
      });

      final dioResponse = await client.post<dynamic>(
        '/pets/identify_pet/',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            var progress = sent / total;
            if (progress > 1) progress = 1;
            onProgress(progress);
          }
        },
      );

      return BaseResponse.create(
        response: Response<dynamic>(
          statusCode: dioResponse.statusCode,
          statusText: dioResponse.statusMessage,
          body: dioResponse.data,
        ),
        fromMap: (data) => FindPetResult.fromJson(data),
      );
    } on dio.DioException catch (e, s) {
      final isTimeout = e.type == dio.DioExceptionType.connectionTimeout ||
          e.type == dio.DioExceptionType.sendTimeout ||
          e.type == dio.DioExceptionType.receiveTimeout;

      BugTracking().send(
        'Video upload failed (DioException): ${e.type}',
        e,
        s,
        'URL: /pets/identify_pet/',
        isTimeout ? 'UploadTimeout' : 'UploadError',
      );

      return BaseResponse.create(
        response: Response<dynamic>(
          statusCode: e.response?.statusCode ?? 0,
          statusText: e.message,
          body: e.response?.data ??
              {
                'errorMessages': [
                  isTimeout
                      ? 'O envio do vídeo demorou muito. Verifique sua conexão e tente novamente.'
                      : 'Verifique sua conexão com a internet.'
                ]
              },
        ),
        fromMap: (data) => FindPetResult.fromJson(data),
      );
    } finally {
      client.close();
    }
  }
}
