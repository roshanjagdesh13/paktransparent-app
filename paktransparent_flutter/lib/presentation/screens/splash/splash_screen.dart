import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/ui_provider.dart';
import '../../../core/routes/app_router.dart';

/// Splash screen — displays app logo and handles initial routing logic.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final authProvider = context.read<AuthProvider>();
    final uiProvider = context.read<UiProvider>();

    // Simulate splash delay for branding
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check onboarding
    final hasOnboarded = await uiProvider.hasCompletedOnboarding();
    if (!hasOnboarded) {
      Navigator.pushReplacementNamed(context, AppRouter.onboarding);
      return;
    }

    // Check authentication
    if (authProvider.isAuthenticated) {
      if (authProvider.isGovernment) {
        Navigator.pushReplacementNamed(context, AppRouter.govDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRouter.citizenHome);
      }
    } else {
      Navigator.pushReplacementNamed(context, AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance,
              size: 100,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            const SizedBox(height: 24),
            Text(
              'PakTransparent',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pakistan Budget Transparency',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
