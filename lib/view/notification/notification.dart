import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:bhu/models/notification.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:bhu/widgets/notification_card.dart';

// ignore: must_be_immutable
class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  List<NotificationModel> notificationList = [
    NotificationModel(
      title: "OPD Schedule Update",
      description: "Dr. Ayesha's OPD timings have been updated to 10 AM - 2 PM.",
      time: "20 minutes ago",
    ),
    NotificationModel(
      title: "Vaccination Drive",
      description: "Free polio vaccination for children under 5 years starts tomorrow.",
      time: "1 hour ago",
    ),
    NotificationModel(
      title: "Appointment Reminder",
      description: "Your appointment with Dr. Imran is scheduled for today at 3 PM.",
      time: "2 hours ago",
    ),
    NotificationModel(
      title: "Health Tip",
      description: "Stay hydrated! Drink at least 8 glasses of water a day.",
      time: "4 hours ago",
    ),
    NotificationModel(
      title: "Lab Report Ready",
      description: "Your blood test report is now available. Visit the BHU to collect it.",
      time: "6 hours ago",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      appBar: AppBar(
        backgroundColor: whiteColor,
        leading: IconButton.filledTonal(
          style: IconButton.styleFrom(backgroundColor: greyColor),
          onPressed: () => Get.back(),
          icon: const Icon(IconlyLight.arrowLeft2),
        ),
        title: Text(
          "Notifications",
          style: titleTextStyle(),
        ),
      ),
      body: notificationList.isNotEmpty
          ? SingleChildScrollView(
              child: Column(
                children: List.generate(
                  notificationList.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: NotificationWidget(notification: notificationList[index]),
                  ),
                ),
              ),
            )
          : Center(
              child: Text(
                "No Notifications",
                style: subTitleTextStyle(color: primaryColor),
              ),
            ),
    );
  }
}
