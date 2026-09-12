// ignore_for_file: unused_element

import 'package:aner_astaner/features/multiple_choice_quiz/presentation/page/Exames_Quiz_Page.dart';
import 'package:aner_astaner/features/verses_exam_quiz/presentation/pages/verses_exam_quiz_page.dart';
import 'package:aner_astaner/features/Login/presentation/page/Edit_User_Page.dart';
import 'package:aner_astaner/features/user/domain/repositories/user_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide Rx;
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';

class ChurchUsersResultsPage extends StatefulWidget {
  const ChurchUsersResultsPage({super.key});

  @override
  State<ChurchUsersResultsPage> createState() => _ChurchUsersResultsPageState();
}

class _ChurchUsersResultsPageState extends State<ChurchUsersResultsPage>
    with SingleTickerProviderStateMixin {
  String? currentUserChurchID;
  String? currentUserClassID;
  String? ChurchName;
  String? SeasonName;
  String? currentUserRole;

  late TabController _tabController;
  late Future<void> _userDataFuture;

  Stream<List<Map<String, dynamic>>>? _examResultsStream;
  Stream<List<Map<String, dynamic>>>? _ayatResultsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _userDataFuture = fetchCurrentUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> fetchCurrentUserData() async {
    final profile = await Get.find<UserRepository>().fetchCurrentUserProfile();
    if (profile == null) return;

    currentUserChurchID = profile.churchId;
    currentUserClassID = profile.chapterId;
    ChurchName = profile.church;
    SeasonName = profile.season;
    currentUserRole = profile.role;
  }

  Future<void> refreshData() async {
    await fetchCurrentUserData();
    setState(() {});
  }

  Stream<List<Map<String, dynamic>>> get examResultsStream =>
      _examResultsStream ??= getExamResults().asBroadcastStream();

  Stream<List<Map<String, dynamic>>> get ayatResultsStream =>
      _ayatResultsStream ??= getAyatResults().asBroadcastStream();

  Stream<Map<String, dynamic>?> latestExamSettingsStream({
    required String churchId,
    required String chapterId,
  }) {
    return FirebaseFirestore.instance
        .collection("Churches")
        .doc(churchId)
        .collection("Chapters")
        .doc(chapterId)
        .collection("Exames")
        .doc(ExamesQuizPage.kFixedExameID)
        .collection("Settings")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          return snap.docs.first.data();
        });
  }

  Stream<String?> latestVersesSettingsIdStream({
    required String churchId,
    required String chapterId,
  }) {
    return FirebaseFirestore.instance
        .collection("Churches")
        .doc(churchId)
        .collection("Chapters")
        .doc(chapterId)
        .collection("Exames")
        .doc(VersesExamQuizPage.kFixedExameID)
        .collection("VersesSettings")
        .orderBy("timestamp", descending: true)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : snap.docs.first.id);
  }

  /// نتائج امتحان "من سيربح الملكوت" مفلترة على الإصحاح النشط حاليًا
  Stream<List<Map<String, dynamic>>> getExamResults() {
    if (currentUserChurchID == null || currentUserClassID == null) {
      return const Stream.empty();
    }

    final resultsStream = FirebaseFirestore.instance
        .collectionGroup("Results")
        .where("examChurchID", isEqualTo: currentUserChurchID)
        .where("chapterID", isEqualTo: currentUserClassID)
        .orderBy("date", descending: true)
        .snapshots();

    final usersStream = FirebaseFirestore.instance
        .collection("users")
        .where("ChurchID", isEqualTo: currentUserChurchID)
        .where("ChapterID", isEqualTo: currentUserClassID)
        .snapshots();

    final settingsStream = latestExamSettingsStream(
      churchId: currentUserChurchID!,
      chapterId: currentUserClassID!,
    );

    return Rx.combineLatest3(resultsStream, usersStream, settingsStream, (
      QuerySnapshot resultsSnap,
      QuerySnapshot usersSnap,
      Map<String, dynamic>? settings,
    ) {
      final examChapterID = settings?['chapterID'];

      final usersMap = <String, Map<String, dynamic>>{};
      for (var doc in usersSnap.docs) {
        usersMap[doc.id] = doc.data() as Map<String, dynamic>;
      }

      final Map<String, Map<String, dynamic>> grouped = {};

      for (var doc in resultsSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final uid = data['userId'];
        if (uid == null) continue;

        final ts = data['date'] is Timestamp
            ? (data['date'] as Timestamp).toDate()
            : DateTime.now();

        final existing = grouped[uid];
        if (existing == null || ts.isAfter(existing['timestamp'] as DateTime)) {
          grouped[uid] = {
            "userId": uid,
            "full_name": data['full_name'] ?? "مستخدم",
            "score": data['score'] ?? 0,
            "total": data['totalQuestions'] ?? 0,
            "percentage":
                double.tryParse(data['percentage']?.toString() ?? "0") ?? 0,
            "bookTitle": data['bookTitle'] ?? "",
            "chapterTitle": data['chapterTitle'] ?? "",
            "chapterID": data['chapterID'],
            "timestamp": ts,
          };
        }
      }

      final List<Map<String, dynamic>> finalList = [];

      for (var e in grouped.values) {
        final uid = e['userId'];
        final user = usersMap[uid];
        if (user == null) continue;
        if (user['disabled'] == true) continue;

        if (examChapterID != null && e['chapterID'] != examChapterID) {
          continue;
        }

        e['profileImageUrl'] = user['profileImageUrl'];
        e['Church'] = user['Church'] ?? "كنيسة";

        finalList.add(e);
      }

      finalList.sort((a, b) {
        final t = (b['timestamp'] as DateTime).compareTo(
          a['timestamp'] as DateTime,
        );
        if (t != 0) return t;
        return (b['score'] as num).compareTo(a['score'] as num);
      });

      return finalList;
    });
  }

  /// ترتيب مسابقة الآيات مفلتر على إعداد الآيات النشط حاليًا
  Stream<List<Map<String, dynamic>>> getAyatResults() {
    if (currentUserChurchID == null || currentUserClassID == null) {
      return const Stream.empty();
    }

    final ayatStream = FirebaseFirestore.instance
        .collection("ExamesAyat")
        .where("examChurchID", isEqualTo: currentUserChurchID)
        .where("chapterID", isEqualTo: currentUserClassID)
        .snapshots();

    final usersStream = FirebaseFirestore.instance
        .collection("users")
        .where("ChurchID", isEqualTo: currentUserChurchID)
        .where("ChapterID", isEqualTo: currentUserClassID)
        .snapshots();

    final versesSettingsIdStream = latestVersesSettingsIdStream(
      churchId: currentUserChurchID!,
      chapterId: currentUserClassID!,
    );

    return Rx.combineLatest3(ayatStream, usersStream, versesSettingsIdStream, (
      QuerySnapshot ayatSnap,
      QuerySnapshot usersSnap,
      String? activeVersesSettingsId,
    ) {
      final usersMap = <String, Map<String, dynamic>>{};
      for (var doc in usersSnap.docs) {
        usersMap[doc.id] = doc.data() as Map<String, dynamic>;
      }

      final Map<String, Map<String, dynamic>> grouped = {};

      for (var doc in ayatSnap.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final uid = data['userId'];
        if (uid == null) continue;

        if (activeVersesSettingsId != null &&
            data['versesSettingsId'] != activeVersesSettingsId) {
          continue;
        }

        final ts = data['date'] is Timestamp
            ? (data['date'] as Timestamp).toDate()
            : DateTime.now();

        final existing = grouped[uid];
        if (existing == null || ts.isAfter(existing['timestamp'] as DateTime)) {
          grouped[uid] = {
            "userId": uid,
            "full_name": data['full_name'] ?? "مستخدم",
            "scoreAyat": data['scoreAyat'] ?? 0,
            "totalQuestionsAyat": data['totalQuestionsAyat'] ?? 0,
            "timestamp": ts,
          };
        }
      }

      final List<Map<String, dynamic>> finalList = [];

      for (var e in grouped.values) {
        final uid = e['userId'];
        final user = usersMap[uid];
        if (user == null) continue;
        if (user['disabled'] == true) continue;

        e['profileImageUrl'] = user['profileImageUrl'];
        e['Church'] = user['Church'] ?? "كنيسة";

        finalList.add(e);
      }

      finalList.sort((a, b) {
        final s = (b['scoreAyat'] as num).compareTo(a['scoreAyat'] as num);
        if (s != 0) return s;
        return (b['timestamp'] as DateTime).compareTo(
          a['timestamp'] as DateTime,
        );
      });

      return finalList;
    });
  }

  void _showEditUserSheet(BuildContext context, String userId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.dg)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(16.dg),
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text('تعديل المستخدم'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditUserPage(userID: userId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard({
    required int rank,
    required String name,
    required String church,
    required String? photoUrl,
    required DateTime date,
    required String userId,
    required List<Widget> subtitleExtras,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.dg),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.w),
          leading: Stack(
            alignment: Alignment.topRight,
            children: [
              CircleAvatar(
                radius: 28.r,
                backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : const AssetImage("assets/images/def_prof.gif")
                          as ImageProvider,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12.dg),
                ),
                padding: EdgeInsets.all(4.dg),
                child: Text(
                  "$rank",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          title: Text(
            name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(church, style: TextStyle(fontSize: 10.sp)),
              ...subtitleExtras,
              Text("📅 ${DateFormat.yMd().add_jm().format(date)}"),
            ],
          ),
          onLongPress:
              (currentUserRole == 'Admin' || currentUserRole == 'SuperAdmin')
              ? () => _showEditUserSheet(context, userId)
              : null,
        ),
      ),
    );
  }

  Widget _buildExamTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: examResultsStream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snap.data!;
        if (results.isEmpty) {
          return const Center(child: Text("لا توجد نتائج بعد"));
        }

        return RefreshIndicator(
          onRefresh: refreshData,
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final data = results[index];
              final percent = (data['percentage'] ?? 0.0) as num;
              final score = data['score'] ?? 0;
              final total = data['total'] ?? 0;
              final book = data['bookTitle'] ?? "سفر";
              final chapter = data['chapterTitle'] ?? "إصحاح";

              return _buildResultCard(
                rank: index + 1,
                name: data['full_name'] ?? "مستخدم",
                church: data['Church'] ?? "كنيسة",
                photoUrl: data['profileImageUrl'],
                date: data['timestamp'] as DateTime,
                userId: data['userId'],
                subtitleExtras: [
                  Text(
                    "📖 $book - $chapter",
                    style: TextStyle(fontSize: 10.sp),
                  ),
                  Text("⭐ $score / $total (${percent.toStringAsFixed(1)}%)"),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildAyatTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: ayatResultsStream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snap.data!;
        if (results.isEmpty) {
          return const Center(child: Text("لا توجد نتائج بعد"));
        }

        return RefreshIndicator(
          onRefresh: refreshData,
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final data = results[index];
              final scoreAyat = data['scoreAyat'] ?? 0;
              final totalAyat = data['totalQuestionsAyat'] ?? 0;

              return _buildResultCard(
                rank: index + 1,
                name: data['full_name'] ?? "مستخدم",
                church: data['Church'] ?? "كنيسة",
                photoUrl: data['profileImageUrl'],
                date: data['timestamp'] as DateTime,
                userId: data['userId'],
                subtitleExtras: [
                  Text("📜 مسابقة الآيات: $scoreAyat / $totalAyat"),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (currentUserChurchID == null || currentUserClassID == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              "⛪ نتائج كنيستى فى $SeasonName",
              style: TextStyle(fontSize: 15.sp),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "مسابقة من سيربح الملكوت"),
                Tab(text: "مسابقة ترتيب الآيات"),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _KeepAlive(child: _buildExamTab()),
              _KeepAlive(child: _buildAyatTab()),
            ],
          ),
        );
      },
    );
  }
}

class _KeepAlive extends StatefulWidget {
  final Widget child;
  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
