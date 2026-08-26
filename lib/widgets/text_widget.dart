import 'package:flutter/material.dart';
import 'package:club_fitness/core/utils/utils.dart';

import '../../core/constants/constants.dart';

class TextWidget extends StatelessWidget {
  final dynamic text;
  final TextStyle? style;
  final bool bold;
  final bool extraBold;
  final Color? color;
  final Color? decorationColor;
  final int? maxLines;
  final double? fontSize;
  final TextAlign textAlign;
  final TextDecoration? decoration;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;
  final double? height;
  final Alignment? boxAlignment;

  const TextWidget(
    this.text, {
    super.key,
    this.style,
    this.bold = false,
    this.extraBold = false,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.color,
    this.fontSize,
    this.decoration,
    this.decorationColor,
    this.overflow = TextOverflow.ellipsis,
    this.fontWeight,
    this.padding,
    this.height,
    this.boxAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? 0.w.all,
      alignment: boxAlignment,
      child: Text(
        text?.toString() ?? '',
        style: (style ?? FontConstant.oxygen).copyWith(
          color: color,
          height: height,
          fontWeight: extraBold
              ? FontWeight.w900
              : bold
              ? FontWeight.bold
              : fontWeight,
          fontSize: fontSize,
          decorationColor: decorationColor,
          decoration: decoration,
        ),
        maxLines: maxLines,
        overflow: maxLines == null ? null : overflow,
        textAlign: textAlign,
      ),
    );
  }

  static Widget xxl(
    String text, {
    bool bold = false,
    bool extraBold = false,
    Color? color,
    Color? decorationColor,
    TextAlign textAlign = TextAlign.start,
    int? maxLines,
    TextDecoration? decoration,
    TextOverflow overflow = TextOverflow.ellipsis,
    EdgeInsetsGeometry? padding,
    Alignment? boxAlignment,
    double? height,
  }) => TextWidget(
    text,
    style: FontConstant.oxygenXXL,
    bold: bold,
    extraBold: extraBold,
    color: color,
    decorationColor: decorationColor,
    textAlign: textAlign,
    maxLines: maxLines,
    decoration: decoration,
    overflow: overflow,
    padding: padding,
    boxAlignment: boxAlignment,
    height: height,
  );

  static Widget xl(
    String text, {
    bool bold = false,
    bool extraBold = false,
    Color? color,
    Color? decorationColor,
    TextAlign textAlign = TextAlign.start,
    int? maxLines,
    TextDecoration? decoration,
    TextOverflow overflow = TextOverflow.ellipsis,
    EdgeInsetsGeometry? padding,
    Alignment? boxAlignment,
    double? height,
  }) => TextWidget(
    text,
    style: FontConstant.oxygenXL,
    bold: bold,
    extraBold: extraBold,
    color: color,
    decorationColor: decorationColor,
    textAlign: textAlign,
    maxLines: maxLines,
    decoration: decoration,
    overflow: overflow,
    padding: padding,
    boxAlignment: boxAlignment,
    height: height,
  );

  static Widget l(
    String text, {
    bool bold = false,
    bool extraBold = false,
    Color? color,
    Color? decorationColor,
    TextAlign textAlign = TextAlign.start,
    int? maxLines,
    TextDecoration? decoration,
    TextOverflow overflow = TextOverflow.ellipsis,
    EdgeInsetsGeometry? padding,
    Alignment? boxAlignment,
    double? height,
  }) => TextWidget(
    text,
    style: FontConstant.oxygenLarge,
    bold: bold,
    extraBold: extraBold,
    color: color,
    decorationColor: decorationColor,
    textAlign: textAlign,
    maxLines: maxLines,
    decoration: decoration,
    overflow: overflow,
    padding: padding,
    boxAlignment: boxAlignment,
    height: height,
  );

  static Widget m(
    String text, {
    bool bold = false,
    bool extraBold = false,
    Color? color,
    Color? decorationColor,
    TextAlign textAlign = TextAlign.start,
    int? maxLines,
    TextDecoration? decoration,
    TextOverflow overflow = TextOverflow.ellipsis,
    EdgeInsetsGeometry? padding,
    Alignment? boxAlignment,
    double? height,
  }) => TextWidget(
    text,
    style: FontConstant.oxygenMedium,
    bold: bold,
    extraBold: extraBold,
    color: color,
    decorationColor: decorationColor,
    textAlign: textAlign,
    maxLines: maxLines,
    decoration: decoration,
    overflow: overflow,
    padding: padding,
    boxAlignment: boxAlignment,
    height: height,
  );

