import 'package:flutter/material.dart';

import '../utils/constants.dart';

Widget buildSection(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: greyColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(children: children),
    );
  }

  Widget buildListTile({String? title, IconData? icon,VoidCallback? onTap,Color?color, bool? isTrailing=true}) {
    return ListTile(
      leading: Icon(icon, color: color??primaryColor),
      title: Text(title!),
      trailing: isTrailing!? const Icon(Icons.arrow_forward_ios, size: 16):SizedBox(),
      onTap: onTap,
    );
  }
  Widget buildListTile2({String? title,String? subttile, IconData? icon,VoidCallback? onTap,Color?color}) {
    return ListTile(
      leading: Icon(icon, color: color??primaryColor),
      title: Text(title!.toUpperCase()),
      subtitle: subttile!=null? Text(subttile):null,
      onTap: onTap,
    );
  }