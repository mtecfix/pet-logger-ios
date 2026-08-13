# Pet Logger iOS
> Medical and coordination tracker for pet owners. Built for senior pets, chronic illness management, and multi-pet households.

[![Build](https://github.com/mtecfix/pet-logger-ios/actions/workflows/build.yml/badge.svg)](https://github.com/mtecfix/pet-logger-ios/actions)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![iOS](https://img.shields.io/badge/iOS-16%2B-blue)

---

## Features
- **Multi-Pet Profiles** — add, edit, delete pets with species, breed, weight
- **Health Metric Logger** — weight, blood glucose, heart rate, medication, temperature, notes
- **Medication Reminders** — daily local push notifications per pet per medication
- **One-Click Export** — generate JSON medical history with presigned S3 download
- **Pet Photo Upload** — attach photos to pet profiles via S3
- **Offline Mode** — full local cache, works without internet, syncs when back online
- **Full Auth Flow** — sign up, email verification, forgot password, sign in

## AWS Backend
| Resource | Value |
|----------|-------|
| API Endpoint | `https://tg5fkkc7k2.execute-api.us-east-1.amazonaws.com/dev` |
| Cognito Pool | `us-east-1_epf05nztC` |
| Cognito Client | `2cbmo12ckk4i92b6jm2r80dq1i` |
| DynamoDB | `pet-logger-data` |
| S3 Bucket | `pet-logger-663877906756` |
| Lambda | `pet-logger-api` (Node.js 20) |

## API Routes
| Method | Route | Description |
|--------|-------|-------------|
| GET | `/pets` | List all pets |
| POST | `/pets` | Create pet |
| PUT | `/pets/{petId}` | Update pet |
| DELETE | `/pets/{petId}` | Delete pet |
| GET | `/metrics/{petId}` | Get health metrics |
| POST | `/metrics` | Log metric |
| DELETE | `/metrics/{metricId}` | Delete metric |
| GET | `/export/{petId}` | Export medical history |
| GET | `/photo-upload` | Presigned S3 URL for photo |

## Project Structure
```
PetLogger/
├── Assets.xcassets/              ← App icon (placeholder — replace AppIcon-1024.png)
├── Config.swift                  ← API endpoints + Cognito IDs
├── PetLoggerApp.swift            ← App entry + launch screen animation
├── Models/
│   ├── Pet.swift
│   └── Metric.swift
├── Services/
│   ├── APIService.swift          ← All HTTP calls
│   ├── AuthService.swift         ← Full Cognito auth flow
│   ├── LocalCache.swift          ← Offline cache (UserDefaults + JSON)
│   ├── NotificationManager.swift ← Push + local notifications
│   └── OfflineBanner.swift       ← Offline indicator UI
├── ViewModels/
│   ├── PetListViewModel.swift    ← Pet CRUD + offline cache
│   └── MetricsViewModel.swift    ← Metrics CRUD + offline cache
└── Views/
    ├── LaunchScreenView.swift    ← Animated launch screen (blue gradient)
    ├── ContentView.swift         ← Auth gate
    ├── LoginView.swift
    ├── SignUpView.swift
    ├── ConfirmEmailView.swift
    ├── ForgotPasswordView.swift
    ├── MainTabView.swift
    ├── PetListView.swift
    ├── PetDetailView.swift       ← Bell (reminders), camera, edit, delete
    ├── AddPetView.swift
    ├── EditPetView.swift
    ├── LogMetricView.swift
    ├── MedicationScheduleView.swift ← Daily reminder scheduler
    ├── PhotoUploadView.swift
    └── SettingsView.swift
```

## Getting Started
1. Clone repo
2. Open `Package.swift` in Xcode 15+
3. Build and run on iOS 16+ simulator or device
4. Create account → verify email → add pets → log health data

## App Icon
Placeholder icon is in `PetLogger/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png` (solid blue).
Replace with your 1024×1024 PNG — Xcode generates all sizes automatically.

## Launch Screen
Blue gradient with pawprint icon, fades out after 1.8s.

## Installing via AltStore (no App Store needed)
1. Download `.ipa` from GitHub Actions build artifacts
2. Open AltStore on iPhone → tap `+` → select `.ipa`
3. Apps expire every 7 days with free Apple ID — AltStore auto-renews on same WiFi

## CI/CD
GitHub Actions builds on every push to `main` using macOS runner (`macos-latest`).
