import 'package:aner_astaner/features/user/presentation/pages/users_blocked_page/presentation/page/Disabled_Account_Page.dart';
import 'package:aner_astaner/features/Login/presentation/page/Edit_User_Profile_Page.dart';
import 'package:aner_astaner/features/show_all_users_results_page/presentation/page/UserPersonalResultsPage.dart';
import 'package:aner_astaner/features/home_page/presentation/page/widgets/BottomNavBar.dart';
import 'package:aner_astaner/features/home_page/presentation/page/widgets/MenuWidget.dart';
import 'package:aner_astaner/features/home_page/presentation/page/widgets/menuItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:aner_astaner/features/auth/data/services/auth_service.dart';
import 'package:get/get.dart';

class MasterHome extends StatefulWidget {
  const MasterHome({super.key});

  @override
  State<MasterHome> createState() => _MasterHomeState();
}

class _MasterHomeState extends State<MasterHome> {
  MenuItem currentItem = MenuItems.home;
  final authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    // نحصل على عرض الشاشة بأمان
    final screenWidth = MediaQuery.of(context).size.width;

    // نتأكد إن القيمة سليمة وإلا نستخدم قيمة افتراضية
    final double slideWidth = (screenWidth.isFinite && screenWidth > 0)
        ? screenWidth * 0.6
        : 250.0;

    return ZoomDrawer(
      style: DrawerStyle.defaultStyle,
      menuBackgroundColor: Colors.indigo,
      borderRadius: 20,
      angle: -5,
      slideWidth: slideWidth,
      showShadow: true,
      drawerShadowsBackgroundColor: Colors.grey,
      openCurve: Curves.fastOutSlowIn,
      closeCurve: Curves.bounceIn,
      mainScreen: getScreen(),
      menuScreen: Builder(
        builder: (context) => MenuWidget(
          currentItem: currentItem,
          onSelectedItem: (item) async {
            if (item == MenuItems.Logout) {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("تأكيد"),
                  content: Text(
                    "هل تريد تسجيل الخروج؟",
                    style: TextStyle(fontSize: 15.sp, color: Colors.black),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("إلغاء"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        "تسجيل الخروج",
                        style: TextStyle(fontSize: 15.sp, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await authService.signOut();
                if (context.mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil("InitalPage", (route) => false);
                }
              }
            } else {
              setState(() => currentItem = item);
              ZoomDrawer.of(context)?.close();
            }
          },
        ),
      ),
    );
  }

  Widget getScreen() {
    final uid = authService.currentUser?.uid;

    switch (currentItem) {
      case MenuItems.home:
        return const CusBottomNavBar();
      case MenuItems.Users:
        return const EditProfilePage();
      case MenuItems.UserPersonalResultsPage:
        if (uid == null) {
          return const Scaffold(
            body: Center(child: Text('لم تقم بتسجيل الدخول')),
          );
        }
        return UserPersonalResultsPage(userId: uid);
      case MenuItems.DisabledUsers:
        return const DisabledUsersPage();
      default:
        return const CusBottomNavBar();
    }
  }
}
