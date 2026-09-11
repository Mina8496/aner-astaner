import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ExamQuizRepository {
  Future<bool> checkApproval({
    required String churchId,
    required String chapterId,
    required String uid,
  });

  Future<List<Map<String, dynamic>>> fetchExamSettingsDocs({
    required String churchId,
    required String chapterId,
    required String examId,
  });

  Future<List<QueryDocumentSnapshot>> fetchQuestions({
    required String churchId,
    required String chapterId,
    required String examId,
    required String alngelId,
    required String alshahatId,
  });

  Future<Map<String, dynamic>?> fetchResultData({
    required String uid,
    required String resultId,
  });

  Future<void> saveResult({
    required String uid,
    required String resultId,
    required Map<String, dynamic> data,
  });
}