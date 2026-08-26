import 'package:club_fitness/config/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:club_fitness/core/constants/constants.dart';

class FilledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int minLines;
  final EdgeInsetsGeometry? padding;
  final int maxLines;
  final bool showErrorBorder;
  final String? labelText;
  final TextStyle? textStyle;
  final VoidCallback? onTap;
  final bool readOnly;
  final double curveRadius;
  final TextStyle? hintStyle;
  final TextStyle? errorStyle;
  final TextStyle? labelStyle;
  final BorderSide borderSide;
  final BorderSide focusedBorderSide;
  final Color labelColor;
  final Color? fillColor;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? textInputType;
  final TextCapitalization? textCapitalization;
  final FormFieldValidator<String?>? validator;
  final void Function(String value)? onChanged;
  final void Function(String value)? onSubmitted;
  final bool hideText;
  final bool autofocus;
  final TextInputAction? textInputAction;
  final bool? isDense;
  final EdgeInsetsGeometry? contentPadding;

  const FilledTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.readOnly = false,
    this.padding,
    this.minLines = 1,
    this.maxLines = 5,
    this.curveRadius = 8,
    this.borderSide = BorderSide.none,
    this.focusedBorderSide = BorderSide.none,
    this.focusNode,
    this.fillColor,
    this.inputFormatters,
    this.onTap,
    this.hintStyle,
    this.textStyle,
    this.labelColor = AppTheme.primary,
    this.errorStyle,
    this.prefixIcon,
    this.textInputType,
    this.suffixIcon,
    this.hideText = false,
    this.showErrorBorder = true,
    this.labelText,
    this.textCapitalization,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.onSubmitted,
    this.autofocus = false,
    this.isDense,
    this.contentPadding,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? 18.all,
      child: TextFormField(
        maxLines: hideText ? 1 : maxLines,
        minLines: minLines,
        autofocus: autofocus,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmitted,
        onTap: onTap,
        readOnly: readOnly,
        focusNode: focusNode,
        controller: controller,
        validator: validator,
        cursorColor: AppTheme.primary,
        obscureText: hideText,
        keyboardType: textInputType,
        style: textStyle,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          isDense: isDense,
          contentPadding: contentPadding,
          errorStyle: errorStyle,
          fillColor: fillColor,
          filled: true,
          labelStyle: (labelStyle ?? FontConstant.oxygen).copyWith(
            color: labelColor,
          ),
          hintStyle: hintStyle,
          suffixIcon: suffixIcon,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(curveRadius),
            borderSide: borderSide,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(curveRadius),
            borderSide: borderSide,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(curveRadius),
            borderSide: focusedBorderSide,
          ),
          errorBorder: !showErrorBorder
              ? null
              : OutlineInputBorder(
                  borderRadius: BorderRadius.circular(curveRadius),
                  borderSide: const BorderSide(color: Colors.red),
                ),
        ),
      ),
    );
  }
}
