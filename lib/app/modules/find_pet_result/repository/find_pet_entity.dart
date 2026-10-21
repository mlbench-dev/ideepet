class FindPetResult {
  final bool exists;
  final String? petId;
  final String? petName;

  /// Message returned by the backend (e.g. why the pet was not found).
  final String? message;
  FindPetResult({
    required this.exists,
    this.petId,
    this.petName,
    this.message,
  });

  factory FindPetResult.fromJson(Map<String, dynamic> json) {
    return FindPetResult(
      exists: json['exists'] ?? false,
      petId: json['pet_id'],
      petName: json['pet_name'],
      message: (json['message'] ?? json['detail'] ?? json['error'])?.toString(),
    );
  }
}
