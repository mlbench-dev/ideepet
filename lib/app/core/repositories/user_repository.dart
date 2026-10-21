import 'package:idee_pet/app/app.dart';

class UserRepository extends BaseRepository {
  static const String getUserPath = '/users/me';
  static const patchUpdateUser = '/users';
  static const putFcmToken = '/users/fcm-token';

  Future<BaseResponse<void>> updateFcmToken(String fcmToken) async {
    final response = await put(putFcmToken, {'fcm_token': fcmToken});
    return BaseResponse.create(response: response);
  }

  /// Saves the user's location, used to find neighbors for lost pet alerts.
  /// The backend expects the coordinates as strings.
  Future<BaseResponse<void>> updateLocation(double lat, double long) async {
    final response = await patch(patchUpdateUser, {
      'address_lat': lat.toString(),
      'address_long': long.toString(),
    });
    return BaseResponse.create(response: response);
  }

  Future<BaseResponse<Profile>> getProfile() async {
    final response = await get(getUserPath);
    return BaseResponse.create(
        response: response, fromMap: (data) => Profile.fromJson(data));
  }

  Future<BaseResponse<Profile>> getProfileWithoutRedirect() async {
    redirect = false;
    final response = await get(getUserPath);
    redirect = true;

    return BaseResponse.create(
      response: response,
      fromMap: (data) => Profile.fromJson(data),
    );
  }

  Future<BaseResponse<Profile>> updateUser(
    UpdateUserRequest request,
  ) async {
    final formData = request.toFormData();

    // ?? Print dos campos normais
    for (var field in formData.fields) {
      print('FIELD -> ${field.key}: ${field.value}');
    }

    // ?? Print dos arquivos (se tiver)
    for (var file in formData.files) {
      print(
        'FILE -> ${file.key}: ${file.value.filename} '
        '(${file.value.contentType})',
      );
    }
    final response = await patch(patchUpdateUser, request.toFormData());
    return BaseResponse.create(
      response: response,
      fromMap: (data) => Profile.fromJson(data),
    );
  }
}
