# KYC & Bank Linking Module

**Path:** `src/modules/core/kyc/`  
**Integration:** Plaid Sandbox (Identity Verification + Auth products)

This is the compliance backbone of Chronos. Every user must pass KYC before accessing financial features. Bank account linking (for ACH deposits) is gated behind KYC approval.

---

## Compliance Flow

```
User registers
      │
      ▼
Create banking profile   POST /kyc/profile
      │
      ▼
Start KYC (IDV)          POST /kyc/session/create  → Plaid Link token
      │
      ▼
User completes Plaid Link (frontend)
      │
      ▼
Sync result              POST /kyc/session/complete
      │
      ├── APPROVED → kycVerified = true → can trade, deposit, link bank
      ├── PENDING  → awaiting Plaid review
      └── FAILED   → retry via POST /kyc/session/retry
      │
      ▼ (after KYC approved)
Link bank account        POST /kyc/bank/link  → Plaid Link token (Auth product)
      │
      ▼
User selects bank in Plaid Link (frontend)
      │
      ▼
Exchange token           POST /kyc/bank/connect  → stores access_token
      │
      ▼
ACH deposits enabled
```

---

## Endpoints

### Identity Verification (KYC)

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| POST | `/kyc/profile` | Yes | Create banking profile |
| GET  | `/kyc/profile` | Yes | Get KYC profile + status |
| POST | `/kyc/session/create` | Yes | Get Plaid Link token for IDV |
| POST | `/kyc/session/complete` | Yes | Sync IDV result after Plaid Link |
| GET  | `/kyc/session/:sessionId` | Yes | Poll live Plaid IDV status |
| POST | `/kyc/session/retry` | Yes | Retry failed/expired IDV |

### Bank Account Linking (Plaid Auth)

| Method | Route | Auth | Requires KYC | Description |
|--------|-------|------|-------------|-------------|
| POST | `/kyc/bank/link` | Yes | Yes | Get Plaid Link token for Auth product |
| POST | `/kyc/bank/connect` | Yes | Yes | Exchange public_token → access_token |
| GET  | `/kyc/bank/account` | Yes | Yes | Get linked account details |

### Webhooks

| Method | Route | Auth | Description |
|--------|-------|------|-------------|
| POST | `/kyc/webhook` | No (Plaid-signed) | Receives Plaid status updates |

### Admin Overrides (Admin role required)

| Method | Route | Description |
|--------|-------|-------------|
| POST | `/kyc/approve/:userId` | Manually approve KYC |
| POST | `/kyc/reject/:userId` | Reject KYC with reason |
| POST | `/kyc/freeze/:userId` | Freeze account |
| POST | `/kyc/unfreeze/:userId` | Unfreeze account |

---

## Plaid Products Used

| Product | Purpose |
|---------|---------|
| Identity Verification (IDV) | KYC — photo ID + selfie + address |
| Auth | Bank account linking for ACH deposits |

---

## Plaid Status → Internal Status Mapping

| Plaid IDV Status | Internal Status | kycVerified |
|-----------------|-----------------|-------------|
| `success` | `APPROVED` | true |
| `failed` | `REJECTED` | false |
| `active` / `pending_review` / `pending_docv` | `PENDING` | false |
| `expired` | `DRAFT` | false |

---

## Environment Variables

```env
PLAID_CLIENT_ID=          # From Plaid Dashboard → Team Settings → Keys
PLAID_SECRET=             # Sandbox secret
PLAID_ENV=sandbox         # sandbox | development | production
PLAID_IDV_TEMPLATE_ID=    # IDV template created in Plaid Dashboard
PLAID_VERIFY_WEBHOOKS=false  # Set true in production
```

---

## Sandbox Testing

**IDV (KYC):**
- Create a template in Plaid Dashboard → Identity Verification
- Use Plaid's test credentials to trigger `success` / `failed` outcomes
- Fire test webhooks via Plaid Dashboard → Send Webhook

**Auth (bank linking):**
- Username: `user_good` / Password: `pass_good`
- Institution: Chase (`ins_109508`) is reliable in sandbox

---

## Production Notes

- `plaidAccessToken` stored on `BankingProfile` — **encrypt at rest** (AES-256 or KMS) before going live
- Set `PLAID_VERIFY_WEBHOOKS=true` — requires `jose` package for full JWK verification:
  ```bash
  npm install jose
  ```
  Then uncomment the full verification block in `kyc.service.ts → verifyWebhookToken()`

---

## Key Files

| File | Purpose |
|------|---------|
| `kyc.service.ts` | All KYC + Auth logic, Plaid API calls |
| `kyc.controller.ts` | Route handlers with full error handling |
| `kyc.routes.ts` | Route definitions with auth/admin guards |
| `kyc.types.ts` | All input/output TypeScript interfaces |
