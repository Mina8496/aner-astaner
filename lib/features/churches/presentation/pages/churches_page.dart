import 'package:aner_astaner/features/alshahat/presentation/page/Chapters_Page.dart';
import 'package:aner_astaner/features/churches/domain/entities/organization_item.dart';
import 'package:aner_astaner/features/churches/presentation/controllers/churches_page_controller.dart';
import 'package:aner_astaner/features/churches/presentation/pages/widgets/Add_churches_Box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChurchesPage extends StatefulWidget {
  const ChurchesPage({super.key});

  @override
  State<ChurchesPage> createState() => _ChurchesPageState();
}

class _ChurchesPageState extends State<ChurchesPage> {
  late final ChurchesPageController controller;

  @override
  void initState() {
    super.initState();
    controller = ChurchesPageController(
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
    controller.fetchData();
  }

  Future<void> editChurchName(String id, String currentName) async {
    final textController = TextEditingController(text: currentName);
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تعديل اسم الكنيسة'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(labelText: 'اسم الكنيسة الجديد'),
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
              await controller.updateChurchName(id, name);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => textController.dispose());
  }

  Future<void> confirmDeleteChurch(String id) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف الكنيسة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await controller.deleteChurch(id);
            },
            child: const Text('نعم'),
          ),
        ],
      ),
    );
  }

  void showChurchActions(OrganizationItem church) {
    if (controller.role == 'Admin') {
      editChurchName(church.id, church.title);
      return;
    }
    if (controller.role != 'SuperAdmin') return;

    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('تعديل اسم الكنيسة'),
            onTap: () {
              Navigator.pop(sheetContext);
              editChurchName(church.id, church.title);
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('حذف الكنيسة'),
            onTap: () {
              Navigator.pop(sheetContext);
              confirmDeleteChurch(church.id);
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
    if (controller.churches.isEmpty) {
      return const Center(child: Text('لا توجد كنائس لعرضها'));
    }
    return _buildChurchesGrid();
  }

  Widget _buildChurchesGrid() {
    return GridView.builder(
      itemCount: controller.churches.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemBuilder: (context, index) {
        final church = controller.churches[index];
        return InkWell(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChaptersPage(ChurchID: church.id),
            ),
          ),
          onLongPress: () => showChurchActions(church),
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/Splash_View2.png', height: 100.h),
                Text(
                  church.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
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
        builder: (_) => AddChurchesBox(onSuccess: controller.fetchData),
      ),
      child: const Icon(Icons.add),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المحافظات والكنائس'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(padding: EdgeInsets.all(8.0.h), child: _buildBody()),
      floatingActionButton: _buildFab(),
    );
  }
}