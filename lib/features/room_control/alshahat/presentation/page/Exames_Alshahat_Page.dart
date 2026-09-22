import 'package:aner_astaner/features/exam/presentation/pages/exam_catalog/presentation/pages/widgets/add_exames_alshahat_box.dart';
import 'package:aner_astaner/features/room_control/question_or_edit_questions/presentation/page/Exames_Questions_Page.dart';
import 'package:aner_astaner/features/exam/presentation/pages/exam_chapter/presentation/controllers/exam_chapter_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ExamesAlshahatPage extends StatefulWidget {
  const ExamesAlshahatPage({
    Key? key,
    this.ChurchID,
    this.ChapterID,
    this.AlngelID,
  }) : super(key: key);
  final String? ChurchID;
  final String? ChapterID;
  final String? AlngelID;

  @override
  State<ExamesAlshahatPage> createState() => _ExamesAlshahatPageState();
}

class _ExamesAlshahatPageState extends State<ExamesAlshahatPage> {
  late final ExamChapterController controller;
  late final String controllerTag;

  @override
  void initState() {
    super.initState();
    controllerTag = '${widget.ChurchID}_${widget.ChapterID}_${widget.AlngelID}';
    controller = Get.put(
      ExamChapterController(
        churchId: widget.ChurchID,
        chapterId: widget.ChapterID,
        categoryId: widget.AlngelID,
      ),
      tag: controllerTag,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(),
      floatingActionButton: _buildFab(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('اسئلة الإصحاحات'),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: EdgeInsets.all(8.0.h),
      child: StreamBuilder(
        stream: controller.watchChapters(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ أثناء التحميل'));
          }
          final chapters = snapshot.data ?? const [];
          return _buildChaptersGrid(context, chapters);
        },
      ),
    );
  }

  GridView _buildChaptersGrid(BuildContext context, List chapters) {
    return GridView.builder(
      itemCount: chapters.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2.bitLength,
        mainAxisExtent: 160.spMax,
      ),
      itemBuilder: (context, i) {
        final chapter = chapters[i];
        return _buildChapterCard(context, chapter);
      },
    );
  }

  Widget _buildChapterCard(BuildContext context, chapter) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ExamesQuestionsPage(
              AlshahatID: chapter.id,
              AlngelID: widget.AlngelID,
              ChapterID: widget.ChapterID,
              ChurchID: widget.ChurchID,
            ),
          ),
        );

        // ViewQuizPage(
        //       categoryid: data[i].id,
        //     )));
      },
      onLongPress: () => _confirmDeleteChapter(context, chapter),
      child: Card(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15.dg),
              child: Image.asset(
                "assets/images/Splash_View2.png",
                height: 100.h,
              ),
            ),
            Text(chapter.title),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteChapter(BuildContext context, chapter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الإصحاح؟'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(ctx),
          ),
          TextButton(
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(ctx);
              await controller.deleteChapter(chapter.id);
            },
          ),
        ],
      ),
    );
  }

  FloatingActionButton _buildFab(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: Colors.amber,
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AddExamesAlshahatBox(
            ChaptersID: widget.ChapterID,
            ChurchID: widget.ChurchID,
            AlngelID: widget.AlngelID,
            controllerTag: controllerTag,
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }
}
