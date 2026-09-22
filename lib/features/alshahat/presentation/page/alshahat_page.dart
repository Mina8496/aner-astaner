import 'package:aner_astaner/features/alshahat/presentation/controllers/chapter_controller.dart';
import 'package:aner_astaner/features/alshahat/presentation/page/add_alshahat_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:get/get.dart';

class AlshahatPage extends StatefulWidget {
  final String AlshahatID;

  const AlshahatPage({super.key, required this.AlshahatID});

  @override
  State<AlshahatPage> createState() => _AlshahatPageState();
}

class _AlshahatPageState extends State<AlshahatPage> {
  late final ChapterController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      ChapterController(categoryId: widget.AlshahatID),
      tag: widget.AlshahatID,
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
      title: const Text('الأصحاحات'),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => ZoomDrawer.of(context)!.toggle(),
        icon: const Icon(Icons.menu),
      ),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : _buildChaptersGrid(),
      ),
    );
  }

  GridView _buildChaptersGrid() {
    return GridView.builder(
      itemCount: controller.chapters.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        // mainAxisExtent: 160,
      ),
      itemBuilder: (context, i) {
        final chapter = controller.chapters[i];
        return _buildChapterCard(context, chapter);
      },
    );
  }

  Widget _buildChapterCard(BuildContext context, chapter) {
    return InkWell(
      onTap: () {
        // Navigator.of(context).push(MaterialPageRoute(
        //     builder: (context) => QusstionPage(
        //           AlshahatID: widget.AlshahatID,
        //           QusstionID: data[i].id,
        //         ))); //QuestionsPage

        // ViewQuizPage(
        //       categoryid: data[i].id,
        //     )));
      },
      onLongPress: () => _confirmDeleteChapter(context, chapter),
      child: Card(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              child: Image.asset("assets/images/alshat.jpeg", height: 100),
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
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذا الأصحاح؟'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('حذف'),
            onPressed: () async {
              await controller.deleteChapter(chapter.id);
              Navigator.pop(context);
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                addAlshahatPage(addAlshahat: widget.AlshahatID),
          ),
        ); //addAlshahatPage
      },
      child: const Icon(Icons.add),
    );
  }
}
