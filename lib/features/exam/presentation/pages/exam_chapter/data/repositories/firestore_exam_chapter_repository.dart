import 'package:aner_astaner/core/constants/exam_constants.dart';
import 'package:aner_astaner/features/alshahat/domain/entities/chapter_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/repositories/exam_chapter_repository.dart';

class FirestoreExamChapterRepository implements ExamChapterRepository {
  FirestoreExamChapterRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>? _chapters({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
  }) {
    if ([churchId, chapterId, categoryId].any((id) => id == null)) {
      return null;
    }

    return _firestore
        .collection('Churches')
        .doc(churchId)
        .collection('Chapters')
        .doc(chapterId)
        .collection('Exames')
        .doc(ExamConstants.fixedExamId)
        .collection('Alangel')
        .doc(categoryId)
        .collection('Alshahat');
  }

  @override
  Stream<List<ChapterModel>> watchChapters({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
  }) {
    final chapters = _chapters(
      churchId: churchId,
      chapterId: chapterId,
      categoryId: categoryId,
    );
    if (chapters == null) return Stream.value(const <ChapterModel>[]);

    return chapters.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (document) => ChapterModel(
              id: document.id,
              title: document.data()['title'] as String? ?? 'بدون عنوان',
            ),
          )
          .toList(),
    );
  }

  @override
  Future<void> addChapter({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String title,
  }) async {
    final chapters = _chapters(
      churchId: churchId,
      chapterId: chapterId,
      categoryId: categoryId,
    );
    if (chapters == null) throw StateError('بيانات مسار الأصحاح غير مكتملة');

    await chapters.add({
      'title': title,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteChapter({
    required String? churchId,
    required String? chapterId,
    required String? categoryId,
    required String sectionId,
  }) async {
    final chapters = _chapters(
      churchId: churchId,
      chapterId: chapterId,
      categoryId: categoryId,
    );
    if (chapters == null) throw StateError('بيانات مسار الأصحاح غير مكتملة');

    await chapters.doc(sectionId).delete();
  }
}
