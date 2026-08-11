# Chronos Backend — Project Context

## What This Project Is

A unified financial super-app backend. Two separate apps live in one repo, **both deployed to AWS**:

| App | Entry Point | Framework | Port | Status |
|---|---|---|---|---|
| Main API | `src/server.ts` → `src/app.ts` | Express 5 + TypeScript | 3000 (local), 8080 (EB) | ✅ Live |
| BlockHub (Crypto/NFT) | `src/modules/blockhub/src/main.ts` | NestJS 11 | 3000 | ✅ Live |

---

## Stack

### Main API
- **Runtime**: Node.js 20 + TypeScript 5
- **Framework**: Express 5
- **ORM**: Prisma 6 + PostgreSQL
- **Auth**: JWT (HS256) + bcrypt
- **KYC/Banking**: Plaid Sandbox (IDV + Auth)
- **AI**: Anthropic Claude (Panther engine) + OpenAI Whisper (STT) + ElevenLabs (TTS)
- **Email**: Nodemailer (SMTP/SendGrid) — lazy init, works without config
- **Push**: Firebase Admin SDK (FCM) — lazy init, works without config
- **Cache**: Redis (optional, falls back to in-memory Map)

### BlockHub (NestJS)
- **Runtime**: Node.js 24 + TypeScript 5
- **Framework**: NestJS 11
- **ORM**: Prisma 6 + PostgreSQL (shared DB)
- **Crypto**: Paxos API (sandbox/production)
- **NFT Minting**: Bull queue (Redis-backed; falls back to retry without Redis)
- **Real-time**: Socket.io (GatewayModule)
- **Auth**: JWT guards + roles decorator

---

## Active API Routes — Main API (mounted in `src/routes/index.ts`)

| Route | Module |
|---|---|
| `/api/v1/auth` | Auth (register, login, OTP, forgot/reset password) |
| `/api/v1/transfer` | Transfers |
| `/api/v1/auto-invest` | Auto-Invest with Chris — allocation preview, plan confirm/rounds/pause/resume/cancel. Crypto legs `[LIVE]` (Paxos), stock/ETF legs `[PLANNED — no brokerage integration]`. See below. |
| `/api/core/accounts` | Bank accounts |
| `/api/cards` | Virtual/physical cards |
| `/api/transactions` | Ledger transactions |
| `/api/wallet` | Wallets |
| `/api/tickpay` | BNPL (TickPay) |
| `/api/lifex` | LifeX — all 11 sub-modules |
| `/api/bills` | Bill payments |
| `/api/currency` | FX rates (Redis-cached) |
| `/api/fx` | FX orders |
| `/api/kyc` | Plaid KYC + webhook |
| `/api/core/transfer` | Core transfers |
| `/api/core/deposit` | ACH deposits |
| `/api/ai` | Panther AI — Chris chat, alerts, voice, BNPL scoring, user level |
| `/api/home` | Dashboard home |
| `/api/notifications` | In-app notifications |
| `/health` | Health check (no auth) |

---

## Auto-Invest with Chris (`/api/v1/auto-invest`, mounted in `src/modules/investing/auto-invest/`)

User sets risk profile + goal + amount + cadence. Chris proposes a diversified crypto/stock/ETF allocation. User confirms before anything executes — no autonomous execution (see `panther/Panther-AI-/PantherAI/CLAUDE.md`).

Only crypto has live trade execution (Paxos, same pipeline as `/api/v1/crypto`). Stock/ETF legs have zero brokerage integration in this codebase — they are computed and persisted as a planned target only, never executed.

All routes require auth.

