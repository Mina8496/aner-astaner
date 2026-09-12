import 'package:aner_astaner/core/services/force_update_service.dart';
import 'package:aner_astaner/features/auth/data/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashViewBody extends StatefulWidget {
  const SplashViewBody({super.key});

  @override
  State<SplashViewBody> createState() => _SplashViewBodyState();
}

class _SplashViewBodyState extends State<SplashViewBody>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  Animation<double>? fadingAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    fadingAnimation = Tween<double>(
      begin: .2,
      end: 1,
    ).animate(animationController!);

    animationController?.repeat(reverse: true);

    goToNextView();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ForceUpdateService.checkForUpdate(context);
    });
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: fadingAnimation!,
            child: Image.asset(
              "assets/images/Splash_View5.jpeg",
              width: 392,
              height: 392,
            ),
          ),
          // const SizedBox(
          //   height: 900,
          // ),
        ],
      ),
    );
  }

  void goToNextView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 1), () {
        final user = Get.find<AuthService>().currentUser;
        final isVerified = user?.emailVerified ?? false;

        Navigator.of(context).pushReplacementNamed(
          (user != null && isVerified) ? "MasterHome" : "InitalPage",
        );
      });
    });
  }
}
