class ExamVersesSettings {
  const ExamVersesSettings({
    required this.verseIds,
    required this.verseTitles,
    required this.durationDays,
    required this.examStart,
    required this.examEnd,
    required this.isRepeatable,
    required this.hasTimer,
    this.timerDuration,
    required this.userFullName,
    required this.userId,
    required this.season,
  });

  final List<String> verseIds;
  final List<String> verseTitles;
  final int durationDays;
  final DateTime examStart;
  final DateTime examEnd;
  final bool isRepeatable;
  final bool hasTimer;
  final int? timerDuration;
  final String? userFullName;
  final String userId;
  final String? season;
}