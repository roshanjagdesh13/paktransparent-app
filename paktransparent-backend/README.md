# Pakistan Transparent - Backend API & Business Logic

This folder contains the backend API logic, data models, and business logic for the Pakistan Transparent application.

## 🚀 Running the Production API Server

The backend includes a native Node.js REST & Real-Time SSE server (`server.mjs`) requiring zero external dependencies:

```bash
# Start the API server on port 3000
npm start
# or: node server.mjs
```

### Run End-to-End Test Suite:
```bash
npm test
# or: node test.mjs
```

The test suite runs 9 automated end-to-end integration tests covering:
- Citizen Authentication
- Official Authentication
- Account Registration
- Project Pagination & Query Filters
- Project Creation & Approval Hierarchy
- Single Project Retrieval
- Citizen Report Submissions
- Government Report Resolutions & Remedial Notes
- Verifiable Audit Trail Logging

---

## 📁 Structure

```
paktransparent-backend/
├── api/
│   ├── services/        # API services and business logic
│   ├── types/          # TypeScript type definitions and data models
│   ├── utils/          # Utility functions
│   ├── constants/      # Application constants
│   ├── config/         # Configuration files
│   └── data/           # Sample/seed data
├── state/              # State management logic
├── .env.example        # Environment variables template
├── .env.production     # Production environment config
└── .gitignore          # Git ignore rules
```

## 🔧 Core Services

### `api/services/`

- **authService.ts** - Authentication and authorization logic
- **securityService.ts** - Security utilities (hashing, encryption, validation)
- **fileUploadService.ts** - File upload and management
- **projectService.ts** - Project management APIs
- **reportService.ts** - Citizen report management
- **budgetService.ts** - Budget allocation and tracking
- **api.ts** - Base API configuration

### `api/types/`

- **index.ts** - Core data models (User, Project, Report, etc.)
- **government.ts** - Government-specific types
- **workflow.ts** - Workflow and approval types

### `api/utils/`

- **validation.ts** - Input validation functions
- **format.ts** - Data formatting utilities
- **security.ts** - Security helpers
- **logger.ts** - Logging utilities
- **export.ts** - Data export functions

### `state/`

State management stores (can be adapted to Flutter state management):

- **authStore.ts** - Authentication state
- **projectStore.ts** - Project state
- **reportStore.ts** - Reports state
- **approvalStore.ts** - Approval workflows
- **governmentProjectStore.ts** - Government project management

## 🎯 Usage for Flutter Application

This backend logic can be:

1. **Directly converted to Dart** - Port TypeScript logic to Dart for Flutter
2. **Used as API backend** - Set up Node.js/Express server using these services
3. **Reference for Flutter implementation** - Use as specification for Flutter code

## 🔐 Security Features

- Password hashing with salt (SHA-256)
- Session management (24hr expiry, 30min timeout)
- CSRF protection
- Rate limiting
- Account lockout (5 attempts = 15min)
- Input sanitization (XSS prevention)
- Audit logging
- Data encryption (AES)

## 📊 Key Data Models

### User
```typescript
{
  id: string;
  email: string;
  name: string;
  role: 'citizen' | 'government';
  phone?: string;
  province?: string;
  district?: string;
  // ... more fields
}
```

### Project
```typescript
{
  id: string;
  projectId: string;
  name: string;
  description: string;
  category: string;
  status: string;
  province: string;
  budgetAllocated: number;
  // ... more fields
}
```

### Report
```typescript
{
  id: string;
  title: string;
  description: string;
  category: string;
  status: 'submitted' | 'under_review' | 'resolved' | 'rejected';
  files: UploadedFile[];
  // ... more fields
}
```

## 🚀 Next Steps for Flutter Integration

### Option 1: Direct Port to Dart
Convert TypeScript services to Dart and integrate into Flutter app.

### Option 2: Create REST API Backend
1. Set up Node.js/Express backend
2. Create REST endpoints using these services
3. Connect Flutter app to API
4. Add database (PostgreSQL/MongoDB)
5. Add cloud storage (AWS S3/Firebase)

### Option 3: Firebase Backend
1. Use Firebase for authentication
2. Use Firestore for database
3. Use Firebase Storage for files
4. Port business logic to Dart

## 📝 Environment Variables

See `.env.example` for required environment variables:

- API URLs
- Encryption keys
- Session configuration
- Rate limiting settings
- File upload limits

## 🔄 Converting to Flutter

### 1. Data Models → Dart Classes
Convert TypeScript interfaces to Dart classes with `fromJson` and `toJson` methods.

### 2. Services → Dart Services
Convert service classes to Dart service classes using `http` or `dio` packages.

### 3. State Management
Choose Flutter state management:
- Provider
- Riverpod
- Bloc
- GetX

Adapt store logic to chosen solution.

### 4. Validation
Use Flutter form validation or adapt validation utilities.

### 5. Security
Implement security features:
- flutter_secure_storage for secure storage
- crypto package for encryption
- Local authentication for biometrics

## 📞 Notes

- This is the core business logic from the React web app
- All React-specific code has been removed
- Only backend logic, types, and utilities are preserved
- Ready for Flutter app development

---

**For Flutter Development:**
Use this as a reference for implementing backend integration in your Flutter mobile application.
