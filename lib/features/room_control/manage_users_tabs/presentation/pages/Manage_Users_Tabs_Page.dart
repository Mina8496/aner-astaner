import 'package:flutter/material.dart';
import 'package:aner_astaner/features/user/domain/entities/user_summary.dart';
import 'package:aner_astaner/features/room_control/manage_users_tabs/presentation/controllers/manage_users_page_controller.dart';

class ManageUsersPage extends StatefulWidget {
  final String churchId;
  final String chapterId;

  const ManageUsersPage({
    Key? key,
    required this.churchId,
    required this.chapterId,
  }) : super(key: key);

  @override
  _ManageUsersPageState createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage>
    with SingleTickerProviderStateMixin {
  late final ManageUsersPageController controller;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    controller = ManageUsersPageController(
      churchId: widget.churchId,
      chapterId: widget.chapterId,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildUsersList(Stream<List<UserSummary>> stream, String tab) {
    return StreamBuilder<List<UserSummary>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;
        if (users.isEmpty) {
          return const Center(child: Text("لا يوجد مستخدمين"));
        }

        print("My Church: ${controller.currentChurch}");
        print("My Chapter: ${controller.currentClass}");

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final fullName = user.name;
            final phoneNumber = user.phone;

            return Card(
              child: ListTile(
                title: Text(fullName),
                subtitle: Text(phoneNumber),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab == "all") ...[
                      // ✅ موافق
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        onPressed: () {
                          controller
                              .updateUserStatus(user.id, 'correct')
                              .then((_) {
                                showSnackBar("✅ تم نقل $fullName إلى موافق");
                              });
                        },
                      ),
                      // ❌ غير موافق
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          controller
                              .updateUserStatus(user.id, 'wrong')
                              .then((_) {
                                showSnackBar(
                                  "❌ تم نقل $fullName إلى غير موافق",
                                );
                              });
                        },
                      ),
                    ] else ...[
                      // ↩️ رجوع إلى pending
                      IconButton(
                        icon: const Icon(Icons.undo, color: Colors.blue),
                        onPressed: () {
                          controller
                              .updateUserStatus(user.id, 'pending')
                              .then((_) {
                                showSnackBar(
                                  "↩️ تم إرجاع $fullName إلى كل المستخدمين",
                                );
                              });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildTabBarView(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text("إدارة المخدومين"),
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: "قيد المراجعة"),
          Tab(text: "موافق"),
          Tab(text: "غير موافق"),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildUsersList(controller.usersStream("all"), "all"),
        _buildUsersList(controller.usersStream("correct"), "correct"),
        _buildUsersList(controller.usersStream("wrong"), "wrong"),
      ],
    );
  }
}