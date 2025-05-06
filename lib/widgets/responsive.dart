import 'package:flutter/material.dart';

class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const Responsive({
    Key? key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  }) : super(key: key);

  // Screen sizes
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 650;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    
    // If width is more than 1100, we consider it as desktop
    if (_size.width >= 1100) {
      return desktop;
    }
    // If width is less than 1100 and more than 650, we consider it as tablet
    else if (_size.width >= 650) {
      return tablet ?? mobile;
    }
    // Or less than 650, we consider it as mobile
    else {
      return mobile;
    }
  }
}