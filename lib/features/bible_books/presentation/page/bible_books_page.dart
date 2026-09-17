import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/bible_books_page_controller.dart';

class BibleBooksPage extends StatefulWidget {
  const BibleBooksPage({Key? key}) : super(key: key);

  @override
  State<BibleBooksPage> createState() => _BibleBooksPageState();
}

class _BibleBooksPageState extends State<BibleBooksPage> {
  late final BibleBooksPageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BibleBooksPageController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    _controller.init();
  }

  void _copyVerse(String verse) {
    Clipboard.setData(ClipboardData(text: verse));
    showToast('تم نسخ الآية');
  }

  void _showFavorites() {
    showModalBottomSheet(
      context: context,
      builder: (_) => ListView(
        children: _controller.favorites
            .map(
              (v) => ListTile(
                title: Text(v, textAlign: TextAlign.right),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => _copyVerse(v),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Text(
          'الكتاب المقدس',
          style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.favorite), onPressed: _showFavorites),
        ],
      ),
      body: _controller.bible.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterChips(),
                _buildBookChapterSelector(),
                Expanded(child: _buildVersesList()),
                _buildChapterNavigation(),
              ],
            ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: ['الكل', 'العهد القديم', 'العهد الجديد'].map((filter) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ChoiceChip(
            label: Text(filter),
            selected: _controller.selectedFilter == filter,
            onSelected: (_) => _controller.selectFilter(filter),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBookChapterSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _controller.selectedBook,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down),
                  style: GoogleFonts.cairo(fontSize: 16, color: Colors.black),
                  onChanged: (value) => _controller.selectBook(value!),
                  items: _controller.bookNames
                      .map(
                        (code) => DropdownMenuItem(
                          value: code,
                          child: Text(
                            BibleBooksPageController.arabicBookNames[code] ?? code,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            DropdownButton<int>(
              value: _controller.selectedChapter,
              onChanged: (value) => _controller.selectChapter(value!),
              items: List.generate(
                _controller.chapterCount,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text('الإصحاح ${i + 1}', style: GoogleFonts.cairo(fontSize: 15)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVersesList() {
    final chapterMap = _controller.currentChapterMap;
    return ListView(
      padding: const EdgeInsets.all(8),
      children:
          chapterMap?.entries.map((entry) {
            final verseNumber = entry.key;
            final verseText = entry.value;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$verseNumber. $verseText',
                      textDirection: TextDirection.rtl,
                      style: GoogleFonts.cairo(fontSize: 18, height: 1.6),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.blueAccent),
                          onPressed: () => _copyVerse(verseText),
                        ),
                        IconButton(
                          icon: Icon(
                            _controller.favorites.contains(verseText)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.red,
                          ),
                          onPressed: () => _controller.toggleFavorite(verseText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList() ??
          [],
    );
  }

  Widget _buildChapterNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: _controller.goToPreviousChapter,
            ),
          ),
          const SizedBox(width: 20),
          CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: _controller.goToNextChapter,
            ),
          ),
        ],
      ),
    );
  }
}