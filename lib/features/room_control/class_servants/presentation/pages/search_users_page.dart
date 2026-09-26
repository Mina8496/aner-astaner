import 'package:aner_astaner/features/room_control/class_servants/presentation/controllers/data_admain_churches_page_controller.dart';
import 'package:aner_astaner/features/user/presentation/pages/edit_user_page.dart';
import 'package:flutter/material.dart';
import 'package:aner_astaner/features/user/domain/entities/user_summary.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DataAdmainChurchesPage extends StatefulWidget {
  final String? church;
  final String? chapter;

  const DataAdmainChurchesPage({
    Key? key,
    required this.church,
    required this.chapter,
  }) : super(key: key);

  @override
  _DataAdmainChurchesPageState createState() => _DataAdmainChurchesPageState();
}

class _DataAdmainChurchesPageState extends State<DataAdmainChurchesPage> {
  late final DataAdmainChurchesPageController controller;

  @override
  void initState() {
    super.initState();
    controller = DataAdmainChurchesPageController(
      churchId: widget.church,
      chapterId: widget.chapter,
      onStateChanged: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة المستخدمين'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildSearchField(),
            SizedBox(height: 12.h),
            // Row(
            //   children: [
            //     Expanded(
            //       child: DropdownButtonFormField<String>(
            //         initialValue: selectedChurch,
            //         decoration: InputDecoration(
            //           labelText: 'الكنيسة',
            //           border: OutlineInputBorder(),
            //           isDense: true,
            //         ),
            //         items: [
            //           const DropdownMenuItem(value: null, child: Text('الكل')),
            //           ...churchesList.map(
            //             (church) => DropdownMenuItem(
            //               value: church,
            //               child: Text(
            //                 church,
            //                 style: TextStyle(fontSize: 10.sp),
            //               ),
            //             ),
            //           ),
            //         ],
            //         onChanged: (value) {
            //           setState(() {
            //             selectedChurch = value;
            //           });
            //         },
            //       ),
            //     ),
            //   ],
            // ),
            SizedBox(height: 12.h),
            Expanded(child: _buildUsersList()),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.blue,
      //   onPressed: () {
      //     showDialog(
      //       context: context,
      //       barrierDismissible: false,
      //       builder: (ctx) => AddDataAdmainChurchesPage(),
      //     );
      //   },
      //   child: const Icon(Icons.add),
      // ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: '...ابحث باسم المستخدم',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.dg)),
      ),
      onChanged: controller.updateSearchQuery,
    );
  }

  Widget _buildUsersList() {
    return StreamBuilder<List<UserSummary>>(
      stream: controller.usersStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final users = controller.filterUsers(snapshot.data!);
        if (users.isEmpty) {
          return const Center(child: Text('لا يوجد نتائج تطابق البحث'));
        }
        return ListView.separated(
          itemCount: users.length,
          separatorBuilder: (context, _) => SizedBox(height: 10.h),
          itemBuilder: (context, index) => _buildUserCard(users[index]),
        );
      },
    );
  }

  Widget _buildUserCard(UserSummary user) {
    final church = widget.church ?? '';
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.dg)),
      child: ListTile(
        title: Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user.email, overflow: TextOverflow.ellipsis),
            Text('الكنيسة: $church', overflow: TextOverflow.ellipsis),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.shield, size: 20, color: Colors.grey),
            Text(user.role, overflow: TextOverflow.ellipsis),
          ],
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => EditUserPage(userID: user.id)),
        ),
      ),
    );
  }
}
