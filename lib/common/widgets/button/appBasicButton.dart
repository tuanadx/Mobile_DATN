import 'package:flutter/material.dart';
import 'package:savefood/core/configs/theme/app_color.dart';


class AppBasicButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final double? height;
  final double? borderRadius;

  const AppBasicButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.height,
    this.borderRadius,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(height ?? 80),
        foregroundColor: Colors.white,
        backgroundColor: AppColor.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
        ),
      ),
      child: Text(title),
    );
  }
}
