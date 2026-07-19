# Mobile Integration Discovery Report

Status: [LIVE] discovery findings as of 2026-04-30.

## Summary

No mobile app source repo was found in the three repos provided for this sprint.

Repos checked:

| Repo | Finding |
|---|---|
| `NahomCJ/Panther-AI-` | Panther FastAPI backend. Contains integration sprint docs and Notion mobile placeholders. No mobile source. |
| `NahomCJ/Panther-` | Older Panther FastAPI backend snapshot. No mobile source. |
| `NahomCJ/Chronos-Backend-` | TypeScript Express backend. Contains production API docs/Postman collections. No mobile source. |

## Mobile Stack

Recommendation: Flutter.

Why:
- Existing Notion export references "Flutter Mobile App".
- One codebase can target iOS and Android.
- The sprint needs backend integration screens, not platform-specific native behavior.
- Flutter gives a typed client layer and testable UI without choosing separate iOS/Android owners.

## Backend Contract

Use `Panther-AI-` as the sprint source of truth unless Martín says otherwise.

Current sprint endpoints:

| Method | Path | Status |
|---|---|---|
| `GET` | `/health` | [LIVE] sanity check |
| `POST` | `/api/authorize-payment` | [LIVE] payment authorization |
| `POST` | `/api/kevin/chat` | [LIVE] Kevin assistant |
| `GET` | `/api/transactions` | [LIVE] transaction list |
| `GET` | `/api/transactions/{id}` | [LIVE] transaction detail |
| `PATCH` | `/api/transactions/{id}` | [LIVE] category feedback |

Auth for this sprint:
- Send `X-User-Id: user_marcus`.
- Also include `user_id: user_marcus` in request bodies/query params where the backend requires it.
- Keep all auth/header injection inside one mobile `apiClient` module.

## Contract Conflict

`Chronos-Backend-` exposes a different production API:

| Area | Panther sprint contract | Chronos production contract |
|---|---|---|
| Base URL | `http://localhost:8000` | `http://chronos.us-east-1.elasticbeanstalk.com` |
| Auth | `X-User-Id: user_marcus` placeholder | `Authorization: Bearer <jwt>` |
| Kevin | `POST /api/kevin/chat` | `POST /api/ai/kevin/chat` |
| BNPL affordability | `POST /api/authorize-payment` | `POST /api/ai/tickpay/affordability` |

Decision needed from Martín:
- Confirm whether mobile should integrate against Panther FastAPI for this sprint.
- Confirm whether Chronos production JWT/API migration is a later sprint.

Recommendation:
- Proceed against Panther FastAPI now.
- Keep the mobile client isolated so the Chronos JWT/API migration changes one layer, not every screen.

## Working Agreement Draft

Until a mobile team is identified:

| Decision | Owner |
|---|---|
| Mobile API client | Full-stack integration owner |
| Mobile screens | Full-stack integration owner |
| Backend endpoint behavior | Martín |
| API contract source | `http://localhost:8000/docs` plus `docs/mobile_integration/API_CONTRACT.md` |
| Breaking changes | Martín posts in `#blockers` before changing endpoint shape |
| Progress tracking | `tasks/SPRINT_INTEGRATION.md` |

## Open Blockers

- Mobile team lead is not identified.
- Slack channel / first sync is not scheduled from this workspace.
- Martín has not acknowledged this report in `#dev-updates`.
- Flutter SDK is installed locally at `../flutter-sdk`.
- Mobile static analysis and API client tests pass in `../Chronos-Mobile`.

## Next Step

Create a new Flutter mobile app repo locally unless Nahom provides an existing mobile repo.
