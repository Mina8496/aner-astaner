import 'package:aner_astaner/features/rewards_page/domain/entities/reward.dart';
import 'package:aner_astaner/features/rewards_page/domain/repositories/reward_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRewardRepository implements RewardRepository {
  final _rewardsRef = FirebaseFirestore.instance.collection('Rewards');

  @override
  Stream<List<Reward>> watchRewards({
    required String churchId,
    required String chapterId,
  }) {
    return _rewardsRef
        .where('churchId', isEqualTo: churchId)
        .where('chapterId', isEqualTo: chapterId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Reward.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  @override
  Future<Map<String, dynamic>?> fetchRewardData(String docId) async {
    final snap = await _rewardsRef.doc(docId).get();
    return snap.data();
  }

  @override
  Future<void> addReward(Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data)
      ..['createdAt'] = FieldValue.serverTimestamp();
    await _rewardsRef.add(payload);
  }

  @override
  Future<void> updateReward(String docId, Map<String, dynamic> data) async {
    final payload = Map<String, dynamic>.from(data)
      ..['createdAt'] = FieldValue.serverTimestamp();
    await _rewardsRef.doc(docId).update(payload);
  }

  @override
  Future<void> deleteReward(String docId) async {
    await _rewardsRef.doc(docId).delete();
  }
}