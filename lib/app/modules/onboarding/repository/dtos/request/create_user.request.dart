import 'dart:io';

import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'package:get/get_connect/http/src/multipart/multipart_file.dart';

class CreateUserRequest {
  final String name;
  final String email;
  final String password;
  final String? phone;
  final String? addressStreet;
  final String? addressCity;
  final String? addressState;
  final String? addressZipCode;
  final String? addressComplement;
  final String? neightbourhood;
  final String? addressNumber;
  String? addressLat;
  String? addressLong;
  final String? influencerId;
  File? image;

  CreateUserRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.addressStreet,
    required this.addressCity,
    required this.addressState,
    required this.addressZipCode,
    this.addressComplement,
    this.neightbourhood,
    this.addressNumber,
    this.addressLat,
    this.addressLong,
    this.influencerId,
    this.image,
  });

  FormData toFormData() {
    final map = <String, dynamic>{};

    void add(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        map[key] = value;
      }
    }

    // ?? obrigatórios
    add('email', email);
    add('password', password);
    add('name', name);

    // ?? opcionais
    add('phone', phone != null ? '+55$phone' : null);
    add('address_street', addressStreet);
    add('address_city', addressCity);
    add('address_state', addressState);
    add('address_cep', addressZipCode);
    add('address_complement', addressComplement);
    add('address_neighborhood', neightbourhood);
    add('address_number', addressNumber);
    add('address_lat', addressLat);
    add('address_long', addressLong);
    add('influencer_id', influencerId);

    // ?? imagem
    if (image != null) {
      map['avatar'] = MultipartFile(
        image!,
        filename: image!.path.split('/').last,
      );
    }

    return FormData(map);
  }
}
