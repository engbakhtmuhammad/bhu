import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:bhu/view/auth/forgot_pwd.dart';
import 'package:bhu/view/auth/signup.dart';
import 'package:bhu/widgets/custom_btn.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';

import '../../widgets/input_field.dart';
import '../navigation/navigation.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: blackColor,
        leading: IconButton.filledTonal(
          style: IconButton.styleFrom(backgroundColor: greyColor),
          onPressed: () => Get.back(),
          icon: Icon(IconlyLight.arrowLeft2),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Log In",
            style: titleTextStyle(size: 24, color: whiteColor),
          ),
          Text(
            "Please sign in to your account",
            style: subTitleTextStyle(color: greyColor),
          ),
          SizedBox(height: defaultPadding * 2),
          Container(
            padding: EdgeInsets.all(defaultPadding),
            width: double.infinity,
            decoration: BoxDecoration(
              color: whiteColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(45), topRight: Radius.circular(45)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: defaultPadding),
                Text(
                  "EMAIL",
                  style: subTitleTextStyle(color: blackColor, size: 15),
                ),
                InputField(
                  hintText: "user@example.com",
                ),
                const SizedBox(height: 10),
                Text(
                  "PASSWORD",
                  style: subTitleTextStyle(color: blackColor, size: 15),
                ),
                InputField(
                  hintText: "Enter your password",
                  isPassword: true,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CheckerBox(
                      onChecked: (bool? value) {
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 20),
                      child: InkWell(
                        onTap: () => Get.to(() => const ForgotPwdScreen()),
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                CustomBtn(
                    text: 'Login',
                    onPressed: () => Get.to(() => const NavigationScreen()),
                  ),
                // Obx(() {
                //   if (false) {
                //     return SpinKitThreeInOut(
                //       color: primaryColor,
                //     );
                //   }
                //   return CustomBtn(
                //     text: 'Login',
                //     onPressed: () => {},
                //   );
                // }),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign Up",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignupScreen(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CheckerBox extends StatefulWidget {
  final ValueChanged<bool?> onChecked;

  const CheckerBox({Key? key, required this.onChecked}) : super(key: key);

  @override
  State<CheckerBox> createState() => _CheckerBoxState();
}

class _CheckerBoxState extends State<CheckerBox> {
  bool isCheck = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isCheck,
          checkColor: Colors.white,
          activeColor: Theme.of(context).colorScheme.primary,
          onChanged: (val) {
            setState(() {
              isCheck = val!;
            });
            widget.onChecked(val);
          },
        ),
        Text(
          "Remember me",
          style: TextStyle(
            color: Colors.grey.withOpacity(0.8),
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
