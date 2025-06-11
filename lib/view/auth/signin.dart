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

import '../../controller/auth_controller.dart';
import '../../controller/app_controller.dart';
import '../../widgets/input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.put(AuthController());
  final AppController appController = Get.find<AppController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    final credentials = await authController.getSavedCredentials();
    final isRememberMeEnabled = await authController.isRememberMeEnabled();

    if (isRememberMeEnabled && credentials['cnic'] != null) {
      setState(() {
        emailController.text = credentials['cnic']!;
        passwordController.text = credentials['password'] ?? '';
        rememberMe = true;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter both CNIC and password',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await authController.loginUser(
      cnic: emailController.text.trim(),
      password: passwordController.text,
      rememberMe: rememberMe,
    );

    if (success) {
      appController.onLoginSuccess();
    }
  }

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
                  "CNIC",
                  style: subTitleTextStyle(color: blackColor, size: 15),
                ),
                InputField(
                  hintText: "Enter your CNIC (e.g., 3520112345678)",
                  controller: emailController, // We'll keep using emailController for backend compatibility
                  inputType: TextInputType.number,
                ),
                const SizedBox(height: 10),
                Text(
                  "PASSWORD",
                  style: subTitleTextStyle(color: blackColor, size: 15),
                ),
                InputField(
                  hintText: "Enter your password",
                  isPassword: true,
                  controller: passwordController,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CheckerBox(
                      value: rememberMe,
                      onChecked: (bool? value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
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
                Obx(() {
                  if (authController.isLoading.value) {
                    return Container(
                      height: 50,
                      child: Center(
                        child: SpinKitThreeInOut(
                          color: primaryColor,
                          size: 30,
                        ),
                      ),
                    );
                  }
                  return CustomBtn(
                    text: 'Login',
                    onPressed: _handleLogin,
                  );
                }),
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
  final bool value;

  const CheckerBox({Key? key, required this.onChecked, this.value = false}) : super(key: key);

  @override
  State<CheckerBox> createState() => _CheckerBoxState();
}

class _CheckerBoxState extends State<CheckerBox> {
  late bool isCheck;

  @override
  void initState() {
    super.initState();
    isCheck = widget.value;
  }

  @override
  void didUpdateWidget(CheckerBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      isCheck = widget.value;
    }
  }

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
