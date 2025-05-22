import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:bhu/utils/constants.dart';
import 'package:bhu/utils/style.dart';

class InputField extends StatefulWidget {
  final String hintText;
  final bool isPassword;
  final bool enable;
  final TextInputType? inputType;
  final VoidCallback? onPressed;
  final Icon? suffix;
  final bool? isBold;
  final TextEditingController? controller;

  const InputField({
    Key? key,
    required this.hintText,
    this.isPassword = false,
    this.enable = true,
    this.inputType,
    this.onPressed,
    this.suffix,
    this.isBold=false,
    this.controller,
  }) : super(key: key);

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  bool _visible = true; // Used only for password fields

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: greyColor,
        borderRadius: BorderRadius.circular(containerRoundCorner),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: TextField(
          enabled: widget.enable,
          keyboardType: widget.inputType ?? TextInputType.text,
          controller: widget.controller,
          obscureText: widget.isPassword ? _visible : false,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: widget.isBold == true ? descriptionTextStyle(fontWeight: FontWeight.bold,color: primaryColor) : descriptionTextStyle(),
            border: InputBorder.none,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _visible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _visible = !_visible;
                      });
                    },
                  )
                : (widget.suffix != null
                    ? GestureDetector(onTap: widget.onPressed, child: widget.suffix)
                    : null),
          ),
        ),
      ),
    );
  }
}

class TagInputField extends StatefulWidget {
  final Function(List<String>) onTagsChanged;

  const TagInputField({Key? key, required this.onTagsChanged}) : super(key: key);

  @override
  _TagInputFieldState createState() => _TagInputFieldState();
}

class _TagInputFieldState extends State<TagInputField> {
  final TextEditingController _tagController = TextEditingController();
  final List<String> _tags = [];

  void _addTag(String tag) {
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagController.clear();
      });
      widget.onTagsChanged(_tags);
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
    widget.onTagsChanged(_tags);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.0,
          children: _tags
              .map((tag) => Chip(
                    label: Text(tag),
                    deleteIcon: Icon(Icons.close, size: 18),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor: primaryLightColor,
                  ))
              .toList(),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: TextField(
            controller: _tagController,
            decoration: InputDecoration(
               hintStyle: descriptionTextStyle(),
              border: InputBorder.none,
              hintText: "Enter a tag...",
              suffix: IconButton(onPressed:() {
              if (_tagController.text.isNotEmpty) {
                _addTag(_tagController.text);
              }
            }, icon: Icon(IconlyLight.tickSquare,color: primaryColor,))
            ),
            onSubmitted: _addTag,
          ),
        ),
      ],
    );
  }
}

