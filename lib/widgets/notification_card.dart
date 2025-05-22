import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:bhu/models/notification.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';

class NotificationWidget extends StatelessWidget {
  const NotificationWidget({super.key, required this.notification});

  final NotificationModel notification;

  @override
  Widget build(BuildContext context) {

    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.red,
        ),
        child: const Icon(
          IconlyLight.delete,
          color: Colors.white,
          size: 25,
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
        final completer = Completer<bool>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: "Keep",
              onPressed: () {
                completer.complete(false);
                ScaffoldMessenger.of(context).removeCurrentSnackBar();
              },
            ),
            content: const Text("Remove from Notification?"),
          ),
        );
        Timer(const Duration(seconds: 3), () {
          if (!completer.isCompleted) {
            completer.complete(true);
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
          }
        });

        return await completer.future;
      },
      onDismissed: (direction) {
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        decoration: BoxDecoration(
          color: greyColor,
          borderRadius: BorderRadius.circular(12), // Rounded borders
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          title: Text(
            notification.title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
      Text(
        notification.description,
        style: Theme.of(context).textTheme.bodySmall,
      ),
      const SizedBox(height: 5), // Spacing between description and time
      Text(
        notification.time,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
      ),
            ],
          ),
          leading: CircleAvatar(
            backgroundColor: primaryLightColor,
            child: Text(
      notification.title[0],
      style: titleTextStyle(),
            ),
          ),
        ),
      ),
    );
  }
}
