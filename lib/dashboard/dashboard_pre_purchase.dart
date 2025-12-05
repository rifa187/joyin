import 'package:flutter/material.dart';
import 'package:joyin/dashboard/dashboard_page.dart';

/// Pre-purchase dashboard now mirrors the post-purchase layout.
/// We keep it as a separate widget so styling/content differences can be added later,
/// but for now it simply reuses DashboardPage so the experience matches before the split.
class DashboardPrePurchasePage extends StatelessWidget {
  const DashboardPrePurchasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardPage();
  }
}
