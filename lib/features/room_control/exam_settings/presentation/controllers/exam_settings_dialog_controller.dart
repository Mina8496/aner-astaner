import 'package:aner_astaner/features/room_control/exam_settings/domain/entities/exam_setting.dart';
import 'package:aner_astaner/features/room_control/exam_settings/presentation/controllers/exam_settings_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aner_astaner/features/user/domain/repositories/user_repository.dart';
import 'package:aner_astaner/features/exam/presentation/pages/exam_catalog/domain/entities/catalog_item.dart';
import 'package:aner_astaner/features/exam/presentation/pages/exam_catalog/presentation/controllers/exam_catalog_controller.dart';


class ExamSettingsDialogController {
  ExamSettingsDialogController({
    required this.churchId,
    required this.chapterId,
    bool initialIsRepeatable = false,
    bool initialHasTimer = false,
    required this.onStateChanged,
    ExamCatalogController? catalogController,
    ExamSettingsController? settingsController,
  })  : isRepeatable = initialIsRepeatable,
        hasTimer = initialHasTimer,
        _catalogController = catalogController ?? Get.find<ExamCatalogController>(),
        _settingsController = settingsController ?? Get.find<ExamSettingsController>();

  final String? churchId;
  final String? chapterId;
  final VoidCallback onStateChanged;
  final ExamCatalogController _catalogController;
  final ExamSettingsController _settingsController;

  bool isRepeatable;
  bool hasTimer;
  bool isLoading = true;
  bool isSaving = false;

  String? fullName;
  String? season;

  List<CatalogItem> booksList = [];
  List<CatalogItem> chaptersList = [];

  String? selectedBookId;
  String? selectedChapterId;

  DateTime? examStartDate;
  DateTime? examEndDate;
  int durationDays = 1;
  double timerDuration = 30;

  Future<void> loadUserData() async {
    final profile = await Get.find<UserRepository>().fetchCurrentUserProfile();
    if (profile != null) {
      fullName = profile.fullName;
      season = profile.season;
    }
    isLoading = false;
    onStateChanged();
    await fetchBooks();
  }

  Future<void> fetchBooks() async {
    if (churchId == null || chapterId == null) return;
    booksList = await _catalogController.fetchCategories(churchId: churchId!, chapterId: chapterId!);
    onStateChanged();
  }

  Future<void> selectBook(String bookId) async {
    selectedBookId = bookId;
    selectedChapterId = null;
    chaptersList = [];
    onStateChanged();
    if (churchId == null || chapterId == null) return;
    chaptersList = await _catalogController.fetchChapters(
      churchId: churchId!,
      chapterId: chapterId!,
      categoryId: bookId,
    );
    onStateChanged();
  }

  void selectChapter(String chapterId) {
    selectedChapterId = chapterId;
    onStateChanged();
  }

  void setExamStartDate(DateTime date) {
    examStartDate = date;
    if (examEndDate != null) {
      durationDays = examEndDate!.difference(examStartDate!).inDays + 1;
    }
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

  String? _titleFor(List<CatalogItem> items, String? id) {
    for (final item in items) {
      if (item.id == id) return item.title;
    }
    return null;
  }

  /// null = صالح للحفظ
  String? validate() {
    if (selectedBookId == null || selectedChapterId == null) return 'يجب اختيار السفر والإصحاح';
    if (examStartDate == null || examEndDate == null) return 'يجب تحديد تواريخ الامتحان';
    return null;
  }

  Future<void> saveSettings() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    isSaving = true;
    onStateChanged();

    final setting = ExamSetting(
      bookId: selectedBookId!,
      chapterId: selectedChapterId!,
      bookTitle: _titleFor(booksList, selectedBookId) ?? "السفر",
      chapterTitle: _titleFor(chaptersList, selectedChapterId) ?? "الإصحاح",
      durationDays: durationDays,
      isRepeatable: isRepeatable,
      hasTimer: hasTimer,
      examStart: examStartDate,
      examEnd: examEndDate,
      timerDuration: hasTimer ? timerDuration.toInt() : null,
      userFullName: fullName,
      userId: currentUser.uid,
      season: season,
    );

    await _settingsController.createSetting(churchId: churchId!, chapterId: chapterId!, setting: setting);

    isSaving = false;
    onStateChanged();
  }
}