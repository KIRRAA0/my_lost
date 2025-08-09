import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class InterTextStyle {
  static Widget getTextWidget({
    required String text,
    double size = 16,
    double opacity = 1.0,
    Color color = const Color(0xFF2E3E5C),
    FontWeight fontWeight = FontWeight.w400,
    double height = 1.5, // Use a reasonable default line height
    double letterSpacing = 0.16,
    TextAlign textAlign = TextAlign.center,
    bool softWrap = true,
    TextOverflow overflow = TextOverflow.visible,
  }) {
    return Opacity(
      opacity: opacity,
      child: Text(
        text,
        textAlign: textAlign,
        softWrap: softWrap,
        overflow: overflow,
        style: GoogleFonts.inter(
          textStyle: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: fontWeight,
            height: height,
            letterSpacing: letterSpacing,
          ),
        ),
      ),
    );
  }
}
