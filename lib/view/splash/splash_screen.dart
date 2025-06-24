import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import '../../controller/app_controller.dart';
import '../../controller/auth_controller.dart';
import '../../utils/constants.dart';
import '../../utils/style.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(AuthController());
    Get.put(AppController());

    return Scaffold(
      backgroundColor: whiteColor,
      body: Obx(() {
        final appController = Get.find<AppController>();
        
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo
              SizedBox(
                width: 120,
                height: 120,
                child: Image.asset("assets/images/pphi.png",fit: BoxFit.contain,),
              ),
              
              const SizedBox(height: 30),
              
              // App Name
              Text(
                'Basic Health Unit',
                style: titleTextStyle(
                  size: 26,
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 10),
              
              // App Tagline
              Text(
                'Your Health, Our Priority',
                style: subTitleTextStyle(
                  color: blackLightColor,
                  size: 16,
                ),
              ),
              
              const SizedBox(height: 50),
              
              // Loading Indicator
              if (appController.isLoading.value) ...[
                SpinKitThreeInOut(
                  color: primaryColor,
                  size: 40,
                ),
                const SizedBox(height: 20),
                Text(
                  'Initializing...',
                  style: subTitleTextStyle(
                    color: blackLightColor,
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
