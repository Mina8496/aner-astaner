import 'package:aner_astaner/features/alshahat/presentation/page/widgets/Add_Chapters_Box.dart';
import 'package:aner_astaner/features/churches/domain/entities/organization_item.dart';
import 'package:aner_astaner/features/churches/presentation/controllers/chapters_page_controller.dart';
import 'package:aner_astaner/features/room_control/presentation/page/Room_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChaptersPage extends StatefulWidget {
  final String? ChurchID;

  const ChaptersPage({super.key, this.ChurchID});

  @override
  State<ChaptersPage> createState() => _ChaptersPageState();
}

class _ChaptersPageState extends State<ChaptersPage> {
  late final ChaptersPageController controller;

  @override
  void initState() {
    super.initState();
    controller = ChaptersPageController(
      churchId: widget.ChurchID,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    controller.fetchChapters();
  }

  Future<void> editChapterName(String id, String currentName) async {
    final textController = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تعديل اسم الفصل'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(labelText: 'اسم الفصل الجديد'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = textController.text.trim();
              if (name.isEmpty) return;
              await controller.updateChapterName(id, name);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => textController.dispose(),
    );
  }

  Future<void> showDeleteDialog(String chapterId) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد أنك تريد حذف هذا الفصل؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await controller.deleteChapter(chapterId);
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }

  void showChapterActions(OrganizationItem chapter) {
    if (controller.role == 'Admin') {
      editChapterName(chapter.id, chapter.title);
      return;
    }
    if (controller.role != 'SuperAdmin') return;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('تعديل'),
            onTap: () {
              Navigator.pop(sheetContext);
              editChapterName(chapter.id, chapter.title);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('حذف'),
            onTap: () {
              Navigator.pop(sheetContext);
              showDeleteDialog(chapter.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (controller.chapters.isEmpty) {
      return const Center(child: Text('لا توجد فصول حالياً'));
    }
    return _buildChaptersGrid();
  }

  Widget _buildChaptersGrid() {
    return GridView.builder(
      itemCount: controller.chapters.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final chapter = controller.chapters[index];
        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  RoomPage(ChurchID: widget.ChurchID, ChapterID: chapter.id),
            ),
          ),
          onLongPress: () => showChapterActions(chapter),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/Splash_View2.png', height: 100.h),
                SizedBox(height: 10.h),
                Text(
                  chapter.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget? _buildFab() {
    if (controller.role != 'SuperAdmin') return null;
    return FloatingActionButton(
      backgroundColor: Colors.amber,
      onPressed: () => showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AddChaptersBox(churchID: widget.ChurchID),
      ).then((_) => controller.fetchChapters()),
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الفصول'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(padding: EdgeInsets.all(8.0.h), child: _buildBody()),
      floatingActionButton: _buildFab(),
    );
  }
}
