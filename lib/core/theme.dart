import 'package:flutter/material.dart';

/// Colour palette sampled from the reference mock-ups.
class AppColors {
  AppColors._();

  static const outline = Color(0xFF14246B); // dark navy text outline
  static const navy = Color(0xFF0E3A8C);
  static const panel = Color(0xE60B3A8A); // Best / Score + coin pill
  static const ink = Color(0xFF152B5E); // dark body text on light cards
  static const brownOutline = Color(0xFF8A3F00); // outline on yellow buttons
  static const gold = Color(0xFFFFC21A);
}

/// Scales UI sizes relative to a 390 dp wide phone.
double uiScale(BuildContext context) =>
    (MediaQuery.sizeOf(context).width / 390).clamp(0.8, 1.35).toDouble();

/// Space at the bottom of menu screens that is occupied by the ground strip.
double groundSpace(BuildContext context) =>
    (MediaQuery.sizeOf(context).height * 0.11).clamp(80.0, 130.0).toDouble();

Route<T> fadeRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondary) => page,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (context, animation, secondary, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
