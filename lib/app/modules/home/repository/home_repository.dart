import 'dart:async';

import 'package:idee_pet/app/app.dart';

class HomeRepository extends BaseRepository {
  static const getPetsPath = '/pets';
  static const String getNotificationsPath = '/notifications';

  Future<BaseResponse<List<Pet>>> getPets() async {
    redirect = false;

    final response = await get('$getPetsPath?page=1&limit=500');

    redirect = true;
    return BaseResponse.createList(
      response: response,
      fromMap: (data) => Pet.fromJson(data),
    );
  }

  Future<BaseResponse<String>> sendLostPetAlert(
    String petId, {
    double? lat,
    double? long,
  }) async {
    final body = <String, dynamic>{};
    if (lat != null && long != null) {
      body['lat'] = lat;
      body['long'] = long;
    }

    final response = await post('$getPetsPath/$petId/lost-alert', body);

    return BaseResponse.create<String>(
      response: response,
      fromMap: (data) => (data as Map)['message']?.toString() ?? '',
    );
  }

  Future<BaseResponse<int>> getIntNotifications() async {
    final response = await get(getNotificationsPath);

    return BaseResponse.create<int>(
      response: response,
      fromMap: (data) {
        final list = (data as List)
            .map((json) => GroupNotifications.fromJson(json))
            .toList();

        final count = list
            .expand((group) => group.notifications)
            .where((notification) => !notification.isRead)
            .length;

        return count;
      },
    );
  }
}
