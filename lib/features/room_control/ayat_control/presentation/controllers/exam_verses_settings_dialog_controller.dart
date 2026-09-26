import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aner_astaner/features/user/domain/repositories/user_repository.dart';

import '../../data/repositories/firestore_exam_verses_settings_repository.dart';
import '../../domain/entities/ayat_quiz_verse_option.dart';
import '../../domain/entities/exam_verses_settings.dart';
import '../../domain/repositories/exam_verses_settings_repository.dart';

class ExamVersesSettingsDialogController {
  ExamVersesSettingsDialogController({
    ExamVersesSettingsRepository? repository,
    required this.onStateChanged,
  }) : _repository = repository ?? FirestoreExamVersesSettingsRepository();

  final ExamVersesSettingsRepository _repository;
  final VoidCallback onStateChanged;

  bool isRepeatable = false;
  bool hasTimer = false;
  bool isLoading = true;
  bool isSaving = false;

  String? churchId;
  String? chapterId;
  String? fullName;
  String? season;

  List<AyatQuizVerseOption> versesList = [];
  List<String> selectedVerses = [];

  DateTime? examStartDate;
  DateTime? examEndDate;
  int durationDays = 1;
  double timerDuration = 30;

  Future<void> loadUserData() async {
    final profile = await Get.find<UserRepository>().fetchCurrentUserProfile();
    if (profile == null) return;

    churchId = profile.churchId;
    chapterId = profile.chapterId;
    fullName = profile.fullName;
    season = profile.season;

    await fetchVerses();
    isLoading = false;
    onStateChanged();
  }

  Future<void> fetchVerses() async {
    versesList = await _repository.fetchAvailableVerses(churchId: churchId!, chapterId: chapterId!);
    onStateChanged();
  }

  void toggleVerseSelection(String verseId, bool selected) {
    selected ? selectedVerses.add(verseId) : selectedVerses.remove(verseId);
    onStateChanged();
  }

  void setExamStartDate(DateTime date) {
    examStartDate = date;
    examEndDate ??= date.add(const Duration(days: 1));
    durationDays = examEndDate!.difference(examStartDate!).inDays + 1;
    onStateChanged();
  }

  void setExamEndDate(DateTime date) {
    examEndDate = date;
    durationDays = examEndDate!.difference(examStartDate!).inDays + 1;
    onStateChanged();
  }

  void setIsRepeatable(bool value) { isRepeatable = value; onStateChanged(); }
  void setHasTimer(bool value) { hasTimer = value; onStateChanged(); }
  void setTimerDuration(double value) { timerDuration = value; onStateChanged(); }

  /// null = صالح للحفظ
  String? validate() {
    if (selectedVerses.isEmpty) return "يجب اختيار آية واحدة على الأقل";
    if (examStartDate == null || examEndDate == null) return "يجب تحديد التواريخ";
    return null;
  }

  Future<void> saveSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    isSaving = true;
    onStateChanged();

    final selectedTitles = versesList
        .where((v) => selectedVerses.contains(v.id))
        .map((v) => v.title)
        .toList();

    final settings = ExamVersesSettings(
      verseIds: selectedVerses,
      verseTitles: selectedTitles,
      durationDays: durationDays,
      examStart: examStartDate!,
      examEnd: examEndDate!,
      isRepeatable: isRepeatable,
      hasTimer: hasTimer,
      timerDuration: hasTimer ? timerDuration.toInt() : null,
      userFullName: fullName,
      userId: user.uid,
      season: season,
    );

    await _repository.saveSettings(churchId: churchId!, chapterId: chapterId!, settings: settings);

    isSaving = false;
    onStateChanged();
  }

  void cancelSaving() { isSaving = false; onStateChanged(); }
}