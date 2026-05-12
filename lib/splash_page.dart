import 'dart:async';

import 'package:auto_care/constants/app_layout.dart';
import 'package:auto_care/starting_page.dart';
import 'package:auto_care/utils/color_helper.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(AppLayout.splashDisplayDuration, () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (context) => const StartingPage(),
        ),
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
