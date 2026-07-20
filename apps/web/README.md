# Influencers Monk — Flutter web (`apps/web`)

Frontend workspace root: `frontend-code/` (temporary isolation). Preferred monorepo path later: repo-root `apps/web`.

## Prerequisites

- Flutter **3.44.0** (see `.flutter-version`)
- Backend API running (`backend-code` compose) on `http://localhost:3000`

## Run

```bash
cd frontend-code/apps/web
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

## Dart defines

| Variable | Default | Purpose |
|---|---|---|
| `API_BASE_URL` | `http://localhost:3000` | Nest API origin |
| `ENVIRONMENT` | `local` | local \| staging \| production |
| `SENTRY_DSN` | (empty) | optional |

Never ship secrets (JWT signing keys, gateway secrets) in Flutter.

## Packages

| Package | Path | Notes |
|---|---|---|
| `web` | `apps/web` | Flutter app |
| `api_client` | `packages/api_client` | **Handwritten interim** — replace with OpenAPI gen when backend T0.6 lands |
| `monk_shared` | `packages/shared` | Enums + error codes mirror |

## Quality gates

```bash
dart format --set-exit-if-changed .
dart analyze --fatal-infos
flutter test
flutter build web --release
```

## Architecture

Clean Architecture + `flutter_bloc` + `go_router` + get_it. See `docs/frontend-plan/01-architecture.md` and `docs/frontend/design.md`.

## Auth token storage (human review)

Tokens are stored in `SharedPreferences` for web MVP local/dev. Production should prefer httpOnly cookie session or platform secure storage with documented threat model. Gate: T0.6 HR-A.
