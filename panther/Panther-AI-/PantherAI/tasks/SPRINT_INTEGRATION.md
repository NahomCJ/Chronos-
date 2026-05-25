# Sprint — Mobile Integration

**Owner:** Full-stack developer (new hire, starts 2026-04-15)
**Backend contact:** Martín
**Goal:** Integrate LIVE Panther backend capabilities into the mobile app.

Read `tasks/ONBOARDING_FULLSTACK.md` first. Everything in this file assumes you have.

**Progress tracking:** `[ ]` pending → `[/]` in progress → `[x]` done. Update as you work.

---

## Phase 1 — Discovery (days 1-3)

No integration code until these four tickets are reported to Martín.

### [ ] D-1: Identify the mobile team and communication channel

**Why:** Martín currently has zero contact with mobile dev team. Cannot plan integration without knowing who (if anyone) is on the other side.

**What to do:**
- Confirm whether a mobile team exists today. If yes: who leads it, team size, reporting line.
- Establish a communication channel (Slack channel, email thread, recurring sync).
- If no team exists: report that back to Martín — it changes the plan.

**Done when:**
- Document in this ticket: team lead name, channel name, first sync scheduled (or "no team exists" with evidence).
- Daily report mentions the outcome.

---

### [ ] D-2: Audit the mobile app repository

**Why:** We don't know if the repo exists, what stack it uses, or whether any integration has been attempted before. You cannot integrate against an unknown target.

**What to do:**
- Locate the mobile repo (ask Nahom the mobile devs contact and they will tell you where to start looking).
- Determine the stack: React Native, Flutter, Expo, native iOS/Android, or none yet.
- Audit current state: is there code? A running app? Any existing backend calls?
- List any previous attempts at auth, API clients, or state management.

**Done when:**
- Report in this ticket: repo URL, stack, lines of code (rough), current state (greenfield / in-progress / abandoned), list of any existing HTTP clients.
- If no repo exists: recommend a stack to Martín with a one-paragraph rationale.

---

### [ ] D-3: Align working contract with the mobile team

**Why:** Parallel work without a contract causes merge conflicts, duplicated code, and wasted sprints.

**What to do:**
- Agree with the mobile team (or decide solo if none exists) on:
  - Who owns the HTTP client layer.
  - Where API contracts live (OpenAPI export? Shared types? Doc?).
  - Cadence of syncs with backend (daily, weekly).
  - How breaking changes are communicated.
- Document the agreement.

**Done when:**
- A short written agreement exists (can be a Slack pinned message or a markdown file in the mobile repo).
- Martín has acknowledged it.

---

### [ ] D-4: Report findings and get green light on stack

**Why:** Everything downstream depends on the answers from D-1, D-2, D-3. Martín needs to sign off before Phase 2 begins.

**What to do:**
- Write a single summary: team status, repo status, stack, working contract, risks.
- Post in `#dev-updates` and tag Martín.
- Wait for explicit green light before starting I-1.

**Done when:**
- Summary posted.
- Martín has responded with "green light, proceed to I-1" or given a corrective instruction.

---

## Phase 2 — Integration (day 4 onward)

Do not start until D-4 is approved.

### [ ] I-1: Build typed HTTP client + placeholder auth layer

**Why:** Every other integration ticket depends on this. One place for base URL, headers, error handling, and the eventual JWT migration.

**What to do:**
- Create a single `apiClient` module in the mobile repo.
- Configure base URL via env var (`API_BASE_URL`).
- Inject `X-User-Id: user_marcus` as a placeholder header. Leave a `// TODO(auth): replace with JWT Bearer when backend ships F-1` comment.
- Implement typed request/response with error handling (network error, 4xx, 5xx, timeout).
- Export typed methods only — no raw `fetch` outside this module.

**Done when:**
- `apiClient.health()` successfully hits `GET /health` and returns typed response.
- Unit test: mocked 500 response produces a typed error, not a crash.
- PR merged to mobile main.

---

### [ ] I-2: Payment authorization flow

**Endpoint:** `POST /api/authorize-payment`
**Capability:** Given a merchant + amount, returns whether the user can afford it, with BNPL risk context.

**What to do:**
- Add `apiClient.authorizePayment(request)` method.
- Build a "Can I buy this?" screen: merchant input, amount input, submit button.
- Display the response: authorization status, risk level, BNPL score, recommendation text.
- Handle error states (network down, backend error).

