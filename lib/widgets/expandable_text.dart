import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  ExpandableText({required this.text, this.maxLines = 4});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool showMore = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textSpan = TextSpan(
          text: widget.text,
          style: TextStyle(fontSize: 16, color: Colors.black),
        );

        final textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);


        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text.rich(
              TextSpan(
                
                text: showMore ? widget.text : _getTrimmedText(widget.text),
                style: subTitleTextStyle(),
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()..onTap = () {
                  setState(() {
                    showMore = !showMore;
                  });
                },
                    text: showMore ? ' show less' : ' show more',
                    style: descriptionTextStyle(color: primaryColor)
                  ),
                ],
              ),
              maxLines: showMore ? null : widget.maxLines,
              overflow: showMore ? TextOverflow.visible : TextOverflow.ellipsis,
              
            ),
            
          ],
        );
      },
    );
  }

  String _getTrimmedText(String text) {
    return text.length > 100 ? text.substring(0, 100) : text;
  }
}
