import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/constants/app_constants.dart';
import 'data/providers/auth_provider.dart';
import 'data/providers/project_provider.dart';
import 'data/providers/report_provider.dart';
import 'data/providers/ui_provider.dart';
import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/project_service.dart';
import 'data/services/report_service.dart';
import 'data/services/security_service.dart';

void main() async {
  // Ensure Flutter is initialized before doing anything async
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait orientation only (common for government apps)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize dependencies
  final sharedPrefs = await SharedPreferences.getInstance();
  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Initialize services (singletons)
  final securityService = SecurityService(secureStorage: secureStorage);
  final apiService = ApiService(secureStorage: secureStorage);
  final authService = AuthService(apiService: apiService, securityService: securityService);
  final projectService = ProjectService(apiService: apiService);
  final reportService = ReportService(apiService: apiService);

  runApp(
    MultiProvider(
      providers: [
        // UI state (theme, language)
        ChangeNotifierProvider(
          create: (_) => UiProvider(prefs: sharedPrefs),
        ),
        // Auth state — load persisted session on start
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            securityService: securityService,
            secureStorage: secureStorage,
          )..initialize(),
        ),
        // Project state
        ChangeNotifierProvider(
          create: (_) => ProjectProvider(projectService: projectService),
        ),
        // Report state
        ChangeNotifierProvider(
          create: (_) => ReportProvider(reportService: reportService),
        ),
      ],
      child: const PakTransparentApp(),
    ),
  );
}
