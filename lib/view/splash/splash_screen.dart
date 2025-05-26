import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../controller/app_controller.dart';
import '../../controller/auth_controller.dart';
import '../../utils/constants.dart';
import '../../utils/style.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(AuthController());
    Get.put(AppController());

    return Scaffold(
      backgroundColor: primaryColor,
      body: Obx(() {
        final appController = Get.find<AppController>();
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.local_hospital,
                    size: 60,
                    color: primaryColor,
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // App Name
              Text(
                'BHU Health',
                style: titleTextStyle(
                  size: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 10),
              
              // App Tagline
              Text(
                'Your Health, Our Priority',
                style: subTitleTextStyle(
                  color: Colors.white.withOpacity(0.8),
                  size: 16,
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Loading Indicator
              if (appController.isLoading.value) ...[
                SpinKitThreeInOut(
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 20),
                Text(
                  'Initializing...',
                  style: subTitleTextStyle(
                    color: Colors.white.withOpacity(0.7),
                    size: 14,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}
