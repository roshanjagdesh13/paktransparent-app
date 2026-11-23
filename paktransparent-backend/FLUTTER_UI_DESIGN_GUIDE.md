# Flutter UI Design Guide - Based on Reference Screens

## 📱 Overview

This guide provides detailed instructions for implementing the Flutter UI based on the 23 design reference screens provided in `design_reference/screens/`.

---

## 📁 Design Reference Screens (23 screens)

All reference designs are located in: `design_reference/screens/`

### Authentication Screens (4)
1. **splash_screen.png** - App launch screen
2. **onboarding_1_track_spending.png** - Onboarding page 1
3. **onboarding_2_project_progress.png** - Onboarding page 2
4. **onboarding_3_call_to_action.png** - Onboarding page 3
5. **login_screen.png** - Login page
6. **citizen_registration.png** - Citizen signup
7. **government_registration.png** - Government signup
8. **otp_verification.png** - OTP verification

### Citizen Screens (8)
9. **citizen_home_dashboard.png** - Main dashboard
10. **search_filter_projects.png** - Project search & filter
11. **project_details_screen.png** - Project details
12. **submit_report_feedback.png** - Submit complaints
13. **citizen_reports_management.png** - My reports
14. **budget_comparison_tool.png** - Budget comparison
15. **ai_budget_insights.png** - AI insights
16. **budget_analytics_dashboard.png** - Analytics
17. **qr_code_scanner.png** - QR scanner
18. **bilingual_interface_urdu.png** - Urdu language
19. **settings_profile.png** - Profile & settings

### Government Screens (4)
20. **government_management_dashboard.png** - Gov dashboard
21. **create_new_project.png** - Create project
22. **official_audit_trail.png** - Audit trail
23. **contractor_profile.png** - Contractor info

---

## 🎨 Design System

### Color Palette (Pakistan Theme)

```dart
// lib/core/theme/app_colors.dart
class AppColors {
  // Primary Colors (Pakistan Green & White)
  static const Color primary = Color(0xFF01411C);        // Pakistan Green
  static const Color primaryLight = Color(0xFF0B6623);   // Light Green
  static const Color primaryDark = Color(0xFF003D14);    // Dark Green
  
  // Secondary Colors
  static const Color secondary = Color(0xFFFFFFFF);      // White
  static const Color accent = Color(0xFFE8B923);         // Gold/Yellow
  
  // Surface Colors
  static const Color background = Color(0xFFF5F5F5);     // Light Gray
  static const Color surface = Color(0xFFFFFFFF);        // White
  static const Color surfaceVariant = Color(0xFFE8F5E9); // Light Green Tint
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);    // Almost Black
  static const Color textSecondary = Color(0xFF757575);  // Gray
  static const Color textHint = Color(0xFFBDBDBD);       // Light Gray
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);        // Green
  static const Color warning = Color(0xFFFF9800);        // Orange
  static const Color error = Color(0xFFF44336);          // Red
  static const Color info = Color(0xFF2196F3);           // Blue
  
  // Chart Colors
  static const Color chart1 = Color(0xFF4CAF50);
  static const Color chart2 = Color(0xFF2196F3);
  static const Color chart3 = Color(0xFFFF9800);
  static const Color chart4 = Color(0xFF9C27B0);
}
```

### Typography

```dart
// lib/core/theme/app_text_styles.dart
class AppTextStyles {
  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );
}
```

### Theme Configuration

```dart
// lib/core/theme/app_theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      background: AppColors.background,
      error: AppColors.error,
    ),
    
    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),
    
    // Card Theme
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
    
    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    ),
  );
}
```

---

## 📱 Screen Implementation Guide

### 1. Splash Screen
**Reference:** `splash_screen.png`

