import 'package:aner_astaner/features/rewards_page/domain/entities/reward.dart';

abstract class RewardRepository {
  Stream<List<Reward>> watchRewards({required String churchId, required String chapterId});
  Future<Map<String, dynamic>?> fetchRewardData(String docId);
  Future<void> addReward(Map<String, dynamic> data);
  Future<void> updateReward(String docId, Map<String, dynamic> data);
  Future<void> deleteReward(String docId);
}