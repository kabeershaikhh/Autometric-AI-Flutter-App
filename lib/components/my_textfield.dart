import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final InputDecoration? decoration;
  final FormFieldValidator<String>? validator;
  final int? maxLength;
  final int? minLines;
  final int maxLines;
  final bool useFormField;

  const MyTextField({
    super.key,
    this.controller,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.onChanged,
    this.decoration,
    this.validator,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.useFormField = false,
  });

  @override
  State<MyTextField> createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool obscurePassword;

  @override
  void initState() {
    super.initState();
    obscurePassword = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.useFormField) {
      return TextFormField(
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        validator: widget.validator,
        maxLength: widget.maxLength,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        obscureText: obscurePassword,
        decoration:
            widget.decoration ??
            InputDecoration(
              hintText: widget.hint,
              prefixIcon: Icon(widget.icon),
            ),
      );
    }
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      obscureText: obscurePassword,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(widget.icon),

        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
                icon: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,

        filled: true,
        fillColor: const Color(0xFFF7F2FA),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF7C4DFF), width: 2),
        ),
      ),
    );
  }
}
