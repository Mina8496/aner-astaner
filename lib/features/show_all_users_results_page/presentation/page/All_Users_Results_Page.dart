import 'dart:async';
import 'package:aner_astaner/features/show_all_users_results_page/domain/repositories/results_repository.dart';
import 'package:aner_astaner/features/user/domain/repositories/user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AllUsersResultsPage extends StatefulWidget {
  const AllUsersResultsPage({super.key});

  @override
  State<AllUsersResultsPage> createState() => _AllUsersResultsPageState();
}

class _AllUsersResultsPageState extends State<AllUsersResultsPage> {
  final ResultsRepository resultsRepo = Get.find<ResultsRepository>();

  String selectedTimeFilter = 'الكل';
  String? selectedBookTitle;
  List<String> timeFilters = ['الكل', 'اليوم', 'الأسبوع', 'الشهر', 'السنة'];
  List<String> bookTitles = [];

  bool? pageEnabled; //  مفتاح تفعيل الصفحة
  String? currentRole;

  StreamSubscription? _pageStatusSub; //  علشان نلغي الاشتراك في dispose

  @override
  void initState() {
    super.initState();
    fetchBookTitles();
    fetchCurrentUserRole();
    listenToPageStatus();
  }

  void listenToPageStatus() {
    _pageStatusSub = resultsRepo.watchResultsPageEnabled().listen((enabled) {
      if (!mounted) return;
      setState(() {
        pageEnabled = enabled;
      });
    });
  }

  Future<void> fetchCurrentUserRole() async {
    final profile = await Get.find<UserRepository>().fetchCurrentUserProfile();
    if (!mounted) return;
    setState(() {
      currentRole = profile?.role;
    });
  }

  Future<void> fetchBookTitles() async {
    final titles = await resultsRepo.fetchDistinctBookTitles();
    if (!mounted) return;
    setState(() {
      bookTitles = titles;
    });
  }

  bool isWithinSelectedTime(DateTime date) {
    final now = DateTime.now();
    switch (selectedTimeFilter) {
      case 'اليوم':
        return now.day == date.day &&
            now.month == date.month &&
            now.year == date.year;
      case 'الأسبوع':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return date.isAfter(startOfWeek);
      case 'الشهر':
        return now.month == date.month && now.year == date.year;
      case 'السنة':
        return now.year == date.year;
      default:
        return true;
    }
  }

  Future<Map<String, Map<String, dynamic>>> fetchUsers(List<String> userIds) {
    return Get.find<UserRepository>().fetchUsersByIds(userIds);
  }

  Stream<List<Map<String, dynamic>>> getCombinedResults() {
    return resultsRepo.watchCombinedResults();
  }

  @override
  void dispose() {
    _pageStatusSub?.cancel(); // ✅ وقف الاستماع
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (pageEnabled == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!pageEnabled!) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("🌍 كل النتائج الكرازة"),
          actions: [
            if (currentRole == "SuperAdmin")
              IconButton(
                icon: const Icon(Icons.lock_open),
                onPressed: () {
                  resultsRepo.setResultsPageEnabled(true);
                },
              ),
          ],
        ),
        body: const Center(
          child: Text(
            "🚫 الصفحة مقفولة مؤقتًا",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("🌍 كل النتائج الكرازة"),
        actions: [
          if (currentRole == "SuperAdmin")
            IconButton(
              icon: const Icon(Icons.lock),
              onPressed: () {
                resultsRepo.setResultsPageEnabled(false);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 10.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoSegmentedControl<String>(
                    groupValue: selectedTimeFilter,
                    children: {for (var f in timeFilters) f: Text(f)},
                    onValueChanged: (val) =>
                        setState(() => selectedTimeFilter = val),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButton<String>(
              isExpanded: true,
              hint: const Text("اختيار السفر"),
              value: selectedBookTitle,
              items: bookTitles
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (val) => setState(() => selectedBookTitle = val),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: getCombinedResults(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filtered = snapshot.data!.where((data) {
                  final date = data['timestamp'] as DateTime;
                  final matchesBook =
                      selectedBookTitle == null ||
                      data['bookTitle'] == selectedBookTitle;
                  return isWithinSelectedTime(date) && matchesBook;
                }).toList();

                final userIds = filtered
                    .map((e) => e['userId'])
                    .whereType<String>()
                    .toSet()
                    .toList();

                return FutureBuilder<Map<String, Map<String, dynamic>>>(
                  future: fetchUsers(userIds),
                  builder: (context, usersSnapshot) {
                    if (!usersSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final usersMap = usersSnapshot.data!;

                    final visible = filtered.where((item) {
                      final u = usersMap[item['userId']];
                      return u != null && u['role'] == 'User';
                    }).toList();

                    if (visible.isEmpty) {
                      return const Center(
                        child: Text("🚫 لا توجد نتائج متاحة"),
                      );
                    }

                    return ListView.builder(
                      itemCount: visible.length,
                      itemBuilder: (context, index) {
                        final data = visible[index];
                        final userId = data['userId'];
                        final fullName = data['full_name'];
                        final percent = data['percentage'] ?? 0.0;
                        final score = data['score'];
                        final total = data['total'];
                        final book = data['bookTitle'] ?? "";
                        final chapter = data['chapterTitle'] ?? "";
                        final date = data['timestamp'] as DateTime;
                        final scoreAyat = data['scoreAyat'];
                        final totalAyat = data['totalQuestionsAyat'];

                        final userData = usersMap[userId] ?? {};
                        final photoUrl = userData['profileImageUrl'];
                        final church = userData['Church'] ?? "كنيسة";

                        int getStars() {
                          if (percent >= 90) return 5;
                          if (percent >= 75) return 4;
                          if (percent >= 60) return 3;
                          if (percent >= 45) return 2;
                          return 1;
                        }

                        Color getColor() {
                          if (percent >= 90) return Colors.green;
                          if (percent >= 75) return Colors.orange;
                          return Colors.red;
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              leading: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  CircleAvatar(
                                    radius: 28,
                                    backgroundImage:
                                        photoUrl != null &&
                                            photoUrl.toString().isNotEmpty
                                        ? NetworkImage(photoUrl)
                                        : const AssetImage(
                                                "assets/images/def_prof.gif",
                                              )
                                              as ImageProvider,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              title: Text(
                                fullName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$church",
                                    style: TextStyle(fontSize: 10.sp),
                                  ),
                                  if (book.isNotEmpty)
                                    Text("📖 $book - $chapter"),
                                  if (score != null &&
                                      total != null &&
                                      total > 0)
                                    Text(
                                      "⭐ $score / $total (${percent.toStringAsFixed(1)}%)",
                                    ),
                                  if (scoreAyat != null && totalAyat != null)
                                    Text(
                                      "📜 مسابقة الآيات: $scoreAyat / $totalAyat",
                                    ),
                                  Text(
                                    "📅 ${DateFormat.yMd().add_jm().format(date)}",
                                  ),
                                  const SizedBox(height: 4),
                                  if (score != null &&
                                      total != null &&
                                      total > 0)
                                    Row(
                                      children: List.generate(
                                        5,
                                        (i) => Icon(
                                          Icons.star,
                                          color: i < getStars()
                                              ? getColor()
                                              : Colors.grey[300],
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
