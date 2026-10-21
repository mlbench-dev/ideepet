import 'package:flutter/foundation.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Initializes Branch and keeps the influencer that brought the user to the
/// app, so it can be sent to the backend when registration succeeds.
///
/// Influencer links are created in the Branch dashboard with a custom
/// parameter `influencer_id` (e.g. `influencer_001`).
class BranchService {
  static const _influencerKey = 'branch_influencer_id';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    try {
      await FlutterBranchSdk.init(
        enableLogging: kDebugMode,
        logLevel: kDebugMode ? BranchLogLevel.DEBUG : BranchLogLevel.NONE,
      );
    } catch (e) {
      // Branch must never block app startup.
      debugPrint('@@@ Branch init failed: $e');
      return;
    }

    FlutterBranchSdk.listSession().listen(
      _onSession,
      onError: (error) => debugPrint('@@@ Branch session error: $error'),
    );
  }

  static Future<void> _onSession(Map<dynamic, dynamic> data) async {
    if (kDebugMode) {
      debugPrint('@@@ Branch session: $data');
    }
    if (data['+clicked_branch_link'] != true) return;

    final influencerId = data['influencer_id']?.toString();
    if (influencerId == null || influencerId.isEmpty) return;

    // Keep the first influencer (first-touch attribution).
    if (referredInfluencerId != null) return;
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_influencerKey, influencerId);
  }

  /// Influencer that referred this install, if any.
  static String? get referredInfluencerId => _prefs?.getString(_influencerKey);

  /// Call after the influencer was saved on the backend.
  static Future<void> clearInfluencer() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.remove(_influencerKey);
  }

  /// Ties Branch events to the logged-in user.
  static void setIdentity(String userId) => FlutterBranchSdk.setIdentity(userId);

  static void logout() => FlutterBranchSdk.logout();
}