| Route | Purpose | Status |
|---|---|---|
| `POST /allocation-preview` | Generate an allocation from `{ riskProfile, goal, amountUsd }` — no persistence | — |
| `POST /plans` | Create a plan (`PENDING_CONFIRMATION`) from the preview's allocations | — |
| `POST /plans/:id/confirm` | Execute round 1 | Crypto legs `[LIVE]`, stock/ETF legs `[PLANNED — no brokerage integration]` |
| `POST /plans/:id/rounds` | Manually execute the next round (dashboard "Invest Next Round Now" button — no background scheduler) | same split as confirm |
| `GET /plans/active` | Caller's current non-cancelled/non-completed plan | — |
| `GET /plans/:id` | Single plan (allocations + executions) | — |
| `PATCH /plans/:id/pause` / `/resume` | Toggle `ACTIVE` ↔ `PAUSED` | — |
| `DELETE /plans/:id` | Soft-cancel (`CANCELLED`, rows kept) | — |
| `GET /plans/:id/executions` | Full execution history, newest first | — |

A failed crypto leg (e.g. compliance/balance rejection from the existing Paxos pipeline) is recorded as `FAILED` with a reason and does not block the other legs in the same round.

Old dead-code stub at `src/modules/core/transactions/autonomous-investor/` (Mongoose-based, unmounted) is unrelated to this feature — left untouched.

---

## Active API Routes — BlockHub (prefix: `/api/v1`)

| Route | Module |
|---|---|
| `/api/v1/auth` | Auth (register, login, JWT) |
| `/api/v1/crypto` | Crypto wallets, balances, buy/sell (Paxos) |
| `/api/v1/nft` | NFT minting, gallery, transfer |
| `/health` | Health check (no auth) |

---

## LifeX Sub-modules (all fully implemented)

Mounted under `/api/lifex`:

| Route | Module | Status |
|---|---|---|
| `/education` | Courses, scholarships, tutors, student loans | ✅ |
| `/health` | Health metrics, habits, HSA, appointments | ✅ |
| `/finance` | Budgets, financial plans | ✅ |
| `/vision` | Vision boards, long-term goals | ✅ |
| `/activity` | Activity logs, stats, streaks | ✅ |
| `/ai` | LifeX AI coach (insights, chat, weekly plan) + `/ai/voice/*` ElevenLabs voice chat (see below) | ✅ |
| `/export` | Data export (health, finance, education, vision, full) | ✅ |
| `/family` | Family groups, shared goals, shared budgets | ✅ |
| `/social` | Follow/unfollow, posts, likes, community feed | ✅ |
| `/spiritual` | Meditation, gratitude, spiritual goals, streak | ✅ |
| `/feed` | Unified personal + community timeline feed | ✅ |

---

## Notification System (implemented in v16+)

**Files**:
- `src/modules/notification/email.service.ts` — nodemailer sender (lazy, skips if SMTP not configured)
- `src/modules/notification/email.templates.ts` — HTML email templates for all 20 event types
- `src/modules/notification/notification.queue.ts` — inline shim (no bullmq/Redis required)
- `src/modules/notification/notificatoin.service.ts` — `sendNotification(user, opts)` + `notifyUser(userId, opts)` + `sendDirectEmail()`
- `src/modules/notification/push.provider.ts` — Firebase FCM (lazy init, skips if FCM_SERVICE_ACCOUNT not set)

**Key design decisions**:
- All notification calls are fire-and-forget (`.catch(() => {})`) — never block the request
- `notifyUser(userId, opts)` does the DB user lookup internally — callers just pass userId
- `sendDirectEmail()` bypasses the queue — used for OTP (time-sensitive)
- No bullmq or Redis required — the queue is a thin inline shim; upgrade to bullmq when Redis is provisioned

**Wired into**: auth controller, transfer service, card service, bill service, fx service, kyc service (webhook), bnpl notification service

---

## Panther AI — Endpoint Reference

**Base URL**: `http://chronos.us-east-1.elasticbeanstalk.com/api/ai`

All AI endpoints require `Authorization: Bearer <jwt>` header unless noted.

### Chris Chat
```
POST /api/ai/chris/chat
Body: { "message": "How much did I spend this month?", "responseMode": "text" }
Response: { "reply": "...", "domain": "BANKING", "userLevel": "BEGINNER", "timestamp": "..." }
```