```dart
// lib/presentation/screens/splash/splash_screen.dart
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    // Check if first time user
    // Navigate to onboarding or home
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pakistan Flag or Logo
            Icon(
              Icons.account_balance,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const Text(
              'Pakistan Transparent',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Budget Transparency Portal',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Onboarding Screens
**Reference:** `onboarding_1_track_spending.png`, `onboarding_2_project_progress.png`, `onboarding_3_call_to_action.png`

```dart
// lib/presentation/screens/onboarding/onboarding_screen.dart
class OnboardingScreen extends StatefulWidget {
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Track Government Spending',
      description: 'Monitor how tax money is spent on public projects',
      icon: Icons.pie_chart,
      color: AppColors.primary,
    ),
    OnboardingPage(
      title: 'View Project Progress',
      description: 'Get real-time updates on development projects',
      icon: Icons.construction,
      color: AppColors.info,
    ),
    OnboardingPage(
      title: 'Report & Voice Concerns',
      description: 'Submit complaints and feedback directly to officials',
      icon: Icons.report,
      color: AppColors.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _goToLogin(),
                child: const Text('Skip'),
              ),
            ),
            
            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Page Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => _buildDot(index == _currentPage),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _pages.length - 1) {
                      _goToLogin();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            page.icon,
            size: 120,
            color: page.color,
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.textHint,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
```

### 3. Login Screen
**Reference:** `login_screen.png`

```dart
// lib/presentation/screens/auth/login_screen.dart
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Logo & Title
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance,
                        size: 80,
                        color: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Welcome Back',
                        style: AppTextStyles.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sign in to continue',
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    // Use validation from backend utils
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                ),
                
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: const Text('Forgot Password?'),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Login Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogin,
                    child: const Text('Login'),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Don\'t have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      // Use auth provider to login
      // Navigate to home based on user role
    }
  }
}
```

### 4. Citizen Home Dashboard
**Reference:** `citizen_home_dashboard.png`

```dart
// lib/presentation/screens/citizen/home_screen.dart
class CitizenHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pakistan Transparent'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.pushNamed(context, '/qr-scanner');
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _buildWelcomeCard(),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildQuickActions(context),
            
            const SizedBox(height: 24),
            
            // Featured Projects
            const Text(
              'Featured Projects',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildFeaturedProjects(),
            
            const SizedBox(height: 24),
            
            // Budget Overview
            const Text(
              'Budget Overview',
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 16),
            _buildBudgetOverview(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildWelcomeCard() {
    return Card(
      color: AppColors.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Welcome, Ahmad!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track government projects and spending',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.account_circle,
              size: 60,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildActionCard(
          icon: Icons.search,
          title: 'Browse Projects',
          color: AppColors.primary,
          onTap: () => Navigator.pushNamed(context, '/projects'),
        ),
        _buildActionCard(
          icon: Icons.report,
          title: 'Submit Report',
          color: AppColors.warning,
          onTap: () => Navigator.pushNamed(context, '/submit-report'),
        ),
        _buildActionCard(
          icon: Icons.analytics,
          title: 'Analytics',
          color: AppColors.info,
          onTap: () => Navigator.pushNamed(context, '/analytics'),
        ),
        _buildActionCard(
          icon: Icons.lightbulb,
          title: 'AI Insights',
          color: AppColors.accent,
          onTap: () => Navigator.pushNamed(context, '/ai-insights'),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.labelLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ... more widgets
}
```

---

## 📋 Complete Screen Checklist

### Authentication Flow
- [ ] Splash Screen
- [ ] Onboarding (3 pages)
- [ ] Login Screen
- [ ] Citizen Registration
- [ ] Government Registration
- [ ] OTP Verification
- [ ] Forgot Password (design missing - create based on login)

### Citizen App
- [ ] Home Dashboard
- [ ] Browse Projects (Search & Filter)
- [ ] Project Details
- [ ] Submit Report/Feedback
- [ ] My Reports Management
- [ ] Budget Comparison Tool
- [ ] AI Budget Insights
- [ ] Budget Analytics Dashboard
- [ ] QR Code Scanner
- [ ] Settings & Profile
- [ ] Language Switcher (Urdu)

### Government App
- [ ] Government Dashboard
- [ ] Create New Project
- [ ] Project Management (upload images/docs)
- [ ] Audit Trail
- [ ] Review Citizen Reports
- [ ] Approve Projects
- [ ] Contractor Profile

---

## 🎨 UI Components Library

Create reusable widgets based on designs:

### Cards
```dart
// lib/presentation/widgets/project_card.dart
class ProjectCard extends StatelessWidget {
  final Project project;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          // Project image
          // Project name
          // Budget info
          // Progress bar
          // Status badge
        ],
      ),
    );
  }
}
```

### Bottom Navigation
```dart
// lib/presentation/widgets/citizen_bottom_nav.dart
class CitizenBottomNav extends StatelessWidget {
  final int currentIndex;
  
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Projects',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.report),
          label: 'Reports',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
```

---

## 📱 Responsive Design

```dart
// lib/core/utils/responsive.dart
class Responsive {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
      
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;
      
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;
      
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;
}
```

---

## 🌐 Bilingual Support (English/Urdu)

**Reference:** `bilingual_interface_urdu.png`

```dart
// lib/l10n/app_localizations.dart
class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  String get appName => locale.languageCode == 'ur' 
      ? 'پاکستان شفاف' 
      : 'Pakistan Transparent';
      
  String get welcome => locale.languageCode == 'ur'
      ? 'خوش آمدید'
      : 'Welcome';
      
  // Add all translations
}
```

---

## 🚀 Next Steps

1. **Create Flutter project**
2. **Set up theme and colors** from this guide
3. **Build screens one by one** following the reference images
4. **Use backend logic** for data management
5. **Test on Android and iOS**

---

**All design references available in:** `design_reference/screens/`

**Start with:** Splash → Onboarding → Login → Home Dashboard
