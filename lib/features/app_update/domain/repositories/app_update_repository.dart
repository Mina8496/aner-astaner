import 'package:aner_astaner/features/app_update/domain/entities/app_version_settings.dart';

abstract class AppUpdateRepository {
  /// Returns null if the settings document doesn't exist,
  /// matching the current `if (!doc.exists) return;` behavior.
  Future<AppVersionSettings?> fetchVersionSettings();
}