import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants.dart';
import '../../utils/style.dart';
import 'custom_btn.dart';

// ignore: must_be_immutable
class AdsWidget extends StatelessWidget {
  VoidCallback? onPressed;
   AdsWidget({
    super.key, this.onPressed
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(containerRoundCorner),
            gradient:
                LinearGradient(colors: [const Color(0xff054F2C), blackColor])),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(
                  'Advertisement Senternce',
                  style: titleTextStyle(size: 16, color: whiteColor),
                ),
                subtitle: Text(
                  'Here is the description of the advertisement',
                  style: descriptionTextStyle(color: greyColor,size: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: CustomBtn(
                    text: "Contact Now", onPressed: onPressed??(){},width: Get.width*.4,height: 40,),
              )
            ],
          ),
        ));
  }
}