  static Widget s(
    String text, {
    bool bold = false,
    bool extraBold = false,
    Color? color,
    Color? decorationColor,
    TextAlign textAlign = TextAlign.start,
    int? maxLines,
    TextDecoration? decoration,
    TextOverflow overflow = TextOverflow.ellipsis,
    EdgeInsetsGeometry? padding,
    Alignment? boxAlignment,
    double? height,
  }) => TextWidget(
    text,
    style: FontConstant.oxygenSmall,
    bold: bold,
    extraBold: extraBold,
    color: color,
    decorationColor: decorationColor,
    textAlign: textAlign,
    maxLines: maxLines,
    decoration: decoration,
    overflow: overflow,
    padding: padding,
    boxAlignment: boxAlignment,
    height: height,
  );

  TextWidget copyWith({
    String? text,
    TextStyle? style,
    bool? bold,
    bool? extraBold,
    Color? color,
    Color? decorationColor,
    int? maxLines,
    double? fontSize,
    TextAlign? textAlign,
    TextDecoration? decoration,
    TextOverflow? overflow,
    FontWeight? fontWeight,
    EdgeInsetsGeometry? padding,
  }) => TextWidget(
    text ?? this.text,
    style: style ?? this.style,
    bold: bold ?? this.bold,
    extraBold: extraBold ?? this.extraBold,
    color: color ?? this.color,
    decorationColor: decorationColor ?? this.decorationColor,
    maxLines: maxLines ?? this.maxLines,
    fontSize: fontSize ?? this.fontSize,
    textAlign: textAlign ?? this.textAlign,
    decoration: decoration ?? this.decoration,
    overflow: overflow ?? this.overflow,
    fontWeight: fontWeight ?? this.fontWeight,
    padding: padding ?? this.padding,
  );
}

class AnimatedTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final bool bold;
  final bool extraBold;
  final Color? color;
  final Color? decorationColor;
  final int? maxLines;
  final double? fontSize;
  final TextAlign textAlign;
  final TextDecoration? decoration;
  final TextOverflow? overflow;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry? padding;

  const AnimatedTextWidget(
    this.text, {
    super.key,
    this.style,
    this.bold = false,
    this.extraBold = false,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.color,
    this.fontSize,
    this.decoration,
    this.decorationColor,
    this.overflow = TextOverflow.ellipsis,
    this.fontWeight,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? 0.w.all,
      child: AnimatedDefaultTextStyle(
        style: (style ?? FontConstant.oxygen).copyWith(
          color: color,
          fontWeight: extraBold
              ? FontWeight.w900
              : bold
              ? FontWeight.bold
              : fontWeight,
          fontSize: fontSize,
          decorationColor: decorationColor,
          decoration: decoration,
        ),
        duration: 400.milliseconds,
        curve: Curves.easeInOut,
        maxLines: maxLines,
        textAlign: textAlign,
        child: Text(text, overflow: maxLines == null ? null : overflow),
      ),
    );
  }
}

extension FontExtension on TextWidget {
  TextWidget get small => copyWith(style: FontConstant.oxygenSmall);

  TextWidget get smallBold => copyWith(style: FontConstant.oxygenSmallBold);

  TextWidget get medium => copyWith(style: FontConstant.oxygenMedium);

  TextWidget get mediumBold => copyWith(style: FontConstant.oxygenMediumBold);

  TextWidget get large => copyWith(style: FontConstant.oxygenLarge);

  TextWidget get largeBold => copyWith(style: FontConstant.oxygenLargeBold);

  TextWidget get xl => copyWith(style: FontConstant.oxygenXL);

  TextWidget get xlb => copyWith(style: FontConstant.oxygenXLBold);

  TextWidget get xxl => copyWith(style: FontConstant.oxygenXXL);

  TextWidget get xxlb => copyWith(style: FontConstant.oxygenXXLBold);
}

extension TextWidgetConversion on Text {
  TextWidget get toTextWidget => TextWidget(
    data ?? '',
    bold: style?.fontWeight == FontWeight.bold,
    color: style?.color,
    decoration: style?.decoration,
    style: style,
    decorationColor: style?.decorationColor,
    extraBold: style?.fontWeight == FontWeight.w900,
    fontSize: style?.fontSize,
    textAlign: textAlign ?? TextAlign.start,
    fontWeight: style?.fontWeight,
    maxLines: maxLines,
    overflow: overflow,
  );
}
