import 'package:flutter/material.dart';

import '../../utils/constants.dart';
import '../../utils/style.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: Center(
        child: Text("No Chat Available",style: subTitleTextStyle(color: primaryColor),),
      ),
    );
  }
}