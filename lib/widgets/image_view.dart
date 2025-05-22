import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:get/get.dart';

import '../utils/constants.dart';

class FullScreenImageView extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton.filledTonal(
          style: IconButton.styleFrom(backgroundColor: greyColor),
          onPressed: () => Get.back(),
          icon: const Icon(IconlyLight.arrowLeft2),
        ),
        backgroundColor: whiteColor,
        title: const Text("Image View"),
      ),
      backgroundColor: Colors.black,
      body: Center(
          child: InteractiveViewer( // ✅ Allows pinch-to-zoom
            child: Image.network(imageUrl, fit: BoxFit.contain),
          ),
        ),
    );
  }
}
