import 'package:aner_astaner/features/user/domain/entities/user_summary.dart';
import 'package:aner_astaner/features/user/presentation/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DataAdmainChurchesPageController {
  DataAdmainChurchesPageController({
    required this.churchId,
    required this.chapterId,
    required this.onStateChanged,
  });

  final String? churchId;
  final String? chapterId;
  final VoidCallback onStateChanged;

  final userController = Get.find<UserController>();

  String? selectedRole;
  String searchQuery = '';

  Stream<List<UserSummary>> usersStream() {
    return userController.watchUsersByOrganization(
      churchId: churchId!,
      chapterId: chapterId!,
      role: selectedRole,
    );
  }

  void updateSearchQuery(String value) {
    searchQuery = value.trim().toLowerCase();
    onStateChanged();
  }

  List<UserSummary> filterUsers(List<UserSummary> users) {
    return users
        .where((user) => user.name.toLowerCase().contains(searchQuery))
        .toList();
  }
}