import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sixvalley_delivery_boy/features/splash/controllers/splash_controller.dart';
import 'package:sixvalley_delivery_boy/features/driver_onboarding/screens/driver_welcome_screen.dart';

/// Keeps the existing first-launch route and persisted intro preference.
class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}
class _OnBoardingScreenState extends State<OnBoardingScreen> {
  @override
  void initState() {
    super.initState();
    Get.find<SplashController>().disableIntro();
  }
  @override
  Widget build(BuildContext context) => const DriverWelcomeScreen();
}
