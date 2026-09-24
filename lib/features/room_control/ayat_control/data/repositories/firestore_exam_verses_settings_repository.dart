import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aner_astaner/core/constants/exam_constants.dart';

import '../../domain/entities/ayat_quiz_verse_option.dart';
import '../../domain/entities/exam_verses_settings.dart';
import '../../domain/repositories/exam_verses_settings_repository.dart';

class FirestoreExamVersesSettingsRepository
    implements ExamVersesSettingsRepository {
  FirestoreExamVersesSettingsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _ayatQuiz(String churchId, String chapterId) =>
      _firestore
          .collection("Churches")
          .doc(churchId)
          .collection("Chapters")
          .doc(chapterId)
          .collection("Exames")
          .doc(ExamConstants.fixedExamId)
          .collection("AyatQuiz");

  CollectionReference<Map<String, dynamic>> _versesSettings(String churchId, String chapterId) =>
      _firestore
          .collection("Churches")
          .doc(churchId)
          .collection("Chapters")
          .doc(chapterId)
          .collection("Exames")
          .doc(ExamConstants.fixedExamId)
          .collection("VersesSettings");

  @override
  Future<List<AyatQuizVerseOption>> fetchAvailableVerses({
    required String churchId,
    required String chapterId,
  }) async {
    final snapshot = await _ayatQuiz(churchId, chapterId).get();

    if (snapshot.docs.isEmpty) {
      return const [AyatQuizVerseOption(id: "none", title: "لا توجد آيات متاحة")];
    }

    return snapshot.docs.map((doc) {
      final data = doc.data();
      String verseTitle = "آية غير مسماة";
      if (data["words"] is List) {
        final words = List<String>.from(data["words"]);
        verseTitle = words.take(4).join(" ") + (words.length > 4 ? "..." : "");
      }
      return AyatQuizVerseOption(id: doc.id, title: verseTitle);
    }).toList();
  }

  @override
  Future<void> saveSettings({
    required String churchId,
    required String chapterId,
    required ExamVersesSettings settings,
  }) {
    // أسماء الحقول دي مقدسة — verses_exam_quiz_page.dart بيقرا منها بالظبط بنفس الأسماء
    return _versesSettings(churchId, chapterId).add({
      'versesIds': settings.verseIds,
      'versesTitles': settings.verseTitles,
      'durationDays': settings.durationDays,
      'examStart': Timestamp.fromDate(settings.examStart),
      'examEnd': Timestamp.fromDate(settings.examEnd),
      'isRepeatable': settings.isRepeatable,
      'hasTimer': settings.hasTimer,
      'timerDuration': settings.hasTimer ? settings.timerDuration : null,
      'timestamp': FieldValue.serverTimestamp(),
      'userFullName': settings.userFullName,
      'userId': settings.userId,
      'season': settings.season,
    });
  }
}