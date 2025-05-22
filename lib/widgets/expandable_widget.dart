import 'package:flutter/material.dart';
import 'package:bhu/utils/constants.dart';

// ignore: must_be_immutable
class ExpandableOptionalSection extends StatefulWidget {
  final List<Widget> widgetList;
  bool? isExpanded;

   ExpandableOptionalSection({super.key, required this.widgetList,this.isExpanded=false});

  @override
  _ExpandableOptionalSectionState createState() => _ExpandableOptionalSectionState();
}

class _ExpandableOptionalSectionState extends State<ExpandableOptionalSection> {

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: greyColor, // Background color
        borderRadius: BorderRadius.circular(15), // Border radius
        
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text(
              "Plant Data",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            trailing: Icon(widget.isExpanded! ? Icons.expand_less : Icons.expand_more),
            onTap: () {
              setState(() {
                widget.isExpanded = !widget.isExpanded!; // Toggle expansion
              });
            },
          ),
          if (widget.isExpanded!)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: widget.widgetList,
              ),
            ),
        ],
      ),
    );
  }
}
