import 'package:aner_astaner/features/room_control/ayat_control/presentation/controllers/exam_verses_settings_dialog_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExamVersesSettingsDialog extends StatefulWidget {
  const ExamVersesSettingsDialog({super.key});

  @override
  State<ExamVersesSettingsDialog> createState() =>
      _ExamVersesSettingsDialogState();
}

class _ExamVersesSettingsDialogState extends State<ExamVersesSettingsDialog> {
  late final ExamVersesSettingsDialogController controller;

  @override
  void initState() {
    super.initState();
    controller = ExamVersesSettingsDialogController(
      onStateChanged: () { if (mounted) setState(() {}); },
    );
    controller.loadUserData();
  }

  Future<void> _handleSave() async {
    final error = controller.validate();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(key: UniqueKey(), content: Text(error)));
      return;
    }
    try {
      await controller.saveSettings();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(key: UniqueKey(), content: Text("تم حفظ إعدادات امتحان الآيات ✅")),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      controller.cancelSaving();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(key: UniqueKey(), content: Text("خطأ أثناء الحفظ: $e")),
      );
    }
  }

  void _showMultiVerseDialog() {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: const Text("اختيار الآيات"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: controller.versesList.length,
              itemBuilder: (context, index) {
                final verse = controller.versesList[index];
                return CheckboxListTile(
                  value: controller.selectedVerses.contains(verse.id),
                  title: Text(verse.title),
                  onChanged: (val) {
                    controller.toggleVerseSelection(verse.id, val ?? false);
                    setInnerState(() {});
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: controller.isSaving ? null : _handleSave,
              child: controller.isSaving
                  ? SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(strokeWidth: 2))
                  : const Text("تم"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("إعدادات امتحان الآيات"),
      content: controller.isLoading ? const Center(child: CircularProgressIndicator()) : _buildSettingsForm(),
      actions: [TextButton(onPressed: _handleSave, child: const Text("تم"))],
    );
  }

  Widget _buildSettingsForm() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVersesPicker(),
          SizedBox(height: 15.h),
          _buildDateRangeRow(),
          if (controller.examStartDate != null && controller.examEndDate != null) _buildDurationLabel(),
          SizedBox(height: 10.h),
          _buildRepeatableSwitch(),
          _buildTimerSwitch(),
          if (controller.hasTimer) _buildTimerSlider(),
        ],
      ),
    );
  }

  Widget _buildVersesPicker() {
    return InkWell(
      onTap: _showMultiVerseDialog,
      child: Container(
        width: 200.w,
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
        ),
        child: Text(
          controller.selectedVerses.isEmpty
              ? "اختيار الآيات"
              : "عدد الآيات المحددة: ${controller.selectedVerses.length}",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDateRangeRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDateColumn(
            label: "تاريخ البداية:",
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
            label: "تاريخ النهاية:",
            date: controller.examEndDate,
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: controller.examEndDate ??
                    (controller.examStartDate ?? DateTime.now()).add(const Duration(days: 1)),
                firstDate: controller.examStartDate ?? DateTime.now(),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null) controller.setExamEndDate(pickedDate);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateColumn({required String label, required DateTime? date, required VoidCallback onTap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 5),
        InkWell(onTap: onTap, child: _dateBox(date != null ? "${date.day}/${date.month}/${date.year}" : "اختر التاريخ")),
      ],
    );
  }

  Widget _buildDurationLabel() {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Text("مدة الامتحان: ${controller.durationDays} يوم", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildRepeatableSwitch() {
    return SwitchListTile(title: const Text("هل الامتحان يتكرر؟"), value: controller.isRepeatable, onChanged: controller.setIsRepeatable);
  }

  Widget _buildTimerSwitch() {
    return SwitchListTile(title: const Text("هل يحتوي على تايمر؟"), value: controller.hasTimer, onChanged: controller.setHasTimer);
  }

  Widget _buildTimerSlider() {
    return Column(
      children: [
        const SizedBox(height: 10),
        Text("مدة التايمر: ${controller.timerDuration.toInt()} ثانية", style: const TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _dateBox(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5)],
      ),
      child: Text(text),
    );
  }
}
