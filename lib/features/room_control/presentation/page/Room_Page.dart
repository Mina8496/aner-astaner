import 'package:aner_astaner/features/show_all_exams_page/presentation/page/All_Exames_page.dart';
import 'package:aner_astaner/features/room_control/ayat_control/presentation/page/ayat_admin_page.dart';
import 'package:aner_astaner/features/room_control/class_servants/presentation/pages/search_users_page.dart';
import 'package:aner_astaner/features/room_control/ayat_control/presentation/page/exam_verses_settings_dialog.dart';
import 'package:aner_astaner/features/room_control/exam_settings/presentation/page/exam_settings_dialog.dart';
import 'package:aner_astaner/features/exam/presentation/pages/exam_catalog/presentation/pages/exames_alngel_page.dart';
import 'package:aner_astaner/features/room_control/manage_users_tabs/presentation/pages/manage_users_tabs_page.dart';
import 'package:aner_astaner/features/room_control/presentation/controllers/room_page_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({Key? key, this.ChapterID, this.ChurchID, this.examId})
    : super(key: key);
  final String? ChapterID;
  final String? ChurchID;
  final String? examId;

  @override
  State<RoomPage> createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late final RoomPageController controller;

  @override
  void initState() {
    super.initState();
    controller = RoomPageController(
      onStateChanged: () {
        if (!mounted) return;
        setState(() {});
      },
    );
    controller.checkIfSuperAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('غرفة البيانات'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0.h),
        child: _buildGrid(context),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      padding: EdgeInsets.all(8.dg),
      children: _buildGridItems(context),
    );
  }

  List<Widget> _buildGridItems(BuildContext context) {
    return [
      if (controller.isSuperAdmin)
        _buildGridCard(
          label: "اختيار امين الفصل",
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DataAdmainChurchesPage(
                  chapter: widget.ChapterID,
                  church: widget.ChurchID,
                ),
              ),
            );
          },
        ),

      ///// sub ///
      _buildGridCard(
        label: "ادارة وقبول المخدومين",
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ManageUsersPage(
                churchId: widget.ChurchID!,
                chapterId: widget.ChapterID!,
              ),
            ),
          );
        },
      ),

      /// Exames////
      _buildGridCard(
        label: "اضافة اسئلة من سيربح الملكوت",
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ExamesAlngelPage(
                ChurchID: widget.ChurchID,
                ChapterID: widget.ChapterID,
              ),
            ),
          );
        },
      ),

      _buildGridCard(
        label: "كل الامتحانات اللي تمت إضافتها",
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AllExamsPage(
              chapterId: widget.ChapterID,
              churchId: widget.ChurchID,
            ),
          );
        },
      ),
      //صفحة كل الامتحانات
      _buildGridCard(
        label: "إضافة مسابقة من سربح الملكوت",
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => ExamSettingsDialog(
              chapter: widget.ChapterID,
              church: widget.ChurchID,
            ),
          );
        },
      ),

      /// Exames////
      // InkWell(
      //   onTap: () {
      //     Navigator.of(context).push(
      //       MaterialPageRoute(
      //         builder: (context) => ExamesAlngelPage(
      //           ChurchID: widget.ChurchID,
      //           ChapterID: widget.ChapterID,
      //         ),
      //       ),
      //     );
      //   },
      //   child: Card(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Center(
      //           child: Text(
      //             "اضافة اسئلة من سيربح الملكوت",
      //             textAlign: TextAlign.center,
      //             style: TextStyle(
      //               fontSize: 15.sp,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      // ترتيب الايات
      _buildGridCard(
        label: "اضافة ايات",
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => AyatQuizAdminPage(
              churchID: widget.ChurchID,
              chapterID: widget.ChapterID,
            ),
          );
        },
      ),
      // اضافة مسابفة ايات
      _buildGridCard(
        label: "اضافة مسابفة ترتيب الايات",
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => ExamVersesSettingsDialog(
              // churchID: widget.ChurchID,
              // chapterID: widget.ChapterID,
            ),
          );
        },
      ),
      // اضافة مستخدم
      // InkWell(
      //   onTap: () {
      //     showDialog(
      //       context: context,
      //       builder: (context) => AddDataAdmainChurchesPage(),
      //     );
      //   },
      //   child: Card(
      //     child: Column(
      //       mainAxisAlignment: MainAxisAlignment.center,
      //       children: [
      //         Center(
      //           child: Text(
      //             "اضافه مستخدم جديد",
      //             textAlign: TextAlign.center,
      //             style: TextStyle(
      //               fontSize: 15.sp,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
    ];
  }

  Widget _buildGridCard({required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}