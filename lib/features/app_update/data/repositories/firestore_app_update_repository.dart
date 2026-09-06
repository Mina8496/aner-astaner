import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aner_astaner/features/app_update/domain/entities/app_version_settings.dart';
import 'package:aner_astaner/features/app_update/domain/repositories/app_update_repository.dart';

class FirestoreAppUpdateRepository implements AppUpdateRepository {
  @override
  Future<AppVersionSettings?> fetchVersionSettings() async {
    final doc = await FirebaseFirestore.instance
        .collection('AppSettings')
        .doc('version')
        .get();

    if (!doc.exists) return null;

    final data = doc.data() ?? {};

    return AppVersionSettings(
      minVersion: _parseVersion(data['minVersion']),
      latestVersion: _parseVersion(data['latestVersion']),
      message: data['updateMessage'] ?? 'يوجد تحديث جديد متاح',
    );
  }

  int _parseVersion(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}