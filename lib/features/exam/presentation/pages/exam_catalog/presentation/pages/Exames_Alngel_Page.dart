import 'package:aner_astaner/features/exam/presentation/pages/exam_catalog/presentation/controllers/exames_alngel_page_controller.dart';
import 'package:aner_astaner/features/exam/presentation/pages/exam_catalog/presentation/pages/widgets/add_exames_alngel_box.dart';
import 'package:aner_astaner/features/room_control/alshahat/presentation/page/exames_alshahat_page.dart';
import 'package:aner_astaner/features/exam/presentation/pages/exam_catalog/presentation/controllers/exam_catalog_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ExamesAlngelPage extends StatefulWidget {
  const ExamesAlngelPage({Key? key, this.ChurchID, this.ChapterID})
    : super(key: key);
  final String? ChurchID;
  final String? ChapterID;

  @override
  State<ExamesAlngelPage> createState() => _ExamesAlngelPageState();
}

class _ExamesAlngelPageState extends State<ExamesAlngelPage> {
  late final pageController = ExamesAlngelPageController(
    catalogController: Get.find<ExamCatalogController>(),
    churchId: widget.ChurchID,
    chapterId: widget.ChapterID,
  );

  Future<void> _loadCategories() async {
    await pageController.fetchCategories();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (widget.ChurchID != null && widget.ChapterID != null) {
      _loadCategories();
    } else {
      debugPrint("ChurchID or ChapterID is null!");
    }
  }

  // 🟠 تعديل اسم السؤال
  void editExamName(String docId, String currentTitle) {
    TextEditingController titleController = TextEditingController(
      text: currentTitle,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("تعديل اسم السؤال"),
        content: TextField(
          controller: titleController,
          decoration: const InputDecoration(labelText: "الاسم الجديد"),
        ),
        actions: [
          TextButton(
            child: const Text("إلغاء"),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text("حفظ"),
            onPressed: () async {
              if (titleController.text.trim().isNotEmpty) {
                await pageController.updateCategory(
                  categoryId: docId,
                  title: titleController.text.trim(),
                );
                Navigator.pop(ctx);
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اسئلة الاسفار'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0.h),
        child: pageController.isLoading
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
                itemCount: pageController.examCategories.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2.bitLength,
                  mainAxisExtent: 160.spMax,
                ),
                itemBuilder: (context, i) {
                  final exam = pageController.examCategories[i];
                  return InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ExamesAlshahatPage(
                            AlngelID: exam.id,
                            ChapterID: widget.ChapterID,
                            ChurchID: widget.ChurchID,
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('اختر إجراء'),
                          content: const Text(
                            'هل تريد تعديل الاسم أم حذف السفر؟',
                          ),
                          actions: [
                            TextButton(
                              child: const Text(
                                'حذف',
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await pageController.deleteCategory(exam.id);
                                setState(() {});
                              },
                            ),
                            TextButton(
                              child: const Text(
                                'تعديل',
                                style: TextStyle(color: Colors.blue),
                              ),
                              onPressed: () {
                                Navigator.pop(ctx);
                                editExamName(exam.id, exam.title);
                              },
                            ),
                          ],
                        ),
                      );
                    },

                    child: Card(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            child: Image.asset(
                              "assets/images/Splash_View2.png",
                              height: 100,
                            ),
                          ),
                          Text(exam.title),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => AddExamesAlngelBox(
              ChaptersID: widget.ChapterID,
              ChurchID: widget.ChurchID,
              onExameAdded: () {
                _loadCategories();
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}