### AI Alerts
```
GET    /api/ai/alerts           → list active alerts
POST   /api/ai/alerts/generate  → trigger alert generation
DELETE /api/ai/alerts/:id       → dismiss alert
```

### BNPL Affordability
```
POST /api/ai/tickpay/affordability
Body: { "amount": 250, "merchant": "Apple Store" }
Response: { "approved": true, "riskScore": 0.3, "maxAmount": 400, "message": "...", "reasoning": "..." }
```

### User Level
```
GET  /api/ai/user-level
PUT  /api/ai/user-level         → { "level": "INTERMEDIATE" }
POST /api/ai/user-level/quiz    → { "answers": { "q1": "a", "q2": "b", ... } }
```

### Voice
```
POST /api/ai/voice/transcribe   → multipart/form-data, field: "audio" → { "text": "..." }
POST /api/ai/voice/synthesize   → { "text": "Hello" } → audio/mpeg stream
GET  /api/ai/voice/health       → { configured, ok, detail?, charactersUsed?, charactersLimit? }
```
`/health` hits ElevenLabs' subscription endpoint (spends no characters) so a
misconfigured/invalid/quota-exhausted key can be diagnosed directly. Errors
from `/synthesize` now return the real ElevenLabs response body (previously
`response.statusText`, which is frequently empty) and a 503 (not configured)
vs 502 (live call failed) status split — see Bugs Fixed #13.