**Request shape:** see `http://localhost:8000/docs` → `PaymentRequest`.
**Response shape:** see `http://localhost:8000/docs` → `PaymentAuthorizationResponse`.

**Done when:**
- Screen works end-to-end against local backend with `user_marcus`.
- At least 3 test scenarios verified manually: safe purchase, risky purchase, declined purchase.
- Screenshot or Loom attached to daily report.
- Ticket checked.

---

### [ ] I-3: Kevin chat assistant

**Endpoint:** `POST /api/kevin/chat`
**Capability:** Conversational Q&A with tool calling (check balance, list bills, assess affordability).

**What to do:**
- Add `apiClient.kevinChat(request)` method.
- Build a chat UI: message list, input box, send button, loading state.
- Maintain `conversation_history` client-side and pass it with each request.
- Display `tools_called` somewhere visible (debug drawer or small indicator) — the demo value of Kevin is that users see it using tools.
- Handle the Ollama-offline fallback gracefully (Kevin returns a mock response; UI should still render it).

**Request shape:** `{user_id, message, conversation_history?, history_user_id?}`
**Response shape:** `{response, tools_called: list[str], context_used: dict, conversation_history?}`

**Cross-user security note:** always pass the current user's ID as both `user_id` and `history_user_id`. Never pass someone else's history. The backend enforces this, but the client should not test it.

**Done when:**
- Three-turn conversation works: "what is my balance" → "can I afford a $500 laptop" → "list my bills".
- Tools-called indicator visible in UI during each turn.
- Offline-Ollama case tested (stop Ollama locally, verify UI doesn't crash).
- Screenshot or Loom attached.
- Ticket checked.

---

### [ ] I-4: Transactions list + feedback loop

**Endpoints:**
- `GET /api/transactions?user_id=...&days=...` — list
- `GET /api/transactions/{id}` — single
- `PATCH /api/transactions/{id}` — user feedback on category

**Capability:** Show categorized transactions; let the user correct a wrong category (this feeds the classifier retraining loop).

**What to do:**
- Add three `apiClient` methods.
- Build a transactions list screen: grouped by date, showing merchant + amount + category chip.
- Tap a transaction → detail view with a "Wrong category?" button.
- "Wrong category?" opens a picker of the 44 subcategories → on select, PATCH request → optimistic UI update.
- Handle pagination or date-range filter (start with last 30 days).

**Request/response shapes:** `http://localhost:8000/docs` → `TransactionOut`, `PatchCategoryRequest`, `PatchCategoryResponse`.

**Done when:**
- List renders at least 20 real transactions from `user_marcus`.
- PATCH confirmed end-to-end: change category, reload, verify change persisted.
- Error state tested: PATCH with invalid category → UI shows error, does not crash.
- Screenshot or Loom attached.
- Ticket checked.

---

## Parked / out of scope

These exist in the backend but you do not integrate them. Ask Martín before touching any of them.

- `GET /api/insights/spending-summary` — mock data, waiting for real data migration.
- `GET /api/insights/top-categories` — mock data.
- `GET /api/insights/warnings-history` — mock data.
- `POST /webhooks/plaid/transactions` — server-to-server webhook, not a mobile concern.
- Shopping Assistant endpoints — Martín building now, not ready.
- Health Metrics endpoints — Martín building now, not ready.

When Martín ships the real versions of the above, new tickets will be appended to this file.

---

## Reference — backend inventory (snapshot 2026-04-15)

| Endpoint | Status | In this sprint? |
|---|---|---|
| `GET /health` | LIVE | Used for I-1 sanity check |
| `POST /api/authorize-payment` | LIVE | **I-2** |
| `POST /api/kevin/chat` | LIVE | **I-3** |
| `GET /api/transactions` | LIVE | **I-4** |
| `GET /api/transactions/{id}` | LIVE | **I-4** |
| `PATCH /api/transactions/{id}` | LIVE | **I-4** |
| `GET /api/insights/spending-summary` | MOCK | Parked |
| `GET /api/insights/top-categories` | MOCK | Parked |
| `GET /api/insights/warnings-history` | MOCK | Parked |
| `POST /webhooks/plaid/transactions` | LIVE | Out of scope |

Authoritative contracts live at `http://localhost:8000/docs`. If this table and `/docs` disagree, `/docs` wins.
