import 'package:aner_astaner/features/user/presentation/controllers/user_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class RoomPageController {
  RoomPageController({required this.onStateChanged});

  final VoidCallback onStateChanged;

  bool isSuperAdmin = false;

  Future<void> checkIfSuperAdmin() async {
    final profile = await Get.find<UserController>().fetchCurrentUserProfile();
    if (profile != null) {
      isSuperAdmin = profile.role == 'SuperAdmin';
      onStateChanged();
    }
  }
}