All ElevenLabs calls across the whole backend (this module AND the LifeX AI
coach's voice chat below) go through one shared client:
`src/modules/ai/voice/elevenlabs.client.ts` — single source of truth for the
API key (`ELEVENLABS_API_KEY`, `XI_API_KEY` alias), default voice/model, and
a 600-char synthesis cap so no caller can accidentally run up a huge
ElevenLabs bill on an unbounded LLM reply. See Bugs Fixed #14.

### LifeX AI Coach — Voice Chat
```
GET  /api/lifex/ai/voice/config      → { elevenLabsConfigured, agentConfigured, ttsModel, sttModel, ... } (auth required)
GET  /api/lifex/ai/voice/signed-url  → { signedUrl, agentId } — for the ElevenLabs Agent widget (needs ELEVENLABS_AGENT_ID)
POST /api/lifex/ai/voice/text        → { message, conversationId?, history? } → { transcript, reply, audioBase64, audioMimeType }
POST /api/lifex/ai/voice/audio       → { audioBase64 | audioDataUrl, mimeType, ... } → same shape (STT via ElevenLabs, not Whisper)
```
Replies default to `LifeAiService.coachReply()` (the LifeX AI coach) unless
`CHRONOS_VOICE_CHAT_URL` is set to proxy elsewhere. Manual test client at
`GET /chronos-voice-chat.html` (statically served, requires pasting a JWT —
see Bugs Fixed #14). Not currently called from the Flutter app — no LifeX
page has a live chat UI wired to `/insights`, `/chat`, or `/weekly-plan` yet
(the LifeX AI Insights page's content is still static/hardcoded).

---

## Environment Variables

### Main API — Required
```env
NODE_ENV=production
PORT=8080
DATABASE_URL=postgresql://chronos:chronosdbrds@chronosdb.csjwyuqii28q.us-east-1.rds.amazonaws.com:5432/chronosdb
JWT_SECRET=<64-byte hex string>
DEPOSIT_MIN_AMOUNT=1
```

### Main API — Optional (app boots and degrades gracefully without these)
```env
# AI
ANTHROPIC_API_KEY=       # Chris chat, AI alerts, LifeX AI coach
OPENAI_API_KEY=          # Voice transcription (Whisper)
ELEVENLABS_API_KEY=      # Voice synthesis (ElevenLabs TTS)
ELEVENLABS_VOICE_ID=     # Optional — defaults to Rachel voice

# Email (SendGrid SMTP)
SMTP_HOST=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USER=apikey
SMTP_PASS=<sendgrid_api_key>
SMTP_FROM="Chronos" <noreply@chronos.app>

# Push Notifications (Firebase)
FCM_SERVICE_ACCOUNT={"type":"service_account",...}   # Full JSON as string

# KYC
PLAID_CLIENT_ID=
PLAID_SECRET=
PLAID_ENV=sandbox
PLAID_IDV_TEMPLATE_ID=
PLAID_VERIFY_WEBHOOKS=true   # Enables Plaid webhook signature verification via jose

# Redis (optional — in-memory fallback active without it)
REDIS_HOST=127.0.0.1
REDIS_PORT=6379

# Monitoring
SENTRY_DSN=
```

### BlockHub — Required
```env
NODE_ENV=production
JWT_SECRET=<same or separate 64-byte hex string>
DATABASE_URL=postgresql://chronos:chronosdbrds@chronosdb.csjwyuqii28q.us-east-1.rds.amazonaws.com:5432/chronosdb
```

### BlockHub — Optional
```env
REDIS_URL=redis://localhost:6379   # NFT minting queue; app starts without it but minting jobs won't process
PAXOS_CLIENT_ID=                   # Paxos crypto API
PAXOS_CLIENT_SECRET=
PAXOS_ENV=sandbox                  # or production
```

---

## AWS Deployment Setup

### Infrastructure

#### Main API
- **App**: AWS Elastic Beanstalk (`chronos-backend-env`)
  - URL: `http://chronos.us-east-1.elasticbeanstalk.com`
  - Platform: Node.js 20 on 64-bit Amazon Linux 2023
  - Instance: t3.micro (free tier)
  - Region: us-east-1
  - Account ID: 551451910710
  - Current version: `chronos-v21`

#### BlockHub
- **App**: AWS Elastic Beanstalk (`blockhub-env`)
  - URL: `http://blockhub-env.us-east-1.elasticbeanstalk.com`
  - Application name: `chronos-blockhub`
  - Environment ID: `e-xyivdycae4`
  - Platform: Node.js 24 on 64-bit Amazon Linux 2023
  - Instance: t3.micro (free tier)
  - Region: us-east-1
  - Current version: `blockhub-v2`

#### Shared
- **Database**: AWS RDS PostgreSQL (`chronosdb`)
  - Endpoint: `chronosdb.csjwyuqii28q.us-east-1.rds.amazonaws.com:5432`
  - DB name: `chronosdb`, Username: `chronos`, Password: `chronosdbrds`
  - Instance: db.t4g.micro (free tier), Public access: Yes
- **S3 bucket**: `elasticbeanstalk-us-east-1-551451910710`

### IAM / AWS CLI
- AWS CLI installed via pip: `C:\Users\Nahom\AppData\Roaming\Python\Python313\Scripts\aws`
- Credentials saved to `~/.aws/credentials` (persistent)
- Add to PATH: `$env:PATH += ";C:\Users\Nahom\AppData\Roaming\Python\Python313\Scripts"`

---

### Deploying the Main API

```bash
# 1. Build
npx prisma generate
npm run build

# 2. ZIP (must use Python — PowerShell/tar break Linux paths)
python -c "
import zipfile, os
files = [('dist', True), ('node_modules', True), ('package.json', False), ('package-lock.json', False), ('Procfile', False), ('prisma', True), ('.ebextensions', True)]
with zipfile.ZipFile('chronos-deploy.zip', 'w', zipfile.ZIP_DEFLATED) as zf:
    for name, is_dir in files:
        if is_dir:
            for root, dirs, fs in os.walk(name):
                for f in fs:
                    fp = os.path.join(root, f)
                    zf.write(fp, fp.replace(os.sep, '/'))
        else:
            zf.write(name, name)
print('Done!')
"

# 3. Upload + deploy
aws s3 cp chronos-deploy.zip s3://elasticbeanstalk-us-east-1-551451910710/chronos-backend/chronos-vXX.zip
aws elasticbeanstalk create-application-version --application-name chronos-backend --version-label "chronos-vXX" --source-bundle S3Bucket="elasticbeanstalk-us-east-1-551451910710",S3Key="chronos-backend/chronos-vXX.zip"
aws elasticbeanstalk update-environment --environment-name chronos-backend-env --version-label "chronos-vXX"
```

---

### Deploying BlockHub

```bash
# 1. Build
npx tsc -p tsconfig.blockhub.json

# 2. ZIP (custom Procfile injected inline — do NOT use the root Procfile)
python -c "
import zipfile, os
items = [('dist-blockhub', True), ('node_modules', True), ('package.json', False), ('package-lock.json', False), ('prisma', True), ('.ebextensions', True)]
with zipfile.ZipFile('blockhub-deploy.zip', 'w', zipfile.ZIP_DEFLATED) as zf:
    zf.writestr('Procfile', 'web: node dist-blockhub/main.js\n')
    for name, is_dir in items:
        if is_dir:
            for root, dirs, files in os.walk(name):
                dirs[:] = [d for d in dirs if d not in ['.cache', '.git']]
                for f in files:
                    fp = os.path.join(root, f)
                    zf.write(fp, fp.replace(os.sep, '/'))
        else:
            if os.path.exists(name):
                zf.write(name, name)
print('Done!')
"

# 3. Upload to S3 (upload manually via console if on slow connection — file is ~300 MB)
aws s3 cp blockhub-deploy.zip s3://elasticbeanstalk-us-east-1-551451910710/chronos-blockhub/blockhub-vXX.zip

# 4. Deploy
aws elasticbeanstalk create-application-version --application-name chronos-blockhub --version-label "blockhub-vXX" --source-bundle S3Bucket="elasticbeanstalk-us-east-1-551451910710",S3Key="chronos-blockhub/blockhub-vXX.zip"
aws elasticbeanstalk update-environment --environment-name blockhub-env --version-label "blockhub-vXX"
```

**Key difference from main API**: The Procfile is written inline into the ZIP (`web: node dist-blockhub/main.js`), not from the root `Procfile` file (which points to `dist/server.js`).

---

### Schema Changes
Run locally — never on EB instance (too slow):
```powershell
$env:DATABASE_URL="postgresql://chronos:chronosdbrds@chronosdb.csjwyuqii28q.us-east-1.rds.amazonaws.com:5432/chronosdb"
npx prisma db push --accept-data-loss
```

### Key Config Files
- `Procfile` — `web: node dist/server.js` (main API only)
- `.ebextensions/01_deploy.config` — sets `NODE_ENV=production` (used by both apps)
- `tsconfig.json` — main API build config
- `tsconfig.blockhub.json` — BlockHub build config, outputs to `dist-blockhub/`
- `prisma/schema.prisma` — `binaryTargets = ["native", "rhel-openssl-3.0.x"]` (critical for Linux EB)

---

## Bugs Fixed

### 1. Double `app.listen()` (critical, v1)
`app.ts` AND `server.ts` both called `app.listen()`. Fixed: removed from `app.ts`.

### 2. TypeScript 219 errors (v2)
Set `noEmitOnError: false`, `noImplicitAny: false`, added exclude list in tsconfig. Build emits JS despite errors in dead code.

### 3. Prisma client types missing (v3)
Run `npx prisma generate` before every build.

### 4. EB deployment backslash paths (v4)
Windows `Compress-Archive` uses backslashes. Fix: Python `zipfile` module.

### 5. EB t3.micro timeout on npm install + prisma generate (v8)
Include `node_modules` in ZIP with pre-built Linux binary (`rhel-openssl-3.0.x`).

### 6. Auth response leaking hashed password (v11)
Destructure password out before returning: `const { password: _pw, ...safeUser } = user`

### 7. AI SDK clients crashing app on startup (v15)
`new Anthropic()` and `new OpenAI()` at module load time throw without API keys. Fixed with lazy initialization.

### 8. bullmq not in package.json — startup crash (v16)
`notification.queue.ts` imported `bullmq` which was never installed. Fixed: replaced queue with an inline shim that calls `sendEmail` directly. No bullmq or Redis needed.

### 9. Firebase crashing app on startup (v17)
`push.provider.ts` called `admin.initializeApp({ credential: cert({}) })` at module load time when `FCM_SERVICE_ACCOUNT` was empty. Fixed: lazy initialization — only calls `initializeApp` when `FCM_SERVICE_ACCOUNT` is set and `sendPush` is actually called.

### 10. Prisma Linux binary missing — EB 502 (v21)
`binaryTargets` was missing from `prisma/schema.prisma`. Windows build only produced the Windows DLL; EB (Linux) crashed with `could not locate Query Engine for runtime "rhel-openssl-3.0.x"`. Fixed: added `binaryTargets = ["native", "rhel-openssl-3.0.x"]`, ran `npx prisma generate`.

### 11. RDS going offline (recurring)
RDS auto-stops after periods of inactivity. Symptoms: EB returns 502, `prisma db push` returns P1001. Fix: start the RDS instance from AWS Console → RDS → `chronosdb` → Actions → Start. Takes ~2 min to become available.

### 12. BlockHub missing env vars — EB Degraded (blockhub-v2)
BlockHub crashed on startup with `Configuration key "JWT_SECRET" does not exist`. Fixed: set `JWT_SECRET`, `DATABASE_URL`, `NODE_ENV` as EB environment properties on `blockhub-env`.

### 13. Chris voice synthesis silently broken for months (client-side, undiagnosable)
`voice.service.ts`'s `synthesizeSpeech()` discarded ElevenLabs' actual error body on a failed call and threw only `response.statusText`, which is frequently empty — every failure (bad key, exhausted monthly character quota, invalid voice ID, network error) looked identical. Worse, the Flutter `TtsService._fetchAudio()` caught that exception and silently fell back to the on-device `flutter_tts` voice with just a `debugPrint`, so there was no way to tell from the running app whether voice was even attempting the ElevenLabs call, let alone why it failed. Fixed: `synthesizeSpeech()` now reads and includes the real response body in the thrown error; the controller logs it server-side and returns 503 (key not configured) vs 502 (call failed) instead of a blanket 500; added `GET /api/ai/voice/health` which checks ElevenLabs' subscription endpoint (spends no characters) to report configured/valid/quota-remaining directly. Client-side, `TtsService` now exposes `lastError`/`onError` instead of swallowing failures, and `ChrisHomeFab` shows a one-time SnackBar with the real reason when the premium voice can't be reached. Also hardened the transport layer that both chat and voice depend on: the EB backend has no TLS cert, so its `http://` URL is silently blocked by default network security policy on real devices (Android `cleartextTrafficPermitted="false"`, iOS ATS) — added explicit cleartext/ATS exceptions scoped to the two EB hostnames on both platforms, and declared `RECORD_AUDIO` explicitly in `AndroidManifest.xml` for `speech_to_text`. `.env.example` never listed `ANTHROPIC_API_KEY`/`OPENAI_API_KEY`/`ELEVENLABS_API_KEY`/`ELEVENLABS_VOICE_ID` at all — backfilled as documented-optional entries.

### 14. Duplicate ElevenLabs integrations + voice never wired outside the home FAB
A same-day teammate PR (`agent/elevenlabs-voice-chat`, merged as #90) added a second, fully independent ElevenLabs client (`src/modules/lifex/modules/ai/elevenLabsVoice.service.ts`) for the LifeX AI coach, with its own default voice ID (`JBFqnCBsd6RMkjVDRZzb` vs. Chris's `21m00Tcm4TlvDq8ikWAM`), its own env-var name (`XI_API_KEY` as an alt for the key), no character-length cap on synthesis (risk: an unbounded LLM reply → a huge/slow/costly ElevenLabs call), and an unauthenticated `GET /config` leaking whether ElevenLabs/agent keys were configured. Its manual test page (`public/chronos-voice-chat.html`) also never attached a JWT to any of its `requireAuth`-gated calls, so it 401'd on every request even before this fix. Consolidated: both integrations now call one shared client, `src/modules/ai/voice/elevenlabs.client.ts` (single API key resolution, single default voice/model, a 600-char synthesis cap enforced centrally regardless of caller); `/config` now requires auth; `chronos-voice-chat.html` got a token input (saved to `localStorage`, attached as `Authorization: Bearer` on every call) so the manual test page actually works end to end. Separately, voice output had only ever been wired into the home-screen Chris FAB — `panther_ai_chat_page.dart`'s full chat page (same `/api/ai/chris/chat` backend, same `SendMessage` usecase) never spoke replies at all, and its voice-mode volume-mute button (`Icons.volume_up_rounded`) was a dead `onTap: () {}` stub; `chris_shopping_page.dart` (TickPay's "Chris" shopping assistant, chat-bubble UI, Chris-branded) never spoke its scripted replies either. Both now call `TtsService().speak(...)`, with the Panther chat page speaking only in its dedicated voice mode (not the plain typed-text view) and stopping playback on mode-switch/dispose; the previously-dead volume button now actually mutes.

### 15. Every Chris chat reply failed — invalid hardcoded model id
User reported every single chat/voice query returned the same generic failure, and (reasonably) assumed the Anthropic/ElevenLabs keys they'd set were the problem — but those keys were set on **Vercel**, and the app hasn't called the Vercel serverless functions (`api/chat.js`/`api/synthesize.js`, both dead code) since Bug #13 repointed it straight at this backend's `/api/ai/chris/chat`/`/api/ai/voice/synthesize`. The real bug: `claude.client.ts`'s default model and all 5 domain agents (`banking-analyst`, `predictive-finance`, `risk-fraud`, `lifestyle`, `affordability`) plus `orchestrator.ts`'s UNIFIED fallback all hardcoded `model: "claude-sonnet-4-6"` — not a real Anthropic model id. Only `routing-agent.ts`/`compliance-guard.ts` (via `callLLMFast`, which correctly used `claude-haiku-4-5-20251001`) ever succeeded, so a query would route and pass compliance and then fail generating the actual answer — every single time, regardless of what was asked, matching the reported symptom exactly. Fixed all 9 occurrences (7 files here + the 2 dead Vercel functions, fixed for consistency in case they're ever repointed back) to `claude-sonnet-5`. **Requires an EB redeploy of the main API (`chronos-backend-env`) to reach the live app** — not done as part of this change; no AWS access from the environment that made this fix.

**Follow-up**: since an EB redeploy wasn't actionable, and the user is running/testing against the Vercel deployment (`chronosapp-rosy.vercel.app`) where the Anthropic/ElevenLabs keys already work as Vercel env vars, the Flutter app's `PantherAiRemoteDataSource.sendMessage`/`TtsService._fetchAudio` were repointed at Vercel's `api/chat.js`/`api/synthesize.js` (see `chronos/FEATURES.md`) rather than this backend's `/api/ai/chris/chat`/`/api/ai/voice/synthesize`. This backend's routes and the `orchestrator.ts` domain-agent pipeline (real per-user financial context) are unchanged and still work — they're just not what the mobile app calls right now. Re-pointing back here (once redeployable) would restore that personalized context; Vercel's functions are a stateless Claude call with no user data.

---

## Deployment Status — BOTH LIVE ✅

### Main API
**Current version**: chronos-v21  
**Live URL**: http://chronos.us-east-1.elasticbeanstalk.com  
**Health check**: GET /health → `{"status":"ok"}`

### BlockHub
**Current version**: blockhub-v2  
**Live URL**: http://blockhub-env.us-east-1.elasticbeanstalk.com  
**Health check**: GET /health → `{"status":"ok"}`

### Version History — Main API
| Version | What changed |
|---------|-------------|
| v11 | Fix auth response leaking hashed password |
| v15 | Panther AI (Chris, alerts, voice, user level, BNPL scoring) |
| v16 | LifeX 7 new modules + email notifications + Plaid webhook verification + Redis cache |
| v17 | Fix bullmq startup crash (replaced with inline shim) |
| v18 | Fix Firebase startup crash (lazy init) |
| v19 | Fix cache.ts redis.config import error |
| v20 | Attempted Prisma fix (incomplete — still missing Linux binary) |
| v21 | Fix Prisma Linux binary — added `rhel-openssl-3.0.x` binaryTarget ✅ |

### Version History — BlockHub
| Version | What changed |
|---------|-------------|
| v1 | Initial deploy (crashed — missing env vars) |
| v2 | Full NestJS deploy with correct Procfile; env vars set via EB console ✅ |

---

## What Still Needs To Be Done

- [x] Fix auth response leaking hashed password — v11
- [x] Panther AI (Chris chat, agents, voice, alerts, user level) — v15
- [x] LifeX: Activity, AI coach, Export, Family, Social, Spiritual, Feed modules — v16
- [x] Email notification system (nodemailer + SendGrid templates) — v16
- [x] Plaid webhook signature verification (jose JWT + body hash) — v16
- [x] Redis cache for currency rates and FX (5 min / 60 sec TTL) — v16
- [x] Fix bullmq crash — v17
- [x] Fix Firebase crash — v18
- [x] Fix Prisma Linux binary (rhel-openssl-3.0.x) — v21
- [x] Deploy BlockHub (NestJS) as separate EB environment — blockhub-v2
- [x] **Add `ANTHROPIC_API_KEY` to EB env vars (main API)** — keys sourced from Panther repo
- [ ] **Add `SMTP_HOST/USER/PASS` to EB env vars (main API)** — emails won't send without these
- [ ] Add `OPENAI_API_KEY` to EB — voice transcription
- [x] Add `ELEVENLABS_API_KEY` to EB — keys sourced from Panther repo
- [ ] Add `FCM_SERVICE_ACCOUNT` to EB — push notifications
- [ ] Add Paxos keys to BlockHub EB env — crypto trading won't work without these
- [ ] Provision Redis (ElastiCache or Upstash) for BlockHub NFT minting queue + main API cache
- [ ] Set up HTTPS/SSL for both environments (requires domain + ACM certificate)
- [ ] Add Plaid keys to EB when ready for KYC
- [ ] Connect Firecrawl to marketplace search agent (`/api/ai/tickpay/search`)
- [ ] Consider AWS Secrets Manager for DATABASE_URL in production

---

## tsconfig Excluded Modules (dead code, not in build)

- `src/modules/blockhub` — NestJS app, built separately via `tsconfig.blockhub.json`
- `src/exchange` — old/unused
- `src/modules/dwm` — unused
- `src/modules/akoya` — unused
- `src/modules/integrations` — unused
- `src/modules/notification` — NOT excluded (active and deployed)
- `src/modules/crypto` — commented out in routes
- `src/modules/core/gov` — unused

`src/modules/ai` and `src/modules/lifex` are **active and included** in the build.

---

## Postman Collection

- **File**: `Chronos-API.postman_collection.json`
- **Environment**: `Chronos-ENV.postman_environment.json`
- **Base URL**: `http://chronos.us-east-1.elasticbeanstalk.com`
- **Total requests**: ~185
- Token auto-saved on Register (201) and Login (200) via test scripts

Run with Newman:
```bash
newman run Chronos-API.postman_collection.json --reporters cli,htmlextra --reporter-htmlextra-export newman-report.html --delay-request 300 --timeout-request 15000
```
