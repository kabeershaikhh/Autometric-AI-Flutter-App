import 'package:flutter/material.dart';

class MySocialButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback? onPressed;

  const MySocialButton({
    super.key,
    required this.imagePath,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: const Color(0xFFECECEC),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      onPressed: onPressed,
      icon: Image.asset(
        imagePath,
        width: 22,
        height: 22,
      ),
      label: Text(label),
    );
  }
}