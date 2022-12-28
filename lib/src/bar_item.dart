import 'package:flutter/material.dart';

class BarItem {
  final Widget icon;
  final String? title;
  final bool isCenter;

  const BarItem({
    required this.icon,
    this.title,
    this.isCenter = false,
  });
}
