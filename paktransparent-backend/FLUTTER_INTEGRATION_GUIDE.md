# Flutter Integration Guide

## 🎯 Overview

This guide explains how to integrate the backend business logic into your Flutter mobile application.

## 📁 Recommended Flutter Project Structure

```
paktransparent_flutter/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart       # From api/constants/
│   │   ├── config/
│   │   │   └── app_config.dart          # From api/config/
│   │   ├── utils/
│   │   │   ├── validators.dart          # From api/utils/validation.ts
│   │   │   ├── formatters.dart          # From api/utils/format.ts
│   │   │   ├── security_utils.dart      # From api/utils/security.ts
│   │   │   └── logger.dart              # From api/utils/logger.ts
│   │   └── theme/
│   │       └── app_theme.dart
│   ├── data/
│   │   ├── models/
│   │   │   ├── user.dart                # From api/types/index.ts
│   │   │   ├── project.dart             # From api/types/index.ts
│   │   │   ├── report.dart              # From api/types/index.ts
│   │   │   ├── government.dart          # From api/types/government.ts
│   │   │   └── workflow.dart            # From api/types/workflow.ts
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart
│   │   │   ├── project_repository.dart
│   │   │   └── report_repository.dart
│   │   ├── services/
│   │   │   ├── api_service.dart         # From api/services/api.ts
│   │   │   ├── auth_service.dart        # From api/services/authService.ts
│   │   │   ├── security_service.dart    # From api/services/securityService.ts
│   │   │   ├── file_service.dart        # From api/services/fileUploadService.ts
│   │   │   ├── project_service.dart     # From api/services/projectService.ts
│   │   │   └── report_service.dart      # From api/services/reportService.ts
│   │   └── data_sources/
│   │       ├── local/
│   │       │   └── local_storage.dart
│   │       └── remote/
│   │           └── api_client.dart
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   ├── presentation/
│   │   ├── providers/                   # State Management
│   │   │   ├── auth_provider.dart       # From state/authStore.ts
│   │   │   ├── project_provider.dart    # From state/projectStore.ts
│   │   │   └── report_provider.dart     # From state/reportStore.ts
│   │   ├── screens/
│   │   │   ├── auth/
│   │   │   ├── citizen/
│   │   │   └── government/
│   │   ├── widgets/
│   │   └── routes/
│   └── l10n/
│       └── app_localizations.dart
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── test/
├── pubspec.yaml
└── README.md
```

## 📦 Required Flutter Packages

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  provider: ^6.1.1              # or riverpod, bloc, getx
  
  # Networking
  http: ^1.1.0                  # or dio
  
  # Local Storage
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
  
  # Serialization
  json_annotation: ^4.8.1
  
  # Validation
  formz: ^0.6.1                 # or form_field_validator
  
  # File Handling
  image_picker: ^1.0.5
  file_picker: ^6.1.1
  path_provider: ^2.1.1
  
  # Security
  crypto: ^3.0.3
  encrypt: ^5.0.3
  
  # Date/Time
  intl: ^0.18.1
  
  # QR Code
  qr_code_scanner: ^1.0.1
  qr_flutter: ^4.1.0
  
  # Maps
  google_maps_flutter: ^2.5.0
  
  # Charts
  fl_chart: ^0.65.0
  
  # UI Components
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.6
  json_serializable: ^6.7.1
  flutter_lints: ^3.0.0
```

## 🔄 Conversion Steps

### Step 1: Convert Type Definitions

**TypeScript (`api/types/index.ts`):**
```typescript
interface User {
  id: string;
  email: string;
  name: string;
  role: 'citizen' | 'government';
}
```

**Dart (`lib/data/models/user.dart`):**
```dart
class User {
  final String id;
  final String email;
  final String name;
  final UserRole role;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role.toString(),
    };
  }
}

