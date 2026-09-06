import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:aner_astaner/features/app_update/domain/repositories/app_update_repository.dart';

class ForceUpdateService {
  static bool _dialogShown = false;

  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final int currentVersion = int.tryParse(packageInfo.buildNumber) ?? 0;

      final settings =
          await Get.find<AppUpdateRepository>().fetchVersionSettings();
      if (settings == null) return;

      if (_dialogShown) return;

      if (currentVersion < settings.minVersion) {
        _dialogShown = true;
        _showForceDialog(context, settings.message);
      } else if (currentVersion < settings.latestVersion) {
        _dialogShown = true;
        _showOptionalDialog(context, settings.message);
      }
    } catch (_) {}
  }

  static void _showForceDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('تحديث إجباري'),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: _openStore,
            child: const Text('تحديث الآن'),
          ),
        ],
      ),
    );
  }

  static void _showOptionalDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تحديث متاح'),
        content: Text(message),
        actions: [
          ElevatedButton(onPressed: _openStore, child: const Text('تحديث')),
        ],
      ),
    );
  }

  static Future<void> _openStore() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final uri = Uri.parse(
      'https://play.google.com/store/apps/details?id=${packageInfo.packageName}',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}