
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/input_field.dart';

class ForgotPwdScreen extends StatefulWidget {
  const ForgotPwdScreen({Key? key}) : super(key: key);

  @override
  _ForgotPwdScreenState createState() => _ForgotPwdScreenState();
}

class _ForgotPwdScreenState extends State<ForgotPwdScreen> {
  final _formKey = GlobalKey<FormState>();
  var email = "";

  resetPassword() async {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blackColor,
      appBar: AppBar(
        backgroundColor: blackColor,
        leading: IconButton(
          style: IconButton.styleFrom(backgroundColor: greyColor),
          onPressed: () => Get.back(),
          icon: Icon(IconlyLight.arrowLeft2, color: blackColor),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Forgot Password",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Enter your email to reset your password",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 40),
          Container(
            padding: EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(45),
                topRight: Radius.circular(45),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                          height: 250,
                          width: MediaQuery.of(context).size.width * 0.8,
                          margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.09,
                          ),
                          child: Image.asset("assets/icons/forgot.png"),
                        ),
                Text(
                  "EMAIL",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                InputField(
                  hintText: "Enter your email",
                ),
                SizedBox(height: 20),
                CustomBtn(
                  icon: IconlyLight.message,
                  text: "Send Reset Email",
                  onPressed: () {
                    setState(() {
                      });
                      resetPassword();
                  },
                ),
                SizedBox(height: 30),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Remember your password? ",
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                      children: [
                        TextSpan(
                          text: "Sign In",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Get.back(),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



