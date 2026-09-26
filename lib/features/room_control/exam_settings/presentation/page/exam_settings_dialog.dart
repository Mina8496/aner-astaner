import 'package:aner_astaner/features/room_control/exam_settings/presentation/controllers/exam_settings_dialog_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExamSettingsDialog extends StatefulWidget {
  final String? church;
  final String? chapter;
  final bool? isRepeatable;
  final bool? hasTimer;
  final String? alngelId;

  const ExamSettingsDialog({
    super.key,
    this.isRepeatable,
    this.hasTimer,
    this.church,
    this.chapter,
    this.alngelId,
  });

  @override
  State<ExamSettingsDialog> createState() => _ExamSettingsDialogState();
}

class _ExamSettingsDialogState extends State<ExamSettingsDialog> {
  late final ExamSettingsDialogController controller;

  @override
  void initState() {
    super.initState();
    controller = ExamSettingsDialogController(
      churchId: widget.church,
      chapterId: widget.chapter,
      initialIsRepeatable: widget.isRepeatable ?? false,
      initialHasTimer: widget.hasTimer ?? false,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    controller.loadUserData();
  }

  Future<void> _handleSave() async {
    final error = controller.validate();
    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    try {
      await controller.saveSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم إضافة امتحان جديد بنجاح ✅")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("خطأ أثناء الحفظ: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("إعدادات الامتحان"),
      content: SingleChildScrollView(child: _buildForm()),
      actions: [TextButton(onPressed: _handleSave, child: const Text("تم"))],
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBookDropdown(),
        SizedBox(height: 10.h),
        _buildChapterDropdown(),
        const SizedBox(height: 10),
        _buildDateRangeRow(),
        SizedBox(height: 10.h),
        if (controller.examStartDate != null && controller.examEndDate != null)
          _buildDurationLabel(),
        SizedBox(height: 10.h),
        _buildRepeatableSwitch(),
        _buildTimerSwitch(),
        if (controller.hasTimer) _buildTimerSlider(),
      ],
    );
  }

  Widget _buildBookDropdown() {
    return Container(
      width: 150.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: DropdownButton<String>(
        value: controller.selectedBookId,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: controller.booksList.isNotEmpty
            ? controller.booksList
                  .map(
                    (b) => DropdownMenuItem(value: b.id, child: Text(b.title)),
                  )
                  .toList()
            : [
                const DropdownMenuItem(
                  value: null,
                  child: Text("لا يوجد أسفار متاحة"),
                ),
              ],
        onChanged: (value) {
          if (value != null) controller.selectBook(value);
        },
        hint: const Center(child: Text("السفر")),
      ),
    );
  }

  Widget _buildChapterDropdown() {
    return Container(
      width: 150.w,
      padding: EdgeInsets.symmetric(horizontal: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: DropdownButton<String>(
        value: controller.selectedChapterId,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.arrow_drop_down),
        items: controller.chaptersList.isNotEmpty
            ? controller.chaptersList
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.title)),
                  )
                  .toList()
            : [
                DropdownMenuItem(
                  value: null,
                  child: Text(
                    "اختار السفر أولاً",
                    style: TextStyle(fontSize: 15.sp),
                  ),
                ),
              ],
        onChanged: (value) {
          if (value != null) controller.selectChapter(value);
        },
        hint: const Center(child: Text("الإصحاح")),
      ),
    );
  }

  Widget _buildDateRangeRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDateColumn(
            label: "تاريخ بداية الامتحان:",
            date: controller.examStartDate,
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: controller.examStartDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) controller.setExamStartDate(pickedDate);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDateColumn(
            label: "تاريخ نهاية الامتحان:",
            date: controller.examEndDate,
            onTap: () async {
              if (controller.examStartDate == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('اختر تاريخ البداية أولاً')),
                );
                return;
              }
              final pickedDate = await showDatePicker(
                context: context,
                initialDate:
                    controller.examEndDate ??
                    controller.examStartDate!.add(const Duration(days: 1)),
                firstDate: controller.examStartDate!,
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) controller.setExamEndDate(pickedDate);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateColumn({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
              ],
            ),
            child: Text(
              date != null
                  ? "${date.day}/${date.month}/${date.year}"
                  : "اختر التاريخ",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDurationLabel() {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Text(
        "مدة الامتحان: ${controller.durationDays} يوم${controller.durationDays > 1 ? "s" : ""}",
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildRepeatableSwitch() {
    return SwitchListTile(
      title: const Text("هل الامتحان يتكرر؟"),
      value: controller.isRepeatable,
      onChanged: controller.setIsRepeatable,
    );
  }

  Widget _buildTimerSwitch() {
    return SwitchListTile(
      title: const Text("هل يحتوي على تايمر؟"),
      value: controller.hasTimer,
      onChanged: controller.setHasTimer,
    );
  }

  Widget _buildTimerSlider() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(
          "مدة التايمر: ${controller.timerDuration.toInt()} ثانية",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Slider(
          value: controller.timerDuration,
          min: 20,
          max: 60,
          divisions: 8,
          label: "${controller.timerDuration.toInt()} ثانية",
          onChanged: controller.setTimerDuration,
        ),
      ],
    );
  }
}
