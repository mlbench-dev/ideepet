import 'package:flutter/material.dart';
import 'package:idee_pet/app/core/core_old/colors.dart';

class CustomButton extends StatelessWidget {
  final Widget title;
  final VoidCallback? action;
  final Color backgroundColor;
  final double elevation;
  final BorderSide? border;

  const CustomButton._({
    required this.title,
    required this.action,
    required this.backgroundColor,
    this.elevation = 8,
    this.border,
  });

  factory CustomButton.filled({
    required Widget title,
    required VoidCallback? action,
  }) {
    return CustomButton._(
      title: title,
      action: action,
      backgroundColor: AppColors.primary,
      elevation: 8,
    );
  }

  factory CustomButton.transparent({
    required Widget title,
    required VoidCallback? action,
  }) {
    return CustomButton._(
      title: title,
      action: action,
      backgroundColor: Colors.transparent,
      elevation: 0,
      border: BorderSide(color: AppColors.primary, width: 2),
    );
  }

  factory CustomButton.outlined({
    required Widget title,
    required VoidCallback? action,
  }) {
    return CustomButton._(
      title: title,
      action: action,
      backgroundColor: Colors.white,
      elevation: 0,
      border: BorderSide(color: AppColors.primary, width: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: action,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: AppColors.grey,
        backgroundColor: backgroundColor,
        elevation: elevation,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: border ?? BorderSide.none,
        ),
        shadowColor: AppColors.primary.withAlpha(80),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Flexible(child: title)],
      ),
    );
  }
}

class CustomButtonSelect extends StatelessWidget {
  final Widget title;
  final bool select;
  final VoidCallback? action;
  final EdgeInsetsGeometry? padding;

  const CustomButtonSelect({
    super.key,
    required this.title,
    this.select = false,
    required this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: padding ?? EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: select ? AppColors.selectColorButton : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: select
              ? null
              : Border.all(color: AppColors.selectColorButton, width: 2),
          boxShadow: select
              ? [
                  BoxShadow(
                    color: AppColors.selectColorButton.withAlpha(80),
                    blurRadius: 8,
                    spreadRadius: 2,
                    offset: Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Center(
          child: title,
        ),
      ),
    );
  }
}
