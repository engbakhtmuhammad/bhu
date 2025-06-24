import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';

import '../controller/auth_controller.dart';
import '../view/auth/signin.dart';
import '../view/navigation/navigation.dart';
import '../view/onboarding/onboarding_content.dart';

class CustomBtn extends StatelessWidget {
  final IconData? icon;
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? color;

  const CustomBtn({
    super.key,
    this.icon,
    required this.text,
    this.onPressed,
    this.height,this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 50,
      child: icon == null
          ? FilledButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(color??primaryColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(containerRoundCorner), // Customize the radius
                  ),
                ),
              ),
              onPressed: onPressed ?? () {},
              child: Text(text,style: buttonTextStyle(),),
            )
          : FilledButton.icon(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(containerRoundCorner), // Customize the radius
                  ),
                ),
              ),
              onPressed: onPressed ?? () {},
              icon: Icon(icon),
              label: Text(text,style: buttonTextStyle(),),
            ),
    );
  }
}


class CustomBtnOnBoarding extends StatelessWidget {
  CustomBtnOnBoarding({
    super.key,
    required this.currentIndex,
    required PageController controller,
    required this.onComplete,
  }) : _controller = controller;

  final int currentIndex;
  final AuthController _authController = AuthController();
  final PageController _controller;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    return CustomBtn(
      onPressed: () async {
        if (currentIndex == contents.length - 1) {
          await onComplete();
          if (!_authController.isAuthenticated) {
            await _authController.logout();
            Get.offAll(() => const LoginScreen());
          }
          else {
            Get.off(() => const NavigationScreen());
          }
        } else {
          _controller.nextPage(
            duration: const Duration(milliseconds: 100),
            curve: Curves.bounceIn,
          );
        }
      },
      text: currentIndex == contents.length - 1 ? "Continue" : "Next",
    );
  }
}

