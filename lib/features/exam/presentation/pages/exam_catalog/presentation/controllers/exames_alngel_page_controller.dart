import '../../domain/entities/catalog_item.dart';
import 'exam_catalog_controller.dart';

class ExamesAlngelPageController {
  ExamesAlngelPageController({
    required this.catalogController,
    required this.churchId,
    required this.chapterId,
  });

  final ExamCatalogController catalogController;
  final String? churchId;
  final String? chapterId;

  List<CatalogItem> examCategories = [];
  bool isLoading = true;

  Future<void> fetchCategories() async {
    if (churchId == null || chapterId == null) return;
    examCategories = await catalogController.fetchCategories(
      churchId: churchId!,
      chapterId: chapterId!,
    );
    isLoading = false;
  }

  Future<void> updateCategory({
    required String categoryId,
    required String title,
  }) async {
    await catalogController.updateCategory(
      churchId: churchId!,
      chapterId: chapterId!,
      categoryId: categoryId,
      title: title,
    );
    await fetchCategories();
  }

  Future<void> deleteCategory(String categoryId) async {
    await catalogController.deleteCategory(
      churchId: churchId!,
      chapterId: chapterId!,
      categoryId: categoryId,
    );
    await fetchCategories();
  }
}