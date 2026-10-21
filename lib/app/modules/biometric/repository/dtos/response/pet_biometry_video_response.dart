class PetBiometryVideoResponse {
  final int miss;
  final String biometry;
  final String videoUrl;

  PetBiometryVideoResponse({
    required this.miss,
    required this.biometry,
    required this.videoUrl,
  });

  factory PetBiometryVideoResponse.fromJson(Map<String, dynamic> json) {
    return PetBiometryVideoResponse(
      miss: json['miss'] as int,
      biometry: json['biometry'].toString(),
      videoUrl: json['video_url'] as String,
    );
  }
}
