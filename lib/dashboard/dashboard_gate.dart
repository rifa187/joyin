import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dashboard_page.dart';
import 'dashboard_pre_purchase.dart';
import '../providers/package_provider.dart';
import '../providers/auth_provider.dart';

/// Entry point that decides which dashboard experience to show.
class DashboardGate extends StatelessWidget {
  const DashboardGate({super.key});

  @override
  Widget build(BuildContext context) {
    final packageProvider = context.watch<PackageProvider>();
    final user = context.watch<AuthProvider>().user;

    final bool hasPackage =
        (packageProvider.currentUserPackage?.isNotEmpty ?? false) ||
            (user?.hasPurchasedPackage ?? false);

    if (!hasPackage) {
      return const DashboardPrePurchasePage();
    }

    return const DashboardPage();
  }
}
