import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';
import 'package:bhu/models/notification.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';
import 'package:bhu/widgets/notification_card.dart';
import 'package:bhu/controller/opd_controller.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class NotificationScreen extends StatelessWidget {
  NotificationScreen({super.key});

  final OpdController opdController = Get.find<OpdController>();
  
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
      body: Obx(() {
        // Convert OPD visits to notifications
        List<NotificationModel> notificationList = [];
        
        if (opdController.opdVisits.isNotEmpty) {
          // Add OPD visit notifications
          for (var visit in opdController.opdVisits.take(5)) {
            final dateFormat = DateFormat('dd/MM/yyyy');
            final timeFormat = DateFormat('hh:mm a');
            final visitDate = visit.visitDateTime;
            final formattedDate = dateFormat.format(visitDate);
            final formattedTime = timeFormat.format(visitDate);
            
            // Calculate time ago
            final now = DateTime.now();
            final difference = now.difference(visitDate);
            String timeAgo;
            
            if (difference.inMinutes < 60) {
              timeAgo = '${difference.inMinutes} minutes ago';
            } else if (difference.inHours < 24) {
              timeAgo = '${difference.inHours} hours ago';
            } else if (difference.inDays < 7) {
              timeAgo = '${difference.inDays} days ago';
            } else {
              timeAgo = formattedDate;
            }
            
            notificationList.add(
              NotificationModel(
                title: "OPD Visit: ${visit.opdTicketNo}",
                description: "Patient visit for ${visit.reasonForVisit} on $formattedDate at $formattedTime",
                time: timeAgo,
              ),
            );
          }
          
          // Add follow-up reminders if any
          for (var visit in opdController.opdVisits) {
            if (visit.followUpAdvised && visit.followUpDays != null) {
              final followUpDate = visit.visitDateTime.add(Duration(days: visit.followUpDays!));
              
              // Only show upcoming follow-ups within the next 7 days
              final now = DateTime.now();
              final difference = followUpDate.difference(now);
              
              if (difference.inDays >= 0 && difference.inDays <= 7) {
                final dateFormat = DateFormat('dd/MM/yyyy');
                final formattedDate = dateFormat.format(followUpDate);
                
                notificationList.add(
                  NotificationModel(
                    title: "Follow-up Reminder",
                    description: "Follow-up visit for ticket ${visit.opdTicketNo} is scheduled for $formattedDate",
                    time: "Upcoming",
                  ),
                );
              }
            }
          }
        }
        
        // If no OPD visits, add a welcome notification
        if (notificationList.isEmpty) {
          notificationList.add(
            NotificationModel(
              title: "Welcome to BHU App",
              description: "Start registering patients and recording OPD visits to see notifications here.",
              time: "Just now",
            ),
          );
        }
        
        return notificationList.isNotEmpty
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
              );
      }),
    );
  }
}
