# SmartAttend

SmartAttend is an automated, secure proximity-based attendance management platform built with **Flutter**, **Node.js/Express**, and **Bluetooth Low Energy (BLE)**.

The system prevents proxy attendance through real-time hardware proximity verification and single-device session locking.

---

## Architecture Overview

```
 ┌─────────────────────────┐               ┌─────────────────────────┐
 │     Teacher App         │               │      Student App        │
 │  (BLE Beacon Broadcast) │               │   (BLE Proximity Scan)  │
 └────────────┬────────────┘               └────────────┬────────────┘
              │                                         │
              │ RSSI / Session Verification             │
              ▼                                         ▼
        ┌─────────────────────────────────────────────────────┐
        │                 SmartAttend API                     │
        │               (Node.js & Express)                   │
        │  - Anti-Proxy DeviceLock Management                 │
        │  - Attendance Sessions & Verification               │
        │  - Student / Teacher Records                        │
        └──────────────────────────┬──────────────────────────┘
                                   │
                                   ▼
                        ┌─────────────────────┐
                        │   MongoDB Database  │
                        └─────────────────────┘
```

---

## Key Features

* **Proximity Attendance with BLE**: Teacher initiates a session broadcasting a unique BLE UUID; student devices scan and verify proximity using signal strength (RSSI).
* **Anti-Proxy Device Lock**: Physical device binding prevents a student from logging into another student's account on the same phone during an active session.
* **Role-Based Access**: Dedicated portals and workflows for both teachers and students.
* **Instant Export & Reporting**: One-tap Excel sheet generation directly from the teacher dashboard for immediate academic record submission.

---

## Project Structure

```
Smart attend/
├── backend/            # Express.js & MongoDB API
│   ├── config/         # Database connection
│   ├── controllers/    # Route controllers
│   ├── middleware/     # JWT authentication & role guards
│   ├── models/         # Mongoose data schemas
│   ├── routes/         # REST API endpoints
│   ├── services/       # Core business logic
│   └── server.js       # Entry point
│
└── mobile/             # Flutter cross-platform client
    ├── android/        # Native Android configurations & permissions
    ├── lib/
    │   ├── constants/  # API & department configs
    │   ├── models/     # Client data models
    │   ├── screens/    # Auth, Student, and Teacher UI
    │   └── services/   # BLE, HTTP, Storage, and Excel export
    └── pubspec.yaml    # Flutter dependencies
```

---

## Quick Start

### 1. Backend Setup
```bash
cd backend
npm install
npm start
```
* Default server port: `5000`
* Configured MongoDB URI in `.env`: `mongodb://127.0.0.1:27017/smartAttendDB`

### 2. Mobile App Setup
```bash
cd mobile
flutter pub get
flutter run
```
* Update `lib/constants/api_constants.dart` if your local IP changes.

---

## Security Implementation
* Passwords secured using `bcryptjs` with salt round 10.
* Stateless session tokens via JSON Web Tokens (`jsonwebtoken`).
* Device-level hardware fingerprinting to deter attendance fraud.
