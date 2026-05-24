import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/starting_page.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:auto_care/utils/image_helper.dart';
import 'package:auto_care/utils/navigation_helper.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(ImageHelper.logo), context);
    precacheImage(const AssetImage(ImageHelper.shield), context);
  }

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(AppLayout.splashDisplayDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        appRoute<void>(const StartingPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: AppLayout.splashHeroIconSize,
              color: ColorHelper.primaryBlue,
            ),
          ],
        ),
      ),
    );
  }
}
