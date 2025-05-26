import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/app_controller.dart';
import '../../utils/constants.dart';
import '../../utils/style.dart';
import '../../widgets/custom_btn.dart';
import 'onboarding_content.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentIndex = 0;
  late PageController _controller;
  final AppController appController = Get.find<AppController>();

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> completeOnboarding() async {
    await appController.completeOnboarding();
  }

  void skipOnboarding() {
    appController.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Column(
        children: [
          SizedBox(height: Get.height * .2),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: contents.length,
              onPageChanged: (int index) {
                setState(() {
                  currentIndex = index;
                });
              },
              itemBuilder: (_, i) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 55, vertical: 40),
                  child: Column(
                    children: [
                      Image.asset(
                        contents[i].image,
                        height: Get.height * .3,
                      ),
                      const SizedBox(height: 15),
                      Text(
                        contents[i].title,
                        textAlign: TextAlign.center,
                        style: splashTitleTextStyle(),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        contents[i].description,
                        textAlign: TextAlign.center,
                        style: descriptionTextStyle(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              contents.length,
              (index) => buildDot(index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: CustomBtnOnBoarding(
              currentIndex: currentIndex,
              controller: _controller,
              onComplete: completeOnboarding,
            ),
          ),
          TextButton(
            onPressed: skipOnboarding,
            child: Text(
              "Skip",
              style: subTitleTextStyle(),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Container buildDot(int index) {
    return Container(
      height: 10,
      width: currentIndex == index ? 25 : 10,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index ? primaryColor : Colors.grey,
      ),
    );
  }
}

