import 'package:cloud_firestore/cloud_firestore.dart';

class ExamConstants {
  static const String fixedExamId = "nFL11C4v8fPRqIgG0ZAe";

  /// Central reference to the exam "Settings" subcollection.
  /// Both FirestoreExamSettingsRepository and FirestoreExamQuizRepository
  /// used to hardcode this exact path independently — unified here so
  /// it's defined in exactly one place.
  static CollectionReference<Map<String, dynamic>> settingsCollection(
    FirebaseFirestore firestore, {
    required String churchId,
    required String chapterId,
    String examId = fixedExamId,
  }) => firestore
      .collection('Churches')
      .doc(churchId)
      .collection('Chapters')
      .doc(chapterId)
      .collection('Exames')
      .doc(examId)
      .collection('Settings');
}
