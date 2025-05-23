import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';
import '../../utils/style.dart';
import 'custom_btn.dart';

// ignore: must_be_immutable
class AdsWidget extends StatelessWidget {
  VoidCallback? onPressed;
  AdsWidget({
    super.key, 
    this.onPressed
  });

  Future<void> _openWhatsApp() async {
    const phoneNumber = '+923108366447';
    final Uri whatsappUrl = Uri.parse('https://wa.me/$phoneNumber');
    
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error', 
          'Could not open WhatsApp. Please ensure WhatsApp is installed.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Failed to open WhatsApp',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(containerRoundCorner),
        gradient: LinearGradient(
          colors: [const Color(0xff054F2C), blackColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                '24/7 Health Support Available',
                style: titleTextStyle(size: 16, color: whiteColor),
              ),
              subtitle: Text(
                'Need immediate medical assistance? Our healthcare team is ready to help you anytime.',
                style: descriptionTextStyle(color: greyColor, size: 12),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CustomBtn(
                text: "Contact Now", 
                onPressed: onPressed ?? _openWhatsApp,
                width: Get.width * .4,
                height: 40,
              ),
            )
          ],
        ),
      ),
    );
  }
}