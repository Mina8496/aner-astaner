import 'package:flutter/material.dart';

import '../../features/category/presentation/page/AddNewCatgory.dart';
import '../../features/organization/presentation/pages/widgets/Add_churches_Box.dart';
import '../../features/category/presentation/page/Category_Page.dart';
import '../../features/chapter(alshahat)/presentation/page/Chapters_Page.dart';
import '../../features/organization/presentation/pages/Churches_Page.dart';
import '../../features/home_page/presentation/page/Home_page.dart';
import '../../features/Login/Completw_information_body.dart';
import '../../features/Login/Inital_Login.dart';
import '../../features/Login/Rigester_View.dart';
import '../../features/Login/login_Page.dart';
import '../../features/home_page/presentation/page/MasterHome_Page.dart';
import '../../features/splash_page/presentation/page/splash_body.dart';
import '../../features/home_page/presentation/page/widgets/BottomNavBar.dart';

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
