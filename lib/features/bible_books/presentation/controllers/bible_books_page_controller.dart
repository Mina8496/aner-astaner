import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BibleBooksPageController {
  BibleBooksPageController({required this.onStateChanged});

  final VoidCallback onStateChanged;

  Map<String, dynamic> bible = {};
  List<String> bookNames = [];
  String selectedBook = '';
  int selectedChapter = 1;
  Set<String> favorites = {};
  String selectedFilter = 'الكل';

  static const List<String> oldTestament = [
    'gn', 'ex', 'lv', 'nm', 'dt', 'js', 'jud', 'rt', '1sm', '2sm', '1kgs',
    '2kgs', '1ch', '2ch', 'ezr', 'ne', 'et', 'job', 'ps', 'prv', 'ec', 'so',
    'is', 'jr', 'lm', 'ez', 'dn', 'ho', 'jl', 'am', 'ob', 'jn', 'mi', 'na',
    'hk', 'zp', 'hg', 'zc', 'ml',
  ];

  static const List<String> newTestament = [
    'mt', 'mk', 'lk', 'jo', 'act', 'rm', '1co', '2co', 'gl', 'eph', 'ph',
    'cl', '1ts', '2ts', '1tm', '2tm', 'tt', 'phm', 'hb', 'jm', '1pe', '2pe',
    '1jo', '2jo', '3jo', 'jd', 're',
  ];

  static const Map<String, String> arabicBookNames = {
    'gn': 'التكوين', 'ex': 'الخروج', 'lv': 'اللاويين', 'nm': 'العدد',
    'dt': 'التثنية', 'js': 'يشوع', 'jud': 'القضاة', 'rt': 'راعوث',
    '1sm': 'صموئيل الأول', '2sm': 'صموئيل الثاني', '1kgs': 'الملوك الأول',
    '2kgs': 'الملوك الثاني', '1ch': 'أخبار الأيام الأول',
    '2ch': 'أخبار الأيام الثاني', 'ezr': 'عزرا', 'ne': 'نحميا',
    'et': 'أستير', 'job': 'أيوب', 'ps': 'المزامير', 'prv': 'الأمثال',
    'ec': 'الجامعة', 'so': 'نشيد الأنشاد', 'is': 'إشعياء', 'jr': 'إرميا',
    'lm': 'مراثي إرميا', 'ez': 'حزقيال', 'dn': 'دانيال', 'ho': 'هوشع',
    'jl': 'يوئيل', 'am': 'عاموس', 'ob': 'عوبديا', 'jn': 'يونان',
    'mi': 'ميخا', 'na': 'ناحوم', 'hk': 'حبقوق', 'zp': 'صفنيا',
    'hg': 'حجي', 'zc': 'زكريا', 'ml': 'ملاخي', 'mt': 'متى', 'mk': 'مرقس',
    'lk': 'لوقا', 'jo': 'يوحنا', 'act': 'أعمال الرسل', 'rm': 'رومية',
    '1co': 'كورنثوس الأولى', '2co': 'كورنثوس الثانية', 'gl': 'غلاطية',
    'eph': 'أفسس', 'ph': 'فيلبي', 'cl': 'كولوسي',
    '1ts': 'تسالونيكي الأولى', '2ts': 'تسالونيكي الثانية',
    '1tm': 'تيموثاوس الأولى', '2tm': 'تيموثاوس الثانية', 'tt': 'تيطس',
    'phm': 'فليمون', 'hb': 'العبرانيين', 'jm': 'يعقوب',
    '1pe': 'بطرس الأولى', '2pe': 'بطرس الثانية', '1jo': 'يوحنا الأولى',
    '2jo': 'يوحنا الثانية', '3jo': 'يوحنا الثالثة', 'jd': 'يهوذا',
    're': 'الرؤيا',
  };

  Future<void> init() async {
    await _loadBible();
    await _loadFavorites();
  }

  Future<void> _loadBible() async {
    final data = await rootBundle.loadString('assets/bible/ar_svd.json');
    final List<dynamic> bibleList = json.decode(data);

    final Map<String, dynamic> parsed = {};
    for (final book in bibleList) {
      final String abbrev = book['abbrev'];
      final List<dynamic> chapters = book['chapters'];
      final Map<String, Map<String, String>> chapterMap = {};

      for (int i = 0; i < chapters.length; i++) {
        final List<dynamic> verses = chapters[i];
        final Map<String, String> verseMap = {};
        for (int j = 0; j < verses.length; j++) {
          verseMap[(j + 1).toString()] = verses[j];
        }
        chapterMap[(i + 1).toString()] = verseMap;
      }
      parsed[abbrev] = chapterMap;
    }

    bible = parsed;
    bookNames = parsed.keys.toList();
    selectedBook = bookNames.first;
    onStateChanged();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    onStateChanged();
  }

  Future<void> toggleFavorite(String verse) async {
    final prefs = await SharedPreferences.getInstance();
    if (favorites.contains(verse)) {
      favorites.remove(verse);
    } else {
      favorites.add(verse);
    }
    await prefs.setStringList('favorites', favorites.toList());
    onStateChanged();
  }

  void selectFilter(String filter) {
    selectedFilter = filter;
    if (filter == 'العهد القديم') {
      bookNames = oldTestament;
    } else if (filter == 'العهد الجديد') {
      bookNames = newTestament;
    } else {
      bookNames = bible.keys.toList();
    }
    selectedBook = bookNames.first;
    selectedChapter = 1;
    onStateChanged();
  }

  void selectBook(String book) {
    selectedBook = book;
    selectedChapter = 1;
    onStateChanged();
  }

  void selectChapter(int chapter) {
    selectedChapter = chapter;
    onStateChanged();
  }

  void goToPreviousChapter() {
    if (selectedChapter > 1) {
      selectedChapter--;
      onStateChanged();
    }
  }

  void goToNextChapter() {
    final max = bible[selectedBook]?.length ?? 1;
    if (selectedChapter < max) {
      selectedChapter++;
      onStateChanged();
    }
  }

  int get chapterCount => bible[selectedBook]?.length ?? 1;

  Map<String, dynamic>? get currentChapterMap =>
      bible[selectedBook]?['$selectedChapter'] as Map<String, dynamic>?;
}