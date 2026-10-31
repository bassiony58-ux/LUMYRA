# Lumyra — Local Setup, Run & Development Guide

This guide describes how to start and test the complete Lumyra application environment locally.

---

## 1. System Requirements & Prerequisites

- **Flutter SDK**: `>= 3.27.0` (Dart `>= 3.6.0`)
- **Node.js**: `>= 18.x`
- **npm**: `>= 9.x`
- **PostgreSQL**: (Optional for local development; when PostgreSQL is not running, setting `SKIP_DB_CONNECT=true` enables instant standalone mock development mode across all endpoints)

---

## 2. Environment Configuration

### Backend (`backend/.env`)

Copy `backend/.env.example` to `backend/.env` or configure the following development settings:

```bash
NODE_ENV=development
PORT=4000
API_PREFIX=/api/v1

# Database Connection (Optional in mock dev mode)
DATABASE_URL="postgresql://lumyra_user:lumyra_secret@localhost:5432/lumyra_db?schema=public"
SKIP_DB_CONNECT=true

# Firebase Project Configuration
FIREBASE_PROJECT_ID="lumyra-health-dev"

# Development Authentication Switch
# Set to 'true' to enable safe mock bearer tokens for instant local UI/API testing
ALLOW_MOCK_AUTH=true

# Private Medical Scan Storage
STORAGE_PROVIDER="mock-local"
STORAGE_BUCKET_NAME="lumyra-private-scans"
STORAGE_SIGNED_URL_EXPIRY_SECONDS=900

# Pluggable AI / Vision Model Providers (Agnostic / Deferred)
AI_ASSISTANT_PROVIDER="mock"
MEDICAL_VISION_PROVIDER="mock"
RISK_MODEL_PROVIDER="mock"
```

> [!IMPORTANT]
> `ALLOW_MOCK_AUTH` and `SKIP_DB_CONNECT` are strictly intended for local development and automated testing. In production environments (`NODE_ENV=production`), `ALLOW_MOCK_AUTH` must be `false` and live Firebase Admin credentials and PostgreSQL connections are strictly required.

---

## 3. Starting the Backend Server

Open a terminal and execute:

```powershell
cd M:\LUMYRA\backend

# Install dependencies if not already installed
npm install

# Build TypeScript code
npm run build

# Start the NestJS backend
npm run start
```

### Verified Endpoints & Documentation

- **Base API URL**: `http://localhost:4000/api/v1`
- **Health Check**: `http://localhost:4000/api/v1/health`
- **Interactive Swagger Documentation**: `http://localhost:4000/api/docs`

---

## 4. Starting the Flutter Frontend

### Running on Flutter Web (Recommended for Multi-Screen Inspection)

Open a second terminal window:

```powershell
cd M:\LUMYRA

# Ensure clean analysis
flutter analyze lib test

# Launch on Chrome or Edge web browser
flutter run -d chrome --web-port 3000
```

The Flutter web application will open at `http://localhost:3000`.

### Running on Android Emulator / Physical Device

```powershell
cd M:\LUMYRA
flutter run -d <device_id>
```

Or build the debug APK directly:

```powershell
$env:TEMP = "M:\Temp"; $env:TMP = "M:\Temp"; $env:GRADLE_USER_HOME = "M:\.gradle"
flutter build apk --debug
```

The built APK is saved to: `build/app/outputs/flutter-apk/app-debug.apk`.

---

## 5. Development Roles & Test Accounts

Lumyra provides safe, pre-configured development profiles so you can inspect and test every role without setting up live Firebase phone/email credentials:

| Role | Test Account Name | Mock Bearer Token | Initial Screen | Capabilities Tested |
| :--- | :--- | :--- | :--- | :--- |
| **Patient** | مريم أحمد (Mariam Ahmed) | `mock-patient-token` | `/patient` | Patient dashboard, guided questionnaire, appointments, medications, private journal, educational articles, medical centers directory. |
| **Doctor (Approved)** | د. نور الخالدي (Dr. Nour Al-Khalidi) | `mock-doctor-approved-token` | `/doctor` | Approved doctor badge, patient roster overview, secondary imaging viewer layout, clinical triage alerts. |
| **Doctor (Pending Review)** | د. سارة المنشاوي (Dr. Sara El-Minshawi) | `mock-doctor-pending-token` | `/doctor` | Verifies pending approval guard: clinical patient data is restricted until admin approval. |
| **Administrator** | المشرف العام (System Administrator) | `mock-admin-token` | `/admin` | Operational analytics, doctor license verification and approval/rejection actions, audit trails. |

To switch roles in the UI:
1. Open the application.
2. If currently logged in, tap the **Logout** icon at the bottom of the navigation bar/rail.
3. From the **Role Selection Screen** (`/choose-role`), select Patient, Doctor, or Administrator. The application attaches the corresponding dev token and navigates directly to that role's authenticated dashboard.

---

## 6. Running Automated Tests

### Flutter Tests
```powershell
$env:TEMP = "M:\Temp"; $env:TMP = "M:\Temp"
flutter test
```
*Current test suite: 17/17 tests passing (API client, localization, patient dashboard, guided questionnaire, adaptive navigation).*

### Backend Tests
```powershell
cd M:\LUMYRA\backend
npm test
```
*Current test suite: 9/9 test suites passing, 45/45 tests passing (Prisma mocks, RBAC, Firebase auth guard, Doctor approved guard, Access control, Storage service, Questionnaire service).*