enum UserRole {
  citizen,
  government;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.citizen,
    );
  }
}
```

### Step 2: Convert Services

**TypeScript (`api/services/authService.ts`):**
```typescript
export const login = async (email: string, password: string) => {
  // API call
  const response = await api.post('/auth/login', { email, password });
  return response.data;
};
```

**Dart (`lib/data/services/auth_service.dart`):**
```dart
class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<User> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return User.fromJson(response.data);
    } catch (e) {
      throw AuthException('Login failed: $e');
    }
  }
}
```

### Step 3: Convert State Management

**TypeScript (Zustand `state/authStore.ts`):**
```typescript
export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isAuthenticated: false,
  login: async (email, password) => {
    const user = await authService.login(email, password);
    set({ user, isAuthenticated: true });
  },
}));
```

**Dart (Provider `lib/presentation/providers/auth_provider.dart`):**
```dart
class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  User? get user => _user;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  final AuthService _authService;

  AuthProvider(this._authService);

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.login(email, password);
      _isAuthenticated = true;
    } catch (e) {
      _isAuthenticated = false;
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
```

### Step 4: Convert Utilities

**TypeScript (`api/utils/validation.ts`):**
```typescript
export const isValidEmail = (email: string): boolean => {
  const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return regex.test(email);
};
```

**Dart (`lib/core/utils/validators.dart`):**
```dart
class Validators {
  static bool isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Invalid email format';
    }
    return null;
  }
}
```

### Step 5: Implement Security Features

**Password Hashing:**
```dart
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SecurityService {
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  static String generateSalt() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(values);
  }
}
```

**Secure Storage:**
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

## 🔐 Security Implementation

### 1. Session Management
```dart
class SessionManager {
  static const Duration sessionDuration = Duration(hours: 24);
  static const Duration inactivityTimeout = Duration(minutes: 30);

  DateTime? _lastActivity;
  DateTime? _sessionStart;

  bool isSessionValid() {
    if (_sessionStart == null) return false;
    
    final now = DateTime.now();
    
    // Check session expiry
    if (now.difference(_sessionStart!) > sessionDuration) {
      return false;
    }
    
    // Check inactivity
    if (_lastActivity != null &&
        now.difference(_lastActivity!) > inactivityTimeout) {
      return false;
    }
    
    return true;
  }

  void updateActivity() {
    _lastActivity = DateTime.now();
  }

  void startSession() {
    _sessionStart = DateTime.now();
    _lastActivity = DateTime.now();
  }

  void endSession() {
    _sessionStart = null;
    _lastActivity = null;
  }
}
```

### 2. Input Sanitization
```dart
class InputSanitizer {
  static String sanitizeHtml(String input) {
    return input
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('javascript:', '')
        .replaceAllMapped(
          RegExp(r'on\w+\s*=', caseSensitive: false),
          (match) => '',
        );
  }

  static String sanitizeInput(String input) {
    return input.trim();
  }
}
```

## 📱 API Integration Patterns

### Option 1: REST API with http package
```dart
class ApiService {
  final String baseUrl;
  final http.Client client;

  ApiService(this.baseUrl, this.client);

  Future<Response> get(String endpoint) async {
    final response = await client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
    );
    return _handleResponse(response);
  }

  Future<Response> post(String endpoint, {Map<String, dynamic>? data}) async {
    final response = await client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await SecureStorageService().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Response _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return Response(
        data: jsonDecode(response.body),
        statusCode: response.statusCode,
      );
    } else {
      throw ApiException(
        message: 'Request failed: ${response.statusCode}',
        statusCode: response.statusCode,
      );
    }
  }
}
```

### Option 2: Firebase Backend
```dart
// Use Firebase services directly
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return User.fromFirebaseUser(credential.user);
    } catch (e) {
      throw AuthException('Login failed: $e');
    }
  }
}
```

## 🎨 UI Implementation

Refer to the original React components for UI design, but implement using Flutter widgets:

- **Auth Pages** → Flutter login/register screens
- **Dashboard** → Flutter home screen with cards
- **Project List** → ListView.builder with cards
- **Project Details** → Detail screen with tabs
- **File Upload** → image_picker & file_picker

## ✅ Testing

```dart
// Unit Test Example
void main() {
  group('Validators', () {
    test('validates correct email', () {
      expect(Validators.isValidEmail('test@example.com'), true);
    });

    test('rejects invalid email', () {
      expect(Validators.isValidEmail('invalid-email'), false);
    });
  });
}
```

## 🚀 Next Steps

1. Create Flutter project: `flutter create paktransparent_flutter`
2. Add required dependencies to `pubspec.yaml`
3. Convert models from TypeScript to Dart
4. Implement services using http or dio
5. Set up state management (Provider/Riverpod)
6. Build UI screens
7. Implement authentication flow
8. Add file upload functionality
9. Test on Android and iOS
10. Deploy to Play Store and App Store

---

**Need Help?**
- Refer to backend logic in this folder
- Check Flutter documentation: https://docs.flutter.dev
- State management: https://pub.dev/packages/provider
- HTTP client: https://pub.dev/packages/http
