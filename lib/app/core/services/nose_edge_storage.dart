import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the nose edge image URL returned by `POST /pets/{id}/biometry`,
/// because `GET /pets` does not return `nose_edge_url`.
class NoseEdgeStorage {
  static const _prefix = 'nose_edge_url_';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? get(String petId) => _prefs?.getString('$_prefix$petId');

  static Future<void> save(String petId, String url) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString('$_prefix$petId', url);
  }
}
