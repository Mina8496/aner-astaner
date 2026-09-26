import 'package:aner_astaner/features/bible_books/domain/entities/bible_verse.dart';
import 'package:aner_astaner/features/bible_books/presentation/controllers/bible_verse_controller.dart';
import 'package:aner_astaner/features/verses_exam_quiz/presentation/pages/widget/add_ayah_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AyatQuizAdminPage extends StatelessWidget {
  final String? churchID;
  final String? chapterID;

  const AyatQuizAdminPage({
    super.key,
    required this.churchID,
    required this.chapterID,
  });

  BibleVerseController get controller => Get.find<BibleVerseController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("إدارة آيات")),
      floatingActionButton: _buildFab(context),
      body: _buildBody(),
    );
  }

  FloatingActionButton _buildFab(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) =>
              AddAyahDialog(churchID: churchID, chapterID: chapterID),
        );
      },
      backgroundColor: Colors.amber,
      child: const Icon(Icons.add),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<List<BibleVerse>>(
      stream: churchID == null || chapterID == null
          ? const Stream.empty()
          : controller.watchVerses(churchId: churchID!, chapterId: chapterID!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("لا توجد آيات مضافة بعد"));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) =>
              _buildVerseCard(context, snapshot.data![index]),
        );
      },
    );
  }

  Widget _buildVerseCard(BuildContext context, BibleVerse verse) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(verse.text, textDirection: TextDirection.rtl),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.orange),
              onPressed: () => _showEditDialog(
                context,
                churchID!,
                chapterID!,
                verse.id,
                verse.words,
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () =>
                  _confirmDeleteVerse(context, churchID!, chapterID!, verse.id),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteVerse(
    BuildContext context,
    String churchID,
    String chapterID,
    String verseId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("تأكيد الحذف"),
        content: Text("هل تريد حذف هذه الآية؟"),
        actions: [
          TextButton(
            child: Text("إلغاء"),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text("حذف", style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await controller.deleteVerse(
        churchId: churchID,
        chapterId: chapterID,
        verseId: verseId,
      );
    }
  }

  void _showEditDialog(
    BuildContext context,
    String churchID,
    String chapterID,
    String docId,
    List<String> words,
  ) {
    final TextEditingController textController = TextEditingController(
      text: words.join(' '),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل الآية'),
          content: TextFormField(
            controller: textController,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "أدخل الآية الجديدة",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newWords = textController.text.trim().split(
                  RegExp(r'\s+'),
                );
                if (newWords.length < 2) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('يجب إدخال آية صحيحة')),
                  );
                  return;
                }
                await controller.updateVerse(
                  churchId: churchID,
                  chapterId: chapterID,
                  verseId: docId,
                  words: newWords,
                );
                Navigator.pop(context);
              },
              child: Text('حفظ'),
            ),
          ],
        );
      },
    );
  }
}
