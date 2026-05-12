import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class YeekItalicText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const YeekItalicText(
    this.text, {
    super.key,
    this.fontSize,
    this.color,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      style: TextStyle(
        fontFamily: 'YeekItalic',
        fontSize: fontSize ?? 12.sp,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color ?? Colors.white,
        height: 1, // clean spacing
        letterSpacing: 0.2, // premium feel
      ),
    );
  }
}
