import 'package:aner_astaner/features/multiple_choice_quiz/domain/repositories/exam_quiz_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreExamQuizRepository implements ExamQuizRepository {
  @override
  Future<bool> checkApproval({
    required String churchId,
    required String chapterId,
    required String uid,
  }) async {
    final doc = await FirebaseFirestore.instance
        .collection("Churches")
        .doc(churchId)
        .collection("Chapters")
        .doc(chapterId)
        .collection("Approved")
        .doc(uid)
        .get();
    return doc.exists;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchExamSettingsDocs({
    required String churchId,
    required String chapterId,
    required String examId,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('Churches')
        .doc(churchId)
        .collection('Chapters')
        .doc(chapterId)
        .collection('Exames')
        .doc(examId)
        .collection('Settings')
        .get();
    return snapshot.docs.map((d) => d.data()).toList();
  }

  @override
  Future<List<QueryDocumentSnapshot>> fetchQuestions({
    required String churchId,
    required String chapterId,
    required String examId,
    required String alngelId,
    required String alshahatId,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection("Churches")
        .doc(churchId)
        .collection("Chapters")
        .doc(chapterId)
        .collection("Exames")
        .doc(examId)
        .collection("Alangel")
        .doc(alngelId)
        .collection("Alshahat")
        .doc(alshahatId)
        .collection("Qusstions")
        .get();
    return snapshot.docs;
  }

  @override
  Future<Map<String, dynamic>?> fetchResultData({
    required String uid,
    required String resultId,
  }) async {
    final snap = await FirebaseFirestore.instance
        .collection('Exames')
        .doc(uid)
        .collection('Results')
        .doc(resultId)
        .get();
    return snap.data();
  }

  @override
  Future<void> saveResult({
    required String uid,
    required String resultId,
    required Map<String, dynamic> data,
  }) async {
    final payload = Map<String, dynamic>.from(data)
      ..['date'] = FieldValue.serverTimestamp();
    await FirebaseFirestore.instance
        .collection("Exames")
        .doc(uid)
        .collection("Results")
        .doc(resultId)
        .set(payload);
  }
}