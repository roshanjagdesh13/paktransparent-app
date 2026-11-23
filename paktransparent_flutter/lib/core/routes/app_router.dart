import 'package:flutter/material.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/citizen_register_screen.dart';
import '../../presentation/screens/auth/government_register_screen.dart';
import '../../presentation/screens/auth/otp_screen.dart';
import '../../presentation/screens/citizen/home_screen.dart';
import '../../presentation/screens/citizen/projects_screen.dart';
import '../../presentation/screens/citizen/project_detail_screen.dart';
import '../../presentation/screens/citizen/submit_report_screen.dart';
import '../../presentation/screens/citizen/my_reports_screen.dart';
import '../../presentation/screens/citizen/analytics_screen.dart';
import '../../presentation/screens/citizen/budget_comparison_screen.dart';
import '../../presentation/screens/citizen/ai_insights_screen.dart';
import '../../presentation/screens/citizen/qr_scanner_screen.dart';
import '../../presentation/screens/citizen/profile_screen.dart';
import '../../presentation/screens/government/gov_dashboard_screen.dart';
import '../../presentation/screens/government/create_project_screen.dart';
import '../../presentation/screens/government/audit_trail_screen.dart';
import '../../presentation/screens/government/contractor_profile_screen.dart';
import '../../presentation/screens/government/citizen_reports_screen.dart';

/// Central route definitions for the app.
/// All navigation is done via named routes for maintainability.
class AppRouter {
  AppRouter._();

  // Route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String citizenRegister = '/register/citizen';
  static const String governmentRegister = '/register/government';
  static const String otp = '/otp';

  // Citizen routes
  static const String citizenHome = '/citizen/home';
  static const String projects = '/citizen/projects';
  static const String projectDetail = '/citizen/project';
  static const String submitReport = '/citizen/submit-report';
  static const String myReports = '/citizen/my-reports';
  static const String analytics = '/citizen/analytics';
  static const String budgetComparison = '/citizen/budget-comparison';
  static const String aiInsights = '/citizen/ai-insights';
  static const String qrScanner = '/citizen/qr-scanner';
  static const String profile = '/citizen/profile';

  // Government routes
  static const String govDashboard = '/gov/dashboard';
  static const String createProject = '/gov/create-project';
  static const String auditTrail = '/gov/audit';
  static const String contractorProfile = '/gov/contractor';
  static const String citizenReports = '/gov/citizen-reports';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fade(const SplashScreen());
      case onboarding:
        return _slide(const OnboardingScreen());
      case login:
        return _slide(const LoginScreen());
      case citizenRegister:
        return _slide(const CitizenRegisterScreen());
      case governmentRegister:
        return _slide(const GovernmentRegisterScreen());
      case otp:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slide(OtpScreen(email: args?['email'] ?? ''));
      case citizenHome:
        return _fade(const CitizenHomeScreen());
      case projects:
        return _slide(const ProjectsScreen());
      case projectDetail:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slide(ProjectDetailScreen(projectId: args?['projectId'] ?? ''));
      case submitReport:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slide(SubmitReportScreen(projectId: args?['projectId']));
      case myReports:
        return _slide(const MyReportsScreen());
      case analytics:
        return _slide(const AnalyticsScreen());
      case budgetComparison:
        return _slide(const BudgetComparisonScreen());
      case aiInsights:
        return _slide(const AiInsightsScreen());
      case qrScanner:
        return _slide(const QrScannerScreen());
      case profile:
        return _slide(const ProfileScreen());
      case govDashboard:
        return _fade(const GovDashboardScreen());
      case createProject:
        return _slide(const CreateProjectScreen());
      case auditTrail:
        return _slide(const AuditTrailScreen());
      case contractorProfile:
        final args = settings.arguments as Map<String, dynamic>?;
        return _slide(ContractorProfileScreen(contractorId: args?['contractorId'] ?? ''));
      case citizenReports:
        return _slide(const GovCitizenReportsScreen());
      default:
        return _fade(const _NotFoundScreen());
    }
  }

  // Custom transitions
  static PageRoute _fade(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 250),
      );

  static PageRoute _slide(Widget page) => PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 250),
      );
}

class _NotFoundScreen extends StatelessWidget {
  const _NotFoundScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64),
            const SizedBox(height: 16),
            const Text('Page not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}
