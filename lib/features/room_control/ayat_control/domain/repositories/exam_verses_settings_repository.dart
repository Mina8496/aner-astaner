import '../entities/ayat_quiz_verse_option.dart';
import '../entities/exam_verses_settings.dart';

abstract interface class ExamVersesSettingsRepository {
  Future<List<AyatQuizVerseOption>> fetchAvailableVerses({
    required String churchId,
    required String chapterId,
  });

  Future<void> saveSettings({
    required String churchId,
    required String chapterId,
    required ExamVersesSettings settings,
  });
}