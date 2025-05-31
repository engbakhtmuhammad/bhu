import 'package:flutter/material.dart';

import '../utils/constants.dart';

class DropDownWidget extends StatelessWidget {
   DropDownWidget({
    super.key,
     this.child,
  });

   Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: greyColor,
        borderRadius: BorderRadius.circular(containerRoundCorner),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: child??SizedBox()
      ),
    );
  }
}
