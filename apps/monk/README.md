# Monk (`apps/monk`)

Flutter web/mobile client for Influencers Monk.

## Offline demo (mock mode)

Runs fully offline with in-memory seed data — no API required.

```bash
cd apps/monk
flutter run -d chrome --dart-define=USE_MOCKS=true --dart-define=MOCK_LATENCY_MS=150
```

| Define | Default | Purpose |
|---|---|---|
| `USE_MOCKS` | `false` | Swap all domain repositories for offline mocks |
| `MOCK_LATENCY_MS` | `150` | Artificial delay so loading UI is visible |

### Demo personas

All share password **`123456`**.

| Label | Username | Landing |
|---|---|---|
| Creator (Arjun) | `creator` | `/c/dashboard` |
| Brand (Priya) | `brand` | `/b/dashboard` |
| Manager (Meera) | `manager` | `/c/roster` |
| Admin | `admin` | `/a/dashboard` |
| Agency (Alex) | `agency` | `/a/agency/briefs` |
| Fresh Brand | `newbrand` | `/b/onboarding` |
| Fresh Creator | `newcreator` | `/c/onboarding` |

Legacy `demo.*@influencersmonk.local` emails, first-name aliases (`arjun`, `priya`, `meera`, `alex`), and `local-part@anything` still resolve via `MockSeedStore.findAccountByEmail`.

### Caveats

- **B9:** Mock data lives in memory — full page reload resets the store.
- **B10:** Login also accepts a few legacy passwords (`Password123!`, `password`) for convenience.
- **B8:** `newcreator` is onboarding-only; completing wizard does not yet seed a full marketplace graph for that persona.

## API mode

```bash
cd apps/monk
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:3000
```

Optional:

```bash
--dart-define=ENVIRONMENT=local
--dart-define=ENABLE_AI=true
```

## Tests

```bash
cd apps/monk
flutter test
```

## Related docs

- `docs/frontend-tasks/demo-mock/TASKS.md` — implementation checklist
- `docs/mock-mode-audit.md` — mock quality audit
