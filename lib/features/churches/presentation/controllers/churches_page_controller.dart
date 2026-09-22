import 'package:flutter/foundation.dart';
import 'package:aner_astaner/features/churches/domain/entities/organization_item.dart';
import 'package:aner_astaner/features/churches/presentation/controllers/organization_controller.dart';
import 'package:aner_astaner/features/user/presentation/controllers/user_controller.dart';
import 'package:get/get.dart';

class ChurchesPageController {
  ChurchesPageController({required this.onStateChanged});

  final VoidCallback onStateChanged;

  final organizationController = Get.find<OrganizationController>();
  final userController = Get.find<UserController>();

  List<OrganizationItem> churches = [];
  bool isLoading = true;
  String role = '';
  String? churchId;

  Future<void> fetchData() async {
    isLoading = true;
    onStateChanged();

    final profile = await userController.fetchCurrentUserProfile();
    if (profile == null) {
      isLoading = false;
      onStateChanged();
      return;
    }

    role = profile.role ?? '';
    churchId = profile.churchId;
    churches = await organizationController.fetchChurches(
      role: role,
      churchId: churchId,
    );
    isLoading = false;
    onStateChanged();
  }

  Future<void> updateChurchName(String id, String name) async {
    await organizationController.updateChurch(id, name);
    await fetchData();
  }

  Future<void> deleteChurch(String id) async {
    await organizationController.deleteChurch(id);
    await fetchData();
  }
}