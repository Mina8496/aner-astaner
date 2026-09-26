import 'package:cloud_firestore/cloud_firestore.dart';

class ExamSetting {
  const ExamSetting({
    this.id = '',
    required this.bookId,
    required this.chapterId,
    required this.bookTitle,
    required this.chapterTitle,
    required this.durationDays,
    required this.isRepeatable,
    required this.hasTimer,
    required this.examStart,
    required this.examEnd,
    this.createdAt,
    this.timerDuration,
    this.userFullName,
    this.userId,
    this.season,
  });

  final String id;
  final String? bookId;
  final String? chapterId;
  final String bookTitle;
  final String chapterTitle;
  final int durationDays;
  final bool isRepeatable;
  final bool hasTimer;
  final DateTime? examStart;
  final DateTime? examEnd;
  final DateTime? createdAt;
  final int? timerDuration;
  final String? userFullName;
  final String? userId;
  final String? season;

  factory ExamSetting.fromMap(Map<String, dynamic> data) {
    return ExamSetting(
      id: data['id'] as String? ?? '',
      bookId: data['bookId'] as String?,
      chapterId: data['chapterId'] as String?,
      bookTitle: data['bookTitle'] as String? ?? 'غير محدد',
      chapterTitle: data['chapterTitle'] as String? ?? 'غير محدد',
      durationDays: (data['durationDays'] as num?)?.toInt() ?? 0,
      isRepeatable: data['isRepeatable'] == true,
      hasTimer: data['hasTimer'] == true,
      examStart: (data['examStart'] as Timestamp?)?.toDate(),
      examEnd: (data['examEnd'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      timerDuration: (data['timerDuration'] as num?)?.toInt(),
      userFullName: data['userFullName'] as String?,
      userId: data['userId'] as String?,
      season: data['season'] as String?,
    );
  }

  bool isAvailableOn(DateTime date) {
    if (examStart == null || examEnd == null) return false;

    final start = examStart!;
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = startDate.add(Duration(days: durationDays));
    final dateOnly = DateTime(date.year, date.month, date.day);

    return !dateOnly.isBefore(startDate) && dateOnly.isBefore(endDate);
  }
}
