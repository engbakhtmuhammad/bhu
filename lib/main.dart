


import 'package:bhu/utils/constants.dart';
import 'package:bhu/view/onboarding/onboarding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'view/auth/signin.dart';
import 'view/navigation/navigation.dart';

Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();

final SharedPreferences prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(
    hasSeenOnboarding: hasSeenOnboarding,
    isLoggedIn: isLoggedIn,
  ));
}
class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  final bool isLoggedIn;

  const MyApp({
    super.key,
    required this.hasSeenOnboarding,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        
         colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
        textTheme: GoogleFonts.senTextTheme(),
      ),
      home: false
          ? (isLoggedIn ? const NavigationScreen() : const LoginScreen())
          : const OnboardingScreen(),
      // home:  AddPlantScreen(),
    );
  }
}
