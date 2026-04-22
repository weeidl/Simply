# Simply

A Flutter app that forwards incoming SMS from an Android phone to all the
user's other devices (iOS / Android) via Firebase Cloud Firestore.

Typical use case: keep a work Android as an SMS/OTP receiver; read codes and
messages live on a personal iPhone under the same Simply account.

## Quick start

```bash
flutter pub get
# Place your own Firebase config:
#   android/app/google-services.json
#   ios/Runner/GoogleService-Info.plist
flutter run
```

Minimum SDKs: Flutter 3.24 / Dart 3.5.

## Platforms

| Platform | SMS interception | Receive forwarded SMS |
|----------|:----------------:|:---------------------:|
| Android  | ✅               | ✅                    |
| iOS      | ❌ (not possible)| ✅                    |

## Tech stack

- `flutter_bloc` (Cubit) — state management
- Firebase: Auth, Cloud Firestore, Messaging
- `another_telephony` — SMS receiver on Android
- `flutter_local_notifications` — foreground-service notification
- `device_info_plus`, `battery_plus`, `permission_handler`

## Docs

Project documentation — product overview, screen map, bugs / audit / roadmap —
lives in [`docs/`](./docs/README.md).

- [`docs/01_PRODUCT_OVERVIEW.md`](./docs/01_PRODUCT_OVERVIEW.md)
- [`docs/02_SCREENS_OVERVIEW.md`](./docs/02_SCREENS_OVERVIEW.md)
- [`docs/03_BUGS_AND_ISSUES.md`](./docs/03_BUGS_AND_ISSUES.md)
- [`docs/04_SECURITY_AUDIT.md`](./docs/04_SECURITY_AUDIT.md)
- [`docs/05_ARCHITECTURE_IMPROVEMENTS.md`](./docs/05_ARCHITECTURE_IMPROVEMENTS.md)
- [`docs/06_FIX_PROGRESS.md`](./docs/06_FIX_PROGRESS.md)
- [`docs/07_RELEASE_SIGNING.md`](./docs/07_RELEASE_SIGNING.md)
- [`docs/08_CLAUDE_DESIGN_PROMPT.md`](./docs/08_CLAUDE_DESIGN_PROMPT.md)
- [`firestore.rules`](./firestore.rules) — baseline Firestore Security Rules.

## Contributing

See `docs/05_ARCHITECTURE_IMPROVEMENTS.md` for the refactor roadmap before
opening large PRs.
