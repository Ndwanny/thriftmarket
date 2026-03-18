import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextCapitalization textCapitalization;
  final bool enabled;
  final void Function(String)? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? maxLength;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.onFieldSubmitted,
    this.textInputAction,
    this.maxLines = 1,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.grey700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          enabled: enabled,
          onFieldSubmitted: onFieldSubmitted,
          textInputAction: textInputAction,
          maxLines: maxLines,
          maxLength: maxLength,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 20, color: AppColors.grey500)
                : null,
            suffixIcon: suffixIcon,
            counterText: '',
          ),
          validator: validator,
        ),
      ],
    );
  }
}
