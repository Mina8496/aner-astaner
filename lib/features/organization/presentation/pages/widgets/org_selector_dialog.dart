import 'package:aner_astaner/features/organization/domain/entities/organization_item.dart';
import 'package:aner_astaner/features/organization/presentation/controllers/organization_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrgSelectionResult {
  final String churchId;
  final String churchTitle;
  final String chapterId;
  final String chapterTitle;

  OrgSelectionResult({
    required this.churchId,
    required this.churchTitle,
    required this.chapterId,
    required this.chapterTitle,
  });
}

class OrgSelectorDialog extends StatefulWidget {
  const OrgSelectorDialog({super.key});

  @override
  State<OrgSelectorDialog> createState() => _OrgSelectorDialogState();
}

class _OrgSelectorDialogState extends State<OrgSelectorDialog> {
  final organizationController = Get.find<OrganizationController>();

  List<OrganizationItem> churches = [];
  List<OrganizationItem> chapters = [];
  bool isLoadingChurches = true;
  bool isLoadingChapters = false;

  String? selectedChurchId;
  String? selectedChurchTitle;
  String? selectedChapterId;
  String? selectedChapterTitle;

  @override
  void initState() {
    super.initState();
    fetchChurches();
  }

  Future<void> fetchChurches() async {
    setState(() => isLoadingChurches = true);
    // الدايلوج ده مبني إنه ظاهر لـ SuperAdmin بس (شرط في Home_Widget)
    churches = await organizationController.fetchChurches(
      role: 'SuperAdmin',
      churchId: null,
    );
    if (!mounted) return;
    setState(() => isLoadingChurches = false);
  }

  Future<void> fetchChaptersFor(String churchId) async {
    setState(() {
      isLoadingChapters = true;
      chapters = [];
      selectedChapterId = null;
      selectedChapterTitle = null;
    });
    chapters = await organizationController.fetchChapters(
      churchId: churchId,
      role: 'SuperAdmin',
      selectedChapterId: null,
    );
    if (!mounted) return;
    setState(() => isLoadingChapters = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('اختر الكنيسة والفصل'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            isLoadingChurches
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                : DropdownButtonFormField<String>(
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'الكنيسة'),
                    value: selectedChurchId,
                    items: churches
                        .map(
                          (c) => DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(
                              c.title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;

                      final church = churches.firstWhere((c) => c.id == value);

                      setState(() {
                        selectedChurchId = value;
                        selectedChurchTitle = church.title;
                      });

                      fetchChaptersFor(value);
                    },
                  ),
            const SizedBox(height: 16),
            if (selectedChurchId != null)
              isLoadingChapters
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    )
                  : DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(labelText: 'الفصل'),
                      value: selectedChapterId,
                      items: chapters
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c.id,
                              child: Text(
                                c.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        final chapter = chapters.firstWhere(
                          (c) => c.id == value,
                        );

                        setState(() {
                          selectedChapterId = value;
                          selectedChapterTitle = chapter.title;
                        });
                      },
                    ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: selectedChurchId != null && selectedChapterId != null
              ? () {
                  Navigator.pop(
                    context,
                    OrgSelectionResult(
                      churchId: selectedChurchId!,
                      churchTitle: selectedChurchTitle!,
                      chapterId: selectedChapterId!,
                      chapterTitle: selectedChapterTitle!,
                    ),
                  );
                }
              : null,
          child: const Text('تأكيد'),
        ),
      ],
    );
  }
}
