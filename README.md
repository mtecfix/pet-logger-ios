# Pet Logger iOS

Medical and coordination tracker for pet owners — built for senior pets, chronic illness management, and multi-pet households.

## Features
- **Multi-Pet Profiles** — track multiple pets with species, breed, and weight
- **Health Metric Logger** — log weight, blood glucose, heart rate, medication, temperature, notes
- **One-Click Export** — generate JSON medical history with presigned S3 download link
- **Pet Photo Upload** — attach photos to pet profiles via S3
- **Edit & Delete** — full CRUD on pets and metrics with swipe-to-delete
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
| POST | `/pets` | Create new pet |
| PUT | `/pets/{petId}` | Update pet |
| DELETE | `/pets/{petId}` | Delete pet |
| GET | `/metrics/{petId}` | Get metrics for pet |
| POST | `/metrics` | Log health metric |
| DELETE | `/metrics/{metricId}` | Delete metric |
| GET | `/export/{petId}` | Export medical history |
| GET | `/photo-upload` | Presigned S3 URL for photo |

## Project Structure
```
PetLogger/
├── Config.swift / PetLoggerApp.swift
├── Models/          Pet.swift, Metric.swift
├── Services/        APIService.swift, AuthService.swift
├── ViewModels/      PetListViewModel.swift, MetricsViewModel.swift
└── Views/           Login, SignUp, ConfirmEmail, ForgotPassword,
                     PetList, PetDetail, AddPet, EditPet,
                     LogMetric, PhotoUpload, Settings
```

## Getting Started
1. Open `Package.swift` in Xcode 15+
2. Build and run on iOS 16+ simulator or device
3. Create an account, verify email, add pets

## Installing via AltStore
1. Download `.ipa` from GitHub Actions build artifacts
2. Open AltStore on iPhone → tap `+` → select `.ipa`
