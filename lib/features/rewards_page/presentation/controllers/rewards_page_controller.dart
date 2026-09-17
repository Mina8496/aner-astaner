import 'package:aner_astaner/features/rewards_page/domain/entities/reward.dart';
import 'package:aner_astaner/features/rewards_page/domain/repositories/reward_repository.dart';
import 'package:aner_astaner/features/user/domain/repositories/user_repository.dart';

class RewardsPageController {
  RewardsPageController({
    required this.rewardRepository,
    required this.userRepository,
  });

  final RewardRepository rewardRepository;
  final UserRepository userRepository;

  bool isAdmin = false;
  String? churchId;
  String? chapterId;

  Future<void> resolveOrganization({String? churchId, String? chapterId}) async {
    if (churchId != null && chapterId != null) {
      this.churchId = churchId;
      this.chapterId = chapterId;
      return;
    }
    final profile = await userRepository.fetchCurrentUserProfile();
    this.churchId = churchId ?? profile?.churchId;
    this.chapterId = chapterId ?? profile?.chapterId;
  }

  Future<void> checkIfAdmin() async {
    final profile = await userRepository.fetchCurrentUserProfile();
    final role = profile?.role ?? "user";
    if (role == "Admin" || role == "SuperAdmin") {
      isAdmin = true;
    }
  }

  Future<Map<String, dynamic>?> fetchRewardData(String docId) {
    return rewardRepository.fetchRewardData(docId);
  }

  Future<void> addReward(Map<String, dynamic> data) {
    return rewardRepository.addReward(data);
  }

  Future<void> updateReward(String docId, Map<String, dynamic> data) {
    return rewardRepository.updateReward(docId, data);
  }

  Future<void> deleteReward(String docId) {
    return rewardRepository.deleteReward(docId);
  }

  Stream<List<Reward>> watchRewards() {
    return rewardRepository.watchRewards(
      churchId: churchId!,
      chapterId: chapterId!,
    );
  }
}