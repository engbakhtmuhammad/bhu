import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters; // ✅ Added inputFormatters

  const InputField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.enable = true,
    this.inputType,
    this.onPressed,
    this.suffix,
    this.isBold = false,
    this.controller,
    this.onChanged,
    this.validator,
    this.inputFormatters,
    String? errorText, // ✅ Added inputFormatters to constructor
  });

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
        child: TextFormField(
          enabled: widget.enable,
          keyboardType: widget.inputType ?? TextInputType.text,
          controller: widget.controller,
          obscureText: widget.isPassword ? _visible : false,
          onChanged: widget.onChanged,
          validator: widget.validator,
          inputFormatters: widget.inputFormatters, // ✅ Applied here
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: widget.isBold == true
                ? descriptionTextStyle(fontWeight: FontWeight.bold, color: primaryColor)
                : descriptionTextStyle(),
            border: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
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
