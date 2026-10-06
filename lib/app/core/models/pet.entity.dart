import 'package:flutter/foundation.dart';
import 'package:idee_pet/app/app.dart';

class Pet {
  final String id;
  final String name;
  final PetType type;
  final Breed? breed;
  final PetAge? age;
  final PetSize? size;
  final String? edgeUrl;
  final String? userId;
  final PetWeight? weight;
  final List<PetPersonality> personalitys;
  final List<String> foods;
  final String? avatarKey;
  final String? singleId;
  final String? nft;
  final String? nftUrl;
  final String? createdAt;
  final DateTime? updatedAt;
  final String? avatarUrl;
  final bool healthPlan;
  final bool healthCondition;
  final DateTime? birthDate;
  String? healthConditionValue;
  String? healthPlanId;
  String healthDate;
  String healthSeverity;
  final PetSex petSex;
  final bool isVerified;
  final DateTime? verifiedAt;
  Pet({
    this.id = '',
    this.name = 'Nome Padrão',
    this.type = PetType.dog,
    this.breed,
    this.age = PetAge.op0,
    this.size = DogSize.small,
    this.edgeUrl,
    this.userId = '',
    this.weight = DogWeight.op1,
    this.personalitys = const [],
    this.foods = const [],
    this.avatarKey,
    this.singleId,
    this.nft,
    this.nftUrl,
    this.createdAt = '',
    this.updatedAt,
    this.avatarUrl,
    this.healthPlan = false,
    this.healthCondition = false,
    this.healthConditionValue,
    this.healthPlanId,
    this.healthDate = '',
    this.healthSeverity = '',
    this.petSex = PetSex.macho,
    this.birthDate,
    this.isVerified = false,
    this.verifiedAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    debugPrint('@@@ Pet keys: ${json.keys.toList()}');
    debugPrint('@@@ Pet nose_edge_url: ${json['nose_edge_url']}');
    late PetType type;
    if (json['type'] != null) {
      type = PetType.fromJson(json['type']);
    } else {
      type = PetType.dog;
    }

    return Pet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: type,
      breed: json['breed_id'] == null
          ? null
          : Breed(
              id: json['breed_id'], name: json['breed_name'] ?? 'Desconhecido'),
      age: json['age'] != null ? PetAge.fromValue(json['age']) : null,
      size: json['size'] != null ? PetSize.fromValue(type, json['size']) : null,
      edgeUrl: json['nose_edge_url'],
      weight: json['weight'] != null
          ? PetWeight.fromValue(type, json['weight'])
          : null,
      personalitys: json['personality'] != null
          ? PetPersonality.fromJsonList(json['personality'])
          : [],
      foods: json['food'] != null ? PetFood.fromJsonList(json['food']) : [],
      userId: json['user_id'] ?? '',
      avatarKey: json['avatar_key'] ?? '',
      singleId: json['single_id'] ?? '',
      nft: json['nft'] ?? '',
      nftUrl: json['nft_url'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      avatarUrl: json['avatar_url'] ?? '',
      healthPlan: json['is_health_plan'] ?? false,
      healthCondition: json['is_health_condition'] ?? false,
      healthConditionValue: json['health_condition'] ?? '',
      healthPlanId: json['health_plan_id'] ?? '',
      healthDate: json['health_date'] ?? '',
      healthSeverity: json['health_severity'] ?? '',
      petSex: json['sex'] != null ? PetSex.fromJson(json['sex']) : PetSex.macho,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : null,
      isVerified: json['is_verified'] ?? false,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'])
          : null,
    );
  }

  factory Pet.empty() => Pet.fromJson({'': ''});

  String getAge() {
    if (birthDate == null) {
      return 'Data de nascimento não informada';
    }

    final now = DateTime.now();
    final duration = now.difference(birthDate!);

    final years = (duration.inDays / 365).floor();
    final months = ((duration.inDays % 365) / 30).floor();
    final days = (duration.inDays % 365) % 30;

    if (years > 0) {
      return '$years anos';
    } else if (months > 0) {
      return '$months meses';
    } else if (days > 0) {
      return '$days dias';
    } else {
      return 'Idade não calculada';
    }
  }

  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'breed': breed,
  //     'age': age,
  //     'size': size,
  //     'user_id': userId,
  //     'avatar_key': avatarKey,
  //     'single_id': singleId,
  //     'nft': nft,
  //     'nft_url': nftUrl,
  //     'created_at': createdAt,
  //     'updated_at': updatedAt,
  //     'avatar_url': avatarUrl,
  //   };
  // }
}
