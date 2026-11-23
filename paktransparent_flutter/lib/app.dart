import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/ui_provider.dart';

/// Root application widget.
/// Sets up theme, locale, and navigation.
class PakTransparentApp extends StatelessWidget {
  const PakTransparentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<UiProvider, AuthProvider>(
      builder: (context, uiProvider, authProvider, _) {
        return MaterialApp(
          title: 'PakTransparent',
          debugShowCheckedModeBanner: false,

          // Theming
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: uiProvider.themeMode,

          // Localization
          locale: uiProvider.locale,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('ur', 'PK'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Navigation
          onGenerateRoute: AppRouter.onGenerateRoute,
          initialRoute: AppRouter.splash,

          // Performance: disable banner in release
          builder: (context, child) {
            return MediaQuery(
              // Prevent text scaling beyond 1.3x (accessibility vs layout integrity)
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(
                  MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.3),
                ),
              ),
              child: child!,
            );
          },
        );
      },
    );
  }
}
