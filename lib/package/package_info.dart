import 'package:flutter/material.dart';

class PackageInfo {
  final String name;
  final String price;
  final List<String> features;
  final LinearGradient gradient;
  final int durationMonths;

  const PackageInfo({
    required this.name,
    required this.price,
    required this.features,
    required this.gradient,
    this.durationMonths = 1,
  });
}
