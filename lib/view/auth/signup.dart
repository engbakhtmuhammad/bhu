import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:bhu/view/auth/signin.dart';
import 'package:bhu/widgets/custom_btn.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import '../../widgets/input_field.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({Key? key}) : super(key: key);

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
            "Sign Up",
            style: titleTextStyle(size: 24, color: whiteColor),
          ),
          Text(
            "Please sign up to get started",
            style: subTitleTextStyle(color: greyColor),
          ),
           SizedBox(height: defaultPadding*2),
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
                  "NAME",
                  style: subTitleTextStyle(color: blackColor, size: 15),
                ),
                InputField(
                  hintText: "Full Name",
                ),
                const SizedBox(height: 10),
                Text(
                  "PHONE",
                  style: subTitleTextStyle(color: blackColor, size: 15),
                ),
                InputField(
                  hintText: "+923000000000",
                  inputType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
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
                  hintText: "*******",
                  isPassword: true,
                ),
                const SizedBox(height: 20),
                CustomBtn(
                  icon: IconlyLight.login,
                  text: "Sign Up",
                  onPressed: () => {},
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30),
                  child: Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Already have an account? ",
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                          fontSize: 16,
                        ),
                        children: [
                          TextSpan(
                            text: "Sign In",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 16,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginScreen()),
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
