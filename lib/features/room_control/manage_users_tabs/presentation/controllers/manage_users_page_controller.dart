import 'package:aner_astaner/features/user/domain/entities/user_summary.dart';
import 'package:aner_astaner/features/user/presentation/controllers/user_controller.dart';
import 'package:get/get.dart';

class ManageUsersPageController {
  ManageUsersPageController({
    required String churchId,
    required String chapterId,
  }) : currentChurch = churchId.trim(),
       currentClass = chapterId.trim();

  final UserController _userController = Get.find<UserController>();

  // ✅ القيم جاية من الصفحة السابقة
  final String currentChurch;
  final String currentClass;

  Stream<List<UserSummary>> usersStream(String status) =>
      _userController.watchUsers(
        churchId: currentChurch,
        chapterId: currentClass,
        status: status == 'all' ? 'pending' : status,
      );

  Future<void> updateUserStatus(String userId, String status) =>
      _userController.updateUserStatus(userId, status);
}