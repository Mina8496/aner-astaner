import 'package:aner_astaner/features/alshahat/presentation/page/Chapters_Page.dart';
import 'package:aner_astaner/features/churches/presentation/pages/churches_page.dart';
import 'package:aner_astaner/features/churches/presentation/pages/widgets/Add_churches_Box.dart';
import 'package:flutter/material.dart';

import '../../features/category/presentation/page/add_new_catgory.dart';
import '../../features/category/presentation/page/category_page.dart';
import '../../features/home_page/presentation/page/home_page.dart';
import '../../features/login/presentation/page/Completw_information_body.dart';
import '../../features/login/presentation/page/inital_login.dart';
import '../../features/login/presentation/page/rigester_view.dart';
import '../../features/login/presentation/page/login_page.dart';
import '../../features/home_page/presentation/page/master_home_page.dart';
import '../../features/splash_page/presentation/page/splash_body.dart';
import '../../features/home_page/presentation/page/widgets/bottom_nav_bar.dart';

abstract final class AppRoutes {
  static const splash = 'splashPage';
  static const initialLogin = 'InitalPage';
  static const login = 'loginPage';
  static const register = 'Regist';
  static const home = 'HomePage';
  static const masterHome = 'MasterHome';
  static const completeLogin = 'comLogin';
  static const category = 'CategoryPage';
  static const churches = 'Churchespage';
  static const chapters = 'ChaptersPage';
  static const addCategory = 'AddNewCatgory';
  static const addChurches = 'AddChurchesBox';
  static const bottomNavigation = 'CusBottomNavBar';

  static final Map<String, WidgetBuilder> pages = {
    splash: (_) => const SplashViewBody(),
    initialLogin: (_) => const InitalLogin(),
    login: (_) => loginPage(),
    register: (_) => RigesterView(),
    home: (_) => const HomePage(),
    masterHome: (_) => const MasterHome(),
    completeLogin: (_) => const CompleteInformationBody(),
    category: (_) => const CategoryPage(),
    churches: (_) => const ChurchesPage(),
    chapters: (_) => const ChaptersPage(),
    addCategory: (_) => const AddNewCatgory(),
    addChurches: (_) => const AddChurchesBox(),
    bottomNavigation: (_) => const CusBottomNavBar(),
  };
}
