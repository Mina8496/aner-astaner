import 'package:aner_astaner/features/churches/domain/entities/organization_item.dart';
import 'package:aner_astaner/features/churches/presentation/controllers/organization_controller.dart';
import 'package:aner_astaner/features/user/presentation/controllers/user_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ChaptersPageController {
  ChaptersPageController({required this.churchId, required this.onStateChanged});

  final String? churchId;
  final VoidCallback onStateChanged;

  final organizationController = Get.find<OrganizationController>();
  final userController = Get.find<UserController>();

  List<OrganizationItem> chapters = [];
  bool isLoading = true;
  String role = '';
  String? selectedChapterId;

  Future<void> fetchChapters() async {
    isLoading = true;
    onStateChanged();

    final profile = await userController.fetchCurrentUserProfile();
    if (profile == null) {
      isLoading = false;
      onStateChanged();
      return;
    }

    role = profile.role ?? '';
    selectedChapterId = profile.chapterId;
    chapters = await organizationController.fetchChapters(
      churchId: churchId,
      role: role,
      selectedChapterId: selectedChapterId,
    );
    isLoading = false;
    onStateChanged();
  }

  Future<void> deleteChapter(String chapterId) async {
    final id = churchId;
    if (id == null) return;
    await organizationController.deleteChapter(churchId: id, chapterId: chapterId);
    await fetchChapters();
  }

  Future<void> updateChapterName(String id, String name) async {
    final cId = churchId;
    if (cId == null) return;
    await organizationController.updateChapter(
      churchId: cId,
      chapterId: id,
      season: name,
    );
    await fetchChapters();
  }
}